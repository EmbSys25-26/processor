`timescale 1ns / 1ps

/*************************************************************************************
 * PS2 MMIO MODULE
 *  Implements PS2 MMIO, instantiates PS2 D2H (Device -> Host) and
 *  PS2 H2D (Host -> Device) submodules.
 *  Features:
 *  - 2 flip-flop synchronizers on CLK and DATA lines
 *  - Falling edge PS2 clock detection shared between RX and TX submodules
 *  - Peripheral interrupt on RX pending (RXNE & RXIE)
 ************************************************************************************/

module ps2_mmio (
    input  wire        i_clk,
    input  wire        i_rst,
    input  wire        i_sel,           // IO selection
    input  wire        i_we,            // IO write enable
    (* mark_debug = "true" *) input  wire        i_re,            // IO read enable
    input  wire [1:0]  i_addr,          // Address used to identify the peripheral register
    input  wire [15:0] i_wdata,         // Data to write
    output wire [15:0] o_rdata,         // Data read
    output wire        o_rdy,           // Feedback peripheral ready
    inout              io_ps2_clk,      // PS2 - Clock (bidirectional, open-drain)
    inout              io_ps2_data,     // PS2 - Data  (bidirectional, open-drain)
    output wire        o_irq_req        // PS2 - Interrupt Request
);

/*************************************************************************************
 * SECTION 1. DECLARE/DEFINE Variables/Registers/Wires
 ************************************************************************************/

/****************************************************************************
 * 1.1 DEFINE SFRs - MMIO REGISTERS' ADDRESSES (LS nibble)
 ***************************************************************************/
    localparam [1:0] PS2DR = 2'b00;   // Data Register
    localparam [1:0] PS2SR = 2'b01;   // Status Register
    localparam [1:0] PS2CR = 2'b10;   // Control Register

/****************************************************************************
 * 1.2 DECLARE SFRs - MMIO REGISTERS
 *
 ***************************************************************************/

    /* PS2DR */
    (* mark_debug = "true" *) reg [7:0] _rxd;         // received scancode byte
    reg [7:0] _txd;         // byte to transmit to device

    /* PS2SR - regs */
    reg  _rxne;             // [0] RX Not Empty
    reg  _pe;               // [2] Parity Error
    reg  _err;              // [3] Framing Error
    reg  _aerr;             // [4] Transmit ACK Error



    /* PS2SR - wires driven directly by submodules */
    wire _txb;              // [1] TX Busy          - driven by H2D o_tx_busy
    wire _rxif;             // [5] RX Interrupt Flag - combinational: RXNE & RXIE

    /* PS2CR */
    reg _rxie;              // [0] RX Interrupt Enable
    reg _en;                // [1] Peripheral Enable

/****************************************************************************
 * 1.3 DECLARE WIRES / REGS
 ***************************************************************************/
    reg  _tx_start;         // pulsed high for 1 cycle when CPU writes PS2DR

    wire        _rx_valid;      // pulses high when D2H finishes a valid frame
    wire [7:0]  _rx_data_wire;  // received byte from D2H module
    wire        _rx_pe;         // parity error flag from D2H module
    wire        _rx_err;        // framing error flag from D2H module
    wire        _tx_aerr;

    (* mark_debug = "true" *)reg [15:0] _rdata;

    // Explicit input wires for inout pins (required for safe synthesis)
    wire _ps2_clk_in  = io_ps2_clk;
    wire _ps2_data_in = io_ps2_data;

    // 2 flip-flop synchronizers
    reg [1:0] _clk_sync;
    reg [1:0] _data_sync;

    wire _ps2_clk_s;        // synchronized PS2 CLK
    wire _ps2_data_s;       // synchronized PS2 DATA

    // Falling edge detection
    reg  _clk_prev;
    wire _fall_edge;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/****************************************************************************
 * 2.1 2 Flip-Flop Synchronizers (clock domain crossing)
 *     Prevents metastability from asynchronous PS2 CLK and DATA lines
 ***************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _clk_sync  <= 2'b11;    // idle state of PS2 CLK is high
            _data_sync <= 2'b11;    // idle state of PS2 DATA is high
        end else begin
            _clk_sync  <= {_clk_sync[0],  _ps2_clk_in};
            _data_sync <= {_data_sync[0], _ps2_data_in};
        end
    end

    assign _ps2_clk_s  = _clk_sync[1];
    assign _ps2_data_s = _data_sync[1];

/****************************************************************************
 * 2.2 Falling Edge Detection
 *     Generates a single-cycle pulse on each falling edge of PS2 CLK
 ***************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _clk_prev <= 1'b1;
        end else begin
            _clk_prev <= _ps2_clk_s;
        end
    end

    assign _fall_edge = _clk_prev & ~_ps2_clk_s;

/****************************************************************************
 * 2.3 PS/2 Submodule Instances
 ***************************************************************************/

    // Combinational flags
    assign _rxif     = _rxne & _rxie;
    assign o_irq_req = _rxif;
    assign o_rdy     = i_sel;

    // Device -> Host: receives scancodes from keyboard
    ps2_d2h u_ps2_d2h (
        .i_clk       (i_clk),
        .i_rst       (i_rst),
        .i_fall_edge (_fall_edge),
        .i_ps2_data  (_ps2_data_s),
        .i_rx_en     (_en),
        .o_rx_data   (_rx_data_wire),
        .o_rx_valid  (_rx_valid),
        .o_rx_pe     (_rx_pe),
        .o_rx_err    (_rx_err)
    );

    // Host -> Device: sends commands to keyboard
    // _txb and _aerr are driven directly from this module - no intermediate regs needed
    ps2_h2d u_ps2_h2d (
        .i_clk        (i_clk),
        .i_rst        (i_rst),
        .i_start      (_tx_start),
        .i_data       (_txd),
        .i_fall_edge  (_fall_edge),
        .i_ps2_data_s (_ps2_data_s),
        .io_ps2_clk   (io_ps2_clk),
        .io_ps2_data  (io_ps2_data),
        .o_tx_done    (),
        .o_tx_busy    (_txb),
        .o_tx_aerr    (_tx_aerr)
    );

/****************************************************************************
 * 2.4 MMIO Side Effects
 ***************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _tx_start <= 1'b0;
            _txd      <= 8'h00;
            _rxd      <= 8'h00;
            _rxne     <= 1'b0;
            _pe       <= 1'b0;
            _err      <= 1'b0;
            _aerr     <= 1'b0;
            _rxie     <= 1'b0;
            _en       <= 1'b0;
        end else begin
            // Default: deassert tx_start every cycle unless set below
            _tx_start <= 1'b0;
            _aerr  <= _tx_aerr;

            // New frame received from D2H module
            // Note: if CPU has not read PS2DR yet, data is overwritten.
            // Software must read PS2DR promptly in the ISR or polling loop.
            if (_rx_valid) begin
                _rxne <= 1'b1;
                _rxd  <= _rx_data_wire;
                _pe   <= _rx_pe;
                _err  <= _rx_err;
            end

            // CPU writes to PS2 SFRs
            if (i_sel && i_we) begin
                case (i_addr)
                    PS2DR: begin
                        // Write byte to transmit, kick off transmission
                        _txd      <= i_wdata[7:0];
                        _tx_start <= 1'b1;
                    end
                    PS2CR: begin
                        // Configure peripheral
                        _rxie <= i_wdata[0];
                        _en   <= i_wdata[1];
                    end
                    default: ;
                endcase
            end

            // CPU reads PS2DR: clear RXNE and error flags (read-clear)
            if (i_sel && i_re && (i_addr == PS2DR)) begin
                _rxne <= 1'b0;
                _pe   <= 1'b0;
                _err  <= 1'b0;
            end
        end
    end

/****************************************************************************
 * 2.5 MMIO Readback
 ***************************************************************************/
    always @(*) begin
        if (!i_sel || !i_re) begin
            _rdata = 16'h0000;
        end else begin
            case (i_addr)
                PS2DR: _rdata = {8'h00, _rxd};
                PS2SR: _rdata = {10'b0,_aerr,_rxif, _err, _pe, _txb, _rxne};
                PS2CR: _rdata = {14'b0, _en, _rxie};
                default: _rdata = 16'h0000;
            endcase
        end
    end

    assign o_rdata = _rdata;

endmodule