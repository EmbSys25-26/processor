`timescale 1ns / 1ps

/*************************************************************************************
 * I2C MASTER MODULE
 *
 * Implements a full I2C master controller supporting:
 *  - 7-bit addressing
 *  - Multi-byte write (master -> peripheral) via TX FIFO
 *  - Multi-byte read  (peripheral -> master) via RX FIFO
 *  - ACK error detection (missing ACK from peripheral, or TX FIFO underflow)
 *  - Configurable SCL clock divider
 *
 * I2C Line Protocol (open-drain, active-low):
 *  - SDA/SCL are driven LOW by asserting _sda_oe_low/_scl_oe_low (pulls line to GND)
 *  - SDA/SCL are released HIGH by de-asserting (line pulled up by external resistor)
 *  - START condition: SDA falls while SCL is HIGH
 *  - STOP  condition: SDA rises while SCL is HIGH
 *  - SDA is modified when SCL is LOW
 ************************************************************************************/

module i2c_master(
    input wire i_clk,
    input wire i_rst,
    input wire i_en,                // Module enable; transaction won't start if low
    input wire i_start,             // Pulse high to begin a transaction
    input wire i_rw,                // 0 = Write to peripheral, 1 = Read from peripheral
    input wire [7:0] i_addr7,       // 7-bit peripheral address (bits [7:1] used, bit 0 ignored)
    input wire [7:0] i_len,         // Number of data bytes to transfer (excluding address byte)
    input wire [15:0] i_divider,    // SCL period = i_divider * i_clk cycles (per FSM step)
    input wire i_tx_push,           // Pulse high to push one byte into TX FIFO
    input wire [7:0] i_tx_push_data,// Byte to push into TX FIFO
    input wire i_rx_pop,            // Pulse high to pop one byte from RX FIFO (advance read pointer)
    input wire i_rx_flush,          // Pulse high to clear entire RX FIFO
    input wire i_clr_done,          // Pulse high to clear o_done flag
    input wire i_clr_ack_err,       // Pulse high to clear o_ack_err flag
    output wire [7:0] o_rx_data,    // Byte at front of RX FIFO (valid when o_rx_valid is high)
    output wire o_rx_valid,         // High when RX FIFO contains at least one byte
    output wire o_busy,             // High throughout a transaction (START -> STOP)
    output wire o_done,             // Latches high when transaction completes (sticky until cleared)
    output wire o_ack_err,          // Latches high on any ACK error (sticky until cleared)
    inout wire io_i2c_sda,          // I2C data line  (open-drain)
    inout wire io_i2c_scl           // I2C clock line (open-drain)
);

/*************************************************************************************
 * SECTION 1. DECLARE/DEFINE VARIABLES
 ************************************************************************************/

/****************************************************************************
 * 1.1 DEFINE FSM STATES 
 ***************************************************************************/
    localparam [4:0] IDLE = 5'd0;
    localparam [4:0] START0 = 5'd1;
    localparam [4:0] START1 = 5'd2;
    localparam [4:0] START2 = 5'd3;
    localparam [4:0] TX_LOW = 5'd4;
    localparam [4:0] TX_HIGH = 5'd5;
    localparam [4:0] TX_FALL = 5'd6;
    localparam [4:0] ACK_LOW = 5'd7;
    localparam [4:0] ACK_HIGH = 5'd8;
    localparam [4:0] ACK_FALL = 5'd9;
    localparam [4:0] RX_LOW = 5'd10;
    localparam [4:0] RX_HIGH = 5'd11;
    localparam [4:0] RX_FALL = 5'd12;
    localparam [4:0] MACK_LOW = 5'd13;
    localparam [4:0] MACK_HIGH = 5'd14;
    localparam [4:0] MACK_FALL = 5'd15;
    localparam [4:0] STOP0 = 5'd16;
    localparam [4:0] STOP1 = 5'd17;
    localparam [4:0] STOP2 = 5'd18;

/****************************************************************************
 * 1.2 DECLARE VARIABLES    
 ***************************************************************************/
    reg [4:0] _state;

    reg _busy;
    reg _done;          // Latches 1 when transaction finishes (STOP2)
    reg _ack_err;       // Latches 1 on NACK from peripheral or TX underflow

    reg _sda_oe_low;
    reg _scl_oe_low;
    wire _sda_in;

    reg [15:0] _div_latched;
    reg [15:0] _div_cnt;
    reg _step_en;

    reg _rw_latched;
    reg [6:0] _addr_latched;
    reg [7:0] _len_latched;
    reg _address_phase;

    reg [7:0] _tx_byte;
    reg [7:0] _rx_shift;
    reg [2:0] _bit_idx;
    reg [7:0] _bytes_done;
    reg _send_nack;
    reg _ack_sample;

    reg [7:0] _tx_fifo [0:255];
    reg [7:0] _tx_wr_idx;
    reg [7:0] _tx_rd_idx;
    reg [8:0] _tx_count;

    reg [7:0] _rx_fifo [0:255];
    reg [7:0] _rx_wr_idx;
    reg [7:0] _rx_rd_idx;
    reg [8:0] _rx_count;

    integer _i;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Open-Drain Line Drivers and Status Outputs
 ************************************************************************************/
    assign io_i2c_sda = _sda_oe_low ? 1'b0 : 1'bz;
    assign io_i2c_scl = _scl_oe_low ? 1'b0 : 1'bz;

    assign _sda_in = io_i2c_sda;

    assign o_rx_data = (_rx_count != 0) ? _rx_fifo[_rx_rd_idx] : 8'h00;
    assign o_rx_valid = (_rx_count != 0);
    assign o_busy = _busy;
    assign o_done = _done;
    assign o_ack_err = _ack_err;

/*************************************************************************************
 * 2.2 Master FSM, FIFO Handling, and Transaction Control
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _state <= IDLE;

            _busy <= 1'b0;
            _done <= 1'b0;
            _ack_err <= 1'b0;

            _sda_oe_low <= 1'b0;
            _scl_oe_low <= 1'b0;

            _div_latched <= 16'd100;
            _div_cnt <= 16'd0;
            _step_en <= 1'b0;

            _rw_latched <= 1'b0;
            _addr_latched <= 7'd0;
            _len_latched <= 8'd0;
            _address_phase <= 1'b0;

            _tx_byte <= 8'h00;
            _rx_shift <= 8'h00;
            _bit_idx <= 3'd7;
            _bytes_done <= 8'd0;
            _send_nack <= 1'b0;
            _ack_sample <= 1'b1;

            _tx_wr_idx <= 8'd0;
            _tx_rd_idx <= 8'd0;
            _tx_count <= 9'd0;

            _rx_wr_idx <= 8'd0;
            _rx_rd_idx <= 8'd0;
            _rx_count <= 9'd0;

            for (_i = 0; _i < 256; _i = _i + 1) begin
                _tx_fifo[_i] <= 8'h00;
                _rx_fifo[_i] <= 8'h00;
            end
        end 
            else begin
            // STICKY FLAG CLEARING
            if (i_clr_done) _done <= 1'b0;
            if (i_clr_ack_err) _ack_err <= 1'b0;

            /*------------------------------------------------------------------
             * TX FIFO PUSH  (only allowed while not busy)
             * MMIO writes a byte and pulses i_tx_push.  If the FIFO is full,
             * flag an error instead of silently dropping the byte.
             *-----------------------------------------------------------------*/
            if (i_tx_push && !_busy) begin
                if (_tx_count < 9'd256) begin
                    _tx_fifo[_tx_wr_idx] <= i_tx_push_data;
                    _tx_wr_idx <= _tx_wr_idx + 8'd1;
                    _tx_count <= _tx_count + 9'd1;
                end else begin
                    _ack_err <= 1'b1;   // TX FIFO overflow — signal error
                end
            end

            /*------------------------------------------------------------------
             * RX FIFO FLUSH / POP  (only allowed while not busy)
             * Flush clears the entire FIFO; pop advances the read index by 1.
             * Flush takes priority over pop when both are asserted simultaneously.
             *-----------------------------------------------------------------*/
            if (i_rx_flush && !_busy) begin
                _rx_wr_idx <= 8'd0;
                _rx_rd_idx <= 8'd0;
                _rx_count <= 9'd0;
            end else if (i_rx_pop && !_busy) begin
                if (_rx_count != 0) begin
                    _rx_rd_idx <= _rx_rd_idx + 8'd1;
                    _rx_count <= _rx_count - 9'd1;
                end
            end

            /*------------------------------------------------------------------
             * CLOCK DIVIDER
             * Counts up to _div_latched then fires a one-cycle _step_en pulse.
             * This creates the per-step timing that drives the FSM.
             * Divider only runs while _busy; resets to 0 when idle.
             *-----------------------------------------------------------------*/
            if (_busy) begin
                if (_div_cnt >= _div_latched) begin
                    _div_cnt <= 16'd0;
                    _step_en <= 1'b1;
                end else begin
                    _div_cnt <= _div_cnt + 16'd1;
                    _step_en <= 1'b0;
                end
            end else begin
                _div_cnt <= 16'd0;
                _step_en <= 1'b0;
            end

            /*------------------------------------------------------------------
             * IDLE / START DETECTION
             * While not busy: keep lines released, state in IDLE.
             * On i_start pulse (and i_en): latch all transaction parameters
             * and transition to START0 to begin the I2C start condition.
             *-----------------------------------------------------------------*/
            if (!_busy) begin
                _sda_oe_low <= 1'b0;
                _scl_oe_low <= 1'b0;
                _state <= IDLE;

                if (i_start && i_en) begin
                    _busy <= 1'b1;
                    _done <= 1'b0;

                    // Latch all transaction parameters
                    _rw_latched <= i_rw;
                    _addr_latched <= i_addr7;
                    _len_latched <= i_len;
                    // Clamp divider to at least 1 to prevent division-by-zero style stall
                    _div_latched <= (i_divider < 16'd1) ? 16'd1 : i_divider;

                    _address_phase <= 1'b1;         // Signal that 1st byte is the address
                    _tx_byte <= {i_addr7, i_rw};    // Address byte: [ADDR7:ADDR1 | R/W]
                    _rx_shift <= 8'h00;
                    _bit_idx <= 3'd7;               // Start from MSB
                    _bytes_done <= 8'd0;
                    _send_nack <= 1'b0;
                    _ack_sample <= 1'b1;

                    _state <= START0;
                end
            end else if (_step_en) begin
                case (_state)
                    START0: begin
                        _scl_oe_low <= 1'b0;
                        _sda_oe_low <= 1'b0;
                        _state <= START1;
                    end

                    START1: begin
                        _scl_oe_low <= 1'b0;
                        _sda_oe_low <= 1'b1;    // START condition
                        _state <= START2;
                    end

                    START2: begin
                        _scl_oe_low <= 1'b1;    // SCL falls (setup for first data bit)
                        _sda_oe_low <= 1'b1;    // SDA held low
                        _state <= TX_LOW;
                    end

                    /*------------------------------------------------------
                     * TX BIT CYCLE  (used for both address and write-data bytes)
                     * TX_LOW:  SCL low, drive SDA to the current bit of _tx_byte.
                     *          SDA is inverted because _sda_oe_low=1 means LOW:
                     *          bit=1 -> release line (HIGH), bit=0 -> pull LOW.
                     * TX_HIGH: Release SCL (HIGH) — peripheral samples SDA here.
                     * TX_FALL: Pull SCL LOW again.
                     *          If all 8 bits sent (_bit_idx==0) -> go to ACK.
                     *          Otherwise decrement _bit_idx and repeat.
                     *----------------------------------------------------*/
                    TX_LOW: begin
                        _scl_oe_low <= 1'b1;
                        _sda_oe_low <= ~_tx_byte[_bit_idx];
                        _state <= TX_HIGH;
                    end

                    TX_HIGH: begin
                        _scl_oe_low <= 1'b0;
                        _state <= TX_FALL;
                    end

                    TX_FALL: begin
                        _scl_oe_low <= 1'b1;
                        if (_bit_idx == 3'd0) begin
                            _state <= ACK_LOW;
                        end else begin
                            _bit_idx <= _bit_idx - 3'd1;
                            _state <= TX_LOW;
                        end
                    end

                    /*------------------------------------------------------
                     * PERIPHERAL ACK  (after every transmitted byte)
                     * ACK_LOW:  SCL low, release SDA so peripheral can drive it.
                     * ACK_HIGH: Release SCL (HIGH), sample SDA into _ack_sample.
                     *           ACK = SDA LOW (peripheral pulls it down).
                     *           NACK = SDA HIGH (no one driving it).
                     * ACK_FALL: SCL falls.  Evaluate _ack_sample:
                     *           - NACK  -> flag error, jump to STOP.
                     *           - ACK after address byte:
                     *               len==0  -> STOP (nothing to transfer).
                     *               read    -> begin RX byte sequence.
                     *               write   -> load first data byte, begin TX.
                     *           - ACK after data byte:
                     *               all bytes done -> STOP.
                     *               more bytes     -> load next byte, continue TX.
                     *----------------------------------------------------*/
                    ACK_LOW: begin
                        _scl_oe_low <= 1'b1;
                        _sda_oe_low <= 1'b0;
                        _state <= ACK_HIGH;
                    end

                    ACK_HIGH: begin
                        _scl_oe_low <= 1'b0;
                        _ack_sample <= _sda_in;
                        _state <= ACK_FALL;
                    end

                    ACK_FALL: begin
                        _scl_oe_low <= 1'b1;

                        if (_ack_sample) begin
                            _ack_err <= 1'b1;
                            _state <= STOP0;
                        end else if (_address_phase) begin
                            _address_phase <= 1'b0;

                            if (_len_latched == 8'd0) begin
                                _state <= STOP0;
                            end else if (_rw_latched) begin
                                _rx_shift <= 8'h00;
                                _bit_idx <= 3'd7;
                                _state <= RX_LOW;
                            end else begin
                                _bit_idx <= 3'd7;
                                if (_tx_count != 0) begin
                                    _tx_byte <= _tx_fifo[_tx_rd_idx];
                                    _tx_rd_idx <= _tx_rd_idx + 8'd1;
                                    _tx_count <= _tx_count - 9'd1;
                                end else begin
                                    _tx_byte <= 8'h00;
                                    _ack_err <= 1'b1;
                                end
                                _state <= TX_LOW;
                            end
                        end else begin
                            _bytes_done <= _bytes_done + 8'd1;

                            if ((_bytes_done + 8'd1) >= _len_latched) begin
                                _state <= STOP0;
                            end else begin
                                _bit_idx <= 3'd7;
                                if (_tx_count != 0) begin
                                    _tx_byte <= _tx_fifo[_tx_rd_idx];
                                    _tx_rd_idx <= _tx_rd_idx + 8'd1;
                                    _tx_count <= _tx_count - 9'd1;
                                end else begin
                                    _tx_byte <= 8'h00;
                                    _ack_err <= 1'b1;
                                end
                                _state <= TX_LOW;
                            end
                        end
                    end

                    /*------------------------------------------------------
                     * RX BIT CYCLE  (receive bytes from peripheral)
                     * RX_LOW:  SCL low, release SDA — peripheral drives the bit.
                     * RX_HIGH: Release SCL (HIGH) — SDA is now stable and valid - data is captured
                     * RX_FALL: SCL falls.
                     *          Capture SDA  into _rx_byte_work at position _bit_idx.
                     *          (Using blocking assignment in _rx_byte_work so the
                     *          updated value is immediately available for the FIFO write.)
                     *          When all 8 bits collected (_bit_idx==0):
                     *            - Write completed byte to RX FIFO (if not full).
                     *            - Determine whether next MACK should be ACK or NACK.
                     *            - Advance to MACK state.
                     *          Otherwise: decrement _bit_idx and continue receiving.
                     *----------------------------------------------------*/
                    RX_LOW: begin
                        _scl_oe_low <= 1'b1;
                        _sda_oe_low <= 1'b0;
                        _state <= RX_HIGH;
                    end

                    RX_HIGH: begin
                        _scl_oe_low <= 1'b0;
                        _rx_shift[_bit_idx] <= _sda_in; 
                        _state <= RX_FALL;
                    end

                    RX_FALL: begin
                        _scl_oe_low <= 1'b1;

                        if (_bit_idx == 3'd0) begin
                            if (_rx_count < 9'd256) begin
                                _rx_fifo[_rx_wr_idx] <= _rx_shift;
                                _rx_wr_idx <= _rx_wr_idx + 8'd1;
                                _rx_count <= _rx_count + 9'd1;
                            end else begin
                                _ack_err <= 1'b1;
                            end

                            _bytes_done <= _bytes_done + 8'd1;
                            _send_nack <= ((_bytes_done + 8'd1) >= _len_latched);
                            _state <= MACK_LOW;
                        end else begin
                            _bit_idx <= _bit_idx - 3'd1;
                            _state <= RX_LOW;
                        end
                    end

                    /*------------------------------------------------------
                     * MASTER ACK/NACK  (after each received byte)
                     * Master sends ACK (SDA LOW)  to request more bytes, or
                     *         sends NACK (SDA HIGH) to signal it's done reading.
                     * MACK_LOW:  SCL low, drive SDA according to _send_nack.
                     *            _send_nack=0 -> ACK  (SDA low  -> oe_low=1)
                     *            _send_nack=1 -> NACK (SDA high -> oe_low=0)
                     * MACK_HIGH: Release SCL (HIGH) — peripheral sees master ACK/NACK.
                     * MACK_FALL: SCL falls.
                     *            NACK was sent -> go to STOP (all bytes received).
                     *            ACK  was sent -> receive next byte.
                     *----------------------------------------------------*/
                    MACK_LOW: begin
                        _scl_oe_low <= 1'b1;
                        _sda_oe_low <= ~_send_nack;
                        _state <= MACK_HIGH;
                    end

                    MACK_HIGH: begin
                        _scl_oe_low <= 1'b0;
                        _state <= MACK_FALL;
                    end

                    MACK_FALL: begin
                        _scl_oe_low <= 1'b1;
                        _sda_oe_low <= 1'b0;

                        if (_send_nack) begin
                            _state <= STOP0;
                        end else begin
                            _rx_shift <= 8'h00;
                            _bit_idx <= 3'd7;
                            _state <= RX_LOW;
                        end
                    end

                    /*------------------------------------------------------
                     * STOP CONDITION
                     * I2C STOP: SDA rises while SCL is high.
                     * STOP0: SCL low, SDA low   (setup — ensure SDA is low before SCL rises)
                     * STOP1: SCL high, SDA low  (hold before SDA rises)
                     * STOP2: SCL high, SDA high (SDA rises -> STOP condition on bus)
                     *        -> Clear _busy, latch _done, return to IDLE.
                     *----------------------------------------------------*/
                    STOP0: begin
                        _scl_oe_low <= 1'b1;
                        _sda_oe_low <= 1'b1;
                        _state <= STOP1;
                    end

                    STOP1: begin
                        _scl_oe_low <= 1'b0;
                        _sda_oe_low <= 1'b1;
                        _state <= STOP2;
                    end

                    STOP2: begin
                        _scl_oe_low <= 1'b0;    // SCL high
                        _sda_oe_low <= 1'b0;    // SDA rises -> STOP condition

                        _busy <= 1'b0;          // Transaction complete
                        _done <= 1'b1;          // Latch done flag for MMIO to read
                        _state <= IDLE;
                    end

                    default: begin          // illegal state
                        _state <= IDLE;     
                    end
                endcase
            end
        end
    end

endmodule
