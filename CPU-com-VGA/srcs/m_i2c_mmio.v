`timescale 1ns / 1ps

/*************************************************************************************
 * I2C MMIO MODULE
 *  Implements I2C MMIO, instantiates I2C Master Module
 *  Features:
 *  - Multi-byte send/receive
 *  - Peripheral Interrupt on Transmission Finished
 ************************************************************************************/

module i2c_mmio(
    input wire i_clk,
    input wire i_rst,
    input wire i_sel,           // IO selection
    input wire i_we,            // IO write enable
    input wire i_re,            // IO read enable
    input wire [2:0] i_addr,    // Address used to identify the peripheral register
    input wire [15:0] i_wdata,  // Data to Write
    output wire [15:0] o_rdata, // Data Read
    output wire o_rdy,          // Feadback peripheral ready
    output wire o_irq_req,      // I2C - Interrupt Request
    inout wire io_i2c_sda,      // I2C - SDA
    inout wire io_i2c_scl       // I2C - SCL
);

/*************************************************************************************
 * SECTION 1. DECLARE/DEFINE Variables/Registers/Wires
 ************************************************************************************/

/****************************************************************************
 * 1.1 DEFINE SFRs - MMIO REGISTERS' ADDRESSES  (LS nibble)
 ***************************************************************************/
    localparam [2:0] CONFIG0_BASE = 3'd0;
    localparam [2:0] CONFIG1_BASE = 3'd1;
    localparam [2:0] DIVIDER = 3'd2;  // Note: CLK/DIVIDER won't exactly specify the baudrate
    localparam [2:0] ADDR = 3'd3;     // Address Only
    localparam [2:0] DATA_LEN = 3'd4;
    localparam [2:0] DATA = 3'd5;

/****************************************************************************
 * 1.2 DECLARE SFRs -  MMIO REGISTERS
 ***************************************************************************/
 // CONFIG0_BASE
    reg _en;
    reg _start;
    reg _rw;
    reg _irq_en;

 // CONFIG1_BASE
    reg _rx_pop;
    reg _rx_flush;
    reg _clr_done;
    reg _clr_ack_err;

    reg [15:0] _div;    // DIVIDER
    reg [7:0] _addr;    // ADDR
    reg [7:0] _len;     // DATA_LEN

/****************************************************************************
 * 1.3 DECLARE WIRES / REGS
 ***************************************************************************/
    reg _irq_pend;

    reg _start_pulse;
    reg _tx_push;
    reg [7:0] _tx_push_data;

    wire _busy;
    wire _done;
    wire _ack_err;
    wire _rx_valid;
    wire [7:0] _rx_data;
    reg _done_d;
    reg _ack_err_d;

    reg [15:0] _rdata;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Static Assignments and Master Instance
 ************************************************************************************/
    assign o_rdy = i_sel;
    assign o_irq_req = _irq_pend;
    assign o_rdata = _rdata;

    i2c_master u_i2c_master (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(_en),
        .i_start(_start_pulse),
        .i_rw(_rw),
        .i_addr7(_addr[7:1]),
        .i_len(_len),
        .i_divider(_div),
        .i_tx_push(_tx_push),
        .i_tx_push_data(_tx_push_data),
        .i_rx_pop(_rx_pop),
        .i_rx_flush(_rx_flush),
        .i_clr_done(_clr_done),
        .i_clr_ack_err(_clr_ack_err),
        .o_rx_data(_rx_data),
        .o_rx_valid(_rx_valid),
        .o_busy(_busy),
        .o_done(_done),
        .o_ack_err(_ack_err),
        .io_i2c_sda(io_i2c_sda),
        .io_i2c_scl(io_i2c_scl)
    );

/*************************************************************************************
 * 2.2 Register Writes and IRQ Latch
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _en <= 1'b0;
            _start <= 1'b0;
            _rw <= 1'b0;
            _irq_en <= 1'b0;

            _div <= 16'd100; // Default divider value = 100  => freq = (CLK_freq/100)
            _addr <= 8'h00;
            _len <= 8'h00;

            _irq_pend <= 1'b0;

            _start_pulse <= 1'b0;
            _tx_push <= 1'b0;
            _tx_push_data <= 8'h00;
            _rx_pop <= 1'b0;
            _rx_flush <= 1'b0;
            _clr_done <= 1'b0;
            _clr_ack_err <= 1'b0;
            _done_d <= 1'b0;
            _ack_err_d <= 1'b0;
        end 
            else begin
            _start_pulse <= 1'b0;
            _tx_push <= 1'b0;
            _rx_pop <= 1'b0;
            _rx_flush <= 1'b0;
            _clr_done <= 1'b0;
            _clr_ack_err <= 1'b0;

            if (_start && !_busy && _en) begin
                _start_pulse <= 1'b1;
            end

            if ((_start && _busy) || _done || _ack_err) begin
                _start <= 1'b0;
            end

            if (((_done && !_done_d) || (_ack_err && !_ack_err_d)) && _irq_en) begin
                _irq_pend <= 1'b1;
            end

            if (i_sel && i_we) begin
                case (i_addr)
                    CONFIG0_BASE: begin
                        _en <= i_wdata[0];
                        _rw <= i_wdata[2];
                        _irq_en <= i_wdata[3];
                        if (i_wdata[1]) begin
                            _start <= 1'b1;
                            if (!_busy && (i_wdata[0] || _en)) begin
                                _start_pulse <= 1'b1;
                            end
                        end
                    end

                    CONFIG1_BASE: begin
                        if (i_wdata[1]) begin
                            _clr_done <= 1'b1;
                        end
                        if (i_wdata[2]) begin
                            _clr_ack_err <= 1'b1;
                        end
                        if (i_wdata[3]) begin
                            _rx_flush <= 1'b1;
                        end
                        if (i_wdata[4]) begin
                            _irq_pend <= 1'b0;
                        end
                    end

                    DIVIDER: begin
                        _div <= i_wdata;
                    end

                    ADDR: begin
                        _addr <= {i_wdata[7:1], 1'b0};
                    end

                    DATA_LEN: begin
                        _len <= i_wdata[7:0];
                    end

                    DATA: begin
                        _tx_push <= 1'b1;
                        _tx_push_data <= i_wdata[7:0];
                    end

                    default: begin
                    end
                endcase
            end

            if (i_sel && i_re && (i_addr == 3'd5)) begin
                _rx_pop <= 1'b1;
            end

            _done_d <= _done;
            _ack_err_d <= _ack_err;
        end
    end

/*************************************************************************************
 * 2.3 Readback Mux
 ************************************************************************************/
    always @(*) begin
        if (!i_sel || !i_re) begin
            _rdata = 16'h0000;
        end else begin
            case (i_addr)
                CONFIG0_BASE: _rdata = {12'b0, _irq_en, _rw, _start, _en};
                CONFIG1_BASE: _rdata = {11'b0, _irq_pend, _rx_valid, _ack_err, _done, _busy};
                DIVIDER: _rdata = _div;
                ADDR: _rdata = {8'h00, _addr};
                DATA_LEN: _rdata = {8'h00, _len};
                DATA: _rdata = {8'h00, _rx_data};
                default: _rdata = 16'h0000;
            endcase
        end
    end

endmodule
