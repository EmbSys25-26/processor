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
    input wire        i_mode_switch,
    //input wire [7:0]  i_ascii_code,    // ASCII do PS/2 ou TB
    //input wire        i_ascii_valid,   // pulso 1 ciclo por carácter
    inout  [14:0] io_DDR_addr,
    inout  [2:0]  io_DDR_ba,
    inout         io_DDR_cas_n,
    inout         io_DDR_ck_n,
    inout         io_DDR_ck_p,
    inout         io_DDR_cke,
    inout         io_DDR_cs_n,
    inout  [3:0]  io_DDR_dm,
    inout  [31:0] io_DDR_dq,
    inout  [3:0]  io_DDR_dqs_n,
    inout  [3:0]  io_DDR_dqs_p,
    inout         io_DDR_odt,
    inout         io_DDR_ras_n,
    inout         io_DDR_reset_n,
    inout         io_DDR_we_n,
    inout         io_FIXED_IO_ddr_vrn,
    inout         io_FIXED_IO_ddr_vrp,
    inout  [53:0] io_FIXED_IO_mio,
    inout         io_FIXED_IO_ps_clk,
    inout         io_FIXED_IO_ps_porb,
    inout         io_FIXED_IO_ps_srstb,
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
    reg        _m_written;
    reg        _m_write_pending; 

/*************************************************************************************
 * SECÇÃO 2 - WIRES / REGS INTERNOS
 ************************************************************************************/

    reg  [15:0] _rdata;
    wire        _endLine;
    wire [1:0]  _hsync_state_debug;
    wire [2:0]  _vsync_state_debug;
    
    wire _enVGA_sync;
    wire _rst_sync_vga;
    wire _vactive;
    wire _flush;
    
    // Sinais AXI-Stream
    (* mark_debug = "true" *)  wire [15:0] _axis_tdata;    
    (* mark_debug = "true" *)  wire        _axis_tvalid;   
    (* mark_debug = "true" *) wire        _axis_tready; 
    (* mark_debug = "true" *) wire        _axis_tuser; 
    (* mark_debug = "true" *)  wire        _axis_tlast;  

    wire _clk_pixel;   // 25 MHz from wrapper

    // Contadores vindos do hsync/vsync
    wire [9:0] _pixelCounter;
    wire [8:0] _lineCounter;
    
    wire [`VGA_CHANNEL_SIZE:0] img_red, img_green, img_blue;

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
    
    assign o_rdy = i_sel;
    assign o_rdata = _rdata;
     
    vga_system_wrapper u_system (
        // DDR3
        .DDR_addr           (io_DDR_addr),
        .DDR_ba             (io_DDR_ba),
        .DDR_cas_n          (io_DDR_cas_n),
        .DDR_ck_n           (io_DDR_ck_n),
        .DDR_ck_p           (io_DDR_ck_p),
        .DDR_cke            (io_DDR_cke),
        .DDR_cs_n           (io_DDR_cs_n),
        .DDR_dm             (io_DDR_dm),
        .DDR_dq             (io_DDR_dq),
        .DDR_dqs_n          (io_DDR_dqs_n),
        .DDR_dqs_p          (io_DDR_dqs_p),
        .DDR_odt            (io_DDR_odt),
        .DDR_ras_n          (io_DDR_ras_n),
        .DDR_reset_n        (io_DDR_reset_n),
        .DDR_we_n           (io_DDR_we_n),
        .FIXED_IO_ddr_vrn   (io_FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp   (io_FIXED_IO_ddr_vrp),
        .FIXED_IO_mio       (io_FIXED_IO_mio),
        .FIXED_IO_ps_clk    (io_FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb   (io_FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb  (io_FIXED_IO_ps_srstb),
        .M_AXIS_MM2S_0_tdata  (_axis_tdata),
        .M_AXIS_MM2S_0_tvalid (_axis_tvalid),
        .M_AXIS_MM2S_0_tready (_axis_tready),   // controlled by m_hsync_vga
        .M_AXIS_MM2S_0_tuser  (_axis_tuser),
        .M_AXIS_MM2S_0_tlast  (_axis_tlast),
        .clk_pixel_0          (_clk_pixel),
        .sys_clock            (i_clkSystem)
    );

    m_hsync_vga hsync_module (
        .i_clk (_clk_pixel),
        .i_rst (_rst_sync_vga),
        .i_enVGA (_enVGA_sync),
        .i_mode_switch (i_mode_switch),
        .i_imgData     (5'b10000),        // fundo branco, letra preta
        .i_pixel_activo(_pixel_activo),
        .o_pixelCounter(_pixelCounter),
        .i_axis_tdata (_axis_tdata),
        .i_axis_tvalid (_axis_tvalid),
        .i_axis_tuser (_axis_tuser),
        .i_axis_tlast (_axis_tlast),
        .o_axis_tready (_axis_tready),
        .o_vga_red(o_vga_red),
        .o_vga_green(o_vga_green),
        .o_vga_blue(o_vga_blue),
        .o_endLine(_endLine),
        .o_hsync(o_hsync),
        .o_state_debug(_hsync_state_debug),
        .i_vactive(_vactive),
        .i_flush(_flush)
     );
     
     m_vsync_vga vsync_module (
        .i_clk (_clk_pixel),
        .i_rst (_rst_sync_vga),
        .i_enVGA (_enVGA_sync),
        .i_mode_switch (i_mode_switch),
        .o_lineCounter (_lineCounter), 
        .i_endLine(_endLine),
        .i_axis_tvalid(_axis_tvalid),
        .i_axis_tuser(_axis_tuser),
        .o_vsync(o_vsync),
        .o_state_debug(_vsync_state_debug),
        .o_vactive(_vactive),
        .o_flush(_flush)
     );
     
     /*ila_0 ila (
        .clk(_clk_pixel),
        .probe0(o_hsync),
        .probe1(o_vsync),
        .probe2(_axis_tvalid),
        .probe3(_endLine),
        .probe4(_axis_tlast)
     );*/
     
/*************************************************************************************
 * SECÇÃO 4 - CDC (Clock Domain Crossing)
 * Double-flop para passar sinais de clkSystem para clkVGA com segurança.
 * A BRAM trata o seu próprio CDC internamente.
 ************************************************************************************/
    xpm_cdc_async_rst #(
        .DEST_SYNC_FF    (2),  
        .INIT_SYNC_FF    (1),  
        .RST_ACTIVE_HIGH (1)   
     ) u_rst_cdc (
        .src_arst  (i_rst),         
        .dest_clk  (_clk_pixel),   
        .dest_arst (_rst_sync_vga)  
     );
          
    xpm_cdc_single #(
        .DEST_SYNC_FF   (2),  
        .INIT_SYNC_FF   (1),  
        .SIM_ASSERT_CHK (0),  
        .SRC_INPUT_REG  (1)   
    ) u_enVGA_cdc (
        .src_clk  (i_clkSystem),   
        .src_in   (_enVGA),        
        .dest_clk (_clk_pixel),    
        .dest_out (_enVGA_sync)    
    );
    
    always @ (posedge i_clkSystem) begin
        if (i_rst) begin
            _enVGA <= 1'b0;
            _auto_inc <= 1'b0;
            _char_addr      <= 12'd0;
            _char_waddr     <= 12'd0;
            _char_we        <= 1'b0;
            _char_wdata     <= 8'd0;
            _m_written      <= 1'b0;
            _m_write_pending <= 1'b1;  
        end
        else begin
            _char_we <= 1'b0; 

            if (_m_write_pending) begin
                _m_write_pending <= 1'b0; 
            end
            else if (!_m_written) begin
                _char_wdata <= 8'd109;   // 'm' ASCII
                _char_waddr <= 12'd1159;
                _char_we    <= 1'b1;
                _char_addr  <= 12'd1;
                _m_written  <= 1'b1;
            end
            else if (i_we && i_sel) begin
                case (i_addr)
                CNTRL: begin
                    _enVGA <= i_wdata[0];
                    _auto_inc <= i_wdata[1];
                end
                endcase
            end
        end      
     end
 
     always @ (*) begin
        if (i_rst || !i_sel || !i_re)
            _rdata = 16'h0000;
        else begin
            case (i_addr) 
                CNTRL: _rdata = {14'b0, _auto_inc, _enVGA};
                default: _rdata =  16'h0000;
            endcase
        end
     end
    endmodule