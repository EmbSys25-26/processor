`timescale 1ns / 1ps

`include "constants.vh"

module m_vga_mmio(
    input wire i_clk,       //FPGA clock
    input wire i_clkSystem,
    input wire i_rst,
    input wire i_sel,
    input wire i_we,            // IO write enable
    input wire i_re,            // IO read enable
    input wire i_addr,          // Address used to identify the peripheral register
    input wire [15:0] i_wdata,
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
     //reg _SrcImg0, _SrcImg1, _SrcImg2, _SrcImg3, _SrcChar;
 
/****************************************************************************
 * 1.3 DECLARE WIRES / REGS
 ***************************************************************************/
    reg [15:0] _rdata;
 
    wire _endLine;
    wire [1:0] _hsync_state_debug;
    wire [1:0] _vsync_state_debug;
    
    // --- CDC: sync imgData from clkSystem -> clkVGA ---
    // The _sync variables are safe to use internally (to pass to the submodules)
    /*reg [4:0] _imgData_meta;   // metastability stage
    reg [4:0] _imgData_sync;   // stable output in VGA domain
    wire [4:0] _imgData_sys = {_SrcChar, _SrcImg3, _SrcImg2, _SrcImg1, _SrcImg0};*/
    wire _enVGA_sync;
    wire _rst_sync_vga;
    
    wire _vactive;
 /****************************************************************************
 * 1.4 DECLARE INTERNAL SIGNALS OF AXI4-STREAM OF VDMA
 ***************************************************************************/
   (* mark_debug = "true" *)  wire [15:0] _axis_tdata;    
   (* mark_debug = "true" *)  wire        _axis_tvalid;   
    (* mark_debug = "true" *) wire        _axis_tready; 
    (* mark_debug = "true" *) wire        _axis_tuser; 
   (* mark_debug = "true" *)  wire        _axis_tlast;   
    
    wire _clk_pixel;   // 25 MHz from internal clocking wizard
    wire _rst_n;       // Reset from PS
       
 /*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/
 
 /*************************************************************************************
 * 2.1 Static Assignments and Modules Instance
 ************************************************************************************/
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
        .sys_clock            (i_clk)
    );
     
     m_hsync_vga hsync_module (
        .i_clk (_clk_pixel),
        .i_rst (_rst_sync_vga),
        .i_enVGA (_enVGA_sync),
        //.i_imgData (_imgData_sync),
        .i_axis_tdata (_axis_tdata),
        .i_axis_tvalid (_axis_tvalid),
        .i_axis_tuser (_axis_tuser),
        .i_axis_tlast (_axis_tlast),
        .o_axis_tready (_axis_tready),
        .o_endLine(_endLine),
        .o_vga_red(o_vga_red),
        .o_vga_green(o_vga_green),
        .o_vga_blue(o_vga_blue),
        .o_hsync(o_hsync),
        .o_state_debug(_hsync_state_debug),
        .i_vactive(_vactive)
     );
     
     m_vsync_vga vsync_module (
        .i_clk (_clk_pixel),
        .i_rst (_rst_sync_vga),
        .i_enVGA (_enVGA_sync),
        .i_endLine(_endLine),
        .o_vsync(o_vsync),
        .o_state_debug(_vsync_state_debug),
        .o_vactive(_vactive)
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
 * 2.2 Clock Domain Crossing avoidance (CDC) -- safe to use internally variables
 ************************************************************************************/  
     xpm_cdc_async_rst #(
        .DEST_SYNC_FF    (2),  // 2 flip-flop synchroniser
        .INIT_SYNC_FF    (1),  // initialise to 1 (reset active)
        .RST_ACTIVE_HIGH (1)   // 1 = active high reset
     ) u_rst_cdc (
        .src_arst  (i_rst),         // asynchronous reset source
        .dest_clk  (_clk_pixel),   
        .dest_arst (_rst_sync_vga)  // synchronised reset output
     );
     
     /*always @(posedge _clk_pixel) begin
        if (_rst_sync_vga) begin
            _imgData_meta <= 5'b0;
            _imgData_sync <= 5'b0;
        end else begin
            _imgData_meta <= _imgData_sys;   // capture (may be metastable)
            _imgData_sync <= _imgData_meta;  // now stable
        end
     end*/
          
    xpm_cdc_single #(
        .DEST_SYNC_FF   (2),  // 2 flip-flop synchroniser
        .INIT_SYNC_FF   (1),  // initialise FFs to 0 on reset
        .SIM_ASSERT_CHK (0),  
        .SRC_INPUT_REG  (1)   
    ) u_enVGA_cdc (
        .src_clk  (i_clkSystem),   // source clock domain
        .src_in   (_enVGA),        // signal to cross
        .dest_clk (_clk_pixel),    // destination clock domain  
        .dest_out (_enVGA_sync)    // synchronised output - use this as before
    );

/*************************************************************************************
 * 2.2 Register Writes
 ************************************************************************************/
     always @ (posedge i_clkSystem) begin
        if (i_rst) begin
            _enVGA <= 1'b0;
            /*_SrcImg0 <= 1'b0;
            _SrcImg1 <= 1'b0;
            _SrcImg2 <= 1'b0;
            _SrcImg3 <= 1'b0;
            _SrcChar <= 1'b0;*/
        end
        else begin
            if (i_we) begin
                case (i_addr)
                CNTRL: _enVGA <= i_wdata[0];
                /*VGASEL: begin
                    _SrcImg0 <= i_wdata[0];
                    _SrcImg1 <= i_wdata[1];
                    _SrcImg2 <= i_wdata[2];
                    _SrcImg3 <= i_wdata[3];
                    _SrcChar <= i_wdata[4];    
                end*/
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
                //VGASEL: _rdata = {3'b0, _SrcChar, _SrcImg3, _SrcImg2, _SrcImg1, _SrcImg0};
                default: _rdata =  16'h0000;
            endcase
        end
     end


endmodule