`timescale 1ns / 1ps

/*************************************************************************************
 * I2S MMIO MODULE
 *  Implements I2S MMIO. Instantiates:
 *    - i2s_clk_gen  : derives BCLK and LRCLK from MCLK
 *    - i2s_tx       : I2S transmitter (playback)
 *    - ssm2603_init : SSM2603 codec initialization via I2C (uses i2c_master)
 *
 *  Memory Map (i_addr [3:1], 0x87xx):
 *    0 - TX_LEFT   [W]  : Left  channel PCM sample to play (16-bit)
 *    1 - TX_RIGHT  [W]  : Right channel PCM sample to play (16-bit)
 *    2 - STATUS    [R]  : Bit 0 = TX ready (sample_req), Bit 1 = codec initialized
 *    3 - CTRL      [W]  : Bit 0 = TX enable, Bit 1 = IRQ enable on TX ready
 *    4 - I2C_INIT  [W]  : Write 1 to trigger SSM2603 initialization sequence
 *
 *  Interrupt:
 *    - o_irq_req asserts when TX sample_req fires AND IRQ is enabled in CTRL
 *
 *  Notes:
 *    - MCLK (12.288 MHz) must be provided by the top-level MMCM (Clock Wizard IP)
 *    - i2c_master is instantiated internally to send the SSM2603 init sequence
 *    - The SSM2603 MUTE pin must be driven HIGH externally by the top-level XDC
 ************************************************************************************/

module i2s_mmio (
    input  wire        i_clk,         // System clock (100 MHz)
    input  wire        i_rst,
    input  wire        i_mclk,        // 12.288 MHz from MMCM (top-level)
    input  wire        i_sel,         // Peripheral select
    input  wire        i_we,          // Write enable
    input  wire        i_re,          // Read enable
    input  wire [2:0]  i_addr,        // Register address (LS nibble, [3:1] from bus)
    input  wire [15:0] i_wdata,       // Write data
    output wire [15:0] o_rdata,       // Read data
    output wire        o_rdy,         // Peripheral ready
    output wire        o_irq_req,     // Interrupt request
    // I2S signals to SSM2603
    output wire        o_mclk,        // Master clock  -> SSM2603 MCLK
    output wire        o_bclk,        // Bit clock     -> SSM2603 BCLK
    output wire        o_lrclk,       // LR clock      -> SSM2603 PBLRC
    output wire        o_pbdat,       // Playback data -> SSM2603 PBDAT
    // I2C signals for SSM2603 configuration
    inout  wire        io_i2c_sda,
    inout  wire        io_i2c_scl
);

/*************************************************************************************
 * SECTION 1. DECLARE/DEFINE VARIABLES
 ************************************************************************************/

/****************************************************************************
 * 1.1 REGISTER ADDRESSES (i_addr [2:0])
 ***************************************************************************/
    localparam [2:0] TX_LEFT  = 3'd0;
    localparam [2:0] TX_RIGHT = 3'd1;
    localparam [2:0] STATUS   = 3'd2;
    localparam [2:0] CTRL     = 3'd3;
    localparam [2:0] I2C_INIT = 3'd4;

/****************************************************************************
 * 1.2 MMIO REGISTERS
 ***************************************************************************/
    reg [15:0] _tx_left;
    reg [15:0] _tx_right;
    reg        _tx_enable;
    reg        _irq_enable;
    reg        _irq_pend;

/****************************************************************************
 * 1.3 INTERNAL WIRES / REGS
 ***************************************************************************/
    wire        _bclk;
    wire        _lrclk;
    wire        _sample_req;
    reg         _codec_init_done;

    // Latched sample buffers: updated by CPU writes, consumed by TX on sample_req
    reg [15:0]  _left_buf;
    reg [15:0]  _right_buf;

    reg [15:0]  _rdata;

    // SSM2603 init FSM via I2C
    reg         _init_trigger;      // Pulse to start init sequence
    wire        _i2c_busy;
    wire        _i2c_done;
    wire        _i2c_ack_err;

    reg         _i2c_start_pulse;
    reg         _i2c_tx_push;
    reg [7:0]   _i2c_tx_push_data;
    reg         _i2c_clr_done;

    // Init FSM
    localparam [4:0] INIT_IDLE      = 5'd0;
    localparam [4:0] INIT_PUSH_H    = 5'd1;  // Push high byte of register write
    localparam [4:0] INIT_PUSH_L    = 5'd2;  // Push low byte
    localparam [4:0] INIT_START     = 5'd3;  // Assert start pulse
    localparam [4:0] INIT_WAIT      = 5'd4;  // Wait for done
    localparam [4:0] INIT_CLR       = 5'd5;  // Clear done flag
    localparam [4:0] INIT_DONE      = 5'd6;  // All registers written

    reg [4:0]   _init_state;
    reg [3:0]   _init_reg_idx;      // Which register we're writing (0..10)

    // SSM2603 init sequence: 11 writes of {reg_addr[6:0], reg_data[8:0]}
    // Packed as 16 bits: [15:9] = reg_addr, [8:0] = reg_data
    reg [15:0]  _init_seq [0:10];
    reg [15:0]  _init_word;         // Current word being sent

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Static Assignments
 ************************************************************************************/
    assign o_rdy     = i_sel;
    assign o_irq_req = _irq_pend;
    assign o_rdata   = _rdata;
    assign o_mclk    = i_mclk;     // Pass MCLK directly to SSM2603 pin

/*************************************************************************************
 * 2.2 Submodule Instances
 ************************************************************************************/
    i2s_clk_gen u_clk_gen (
        .i_mclk  (i_mclk),
        .i_rst   (i_rst),
        .o_bclk  (_bclk),
        .o_lrclk (_lrclk)
    );

    assign o_bclk  = _bclk;
    assign o_lrclk = _lrclk;

    i2s_tx u_tx (
        .i_bclk       (_bclk),
        .i_rst        (i_rst),
        .i_enable     (_tx_enable),
        .i_left       (_left_buf),
        .i_right      (_right_buf),
        .o_pbdat      (o_pbdat),
        .o_lrclk      (),          // LRCLK driven by clk_gen, not TX (shared)
        .o_sample_req (_sample_req)
    );

    i2c_master u_i2c_master (
        .i_clk          (i_clk),
        .i_rst          (i_rst),
        .i_en           (1'b1),
        .i_start        (_i2c_start_pulse),
        .i_rw           (1'b0),            // Always write for SSM2603 init
        .i_addr7        (7'h1A),           // SSM2603 I2C address
        .i_len          (8'd2),            // 2 data bytes per register write
        .i_divider      (16'd250),         // 100 MHz / 250 = 400 kHz I2C
        .i_tx_push      (_i2c_tx_push),
        .i_tx_push_data (_i2c_tx_push_data),
        .i_rx_pop       (1'b0),
        .i_rx_flush     (1'b0),
        .i_clr_done     (_i2c_clr_done),
        .i_clr_ack_err  (1'b0),
        .o_rx_data      (),
        .o_rx_valid     (),
        .o_busy         (_i2c_busy),
        .o_done         (_i2c_done),
        .o_ack_err      (_i2c_ack_err),
        .io_i2c_sda     (io_i2c_sda),
        .io_i2c_scl     (io_i2c_scl)
    );

/*************************************************************************************
 * 2.3 SSM2603 Init Sequence Table
 *  Format: [15:9] = reg_addr (7-bit), [8:0] = reg_data (9-bit)
 *  I2C write = {reg_addr[6:0], reg_data[8]} , {reg_data[7:0]}
 ************************************************************************************/
    always @(posedge i_clk) begin
        // Init sequence loaded once at reset
        _init_seq[0]  <= {7'h0F, 9'h000}; // 1.  Reset
        _init_seq[1]  <= {7'h06, 9'h010}; // 2.  Power up (keep CLKOUT off)
        _init_seq[2]  <= {7'h00, 9'h017}; // 3.  Left  line in  = 0 dB
        _init_seq[3]  <= {7'h01, 9'h017}; // 4.  Right line in  = 0 dB
        _init_seq[4]  <= {7'h02, 9'h079}; // 5.  Left  HP out   = 0 dB
        _init_seq[5]  <= {7'h03, 9'h079}; // 6.  Right HP out   = 0 dB
        _init_seq[6]  <= {7'h04, 9'h010}; // 7.  Analog path: DAC selected, line-in
        _init_seq[7]  <= {7'h05, 9'h000}; // 8.  Digital path: unmute DAC
        _init_seq[8]  <= {7'h07, 9'h002}; // 9.  Format: I2S, 16-bit, slave
        _init_seq[9]  <= {7'h08, 9'h000}; // 10. Sample rate: 48 kHz, MCLK=12.288 MHz
        _init_seq[10] <= {7'h09, 9'h001}; // 11. Activate codec
    end

/*************************************************************************************
 * 2.4 SSM2603 Initialization FSM
 *  Walks through _init_seq[], writing each register via i2c_master.
 *  Triggered by writing 1 to I2C_INIT register via MMIO.
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _init_state     <= INIT_IDLE;
            _init_reg_idx   <= 4'd0;
            _codec_init_done <= 1'b0;
            _i2c_start_pulse <= 1'b0;
            _i2c_tx_push    <= 1'b0;
            _i2c_tx_push_data <= 8'h00;
            _i2c_clr_done   <= 1'b0;
            _init_trigger   <= 1'b0;
            _init_word      <= 16'd0;
        end else begin
            // Default: deassert pulses
            _i2c_start_pulse  <= 1'b0;
            _i2c_tx_push      <= 1'b0;
            _i2c_clr_done     <= 1'b0;

            // Latch trigger from MMIO writes
            if (i_sel && i_we && (i_addr == I2C_INIT) && i_wdata[0]) begin
                _init_trigger <= 1'b1;
            end

            case (_init_state)

                INIT_IDLE: begin
                    if (_init_trigger) begin
                        _init_trigger   <= 1'b0;
                        _init_reg_idx   <= 4'd0;
                        _codec_init_done <= 1'b0;
                        _init_state     <= INIT_PUSH_H;
                    end
                end

                // Push high byte: {reg_addr[6:0], reg_data[8]}
                INIT_PUSH_H: begin
                    _init_word        <= _init_seq[_init_reg_idx];
                    _i2c_tx_push      <= 1'b1;
                    _i2c_tx_push_data <= {_init_seq[_init_reg_idx][15:9],
                                          _init_seq[_init_reg_idx][8]};
                    _init_state       <= INIT_PUSH_L;
                end

                // Push low byte: reg_data[7:0]
                INIT_PUSH_L: begin
                    _i2c_tx_push      <= 1'b1;
                    _i2c_tx_push_data <= _init_word[7:0];
                    _init_state       <= INIT_START;
                end

                // Pulse I2C start
                INIT_START: begin
                    if (!_i2c_busy) begin
                        _i2c_start_pulse <= 1'b1;
                        _init_state      <= INIT_WAIT;
                    end
                end

                // Wait for I2C transaction to complete
                INIT_WAIT: begin
                    if (_i2c_done) begin
                        _i2c_clr_done <= 1'b1;
                        _init_state   <= INIT_CLR;
                    end
                end

                // Clear done, advance to next register or finish
                INIT_CLR: begin
                    if (_init_reg_idx == 4'd10) begin
                        _init_state      <= INIT_DONE;
                    end else begin
                        _init_reg_idx <= _init_reg_idx + 4'd1;
                        _init_state   <= INIT_PUSH_H;
                    end
                end

                INIT_DONE: begin
                    _codec_init_done <= 1'b1;
                    _init_state      <= INIT_IDLE;
                end

                default: _init_state <= INIT_IDLE;

            endcase
        end
    end

/*************************************************************************************
 * 2.5 MMIO Register Writes
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _tx_left    <= 16'h0000;
            _tx_right   <= 16'h0000;
            _left_buf   <= 16'h0000;
            _right_buf  <= 16'h0000;
            _tx_enable  <= 1'b0;
            _irq_enable <= 1'b0;
            _irq_pend   <= 1'b0;
        end else begin
            // Latch sample_req IRQ
            if (_sample_req && _irq_enable) begin
                _irq_pend <= 1'b1;
            end

            // Update sample buffers on sample_req (consume what CPU wrote)
            if (_sample_req) begin
                _left_buf  <= _tx_left;
                _right_buf <= _tx_right;
            end

            if (i_sel && i_we) begin
                case (i_addr)
                    TX_LEFT: begin
                        _tx_left  <= i_wdata;
                    end
                    TX_RIGHT: begin
                        _tx_right <= i_wdata;
                        _irq_pend <= 1'b0;  // Clear IRQ when CPU writes new sample
                    end
                    CTRL: begin
                        _tx_enable  <= i_wdata[0];
                        _irq_enable <= i_wdata[1];
                        if (i_wdata[2]) _irq_pend <= 1'b0; // Manual IRQ clear
                    end
                    default: ;
                endcase
            end
        end
    end

/*************************************************************************************
 * 2.6 Readback Mux
 ************************************************************************************/
    always @(*) begin
        if (!i_sel || !i_re) begin
            _rdata = 16'h0000;
        end else begin
            case (i_addr)
                TX_LEFT:  _rdata = _tx_left;
                TX_RIGHT: _rdata = _tx_right;
                STATUS:   _rdata = {13'b0, _irq_pend, _codec_init_done, _sample_req};
                CTRL:     _rdata = {13'b0, 1'b0, _irq_enable, _tx_enable};
                default:  _rdata = 16'h0000;
            endcase
        end
    end

endmodule
