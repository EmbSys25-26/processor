// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1.1 (lin64) Build 6233196 Thu Sep 11 21:27:11 MDT 2025
// Date        : Sun May 17 13:50:00 2026
// Host        : armeiro-IdeaPad-Flex-5-14ALC05 running 64-bit Ubuntu 24.04.4 LTS
// Command     : write_verilog -force -mode synth_stub -rename_top vga_system_axi_vdma_0_0 -prefix
//               vga_system_axi_vdma_0_0_ vga_system_axi_vdma_0_0_stub.v
// Design      : vga_system_axi_vdma_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* CHECK_LICENSE_TYPE = "vga_system_axi_vdma_0_0,axi_vdma,{}" *) (* core_generation_info = "vga_system_axi_vdma_0_0,axi_vdma,{x_ipProduct=Vivado 2025.1.1,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=axi_vdma,x_ipVersion=6.3,x_ipCoreRevision=23,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_S_AXI_LITE_ADDR_WIDTH=9,C_S_AXI_LITE_DATA_WIDTH=32,C_DLYTMR_RESOLUTION=125,C_PRMRY_IS_ACLK_ASYNC=1,C_ENABLE_VIDPRMTR_READS=1,C_DYNAMIC_RESOLUTION=1,C_NUM_FSTORES=1,C_USE_FSYNC=1,C_USE_MM2S_FSYNC=0,C_USE_S2MM_FSYNC=2,C_FLUSH_ON_FSYNC=1,C_INCLUDE_INTERNAL_GENLOCK=1,C_INCLUDE_SG=0,C_M_AXI_SG_ADDR_WIDTH=32,C_M_AXI_SG_DATA_WIDTH=32,C_INCLUDE_MM2S=1,C_MM2S_GENLOCK_MODE=0,C_MM2S_GENLOCK_NUM_MASTERS=1,C_MM2S_GENLOCK_REPEAT_EN=0,C_MM2S_SOF_ENABLE=1,C_INCLUDE_MM2S_DRE=0,C_INCLUDE_MM2S_SF=0,C_MM2S_LINEBUFFER_DEPTH=2048,C_MM2S_LINEBUFFER_THRESH=4,C_MM2S_MAX_BURST_LENGTH=256,C_M_AXI_MM2S_ADDR_WIDTH=32,C_M_AXI_MM2S_DATA_WIDTH=64,C_M_AXIS_MM2S_TDATA_WIDTH=16,C_M_AXIS_MM2S_TUSER_BITS=1,C_INCLUDE_S2MM=0,C_S2MM_GENLOCK_MODE=0,C_S2MM_GENLOCK_NUM_MASTERS=1,C_S2MM_GENLOCK_REPEAT_EN=1,C_S2MM_SOF_ENABLE=1,C_INCLUDE_S2MM_DRE=0,C_INCLUDE_S2MM_SF=1,C_S2MM_LINEBUFFER_DEPTH=512,C_S2MM_LINEBUFFER_THRESH=4,C_S2MM_MAX_BURST_LENGTH=8,C_M_AXI_S2MM_ADDR_WIDTH=32,C_M_AXI_S2MM_DATA_WIDTH=64,C_S_AXIS_S2MM_TDATA_WIDTH=32,C_S_AXIS_S2MM_TUSER_BITS=1,C_ENABLE_DEBUG_ALL=0,C_ENABLE_DEBUG_INFO_0=0,C_ENABLE_DEBUG_INFO_1=0,C_ENABLE_DEBUG_INFO_2=0,C_ENABLE_DEBUG_INFO_3=0,C_ENABLE_DEBUG_INFO_4=0,C_ENABLE_DEBUG_INFO_5=0,C_ENABLE_DEBUG_INFO_6=1,C_ENABLE_DEBUG_INFO_7=1,C_ENABLE_DEBUG_INFO_8=0,C_ENABLE_DEBUG_INFO_9=0,C_ENABLE_DEBUG_INFO_10=0,C_ENABLE_DEBUG_INFO_11=0,C_ENABLE_DEBUG_INFO_12=0,C_ENABLE_DEBUG_INFO_13=0,C_ENABLE_DEBUG_INFO_14=1,C_ENABLE_DEBUG_INFO_15=1,C_INSTANCE=axi_vdma,C_SELECT_XPM=0,C_ENABLE_VERT_FLIP=0,C_FAMILY=zynq}" *) (* downgradeipidentifiedwarnings = "yes" *) 
(* x_core_info = "axi_vdma,Vivado 2025.1.1" *) 
module vga_system_axi_vdma_0_0(s_axi_lite_aclk, m_axi_mm2s_aclk, 
  m_axis_mm2s_aclk, axi_resetn, s_axi_lite_awvalid, s_axi_lite_awready, s_axi_lite_awaddr, 
  s_axi_lite_wvalid, s_axi_lite_wready, s_axi_lite_wdata, s_axi_lite_bresp, 
  s_axi_lite_bvalid, s_axi_lite_bready, s_axi_lite_arvalid, s_axi_lite_arready, 
  s_axi_lite_araddr, s_axi_lite_rvalid, s_axi_lite_rready, s_axi_lite_rdata, 
  s_axi_lite_rresp, mm2s_frame_ptr_out, m_axi_mm2s_araddr, m_axi_mm2s_arlen, 
  m_axi_mm2s_arsize, m_axi_mm2s_arburst, m_axi_mm2s_arprot, m_axi_mm2s_arcache, 
  m_axi_mm2s_arvalid, m_axi_mm2s_arready, m_axi_mm2s_rdata, m_axi_mm2s_rresp, 
  m_axi_mm2s_rlast, m_axi_mm2s_rvalid, m_axi_mm2s_rready, m_axis_mm2s_tdata, 
  m_axis_mm2s_tkeep, m_axis_mm2s_tuser, m_axis_mm2s_tvalid, m_axis_mm2s_tready, 
  m_axis_mm2s_tlast, mm2s_introut)
/* synthesis syn_black_box black_box_pad_pin="axi_resetn,s_axi_lite_awvalid,s_axi_lite_awready,s_axi_lite_awaddr[8:0],s_axi_lite_wvalid,s_axi_lite_wready,s_axi_lite_wdata[31:0],s_axi_lite_bresp[1:0],s_axi_lite_bvalid,s_axi_lite_bready,s_axi_lite_arvalid,s_axi_lite_arready,s_axi_lite_araddr[8:0],s_axi_lite_rvalid,s_axi_lite_rready,s_axi_lite_rdata[31:0],s_axi_lite_rresp[1:0],mm2s_frame_ptr_out[5:0],m_axi_mm2s_araddr[31:0],m_axi_mm2s_arlen[7:0],m_axi_mm2s_arsize[2:0],m_axi_mm2s_arburst[1:0],m_axi_mm2s_arprot[2:0],m_axi_mm2s_arcache[3:0],m_axi_mm2s_arvalid,m_axi_mm2s_arready,m_axi_mm2s_rdata[63:0],m_axi_mm2s_rresp[1:0],m_axi_mm2s_rlast,m_axi_mm2s_rvalid,m_axi_mm2s_rready,m_axis_mm2s_tdata[15:0],m_axis_mm2s_tkeep[1:0],m_axis_mm2s_tuser[0:0],m_axis_mm2s_tvalid,m_axis_mm2s_tready,m_axis_mm2s_tlast,mm2s_introut" */
/* synthesis syn_force_seq_prim="s_axi_lite_aclk" */
/* synthesis syn_force_seq_prim="m_axi_mm2s_aclk" */
/* synthesis syn_force_seq_prim="m_axis_mm2s_aclk" */;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 S_AXI_LITE_ACLK CLK" *) (* x_interface_mode = "slave S_AXI_LITE_ACLK" *) (* x_interface_parameter = "XIL_INTERFACENAME S_AXI_LITE_ACLK, ASSOCIATED_BUSIF S_AXI_LITE:M_AXI, ASSOCIATED_RESET axi_resetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN vga_system_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input s_axi_lite_aclk /* synthesis syn_isclock = 1 */;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 M_AXI_MM2S_ACLK CLK" *) (* x_interface_mode = "slave M_AXI_MM2S_ACLK" *) (* x_interface_parameter = "XIL_INTERFACENAME M_AXI_MM2S_ACLK, ASSOCIATED_BUSIF M_AXI_MM2S, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN vga_system_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input m_axi_mm2s_aclk /* synthesis syn_isclock = 1 */;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 M_AXIS_MM2S_ACLK CLK" *) (* x_interface_mode = "slave M_AXIS_MM2S_ACLK" *) (* x_interface_parameter = "XIL_INTERFACENAME M_AXIS_MM2S_ACLK, ASSOCIATED_BUSIF M_AXIS_MM2S, FREQ_HZ 25173611, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN vga_system_sys_clock, INSERT_VIP 0" *) input m_axis_mm2s_aclk /* synthesis syn_isclock = 1 */;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 AXI_RESETN RST" *) (* x_interface_mode = "slave AXI_RESETN" *) (* x_interface_parameter = "XIL_INTERFACENAME AXI_RESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input axi_resetn;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S_AXI_LITE AWVALID" *) (* x_interface_mode = "slave S_AXI_LITE" *) (* x_interface_parameter = "XIL_INTERFACENAME S_AXI_LITE, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 9, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 0, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 8, NUM_WRITE_OUTSTANDING 8, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN vga_system_processing_system7_0_0_FCLK_CLK0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input s_axi_lite_awvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S_AXI_LITE AWREADY" *) output s_axi_lite_awready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S_AXI_LITE AWADDR" *) input [8:0]s_axi_lite_awaddr;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S_AXI_LITE WVALID" *) input s_axi_lite_wvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S_AXI_LITE WREADY" *) output s_axi_lite_wready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S_AXI_LITE WDATA" *) input [31:0]s_axi_lite_wdata;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S_AXI_LITE BRESP" *) output [1:0]s_axi_lite_bresp;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S_AXI_LITE BVALID" *) output s_axi_lite_bvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S_AXI_LITE BREADY" *) input s_axi_lite_bready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S_AXI_LITE ARVALID" *) input s_axi_lite_arvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S_AXI_LITE ARREADY" *) output s_axi_lite_arready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S_AXI_LITE ARADDR" *) input [8:0]s_axi_lite_araddr;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S_AXI_LITE RVALID" *) output s_axi_lite_rvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S_AXI_LITE RREADY" *) input s_axi_lite_rready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S_AXI_LITE RDATA" *) output [31:0]s_axi_lite_rdata;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S_AXI_LITE RRESP" *) output [1:0]s_axi_lite_rresp;
  (* x_interface_info = "xilinx.com:signal:video_frame_ptr:1.0 MM2S_FRAME_PTR_OUT FRAME_PTR" *) (* x_interface_mode = "master MM2S_FRAME_PTR_OUT" *) output [5:0]mm2s_frame_ptr_out;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S ARADDR" *) (* x_interface_mode = "master M_AXI_MM2S" *) (* x_interface_parameter = "XIL_INTERFACENAME M_AXI_MM2S, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 2, DATA_WIDTH 64, PROTOCOL AXI4, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_ONLY, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 0, HAS_BRESP 0, HAS_RRESP 1, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN vga_system_processing_system7_0_0_FCLK_CLK0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) output [31:0]m_axi_mm2s_araddr;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S ARLEN" *) output [7:0]m_axi_mm2s_arlen;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S ARSIZE" *) output [2:0]m_axi_mm2s_arsize;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S ARBURST" *) output [1:0]m_axi_mm2s_arburst;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S ARPROT" *) output [2:0]m_axi_mm2s_arprot;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S ARCACHE" *) output [3:0]m_axi_mm2s_arcache;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S ARVALID" *) output m_axi_mm2s_arvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S ARREADY" *) input m_axi_mm2s_arready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S RDATA" *) input [63:0]m_axi_mm2s_rdata;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S RRESP" *) input [1:0]m_axi_mm2s_rresp;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S RLAST" *) input m_axi_mm2s_rlast;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S RVALID" *) input m_axi_mm2s_rvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI_MM2S RREADY" *) output m_axi_mm2s_rready;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S TDATA" *) (* x_interface_mode = "master M_AXIS_MM2S" *) (* x_interface_parameter = "XIL_INTERFACENAME M_AXIS_MM2S, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 1, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 25173611, PHASE 0.0, CLK_DOMAIN vga_system_sys_clock, LAYERED_METADATA undef, INSERT_VIP 0" *) output [15:0]m_axis_mm2s_tdata;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S TKEEP" *) output [1:0]m_axis_mm2s_tkeep;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S TUSER" *) output [0:0]m_axis_mm2s_tuser;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S TVALID" *) output m_axis_mm2s_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S TREADY" *) input m_axis_mm2s_tready;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S TLAST" *) output m_axis_mm2s_tlast;
  (* x_interface_info = "xilinx.com:signal:interrupt:1.0 MM2S_INTROUT INTERRUPT" *) (* x_interface_mode = "master MM2S_INTROUT" *) (* x_interface_parameter = "XIL_INTERFACENAME MM2S_INTROUT, SENSITIVITY LEVEL_HIGH, PortWidth 1" *) output mm2s_introut;
endmodule
