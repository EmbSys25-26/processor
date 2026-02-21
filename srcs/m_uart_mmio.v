`timescale 1ns / 1ps

/*************************************************************************************
 * UART MMIO MODULE
 *  Implements UART MMIO, instantiates UART Transmit and UART Receive Modules 
 *  Features:
 *  - Peripheral Interrupt on Rx Pending
 ************************************************************************************/

module uart_mmio #(
    parameter integer CLK_FREQ = 100_000_000,
    parameter integer BAUD_RATE = 115200
) (
    input wire i_clk,
    input wire i_rst,
    input wire i_sel,           // IO selection
    input wire i_we,            // IO write enable
    input wire i_re,            // IO read enable
    input wire [1:0] i_addr,    // Address used to identify the peripheral register
    input wire [15:0] i_wdata,  // Data to Write
    output wire [15:0] o_rdata, // Data Read
    output wire o_rdy,          // Feadback peripheral ready
    input wire i_rx_in,         // UART - Receive
    output wire o_tx_out,       // UART - Transmit
    output wire o_irq_req       // UART - Interrupt Request
);

/*************************************************************************************
 * SECTION 1. DECLARE/DEFINE Variables/Registers/Wires
 ************************************************************************************/

/****************************************************************************
 * 1.1 DEFINE SFRs - MMIO REGISTERS' ADDRESSES  (LS nibble)
 ***************************************************************************/
    localparam [1:0] SBUF = 2'b00;
    localparam [1:0] STATUS = 2'b01;

/****************************************************************************
 * 1.2 DECLARE SFRs -  MMIO REGISTERS
 ***************************************************************************/
    // SBUF
    reg [7:0] _tx_data;
    reg [7:0] _rx_data;

    // STATUS
    wire _tx_busy;
    reg _rx_pending;

/****************************************************************************
 * 1.3 DECLARE WIRES / REGS
 ***************************************************************************/
    reg [15:0] _rdata;
    reg _tx_start;
    wire [7:0] _rx_data_wire;
    wire _rx_valid;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/****************************************************************************
 * 2.1 UART RX/TX Instances
 ***************************************************************************/
    assign o_rdy = i_sel;
    assign o_irq_req = _rx_pending;

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_tx (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(_tx_data),
        .i_tx_start(_tx_start),
        .o_tx_out(o_tx_out),
        .o_tx_done(),
        .o_tx_busy(_tx_busy),
        .o_state_debug()
    );

    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_rx (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_rx_in(i_rx_in),
        .o_data(_rx_data_wire),
        .o_data_valid(_rx_valid),
        .o_rx_out(),
        .o_rx_busy(),
        .o_state_debug()
    );

/****************************************************************************
 * 2.2 MMIO Side Effects
 ***************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _tx_data <= 8'h00;
            _tx_start <= 1'b0;
            _rx_data <= 8'h00;
            _rx_pending <= 1'b0;
        end else begin
            _tx_start <= 1'b0;

            if (_rx_valid) begin
                _rx_data <= _rx_data_wire;
                _rx_pending <= 1'b1;
            end

            // Write to UART SFRs
            if (i_sel && i_we) begin
                case (i_addr)
                    SBUF: begin
                        if (!_tx_busy) begin
                            _tx_data <= i_wdata[7:0];
                            _tx_start <= 1'b1;
                        end
                    end
                    STATUS: begin
                        if (i_wdata[1]) begin
                            _rx_pending <= 1'b0;
                        end
                    end
                    default: ;
                endcase
            end

            if (i_sel && i_re && (i_addr == SBUF)) begin
                _rx_pending <= 1'b0;    // Clear _rx_pending by HW
            end
        end
    end

/****************************************************************************
 * 2.3 MMIO Readback
 ***************************************************************************/
    always @(*) begin
        if (!i_sel || !i_re) begin
            _rdata = 16'h0000;
        end else begin
            case (i_addr)
                SBUF: _rdata = {8'h00, _rx_data};
                STATUS: _rdata = {14'b0, _rx_pending, _tx_busy};
                default: _rdata = 16'h0000;
            endcase
        end
    end

    assign o_rdata = _rdata;

endmodule
