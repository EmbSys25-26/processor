`timescale 1ns / 1ps
`include "constants.vh"

/*************************************************************************************
 * controller.v
 *
 * O QUE FAZ:
 *   Módulo temporário que simula o que o SoC/CPU fará quando integrado.
 *   Gera os relógios (via clk_wiz), sincroniza o reset, e executa uma FSM
 *   de arranque que configura o periférico VGA via MMIO.
 *
 * QUANDO INTEGRAR NO SoC:
 *   Este módulo desaparece. O barramento do CPU liga directamente ao m_vga_mmio.
 *   Os sinais _sel, _we, _re, _addr, _wdata passam a ser
 *   controlados pelo CPU. i_ascii_code e i_ascii_valid vêm do decoder PS/2.
 *
 * SEQUÊNCIA DE ARRANQUE DA FSM:
 *   1. S_IDLE         → prepara
 *   2. S_WRITE_VGASEL → escreve i_imgSel em VGASEL (addr=01)
 *   3. S_WAIT_VGASEL  → espera _rdy
 *   4. S_WRITE_CNTRL  → escreve 0x0003 em CNTRL (enVGA=1, auto_inc=1)
 *   5. S_WAIT_CNTRL   → espera _rdy
 *   6. S_DONE         → monitoriza mudanças em i_imgSel, re-escreve se necessário
 ************************************************************************************/

module controller(
    input        i_clk,
    input        i_rst,
    input  [4:0] i_imgSel,
    input  wire [7:0] i_ascii_code,
    input  wire       i_ascii_valid,   // pulso 1 ciclo por carácter (PS/2 ou TB)
    output wire [`VGA_CHANNEL_SIZE:0] o_vga_red,
    output wire [`VGA_CHANNEL_SIZE:0] o_vga_green,
    output wire [`VGA_CHANNEL_SIZE:0] o_vga_blue,
    output wire o_hsync,
    output wire o_vsync
);

/*************************************************************************************
 * CLOCKING WIZARD
 ************************************************************************************/

    wire _clkSystem;
    wire _clkVGA;
    wire _locked;

    clk_wiz_0 u_clk_wiz (
        .clk_in1  (i_clk),
        .clk_out1 (_clkSystem),
        .clk_out2 (_clkVGA),
        .reset    (i_rst),
        .locked   (_locked)
    );

    // Reset síncrono: mantém reset até o clk_wiz estar locked
    reg _rst_sync;
    always @(posedge _clkSystem or posedge i_rst) begin
        if (i_rst || ~_locked)
            _rst_sync <= 1'b1;
        else
            _rst_sync <= 1'b0;
    end

/*************************************************************************************
 * SINAIS MMIO
 ************************************************************************************/

    reg        _sel;
    reg        _we;
    reg        _re;
    reg [1:0]  _addr;    
    reg [15:0] _wdata;
    wire [15:0] _rdata;
    wire        _rdy;

/*************************************************************************************
 * INSTÂNCIA DO PERIFÉRICO VGA
 ************************************************************************************/

    m_vga_mmio periph_vga (
        .i_clkSystem  (_clkSystem),
        .i_clkVGA     (_clkVGA),
        .i_rst        (_rst_sync),
        .i_sel        (_sel),
        .i_we         (_we),
        .i_re         (_re),
        .i_addr       (_addr),          
        .i_wdata      (_wdata),
        .i_ascii_code (i_ascii_code),
        .i_ascii_valid(i_ascii_valid),  
        .o_rdata      (_rdata),
        .o_rdy        (_rdy),
        .o_vga_red    (o_vga_red),
        .o_vga_green  (o_vga_green),
        .o_vga_blue   (o_vga_blue),
        .o_hsync      (o_hsync),
        .o_vsync      (o_vsync)
    );

/*************************************************************************************
 * FSM DE ARRANQUE
 ************************************************************************************/

    localparam S_IDLE         = 3'd0;
    localparam S_WRITE_VGASEL = 3'd1;
    localparam S_WAIT_VGASEL  = 3'd2;
    localparam S_WRITE_CNTRL  = 3'd3;
    localparam S_WAIT_CNTRL   = 3'd4;
    localparam S_DONE         = 3'd5;

    reg [2:0] _state;
    reg [4:0] _imgSel_prev;

    always @(posedge _clkSystem) begin
        if (_rst_sync) begin
            _state       <= S_IDLE;
            _sel         <= 1'b0;
            _we          <= 1'b0;
            _re          <= 1'b0;
            _addr        <= 2'b00;      // FIXED: era 1'b0
            _wdata       <= 16'h0000;
            _imgSel_prev <= 5'b00000;
        end
        else begin
            case (_state)

                S_IDLE: begin
                    _sel         <= 1'b0;
                    _we          <= 1'b0;
                    _imgSel_prev <= i_imgSel;
                    _state       <= S_WRITE_VGASEL;
                end

                // Passo 1: escreve i_imgSel em VGASEL (addr=01)
                S_WRITE_VGASEL: begin
                    _sel   <= 1'b1;
                    _we    <= 1'b1;
                    _re    <= 1'b0;
                    _addr  <= 2'b01;                    // FIXED: era 1'b1
                    _wdata <= {11'b0, i_imgSel};
                    _state <= S_WAIT_VGASEL;
                end

                S_WAIT_VGASEL: begin
                    if (_rdy) begin
                        _sel   <= 1'b0;
                        _we    <= 1'b0;
                        _state <= S_WRITE_CNTRL;
                    end
                end

                // Passo 2: escreve 0x0003 em CNTRL (addr=00)
                // bit0 = enVGA = 1
                // bit1 = auto_inc = 1 (cursor avança automaticamente com PS/2/TB)
                S_WRITE_CNTRL: begin
                    _sel   <= 1'b1;
                    _we    <= 1'b1;
                    _re    <= 1'b0;
                    _addr  <= 2'b00;                    // FIXED: era 1'b0
                    _wdata <= 16'h0003;                 // enVGA=1, auto_inc=1
                    _state <= S_WAIT_CNTRL;
                end

                S_WAIT_CNTRL: begin
                    if (_rdy) begin
                        _sel         <= 1'b0;
                        _we          <= 1'b0;
                        _imgSel_prev <= i_imgSel;
                        _state       <= S_DONE;
                    end
                end

                // Passo 3: monitoriza mudanças em i_imgSel, re-escreve se necessário
                S_DONE: begin
                    if (i_imgSel != _imgSel_prev) begin
                        _imgSel_prev <= i_imgSel;
                        _sel         <= 1'b1;
                        _we          <= 1'b1;
                        _re          <= 1'b0;
                        _addr        <= 2'b01;          // VGASEL
                        _wdata       <= {11'b0, i_imgSel};
                    end
                    else begin
                        _sel <= 1'b0;
                        _we  <= 1'b0;
                    end
                end

            endcase
        end
    end

endmodule