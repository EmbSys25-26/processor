`timescale 1ns / 1ps

module uart_mmio #(
    parameter integer CLK_FREQ = 100_000_000,
    parameter integer BAUD_RATE = 115200
) (
    input wire i_clk,
    input wire i_rst,
    input wire i_sel,
    input wire i_we,
    input wire i_re,
    input wire [1:0] i_addr,
    input wire [15:0] i_wdata,
    output wire [15:0] o_rdata,
    output wire o_rdy,
    input wire i_rx_in,
    output wire o_tx_out,
    output wire o_irq_req
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg [15:0] _rdata;

    reg [7:0] _tx_data;
    reg _tx_start;
    wire _tx_busy;

    wire [7:0] _rx_data_wire;
    reg [7:0] _rx_data;
    reg _rx_pending;
    wire _rx_valid;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 UART RX/TX Instances
 ************************************************************************************/
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
        .o_rx_done(),
        .o_rx_busy(),
        .o_state_debug()
    );

/*************************************************************************************
 * 2.2 MMIO Side Effects
 ************************************************************************************/
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

            if (i_sel && i_we) begin
                case (i_addr)
                    2'b00: begin
                        if (!_tx_busy) begin
                            _tx_data <= i_wdata[7:0];
                            _tx_start <= 1'b1;
                        end
                    end
                    2'b01: begin
                        if (i_wdata[1]) begin
                            _rx_pending <= 1'b0;
                        end
                    end
                    default: ;
                endcase
            end

            if (i_sel && i_re && (i_addr == 2'b00)) begin
                _rx_pending <= 1'b0;
            end
        end
    end

/*************************************************************************************
 * 2.3 Readback
 ************************************************************************************/
    always @(*) begin
        if (!i_sel || !i_re) begin
            _rdata = 16'h0000;
        end else begin
            case (i_addr)
                2'b00: _rdata = {8'h00, _rx_data};
                2'b01: _rdata = {14'b0, _rx_pending, _tx_busy};
                default: _rdata = 16'h0000;
            endcase
        end
    end

    assign o_rdata = _rdata;

endmodule
