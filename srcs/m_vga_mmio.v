`timescale 1ns / 1ps
`include "constants.vh"

/*************************************************************************************
 * m_vga_mmio.v
 *
 * DESCRIPTION:
 * VGA peripheral with MMIO interface.
 * Generates VGA signals 640x480 @ 60Hz supporting
 * text mode (80x30 characters, 8x16 font) and solid color modes.
 *
 * MMIO REGISTERS (i_addr [1:0]):
 * 0x0  CNTRL     bit0=enVGA, bit1=auto_inc
 * 0x1  VGASEL    bit4=SrcChar, bit3..0=SrcImg3..0
 * 0x2  Char_Reg
 *
 * WRITING TO CHAR_BUFFER:
 * PS/2: i_ascii_code + i_ascii_valid (1-cycle pulse) -> writes to _char_addr
 *
 * READ PIPELINE (clkVGA domain):
 * The pixelCounter and lineCounter generate char_idx with a +1 lookahead.
 * BRAM has 1 cycle latency -> ascii available in the correct cycle.
 * font_rom uses .spo (asynchronous, 0 cycles) -> immediate active_pixel.
 * RGB is registered in the hsync_module -> correct pixel in every cycle.
 *
 * CDC:
 * _imgData and _enVGA: double-flop (clkSystem -> clkVGA)
 * char_buffer: dual-port BRAM (native CDC, no extra synchronizers needed)
 ************************************************************************************/

module m_vga_mmio(
    input wire        i_clkSystem,
    input wire        i_clkVGA,
    input wire        i_rst,
    input wire        i_sel,
    input wire        i_we,
    input wire        i_re,
    input wire [1:0]  i_addr,          // 2 bits: 4 MMIO registers
    input wire [15:0] i_wdata,
        input wire        i_mode_switch,   // Switch 1
        input wire        i_img_switch,    // Switch 0 
    input wire [7:0]  i_ascii_code,    // ASCII from PS/2 or TB
    input wire        i_ascii_valid,   // 1-cycle pulse per character
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
 * SECTION 1 - ADDRESSES AND MMIO REGISTERS
 ************************************************************************************/

    localparam CNTRL     = 2'b00;
    localparam VGASEL    = 2'b01;
    localparam CHAR_REG  = 2'b10;
    // <-- NEW: Register for the CPU to write text (Offset 0x04)


    // CNTRL
    reg _enVGA;
    reg _auto_inc;
    reg _mode_switch_reg;

    // CHAR_BUFFER - write side (clkSystem)
    // _char_addr  : logical cursor (where the NEXT character will be written)
    // _char_waddr : address captured BEFORE auto-inc -> actual BRAM address
    // Why separate: _char_we is registered (1-cycle delay), so when
    // the BRAM writes, _char_addr has already been incremented.
    // _char_waddr captures the correct value in the exact cycle the valid pulse arrives.
        reg [6:0] _cursor_x; // 0 to 79
        reg [4:0] _cursor_y; // 0 to 29
        reg [11:0] _char_waddr;
        reg [7:0]  _char_wdata;
        reg        _char_we;
        
        wire [11:0] _char_addr_calc = ({7'b0, _cursor_y} << 6) + ({7'b0, _cursor_y} << 4) + {5'b0, _cursor_x};

/*************************************************************************************
 * SECTION 2 - INTERNAL WIRES / REGS
 ************************************************************************************/

    reg  [15:0] _rdata;
    wire        _endLine;
    wire [1:0]  _hsync_state_debug;
    wire [2:0]  _vsync_state_debug;
    
    wire _enVGA_sync;
    wire _rst_sync_vga;
    wire _vactive;
    wire _flush;
    
    // AXI-Stream signals
    (* mark_debug = "true" *)  wire [15:0] _axis_tdata;
    (* mark_debug = "true" *)  wire        _axis_tvalid;
    (* mark_debug = "true" *)  wire        _axis_tready;
    (* mark_debug = "true" *)  wire        _axis_tuser;
    (* mark_debug = "true" *)  wire        _axis_tlast;

    // Counters from hsync/vsync
    wire [9:0] _pixelCounter;
    wire [8:0] _lineCounter;
    
    wire [`VGA_CHANNEL_SIZE:0] img_red, img_green, img_blue;

    // Pipeline signals (clkVGA domain)
    wire [7:0] _char_ascii;       // BRAM Port B output (1-cycle latency)
    wire [3:0] _char_row = _lineCounter[3:0]; // line inside the char (0-15)
    wire [2:0] _char_col = _pixelCounter[2:0]; // column inside the char (0-7)

    // Registered versions to align with the 1-cycle BRAM latency
    reg [3:0] _char_row_r;
    always @(posedge i_clkVGA) _char_row_r <= _char_row;

    wire [7:0] _font_data;
    wire _pixel_activo = _font_data[~_char_col]; // NO _r!
    reg [6:0] _cursor_col;

    // A lookahead is used to prevent pixel delay (it would only be a 1-pixel delay anyway)

    // LOOKAHEAD +1 with line wrap correction
    // Why +1: BRAM has 1 cycle latency.
    // We request the char for pixel P+1 during cycle P so it is available in cycle P+1 (0 delay in font_rom).
    // Why wrap: when pixelCounter = 639, _pix_la = 640 which belongs to the next line, col 0. 
    // Without correction, col_la would be 640>>3=80 (wrong) and row_la would not advance.
    
    // 1 = VISIBLE state in your hsync FSM
    wire _is_visible = (_hsync_state_debug == 2'b11);

    // If visible, lookahead 1 pixel. If in a porch/sync (blanking), 
    // constantly pre-fetch pixel 0 so the first character is ready!
    wire [9:0] _pix_la = _is_visible ? (_pixelCounter + 10'd1) : 10'd0;
    
    wire [6:0] _col_la = _pix_la[9:3];
    wire [4:0] _row_la = _lineCounter[8:4];
    
    wire [11:0] _char_idx_la = ({7'b0, _row_la} << 6) + ({7'b0, _row_la} << 4) + {5'b0, _col_la};

/*************************************************************************************
 * SECTION 3 - MODULE INSTANTIATIONS
 ************************************************************************************/

    // This char_buffer_bram is where the content of each 8x16 block is stored

    // BRAM Simple Dual Port (Vivado IP - Block Memory Generator)
    // IP Configuration:
    //   Memory Type      : Simple Dual Port RAM
    //   Port A Width     : 8,  Depth: 4096  (write, clkSystem)
    //   Port B Width     : 8,  Depth: 4096  (read, clkVGA)
    //   Primitives Output Register : NO (latency = 1 cycle, controlled here)
    //   Init File        : char_buffer_init.coe (2400x 0x20 = space)
    char_buffer_bram u_char_buf (
        .clka  (i_clkSystem),
        .wea   (_char_we),
        .addra (_char_waddr),    // address captured before auto-inc
        .dina  (_char_wdata),
    
        .clkb  (i_clkVGA),
        .addrb (_char_idx_la),   // lookahead +1 with corrected wrap
        .doutb (_char_ascii)     // ascii of current char -> font_rom
    );

    // Font ROM - Distributed Memory (asynchronous, .spo = 0 cycles latency)
    // Address: {ascii[7:0], row[3:0]} = 12 bits -> 4096 positions x 8 bits
    font_rom font_lut (
        .a   ({_char_ascii, _char_row}),
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
        .i_sw_gpio    ({i_mode_switch, i_img_switch}),
        .clk_pixel_0          (),
        .sys_clock            (i_clkVGA)
    );

    m_hsync_vga hsync_module (
        .i_clk (i_clkVGA),
        .i_rst (_rst_sync_vga),
        .i_enVGA (_enVGA_sync),
        .i_mode_switch (_mode_switch_sync),
        .i_imgData     (5'b01110),        // white background, black text
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
        .i_clk (i_clkVGA),
        .i_rst (_rst_sync_vga),
        .i_enVGA (_enVGA_sync),
        .i_mode_switch (_mode_switch_sync),
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
        .clk(i_clkVGA),
        .probe0(o_hsync),
        .probe1(o_vsync),
        .probe2(_axis_tvalid),
        .probe3(_endLine),
        .probe4(_axis_tlast)
     );*/
     
/*************************************************************************************
 * SECTION 4 - CDC (Clock Domain Crossing)
 * Double-flop to safely pass signals from clkSystem to clkVGA.
 * BRAM handles its own CDC internally.
 ************************************************************************************/
    xpm_cdc_async_rst #(
        .DEST_SYNC_FF    (2),  
        .INIT_SYNC_FF    (1),  
        .RST_ACTIVE_HIGH (1)   
     ) u_rst_cdc (
        .src_arst  (i_rst),         
        .dest_clk  (i_clkVGA),   
       
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
        .dest_clk (i_clkVGA),  
  
        .dest_out (_enVGA_sync)    
    );

    wire _mode_switch_sync;
    wire _combined_mode =  (i_img_switch & i_mode_switch) ;//| _mode_switch_reg;
    
        xpm_cdc_single #(
            .DEST_SYNC_FF   (2),
            .INIT_SYNC_FF   (1),
            .SIM_ASSERT_CHK (0),
            .SRC_INPUT_REG  (1)
        ) u_mode_cdc (
            .src_clk  (i_clkSystem),
          
            .src_in   (_combined_mode),
            .dest_clk (i_clkVGA),
            .dest_out (_mode_switch_sync)
        );

    wire _cpu_char_write = (i_we && i_sel && (i_addr == CHAR_REG));
    wire [7:0] _char_to_write = _cpu_char_write ? i_wdata[7:0] : i_ascii_code;

    wire _do_char_write = i_ascii_valid || _cpu_char_write;
    
        always @ (posedge i_clkSystem) begin
            if (i_rst) begin
                _enVGA <= 1'b0;
                _auto_inc <= 1'b0;
                _char_waddr     <= 12'd0;
                _char_we        <= 1'b0;
                _char_wdata     <= 8'd0;
                _mode_switch_reg <= 1'b0; 
                _cursor_x <= 7'd0;
                _cursor_y <= 5'd0;
            end
            
            else begin
                _char_we <= 1'b0;
            // --- Register 0x00: MMIO Configuration ---
            if (i_we && i_sel && i_addr == CNTRL) begin
                _enVGA <= i_wdata[0];
                _auto_inc <= i_wdata[1];
            end
            if (i_we && i_sel && i_addr == VGASEL) begin
                _mode_switch_reg <= i_wdata[4];
                // bit4 = text(1) / image(0)
            end
            
            // --- Register 0x04: Character Write (PS/2 or CPU) ---
            if (_do_char_write) begin
                // 1. ENTER (0x0D)
                if (_char_to_write == 8'h0D) begin
                    _char_we <= 1'b0;
                    if (_auto_inc) begin
                        _cursor_x <= 7'd0;
                        // Instantly snap to the left margin
                        _cursor_y <= (_cursor_y == 5'd29) ?
                        5'd0 : _cursor_y + 5'd1; // Go down 1 line
                    end
                end
                // 2. BACKSPACE (0x08)
                else if (_char_to_write == 8'h08) begin
               
                    _char_waddr <= _char_addr_calc - 12'd1;
                    // Target previous char
                    _char_wdata <= 8'h20;
                    // Write a space over it
                    _char_we    <= 1'b1;
                    if (_auto_inc) begin
                        if (_cursor_x > 0) 
                            _cursor_x <= _cursor_x - 7'd1;
                        else if (_cursor_y > 0) begin 
                            _cursor_x <= 7'd79;
                            _cursor_y <= _cursor_y - 5'd1; 
                        end
                    end
                end
                // 3. NORMAL CHARACTER
                else begin
                    _char_waddr <= _char_addr_calc;
                    _char_wdata <= _char_to_write;
                    _char_we    <= 1'b1;
                    if (_auto_inc) begin
                        if (_cursor_x == 7'd79) begin
                            _cursor_x <= 7'd0;
                            _cursor_y <= (_cursor_y == 5'd29) ? 5'd0 : _cursor_y + 5'd1;
                        end else begin
                            _cursor_x <= _cursor_x + 7'd1;
                        end
                    end
                end
            end 
        end
     end
 endmodule