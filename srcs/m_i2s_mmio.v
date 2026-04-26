`timescale 1ns / 1ps

/*************************************************************************************
 * I2S MMIO MODULE
 * Implements the Memory-Mapped IO (MMIO) interface for the I2S peripheral.
 *
 * Submodules instantiated:
 * - i2s_clk_gen  : Derives BCLK from the master clock (MCLK).
 * - i2s_tx       : I2S transmitter (playback) state machine.
 * - i2s_fifo     : Asynchronous FIFO for Clock Domain Crossing.
 * - i2c_master   : Configures the SSM2603 Audio Codec via I2C at startup.
 ************************************************************************************/
module i2s_mmio (
    input  wire        i_clk,         // System clock (100 MHz)
    input  wire        i_rst,         // Active-high reset
    input  wire        i_mclk,        // Master clock (12.288 MHz)
    input  wire        i_sel,         // Peripheral chip-select
    input  wire        i_we,          // Write enable
    input  wire        i_re,          // Read enable
    input  wire [2:0]  i_addr,        // Register address (word-aligned)
    input  wire [15:0] i_wdata,       // Data bus (write)
    output wire [15:0] o_rdata,       // Data bus (read)
    output wire        o_rdy,         // Peripheral ready handshake
    output wire        o_irq_req,     // Interrupt request to Global Controller

    // I2S signals to SSM2603 Codec
    output wire        o_mclk,        // Master clock pass-through
    output wire        o_bclk,        // Bit clock
    output wire        o_lrclk,       // Left/Right word clock
    output wire        o_pbdat,       // Serial playback data
    
    //I2S signals for AXI4-Stream
    input wire [31:0] s_axis_tdata,   //Audio Data from DDR3 Left[15:0] and Right[15:0]
    input wire s_axis_tvalid,         //DMA is sending valid data
    output wire s_axis_tready,        //Ready to recieve data

    // I2C signals for SSM2603 configuration
    inout  wire        io_i2c_sda,
    inout  wire        io_i2c_scl
    
);

/****************************************************************************
 * 1.1 REGISTER ADDRESSES (Base offset: 0x8700)
 ***************************************************************************/
//    localparam [2:0] TX_LEFT  = 3'd0; // [W/R] Left channel PCM sample
//    localparam [2:0] TX_RIGHT = 3'd1; // [W/R] Right channel PCM sample (commits pair)
    localparam [2:0] STATUS   = 3'd2; // [R]   Read-only status flags
    localparam [2:0] CTRL     = 3'd3; // [W/R] Control flags (Enable, IRQ, etc.)

/****************************************************************************
 * 1.2 MMIO REGISTERS
 ***************************************************************************/
//    reg [31:0] _tx_word;              // Holds {Left[15:0], Right[15:0]}
//    reg        _pair_pending;         // Flags that Left channel is waiting for Right
    reg        _tx_enable;            // Enables I2S hardware transmission
    reg        _irq_enable;           // Enables FIFO almost-empty interrupts
    reg        _irq_pend;             // Latched interrupt request

/****************************************************************************
 * 1.3 INTERNAL WIRES / REGS
 ***************************************************************************/
    wire        _bclk;
    wire        _tx_lrclk;
    reg         _codec_init_done;
    wire        _init_busy;
    reg         _init_error;
    
    reg [15:0]  _rdata;
    wire        _tx_ready;
    wire        _tx_busy;

    // Async FIFO interface
    wire        _fifo_wr_en;
    wire [31:0] _fifo_wdata;
    wire        _fifo_full;
    wire        _fifo_afull;
    wire [31:0] _fifo_rdata;
    wire        _fifo_rd_en;
    wire        _fifo_empty_bclk;
    wire        _fifo_aempty_bclk;

    // Clock Domain Crossing (CDC) synchronizers
    reg         _fifo_empty_s1,  _fifo_empty_s2;
    reg         _fifo_aempty_s1, _fifo_aempty_s2;
    wire        _underrun_bclk;
    reg         _underrun_s1, _underrun_s2;
    reg         _underrun_latched;

    // SSM2603 init FSM via I2C
    reg         _init_trigger;
    wire        _i2c_busy;
    wire        _i2c_done;
    wire        _i2c_ack_err;
    reg         _i2c_start_pulse;
    reg         _i2c_tx_push;
    reg [7:0]   _i2c_tx_push_data;
    reg         _i2c_clr_done;

    localparam [4:0] INIT_IDLE      = 5'd0;
    localparam [4:0] INIT_PUSH_H    = 5'd1;
    localparam [4:0] INIT_PUSH_L    = 5'd2;
    localparam [4:0] INIT_START     = 5'd3;
    localparam [4:0] INIT_WAIT      = 5'd4;
    localparam [4:0] INIT_CLR       = 5'd5;
    localparam [4:0] INIT_DONE      = 5'd6;

    reg [4:0]   _init_state;
    reg [3:0]   _init_reg_idx;
    reg [15:0]  _init_seq [0:10];     // Array holds the 11 I2C initialization commands
    reg [15:0]  _init_word;

/*************************************************************************************
 * 2.1 Static Assignments
 ************************************************************************************/
    assign o_rdy     = i_sel;
    assign o_irq_req = _irq_pend;
    assign o_rdata   = _rdata;
    
    assign o_mclk    = i_mclk;
    assign o_bclk    = _bclk;
    assign o_lrclk   = _tx_lrclk;

    assign _init_busy = (_init_state != INIT_IDLE);
    assign _tx_ready = _codec_init_done && !_fifo_empty_s2;
    assign _tx_busy  = _tx_enable && _tx_ready;
    
    
    //NEW: AXI4-Stream to FIFO Logic
    assign s_axis_tready = !_fifo_full;                //ready if fifo is not full
    assign _fifo_wr_en = s_axis_tvalid && s_axis_tready;  //Write to fifo when DMA sends valid data and we are ready
    assign _fifo_wdata = s_axis_tdata;                    //Connect the 32-bit DMA data directly to the FIFO

/*************************************************************************************
 * 2.2 Submodule Instances
 ************************************************************************************/
    i2s_clk_gen u_clk_gen (
        .i_mclk  (i_mclk),
        .i_rst   (i_rst),
        .o_bclk  (_bclk)
    );

    i2s_tx u_tx (
        .i_bclk        (_bclk),
        .i_rst         (i_rst),
        .i_enable      (_codec_init_done && _tx_enable),
        .i_fifo_rdata  (_fifo_rdata),
        .i_fifo_empty  (_fifo_empty_bclk),
        .o_fifo_rd_en  (_fifo_rd_en),
        .o_underrun    (_underrun_bclk),
        .o_pbdat       (o_pbdat),
        .o_lrclk       (_tx_lrclk)
    );

    i2s_fifo #(.DEPTH_LOG2(4)) u_fifo (
        .i_wclk         (i_clk),
        .i_wrst         (i_rst),
        .i_wr_en        (_fifo_wr_en),
        .i_wdata        (_fifo_wdata),
        .o_full         (_fifo_full),
        .o_almost_full  (_fifo_afull),
        .i_rclk         (_bclk),
        .i_rrst         (i_rst),
        .i_rd_en        (_fifo_rd_en),
        .o_rdata        (_fifo_rdata),
        .o_empty        (_fifo_empty_bclk),
        .o_almost_empty (_fifo_aempty_bclk)
    );

//    assign _fifo_wr_en = i_sel && i_we && (i_addr == TX_RIGHT) && _pair_pending && !_fifo_full;
//    assign _fifo_wdata = {_tx_word[31:16], i_wdata};

    i2c_master u_i2c_master (
        .i_clk          (i_clk),
        .i_rst          (i_rst),
        .i_en           (1'b1),
        .i_start        (_i2c_start_pulse),
        .i_rw           (1'b0),        
        .i_addr7        (7'h1A),
        .i_len          (8'd2),
        .i_divider      (16'd500),     // Safe divider of 500 (generates a stable 200kHz I2C clock)
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
 * 2.2.1 CDC Synchronizers
 * Safely bridges flags from the 3.072MHz I2S domain into the 100MHz System domain
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _fifo_empty_s1  <= 1'b1;
            _fifo_empty_s2  <= 1'b1;
            _fifo_aempty_s1 <= 1'b1;
            _fifo_aempty_s2 <= 1'b1;
            _underrun_s1    <= 1'b0;
            _underrun_s2    <= 1'b0;
        end else begin
            _fifo_empty_s1  <= _fifo_empty_bclk;
            _fifo_aempty_s1 <= _fifo_aempty_bclk;
            _underrun_s1    <= _underrun_bclk;

            _fifo_empty_s2  <= _fifo_empty_s1;
            _fifo_aempty_s2 <= _fifo_aempty_s1;
            _underrun_s2    <= _underrun_s1;
        end
    end

/*************************************************************************************
 * 2.3 SSM2603 Init Sequence Table (Restored full 11-command sequence)
 ************************************************************************************/
    integer k;
initial begin
    _init_seq[0]  = {7'h0F, 9'h000};
    _init_seq[1]  = {7'h06, 9'h000};
    _init_seq[2]  = {7'h00, 9'h017};
    _init_seq[3]  = {7'h01, 9'h017};
    _init_seq[4]  = {7'h02, 9'h079};
    _init_seq[5]  = {7'h03, 9'h079};
    _init_seq[6]  = {7'h04, 9'h010};
    _init_seq[7]  = {7'h05, 9'h000};
    _init_seq[8]  = {7'h07, 9'h002};
    _init_seq[9]  = {7'h08, 9'h000};
    _init_seq[10] = {7'h09, 9'h001};
end

/*************************************************************************************
 * 2.4 SSM2603 Initialization FSM
 * Executes the I2C configuration commands sequentially.
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _init_state       <= INIT_IDLE;
            _init_reg_idx     <= 4'd0;
            _codec_init_done  <= 1'b0;
            _init_error       <= 1'b0;
            
            _i2c_start_pulse  <= 1'b0;
            _i2c_tx_push      <= 1'b0;
            _i2c_tx_push_data <= 8'h00;
            _i2c_clr_done     <= 1'b0;
            _init_trigger     <= 1'b0;
            _init_word        <= 16'd0;
        end else begin
            // Default pulse values (Deasserts automatically)
            _i2c_start_pulse  <= 1'b0;
            _i2c_tx_push      <= 1'b0;
            _i2c_clr_done     <= 1'b0;

            // Manual re-trigger via MMIO CTRL[4]
            if (i_sel && i_we && (i_addr == CTRL) && i_wdata[4]) begin
                _init_trigger <= 1'b1;
                _init_error   <= 1'b0;
            end

            case (_init_state)
                INIT_IDLE: begin
    if (_init_trigger) begin
        _init_trigger    <= 1'b0;
        _init_reg_idx    <= 4'd0;
        _codec_init_done <= 1'b0;
        _init_state      <= INIT_PUSH_H;
    end
end
                INIT_PUSH_H: begin
                    _init_word        <= _init_seq[_init_reg_idx];
                    _i2c_tx_push      <= 1'b1;
                    _i2c_tx_push_data <= {_init_seq[_init_reg_idx][15:9],
                                          _init_seq[_init_reg_idx][8]};
                    _init_state       <= INIT_PUSH_L;
                end

                INIT_PUSH_L: begin
                    _i2c_tx_push      <= 1'b1;
                    _i2c_tx_push_data <= _init_word[7:0];
                    _init_state       <= INIT_START;
                end

                INIT_START: begin
                    if (!_i2c_busy) begin
                        _i2c_start_pulse <= 1'b1;
                        _init_state      <= INIT_WAIT;
                    end
                end

                INIT_WAIT: begin
                    if (_i2c_done) begin
                        _i2c_clr_done <= 1'b1;
                        if (_i2c_ack_err) begin
                            _init_error <= 1'b1;       // Abort on NACK
                            _init_state <= INIT_IDLE;
                        end else begin
                            _init_state <= INIT_CLR;
                        end
                    end
                end

                INIT_CLR: begin
                    // Iterate up to index 10 to include all 11 commands
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
//            _tx_word          <= 32'h0000_0000;
//            _pair_pending     <= 1'b0;
            _tx_enable        <= 1'b0;
            _irq_enable       <= 1'b0;
            _irq_pend         <= 1'b0;
            _underrun_latched <= 1'b0;
        end else begin
            // Sticky latch for audio underrun (processor failed to feed FIFO in time)
            if (_underrun_s2)
                _underrun_latched <= 1'b1;

            // Trigger Interrupt when FIFO hits the almost-empty threshold
            if (_fifo_aempty_s2 && _irq_enable)
                _irq_pend <= 1'b1;

            if (i_sel && i_we) begin
                case (i_addr)
                /*
                    TX_LEFT: begin
                        _tx_word[31:16] <= i_wdata;
                        _pair_pending <= 1'b1;
                    end
                    TX_RIGHT: begin
                        _tx_word[15:0] <= i_wdata;
                        if (_pair_pending)
                            _pair_pending <= 1'b0;
                        _irq_pend <= 1'b0; // Auto-clear IRQ flag on audio refill
                    end
                    */
                    CTRL: begin
                        _tx_enable  <= i_wdata[0];
                        _irq_enable <= i_wdata[1];
                        if (i_wdata[2]) _irq_pend <= 1'b0;         // Write-1-to-Clear IRQ
                        if (i_wdata[3]) _underrun_latched <= 1'b0; // Write-1-to-Clear Underrun
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
//                TX_LEFT:  _rdata = _tx_word[31:16];
//                TX_RIGHT: _rdata = _tx_word[15:0];
                STATUS:   _rdata = {8'b0, _underrun_latched, _irq_pend, _tx_busy,
                                    _tx_ready, _init_error, _init_busy, 
                                    _codec_init_done, _fifo_full};
                CTRL:     _rdata = {11'b0, 3'b000, _irq_enable, _tx_enable};
                default:  _rdata = 16'h0000;
            endcase
        end
    end

endmodule