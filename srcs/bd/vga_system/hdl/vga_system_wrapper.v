//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.1.1 (lin64) Build 6233196 Thu Sep 11 21:27:11 MDT 2025
//Date        : Mon May 18 17:54:14 2026
//Host        : armeiro-IdeaPad-Flex-5-14ALC05 running 64-bit Ubuntu 24.04.4 LTS
//Command     : generate_target vga_system_wrapper.bd
//Design      : vga_system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module vga_system_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    M_AXIS_MM2S_0_tdata,
    M_AXIS_MM2S_0_tkeep,
    M_AXIS_MM2S_0_tlast,
    M_AXIS_MM2S_0_tready,
    M_AXIS_MM2S_0_tuser,
    M_AXIS_MM2S_0_tvalid,
    clk_pixel_0,
    i_sw_gpio_tri_io,
    sys_clock);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  output [15:0]M_AXIS_MM2S_0_tdata;
  output [1:0]M_AXIS_MM2S_0_tkeep;
  output M_AXIS_MM2S_0_tlast;
  input M_AXIS_MM2S_0_tready;
  output [0:0]M_AXIS_MM2S_0_tuser;
  output M_AXIS_MM2S_0_tvalid;
  output clk_pixel_0;
  inout [1:0]i_sw_gpio_tri_io;
  input sys_clock;

  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire [15:0]M_AXIS_MM2S_0_tdata;
  wire [1:0]M_AXIS_MM2S_0_tkeep;
  wire M_AXIS_MM2S_0_tlast;
  wire M_AXIS_MM2S_0_tready;
  wire [0:0]M_AXIS_MM2S_0_tuser;
  wire M_AXIS_MM2S_0_tvalid;
  wire clk_pixel_0;
  wire [0:0]i_sw_gpio_tri_i_0;
  wire [1:1]i_sw_gpio_tri_i_1;
  wire [0:0]i_sw_gpio_tri_io_0;
  wire [1:1]i_sw_gpio_tri_io_1;
  wire [0:0]i_sw_gpio_tri_o_0;
  wire [1:1]i_sw_gpio_tri_o_1;
  wire [0:0]i_sw_gpio_tri_t_0;
  wire [1:1]i_sw_gpio_tri_t_1;
  wire sys_clock;

  IOBUF i_sw_gpio_tri_iobuf_0
       (.I(i_sw_gpio_tri_o_0),
        .IO(i_sw_gpio_tri_io[0]),
        .O(i_sw_gpio_tri_i_0),
        .T(i_sw_gpio_tri_t_0));
  IOBUF i_sw_gpio_tri_iobuf_1
       (.I(i_sw_gpio_tri_o_1),
        .IO(i_sw_gpio_tri_io[1]),
        .O(i_sw_gpio_tri_i_1),
        .T(i_sw_gpio_tri_t_1));
  vga_system vga_system_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .M_AXIS_MM2S_0_tdata(M_AXIS_MM2S_0_tdata),
        .M_AXIS_MM2S_0_tkeep(M_AXIS_MM2S_0_tkeep),
        .M_AXIS_MM2S_0_tlast(M_AXIS_MM2S_0_tlast),
        .M_AXIS_MM2S_0_tready(M_AXIS_MM2S_0_tready),
        .M_AXIS_MM2S_0_tuser(M_AXIS_MM2S_0_tuser),
        .M_AXIS_MM2S_0_tvalid(M_AXIS_MM2S_0_tvalid),
        .clk_pixel_0(clk_pixel_0),
        .i_sw_gpio_tri_i({i_sw_gpio_tri_i_1,i_sw_gpio_tri_i_0}),
        .i_sw_gpio_tri_o({i_sw_gpio_tri_o_1,i_sw_gpio_tri_o_0}),
        .i_sw_gpio_tri_t({i_sw_gpio_tri_t_1,i_sw_gpio_tri_t_0}),
        .sys_clock(sys_clock));
endmodule
