`timescale 1ns / 1ps

`include "constants.vh"

module m_vga_mmio(
    input wire i_clkSystem,
    input wire i_clkVGA,
    input wire i_rst,
    input wire i_sel,
    input wire i_we,            // IO write enable
    input wire i_re,            // IO read enable
    input wire i_addr,          // Address used to identify the peripheral register
    input wire [15:0] i_wdata,
    output wire [15:0] o_rdata,
    output wire o_rdy,
    output wire [`VGA_CHANNEL_SIZE:0] o_vga_red,
    output wire [`VGA_CHANNEL_SIZE:0] o_vga_green,
    output wire [`VGA_CHANNEL_SIZE:0] o_vga_blue,
    output wire o_hsync,
    output wire o_vsync   
);

/*************************************************************************************
 * SECTION 1. DECLARE/DEFINE VARIABLES
 ************************************************************************************/

/****************************************************************************
 * 1.1 DEFINE SFRs - MMIO REGISTERS' ADDRESSES  (LS bit)
 ***************************************************************************/
     localparam CNTRL = 1'b0;
     localparam VGASEL = 1'b1;
 
/****************************************************************************
 * 1.2 DECLARE SFRs -  MMIO REGISTERS
 ***************************************************************************/
   // CNTRL Register
     reg _enVGA;
     
   // VGASEL Register
     reg _SrcImg0, _SrcImg1, _SrcImg2, _SrcImg3, _SrcChar;
 
/****************************************************************************
 * 1.3 DECLARE WIRES / REGS
 ***************************************************************************/
    reg [15:0] _rdata;
 
    wire _endLine;
    wire [1:0] _hsync_state_debug;
    wire [1:0] _vsync_state_debug;
    
    // --- CDC: sync imgData from clkSystem -> clkVGA ---
    // The _sync variables are safe to use internally (to pass to the submodules)
    reg [4:0] _imgData_meta;   // metastability stage
    reg [4:0] _imgData_sync;   // stable output in VGA domain
    wire [4:0] _imgData_sys = {_SrcChar, _SrcImg3, _SrcImg2, _SrcImg1, _SrcImg0};
    reg _enVGA_meta, _enVGA_sync;
    reg _rst_meta, _rst_sync_vga;
       
 /*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/
 
 /*************************************************************************************
 * 2.1 Static Assignments and Modules Instance
 ************************************************************************************/
     assign o_rdy = i_sel;
     assign o_rdata = _rdata;
     
     m_hsync_vga hsync_module (
        .i_clk (i_clkVGA),
        .i_rst (_rst_sync_vga),
        .i_enVGA (_enVGA_sync),
        .i_imgData (_imgData_sync),
        .o_endLine(_endLine),
        .o_vga_red(o_vga_red),
        .o_vga_green(o_vga_green),
        .o_vga_blue(o_vga_blue),
        .o_hsync(o_hsync),
        .o_state_debug(_hsync_state_debug)
     );
     
     m_vsync_vga vsync_module (
        .i_clk (i_clkVGA),
        .i_rst (_rst_sync_vga),
        .i_enVGA (_enVGA_sync),
        .i_endLine(_endLine),
        .o_vsync(o_vsync),
        .o_state_debug(_vsync_state_debug)
     );
     
/*************************************************************************************
 * 2.2 Clock Domain Crossing avoidance (CDC) -- safe to use internally variables
 ************************************************************************************/  
     always @(posedge i_clkVGA) begin
        if (i_rst) begin
            _rst_meta     <= 1'b1;
            _rst_sync_vga <= 1'b1;
        end else begin
            _rst_meta     <= 1'b0;       // i_rst here is _rst_sync from the top level
            _rst_sync_vga <= _rst_meta;
        end
     end 
     
     always @(posedge i_clkVGA) begin
        if (_rst_sync_vga) begin
            _imgData_meta <= 5'b0;
            _imgData_sync <= 5'b0;
        end else begin
            _imgData_meta <= _imgData_sys;   // capture (may be metastable)
            _imgData_sync <= _imgData_meta;  // now stable
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

/*************************************************************************************
 * 2.2 Register Writes
 ************************************************************************************/
     always @ (posedge i_clkSystem) begin
        if (i_rst) begin
            _enVGA <= 1'b0;
            _SrcImg0 <= 1'b0;
            _SrcImg1 <= 1'b0;
            _SrcImg2 <= 1'b0;
            _SrcImg3 <= 1'b0;
            _SrcChar <= 1'b0;
        end
        else begin
            if (i_we) begin
                case (i_addr)
                CNTRL: _enVGA <= i_wdata[0];
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
 * 2.3 Readback Mux
 ************************************************************************************/
 
     always @ (*) begin
        if (i_rst || !i_sel || !i_re)
            _rdata = 16'h0000;
        else begin
            case (i_addr) 
                CNTRL: _rdata = _enVGA;
                VGASEL: _rdata = {3'b0, _SrcChar, _SrcImg3, _SrcImg2, _SrcImg1, _SrcImg0};
                default: _rdata =  16'h0000;
            endcase
        end
     end


endmodule
