`timescale 1ns / 1ps
`include "constants.vh"

/*************************************************************************************
 * m_vga_mmio.v
 *
 * O QUE FAZ:
 *   Periférico VGA com interface MMIO. Gera sinais VGA 640x480 @ 60Hz com suporte
 *   a modo texto (80x30 caracteres, font 8x16) e modos de cor sólida.
 *
 * REGISTOS MMIO (i_addr [1:0]):
 *   0x0  CNTRL     bit0=enVGA, bit1=auto_inc
 *   0x1  VGASEL    bit4=SrcChar, bit3..0=SrcImg3..0
 *
 * ESCRITA NO CHAR_BUFFER:
 *   PS/2: i_ascii_code + i_ascii_valid (pulso 1 ciclo) → escreve em _char_addr
 *
 * PIPELINE DE LEITURA (domínio clkVGA):
 *   O pixelCounter e lineCounter geram char_idx com lookahead +1.
 *   BRAM tem 1 ciclo de latência → ascii disponível no ciclo certo.
 *   font_rom usa .spo (assíncrono, 0 ciclos) → pixel_activo imediato.
 *   RGB é registado no hsync_module → pixel correcto em cada ciclo.
 *
 * CDC:
 *   _imgData e _enVGA: double-flop (clkSystem → clkVGA)
 *   char_buffer: BRAM dual-port (CDC nativa, sem sincronizadores extras)
 ************************************************************************************/

module m_vga_mmio(
    input wire        i_clkSystem,
    input wire        i_clkVGA,
    input wire        i_rst,
    input wire        i_sel,
    input wire        i_we,
    input wire        i_re,
    input wire [1:0]  i_addr,          // 2 bits: 4 registos MMIO
    input wire [15:0] i_wdata,
    //input wire [7:0]  i_ascii_code,    // ASCII do PS/2 ou TB
    //input wire        i_ascii_valid,   // pulso 1 ciclo por carácter
    output wire [15:0] o_rdata,
    output wire        o_rdy,
    output wire [`VGA_CHANNEL_SIZE:0] o_vga_red,
    output wire [`VGA_CHANNEL_SIZE:0] o_vga_green,
    output wire [`VGA_CHANNEL_SIZE:0] o_vga_blue,
    output wire o_hsync,
    output wire o_vsync
);

/*************************************************************************************
 * SECÇÃO 1 - ENDEREÇOS E REGISTOS MMIO
 ************************************************************************************/

    localparam CNTRL     = 2'b00;
    localparam VGASEL    = 2'b01;


    // CNTRL
    reg _enVGA;
    reg _auto_inc;

    // VGASEL - imagens e modo caracteres 
    reg _SrcImg0, _SrcImg1, _SrcImg2, _SrcImg3, _SrcChar;

    // CHAR_BUFFER - lado escrita (clkSystem)
    // _char_addr  : cursor lógico (onde o PRÓXIMO carácter vai ser escrito)
    // _char_waddr : endereço capturado ANTES do auto-inc → endereço real da BRAM
    // Porquê separados: _char_we é registado (1 ciclo de delay), então quando
    // a BRAM escreve, _char_addr já foi incrementado. _char_waddr captura o
    // valor correcto no mesmo ciclo que o pulso valid chega.
    reg [11:0] _char_addr;
    reg [11:0] _char_waddr;
    reg [7:0]  _char_wdata;
    reg        _char_we;

/*************************************************************************************
 * SECÇÃO 2 - WIRES / REGS INTERNOS
 ************************************************************************************/

    reg  [15:0] _rdata;
    wire        _endLine;
    wire [1:0]  _hsync_state_debug;
    wire [1:0]  _vsync_state_debug;

    // CDC double-flop: clkSystem → clkVGA
    reg [4:0] _imgData_meta, _imgData_sync;
    wire [4:0] _imgData_sys = {_SrcChar, _SrcImg3, _SrcImg2, _SrcImg1, _SrcImg0};
    reg _enVGA_meta, _enVGA_sync;
    reg _rst_meta, _rst_sync_vga;

    // Contadores vindos do hsync/vsync
    wire [9:0] _pixelCounter;
    wire [8:0] _lineCounter;

    // Sinais do pipeline (domínio clkVGA)
    wire [7:0] _char_ascii;              // saída da BRAM Porta B (1 ciclo latência)
    wire [3:0] _char_row = _lineCounter[3:0];   // linha dentro do char (0-15)
    wire [2:0] _char_col = _pixelCounter[2:0];  // coluna dentro do char (0-7)
    // Versões registadas para alinhar com a latência de 1 ciclo da BRAM
    reg [3:0] _char_row_r;
    always @(posedge i_clkVGA) _char_row_r <= _char_row;
    wire [7:0] _font_data;
    // O lookahead pede o char do pixel P+1, então _font_data no ciclo P+1 é correcto.
    // Mas _char_col = _pixelCounter[2:0] também avança no ciclo P+1.
    // Registamos _char_col 1 ciclo para alinhar com a saída da BRAM.
    reg [2:0] _char_col_r;
    always @(posedge i_clkVGA) _char_col_r <= _char_col;
    wire _pixel_activo = _font_data[~_char_col_r];
    
    // para nao ter delay de pixeis faz se um lookahead ( tambem ia ser so 1 pixel)

    // LOOKAHEAD +1 com correcção de wrap de linha
    // Porquê +1: BRAM tem 1 ciclo de latência. Pedimos o char do pixel P+1
    // no ciclo P para que esteja disponível no ciclo P+1 (0 atraso na font_rom).
    // Porquê wrap: quando pixelCounter = 639, _pix_la = 640 que pertence à
    // linha seguinte, col 0. Sem correcção, col_la seria 640>>3=80 (errado)
    // e row_la não avançava.
    wire [9:0]  _pix_la    = _pixelCounter + 10'd1;
    wire        _wrap_line = (_pix_la >= 10'd640);
    wire [6:0]  _col_la    = _wrap_line ? 7'd0 : _pix_la[9:3];
    wire [4:0]  _row_la    = _wrap_line ? (_lineCounter[8:4] + 5'd1)
                                        :  _lineCounter[8:4];
    // ×80 sem multiplicador: 80 = 64 + 16 = (1<<6) + (1<<4)
    wire [11:0] _char_idx_la = ({7'b0, _row_la} << 6)
                             + ({7'b0, _row_la} << 4)
                             + {5'b0, _col_la};

/*************************************************************************************
 * SECÇÃO 3 - INSTÂNCIAS DE MÓDULOS
 ************************************************************************************/

//Este char_buffer_bram é onde se guarda o que esta dentro de cada secção de 8*16

    // BRAM Simple Dual Port (IP Vivado - Block Memory Generator)
    // Configuração do IP:
    //   Memory Type      : Simple Dual Port RAM
    //   Port A Width     : 8,  Depth: 4096  (escrita, clkSystem)
    //   Port B Width     : 8,  Depth: 4096  (leitura, clkVGA)
    //   Primitives Output Register : NÃO (latência = 1 ciclo, controlada aqui)
    //   Init File        : char_buffer_init.coe (2400x 0x20 = espaço)
    char_buffer_bram u_char_buf (
        .clka  (i_clkSystem),
        .wea   (_char_we),
        .addra (_char_waddr),    // endereço capturado antes do auto-inc
        .dina  (_char_wdata),
        .clkb  (i_clkVGA),
        .addrb (_char_idx_la),   // lookahead +1 com wrap corrigido
        .doutb (_char_ascii)     // ascii do char actual → font_rom
    );

    // Font ROM - Distributed Memory (assíncrona, .spo = 0 ciclos latência)
    // Endereço: {ascii[7:0], row[3:0]} = 12 bits → 4096 posições × 8 bits
    font_rom font_lut (
        .a   ({_char_ascii, _char_row_r}),
        .spo (_font_data)
    );

    m_hsync_vga hsync_module (
        .i_clk          (i_clkVGA),
        .i_rst          (_rst_sync_vga),
        .i_enVGA        (_enVGA_sync),
        .i_imgData      (_imgData_sync),
        .i_pixel_activo (_pixel_activo),
        .o_pixelCounter (_pixelCounter),
        .o_endLine      (_endLine),
        .o_vga_red      (o_vga_red),
        .o_vga_green    (o_vga_green),
        .o_vga_blue     (o_vga_blue),
        .o_hsync        (o_hsync),
        .o_state_debug  (_hsync_state_debug)
    );

    m_vsync_vga vsync_module (
        .i_clk          (i_clkVGA),
        .i_rst          (_rst_sync_vga),
        .i_enVGA        (_enVGA_sync),
        .i_endLine      (_endLine),
        .o_lineCounter  (_lineCounter),
        .o_vsync        (o_vsync),
        .o_state_debug  (_vsync_state_debug)
    );

/*************************************************************************************
 * SECÇÃO 4 - CDC (Clock Domain Crossing)
 * Double-flop para passar sinais de clkSystem para clkVGA com segurança.
 * A BRAM trata o seu próprio CDC internamente.
 ************************************************************************************/

    always @(posedge i_clkVGA) begin
        if (i_rst) begin
            _rst_meta     <= 1'b1;
            _rst_sync_vga <= 1'b1;
        end else begin
            _rst_meta     <= 1'b0;
            _rst_sync_vga <= _rst_meta;
        end
    end

    always @(posedge i_clkVGA) begin
        if (_rst_sync_vga) begin
            _imgData_meta <= 5'b0;
            _imgData_sync <= 5'b0;
        end else begin
            _imgData_meta <= _imgData_sys;
            _imgData_sync <= _imgData_meta;
        end
    end

    always @(posedge i_clkVGA) begin
        if (_rst_sync_vga) begin
            _enVGA_meta <= 1'b0;
            _enVGA_sync <= 1'b0;
        end else begin
            _enVGA_meta <= _enVGA;
            _enVGA_sync <= _enVGA_meta;
        end
    end
    
    reg _m_written;
    reg _m_write_pending;  
    
/*************************************************************************************
 * SECÇÃO 5 - ESCRITA NOS REGISTOS (domínio clkSystem)
 *
 * PS/2 escreve em _char_addr com auto-inc se activo.
 *
 * TIMING da escrita na BRAM:
 *   Ciclo N:   i_ascii_valid=1 → _char_we<=1, _char_waddr<=addr, _char_addr<=addr+1
 *   Ciclo N+1: _char_we=1, _char_waddr=addr (old) → BRAM escreve em addr ✓
 *              _char_addr=addr+1 (já incrementado, não afecta _char_waddr)
 ************************************************************************************/


    always @(posedge i_clkSystem) begin
        if (i_rst) begin
            _enVGA          <= 1'b0;
            _auto_inc       <= 1'b0;
            _SrcImg0        <= 1'b0;
            _SrcImg1        <= 1'b0;
            _SrcImg2        <= 1'b0;
            _SrcImg3        <= 1'b0;
            _SrcChar        <= 1'b0;
            _char_addr      <= 12'd0;
            _char_waddr     <= 12'd0;
            _char_we        <= 1'b0;
            _char_wdata     <= 8'd0;
            _m_written      <= 1'b0;
            _m_write_pending <= 1'b1;  
        end
        else begin
            _char_we <= 1'b0;   // default: sem escrita

            // --- Escrita hardwired do 'm': espera 1 ciclo após reset ---
            if (_m_write_pending) begin
                _m_write_pending <= 1'b0;  // limpa o pending
                // ainda não escreve, só prepara
            end
            else if (!_m_written) begin
                _char_wdata <= 8'd109;   // 'm' ASCII
                _char_waddr <= 12'd1159;
                _char_we    <= 1'b1;
                _char_addr  <= 12'd1;
                _m_written  <= 1'b1;
            end

            // --- Fonte 2: CPU via MMIO
            else if (i_we && i_sel) begin
                case (i_addr)
                    CNTRL: begin
                        _enVGA    <= i_wdata[0];  // bit 0: liga/desliga VGA
                        _auto_inc <= i_wdata[1];  // bit 1: cursor auto-avança
                    end
                    VGASEL: begin
                        _SrcImg0 <= i_wdata[0];
                        _SrcImg1 <= i_wdata[1];
                        _SrcImg2 <= i_wdata[2];
                        _SrcImg3 <= i_wdata[3];
                        _SrcChar <= i_wdata[4];
                    end
                endcase
            end
        end
    end

/*************************************************************************************
 * SECÇÃO 6 - READBACK MUX
 ************************************************************************************/

    assign o_rdy   = i_sel;
    assign o_rdata = _rdata;

    always @(*) begin
        if (i_rst || !i_sel || !i_re)
            _rdata = 16'h0000;
        else begin
            case (i_addr)
                CNTRL:     _rdata = {14'b0, _auto_inc, _enVGA};
                VGASEL:    _rdata = {11'b0, _SrcChar, _SrcImg3,
                                     _SrcImg2, _SrcImg1, _SrcImg0};
                default:   _rdata = 16'h0000;
            endcase
        end
    end

endmodule