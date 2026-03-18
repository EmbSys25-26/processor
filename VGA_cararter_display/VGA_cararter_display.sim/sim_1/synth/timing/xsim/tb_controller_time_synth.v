// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (lin64) Build 6140274 Wed May 21 22:58:25 MDT 2025
// Date        : Wed Mar 18 18:26:00 2026
// Host        : mendes-Katana-GF66-12UGS running 64-bit Ubuntu 22.04.5 LTS
// Command     : write_verilog -mode timesim -nolib -sdf_anno true -force -file
//               /home/mendes/VGA_cararter_display/VGA_cararter_display.sim/sim_1/synth/timing/xsim/tb_controller_time_synth.v
// Design      : controller
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

(* CHECK_LICENSE_TYPE = "char_buffer_bram,blk_mem_gen_v8_4_11,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_11,Vivado 2025.1" *) 
module char_buffer_bram
   (clka,
    wea,
    addra,
    dina,
    clkb,
    addrb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_mode = "slave BRAM_PORTA" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [11:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [7:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_mode = "slave BRAM_PORTB" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [11:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [7:0]doutb;

  wire [11:0]addra;
  wire [11:0]addrb;
  wire clka;
  wire clkb;
  wire [7:0]dina;
  wire [7:0]doutb;
  wire [0:0]wea;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [7:0]NLW_U0_douta_UNCONNECTED;
  wire [11:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [11:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [7:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "12" *) 
  (* C_ADDRB_WIDTH = "12" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "1" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     4.862099 mW" *) 
  (* C_FAMILY = "zynq" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "0" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "char_buffer_bram.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "4096" *) 
  (* C_READ_DEPTH_B = "4096" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "8" *) 
  (* C_READ_WIDTH_B = "8" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "1" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "4096" *) 
  (* C_WRITE_DEPTH_B = "4096" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "8" *) 
  (* C_WRITE_WIDTH_B = "8" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* c_default_data = "20" *) 
  (* c_elaboration_dir = "./" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  char_buffer_bram_blk_mem_gen_v8_4_11 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(NLW_U0_douta_UNCONNECTED[7:0]),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(1'b0),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[11:0]),
        .regcea(1'b1),
        .regceb(1'b1),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[11:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[7:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(1'b0));
endmodule

module clk_wiz_0
   (clk_out1,
    clk_out2,
    reset,
    locked,
    clk_in1);
  output clk_out1;
  output clk_out2;
  input reset;
  output locked;
  input clk_in1;

  wire clk_in1;
  wire clk_out1;
  wire clk_out2;
  wire locked;
  wire reset;

  clk_wiz_0_clk_wiz inst
       (.clk_in1(clk_in1),
        .clk_out1(clk_out1),
        .clk_out2(clk_out2),
        .locked(locked),
        .reset(reset));
endmodule

module clk_wiz_0_clk_wiz
   (clk_out1,
    clk_out2,
    reset,
    locked,
    clk_in1);
  output clk_out1;
  output clk_out2;
  input reset;
  output locked;
  input clk_in1;

  wire clk_in1;
  wire clk_in1_clk_wiz_0;
  wire clk_out1;
  wire clk_out1_clk_wiz_0;
  wire clk_out2;
  wire clk_out2_clk_wiz_0;
  wire clkfbout_buf_clk_wiz_0;
  wire clkfbout_clk_wiz_0;
  wire locked;
  wire reset;
  wire NLW_mmcm_adv_inst_CLKFBOUTB_UNCONNECTED;
  wire NLW_mmcm_adv_inst_CLKFBSTOPPED_UNCONNECTED;
  wire NLW_mmcm_adv_inst_CLKINSTOPPED_UNCONNECTED;
  wire NLW_mmcm_adv_inst_CLKOUT0B_UNCONNECTED;
  wire NLW_mmcm_adv_inst_CLKOUT1B_UNCONNECTED;
  wire NLW_mmcm_adv_inst_CLKOUT2_UNCONNECTED;
  wire NLW_mmcm_adv_inst_CLKOUT2B_UNCONNECTED;
  wire NLW_mmcm_adv_inst_CLKOUT3_UNCONNECTED;
  wire NLW_mmcm_adv_inst_CLKOUT3B_UNCONNECTED;
  wire NLW_mmcm_adv_inst_CLKOUT4_UNCONNECTED;
  wire NLW_mmcm_adv_inst_CLKOUT5_UNCONNECTED;
  wire NLW_mmcm_adv_inst_CLKOUT6_UNCONNECTED;
  wire NLW_mmcm_adv_inst_DRDY_UNCONNECTED;
  wire NLW_mmcm_adv_inst_PSDONE_UNCONNECTED;
  wire [15:0]NLW_mmcm_adv_inst_DO_UNCONNECTED;

  (* BOX_TYPE = "PRIMITIVE" *) 
  BUFG clkf_buf
       (.I(clkfbout_clk_wiz_0),
        .O(clkfbout_buf_clk_wiz_0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUF #(
    .IOSTANDARD("DEFAULT")) 
    clkin1_ibufg
       (.I(clk_in1),
        .O(clk_in1_clk_wiz_0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  BUFG clkout1_buf
       (.I(clk_out1_clk_wiz_0),
        .O(clk_out1));
  (* BOX_TYPE = "PRIMITIVE" *) 
  BUFG clkout2_buf
       (.I(clk_out2_clk_wiz_0),
        .O(clk_out2));
  (* BOX_TYPE = "PRIMITIVE" *) 
  MMCME2_ADV #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKFBOUT_MULT_F(7.250000),
    .CLKFBOUT_PHASE(0.000000),
    .CLKFBOUT_USE_FINE_PS("FALSE"),
    .CLKIN1_PERIOD(8.000000),
    .CLKIN2_PERIOD(0.000000),
    .CLKOUT0_DIVIDE_F(18.125000),
    .CLKOUT0_DUTY_CYCLE(0.500000),
    .CLKOUT0_PHASE(0.000000),
    .CLKOUT0_USE_FINE_PS("FALSE"),
    .CLKOUT1_DIVIDE(36),
    .CLKOUT1_DUTY_CYCLE(0.500000),
    .CLKOUT1_PHASE(0.000000),
    .CLKOUT1_USE_FINE_PS("FALSE"),
    .CLKOUT2_DIVIDE(1),
    .CLKOUT2_DUTY_CYCLE(0.500000),
    .CLKOUT2_PHASE(0.000000),
    .CLKOUT2_USE_FINE_PS("FALSE"),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT3_DUTY_CYCLE(0.500000),
    .CLKOUT3_PHASE(0.000000),
    .CLKOUT3_USE_FINE_PS("FALSE"),
    .CLKOUT4_CASCADE("FALSE"),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT4_DUTY_CYCLE(0.500000),
    .CLKOUT4_PHASE(0.000000),
    .CLKOUT4_USE_FINE_PS("FALSE"),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT5_DUTY_CYCLE(0.500000),
    .CLKOUT5_PHASE(0.000000),
    .CLKOUT5_USE_FINE_PS("FALSE"),
    .CLKOUT6_DIVIDE(1),
    .CLKOUT6_DUTY_CYCLE(0.500000),
    .CLKOUT6_PHASE(0.000000),
    .CLKOUT6_USE_FINE_PS("FALSE"),
    .COMPENSATION("ZHOLD"),
    .DIVCLK_DIVIDE(1),
    .IS_CLKINSEL_INVERTED(1'b0),
    .IS_PSEN_INVERTED(1'b0),
    .IS_PSINCDEC_INVERTED(1'b0),
    .IS_PWRDWN_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .REF_JITTER1(0.010000),
    .REF_JITTER2(0.010000),
    .SS_EN("FALSE"),
    .SS_MODE("CENTER_HIGH"),
    .SS_MOD_PERIOD(10000),
    .STARTUP_WAIT("FALSE")) 
    mmcm_adv_inst
       (.CLKFBIN(clkfbout_buf_clk_wiz_0),
        .CLKFBOUT(clkfbout_clk_wiz_0),
        .CLKFBOUTB(NLW_mmcm_adv_inst_CLKFBOUTB_UNCONNECTED),
        .CLKFBSTOPPED(NLW_mmcm_adv_inst_CLKFBSTOPPED_UNCONNECTED),
        .CLKIN1(clk_in1_clk_wiz_0),
        .CLKIN2(1'b0),
        .CLKINSEL(1'b1),
        .CLKINSTOPPED(NLW_mmcm_adv_inst_CLKINSTOPPED_UNCONNECTED),
        .CLKOUT0(clk_out1_clk_wiz_0),
        .CLKOUT0B(NLW_mmcm_adv_inst_CLKOUT0B_UNCONNECTED),
        .CLKOUT1(clk_out2_clk_wiz_0),
        .CLKOUT1B(NLW_mmcm_adv_inst_CLKOUT1B_UNCONNECTED),
        .CLKOUT2(NLW_mmcm_adv_inst_CLKOUT2_UNCONNECTED),
        .CLKOUT2B(NLW_mmcm_adv_inst_CLKOUT2B_UNCONNECTED),
        .CLKOUT3(NLW_mmcm_adv_inst_CLKOUT3_UNCONNECTED),
        .CLKOUT3B(NLW_mmcm_adv_inst_CLKOUT3B_UNCONNECTED),
        .CLKOUT4(NLW_mmcm_adv_inst_CLKOUT4_UNCONNECTED),
        .CLKOUT5(NLW_mmcm_adv_inst_CLKOUT5_UNCONNECTED),
        .CLKOUT6(NLW_mmcm_adv_inst_CLKOUT6_UNCONNECTED),
        .DADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .DCLK(1'b0),
        .DEN(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .DO(NLW_mmcm_adv_inst_DO_UNCONNECTED[15:0]),
        .DRDY(NLW_mmcm_adv_inst_DRDY_UNCONNECTED),
        .DWE(1'b0),
        .LOCKED(locked),
        .PSCLK(1'b0),
        .PSDONE(NLW_mmcm_adv_inst_PSDONE_UNCONNECTED),
        .PSEN(1'b0),
        .PSINCDEC(1'b0),
        .PWRDWN(1'b0),
        .RST(reset));
endmodule

(* S_DONE = "3'b101" *) (* S_IDLE = "3'b000" *) (* S_WAIT_CNTRL = "3'b100" *) 
(* S_WAIT_VGASEL = "3'b010" *) (* S_WRITE_CNTRL = "3'b011" *) (* S_WRITE_VGASEL = "3'b001" *) 
(* NotValidForBitStream *)
module controller
   (i_clk,
    i_rst,
    i_imgSel,
    i_ascii_code,
    i_ascii_valid,
    o_vga_red,
    o_vga_green,
    o_vga_blue,
    o_hsync,
    o_vsync);
  input i_clk;
  input i_rst;
  input [4:0]i_imgSel;
  input [7:0]i_ascii_code;
  input i_ascii_valid;
  output [3:0]o_vga_red;
  output [3:0]o_vga_green;
  output [3:0]o_vga_blue;
  output o_hsync;
  output o_vsync;

  wire \FSM_sequential__state[0]_i_1__1_n_0 ;
  wire \FSM_sequential__state[1]_i_1__0_n_0 ;
  wire \FSM_sequential__state[2]_i_1_n_0 ;
  wire [0:0]_addr;
  wire \_addr_reg_n_0_[0] ;
  wire _clkSystem;
  wire _clkVGA;
  wire _imgSel_prev;
  wire \_imgSel_prev[4]_i_2_n_0 ;
  wire \_imgSel_prev_reg_n_0_[0] ;
  wire \_imgSel_prev_reg_n_0_[1] ;
  wire \_imgSel_prev_reg_n_0_[2] ;
  wire \_imgSel_prev_reg_n_0_[3] ;
  wire \_imgSel_prev_reg_n_0_[4] ;
  wire _locked;
  wire _rst_sync;
  wire _rst_sync_i_1_n_0;
  wire _sel_i_1_n_0;
  wire [2:0]_state;
  wire [4:0]_wdata;
  wire \_wdata[4]_i_1_n_0 ;
  wire \_wdata[4]_i_3_n_0 ;
  wire \_wdata[4]_i_4_n_0 ;
  wire \_wdata[4]_i_5_n_0 ;
  wire \_wdata_reg_n_0_[0] ;
  wire \_wdata_reg_n_0_[2] ;
  wire \_wdata_reg_n_0_[4] ;
  wire _we;
  wire [7:0]i_ascii_code;
  wire [7:0]i_ascii_code_IBUF;
  wire i_ascii_valid;
  wire i_ascii_valid_IBUF;
  (* IBUF_LOW_PWR *) wire i_clk;
  wire [4:0]i_imgSel;
  wire [4:0]i_imgSel_IBUF;
  wire i_rst;
  wire i_rst_IBUF;
  wire o_hsync;
  wire o_hsync_OBUF;
  wire [3:0]o_vga_blue;
  wire [0:0]o_vga_blue_OBUF;
  wire [3:0]o_vga_green;
  wire [0:0]o_vga_green_OBUF;
  wire [3:0]o_vga_red;
  wire [0:0]o_vga_red_OBUF;
  wire o_vsync;
  wire o_vsync_OBUF;
  wire p_0_in;

initial begin
 $sdf_annotate("tb_controller_time_synth.sdf",,,,"tool_control");
end
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT5 #(
    .INIT(32'h0000BA51)) 
    \FSM_sequential__state[0]_i_1__1 
       (.I0(_state[0]),
        .I1(_state[1]),
        .I2(_we),
        .I3(_state[2]),
        .I4(_rst_sync),
        .O(\FSM_sequential__state[0]_i_1__1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT4 #(
    .INIT(16'h00C6)) 
    \FSM_sequential__state[1]_i_1__0 
       (.I0(_state[0]),
        .I1(_state[1]),
        .I2(_state[2]),
        .I3(_rst_sync),
        .O(\FSM_sequential__state[1]_i_1__0_n_0 ));
  LUT4 #(
    .INIT(16'h00F8)) 
    \FSM_sequential__state[2]_i_1 
       (.I0(_state[0]),
        .I1(_state[1]),
        .I2(_state[2]),
        .I3(_rst_sync),
        .O(\FSM_sequential__state[2]_i_1_n_0 ));
  (* FSM_ENCODED_STATES = "S_IDLE:000,S_WRITE_VGASEL:001,S_WAIT_VGASEL:010,S_WRITE_CNTRL:011,S_WAIT_CNTRL:100,S_DONE:101," *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_sequential__state_reg[0] 
       (.C(_clkSystem),
        .CE(1'b1),
        .D(\FSM_sequential__state[0]_i_1__1_n_0 ),
        .Q(_state[0]),
        .R(1'b0));
  (* FSM_ENCODED_STATES = "S_IDLE:000,S_WRITE_VGASEL:001,S_WAIT_VGASEL:010,S_WRITE_CNTRL:011,S_WAIT_CNTRL:100,S_DONE:101," *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_sequential__state_reg[1] 
       (.C(_clkSystem),
        .CE(1'b1),
        .D(\FSM_sequential__state[1]_i_1__0_n_0 ),
        .Q(_state[1]),
        .R(1'b0));
  (* FSM_ENCODED_STATES = "S_IDLE:000,S_WRITE_VGASEL:001,S_WAIT_VGASEL:010,S_WRITE_CNTRL:011,S_WAIT_CNTRL:100,S_DONE:101," *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_sequential__state_reg[2] 
       (.C(_clkSystem),
        .CE(1'b1),
        .D(\FSM_sequential__state[2]_i_1_n_0 ),
        .Q(_state[2]),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \_addr[0]_i_1 
       (.I0(_state[1]),
        .O(_addr));
  FDRE #(
    .INIT(1'b0)) 
    \_addr_reg[0] 
       (.C(_clkSystem),
        .CE(\_wdata[4]_i_1_n_0 ),
        .D(_addr),
        .Q(\_addr_reg_n_0_[0] ),
        .R(_rst_sync));
  LUT5 #(
    .INIT(32'h50450045)) 
    \_imgSel_prev[4]_i_1 
       (.I0(_state[1]),
        .I1(_we),
        .I2(_state[2]),
        .I3(_state[0]),
        .I4(\_imgSel_prev[4]_i_2_n_0 ),
        .O(_imgSel_prev));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT5 #(
    .INIT(32'hF6FFFFF6)) 
    \_imgSel_prev[4]_i_2 
       (.I0(i_imgSel_IBUF[3]),
        .I1(\_imgSel_prev_reg_n_0_[3] ),
        .I2(\_wdata[4]_i_4_n_0 ),
        .I3(\_imgSel_prev_reg_n_0_[4] ),
        .I4(i_imgSel_IBUF[4]),
        .O(\_imgSel_prev[4]_i_2_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \_imgSel_prev_reg[0] 
       (.C(_clkSystem),
        .CE(_imgSel_prev),
        .D(i_imgSel_IBUF[0]),
        .Q(\_imgSel_prev_reg_n_0_[0] ),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_imgSel_prev_reg[1] 
       (.C(_clkSystem),
        .CE(_imgSel_prev),
        .D(i_imgSel_IBUF[1]),
        .Q(\_imgSel_prev_reg_n_0_[1] ),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_imgSel_prev_reg[2] 
       (.C(_clkSystem),
        .CE(_imgSel_prev),
        .D(i_imgSel_IBUF[2]),
        .Q(\_imgSel_prev_reg_n_0_[2] ),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_imgSel_prev_reg[3] 
       (.C(_clkSystem),
        .CE(_imgSel_prev),
        .D(i_imgSel_IBUF[3]),
        .Q(\_imgSel_prev_reg_n_0_[3] ),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_imgSel_prev_reg[4] 
       (.C(_clkSystem),
        .CE(_imgSel_prev),
        .D(i_imgSel_IBUF[4]),
        .Q(\_imgSel_prev_reg_n_0_[4] ),
        .R(_rst_sync));
  LUT1 #(
    .INIT(2'h1)) 
    _rst_sync_i_1
       (.I0(_locked),
        .O(_rst_sync_i_1_n_0));
  FDPE #(
    .INIT(1'b1)) 
    _rst_sync_reg
       (.C(_clkSystem),
        .CE(1'b1),
        .D(_rst_sync_i_1_n_0),
        .PRE(i_rst_IBUF),
        .Q(_rst_sync));
  LUT6 #(
    .INIT(64'h00000000FF2BC000)) 
    _sel_i_1
       (.I0(_state[0]),
        .I1(_state[1]),
        .I2(_state[2]),
        .I3(_we),
        .I4(\_wdata[4]_i_1_n_0 ),
        .I5(_rst_sync),
        .O(_sel_i_1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    _sel_reg
       (.C(_clkSystem),
        .CE(1'b1),
        .D(_sel_i_1_n_0),
        .Q(_we),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT3 #(
    .INIT(8'h5C)) 
    \_wdata[0]_i_1 
       (.I0(_state[2]),
        .I1(i_imgSel_IBUF[0]),
        .I2(_state[1]),
        .O(_wdata[0]));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT3 #(
    .INIT(8'h5C)) 
    \_wdata[1]_i_1 
       (.I0(_state[2]),
        .I1(i_imgSel_IBUF[1]),
        .I2(_state[1]),
        .O(_wdata[1]));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \_wdata[2]_i_1 
       (.I0(i_imgSel_IBUF[2]),
        .I1(_state[1]),
        .O(_wdata[2]));
  LUT6 #(
    .INIT(64'h22222220AAAAAAAA)) 
    \_wdata[4]_i_1 
       (.I0(_state[0]),
        .I1(_state[1]),
        .I2(\_wdata[4]_i_3_n_0 ),
        .I3(\_wdata[4]_i_4_n_0 ),
        .I4(\_wdata[4]_i_5_n_0 ),
        .I5(_state[2]),
        .O(\_wdata[4]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \_wdata[4]_i_2 
       (.I0(i_imgSel_IBUF[4]),
        .I1(_state[1]),
        .O(_wdata[4]));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \_wdata[4]_i_3 
       (.I0(\_imgSel_prev_reg_n_0_[4] ),
        .I1(i_imgSel_IBUF[4]),
        .O(\_wdata[4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \_wdata[4]_i_4 
       (.I0(i_imgSel_IBUF[0]),
        .I1(\_imgSel_prev_reg_n_0_[0] ),
        .I2(\_imgSel_prev_reg_n_0_[2] ),
        .I3(i_imgSel_IBUF[2]),
        .I4(\_imgSel_prev_reg_n_0_[1] ),
        .I5(i_imgSel_IBUF[1]),
        .O(\_wdata[4]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \_wdata[4]_i_5 
       (.I0(\_imgSel_prev_reg_n_0_[3] ),
        .I1(i_imgSel_IBUF[3]),
        .O(\_wdata[4]_i_5_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \_wdata_reg[0] 
       (.C(_clkSystem),
        .CE(\_wdata[4]_i_1_n_0 ),
        .D(_wdata[0]),
        .Q(\_wdata_reg_n_0_[0] ),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_wdata_reg[1] 
       (.C(_clkSystem),
        .CE(\_wdata[4]_i_1_n_0 ),
        .D(_wdata[1]),
        .Q(p_0_in),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_wdata_reg[2] 
       (.C(_clkSystem),
        .CE(\_wdata[4]_i_1_n_0 ),
        .D(_wdata[2]),
        .Q(\_wdata_reg_n_0_[2] ),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_wdata_reg[4] 
       (.C(_clkSystem),
        .CE(\_wdata[4]_i_1_n_0 ),
        .D(_wdata[4]),
        .Q(\_wdata_reg_n_0_[4] ),
        .R(_rst_sync));
  IBUF \i_ascii_code_IBUF[0]_inst 
       (.I(i_ascii_code[0]),
        .O(i_ascii_code_IBUF[0]));
  IBUF \i_ascii_code_IBUF[1]_inst 
       (.I(i_ascii_code[1]),
        .O(i_ascii_code_IBUF[1]));
  IBUF \i_ascii_code_IBUF[2]_inst 
       (.I(i_ascii_code[2]),
        .O(i_ascii_code_IBUF[2]));
  IBUF \i_ascii_code_IBUF[3]_inst 
       (.I(i_ascii_code[3]),
        .O(i_ascii_code_IBUF[3]));
  IBUF \i_ascii_code_IBUF[4]_inst 
       (.I(i_ascii_code[4]),
        .O(i_ascii_code_IBUF[4]));
  IBUF \i_ascii_code_IBUF[5]_inst 
       (.I(i_ascii_code[5]),
        .O(i_ascii_code_IBUF[5]));
  IBUF \i_ascii_code_IBUF[6]_inst 
       (.I(i_ascii_code[6]),
        .O(i_ascii_code_IBUF[6]));
  IBUF \i_ascii_code_IBUF[7]_inst 
       (.I(i_ascii_code[7]),
        .O(i_ascii_code_IBUF[7]));
  IBUF i_ascii_valid_IBUF_inst
       (.I(i_ascii_valid),
        .O(i_ascii_valid_IBUF));
  IBUF \i_imgSel_IBUF[0]_inst 
       (.I(i_imgSel[0]),
        .O(i_imgSel_IBUF[0]));
  IBUF \i_imgSel_IBUF[1]_inst 
       (.I(i_imgSel[1]),
        .O(i_imgSel_IBUF[1]));
  IBUF \i_imgSel_IBUF[2]_inst 
       (.I(i_imgSel[2]),
        .O(i_imgSel_IBUF[2]));
  IBUF \i_imgSel_IBUF[3]_inst 
       (.I(i_imgSel[3]),
        .O(i_imgSel_IBUF[3]));
  IBUF \i_imgSel_IBUF[4]_inst 
       (.I(i_imgSel[4]),
        .O(i_imgSel_IBUF[4]));
  IBUF i_rst_IBUF_inst
       (.I(i_rst),
        .O(i_rst_IBUF));
  OBUF o_hsync_OBUF_inst
       (.I(o_hsync_OBUF),
        .O(o_hsync));
  OBUF \o_vga_blue_OBUF[0]_inst 
       (.I(o_vga_blue_OBUF),
        .O(o_vga_blue[0]));
  OBUF \o_vga_blue_OBUF[1]_inst 
       (.I(o_vga_blue_OBUF),
        .O(o_vga_blue[1]));
  OBUF \o_vga_blue_OBUF[2]_inst 
       (.I(o_vga_blue_OBUF),
        .O(o_vga_blue[2]));
  OBUF \o_vga_blue_OBUF[3]_inst 
       (.I(o_vga_blue_OBUF),
        .O(o_vga_blue[3]));
  OBUF \o_vga_green_OBUF[0]_inst 
       (.I(o_vga_green_OBUF),
        .O(o_vga_green[0]));
  OBUF \o_vga_green_OBUF[1]_inst 
       (.I(o_vga_green_OBUF),
        .O(o_vga_green[1]));
  OBUF \o_vga_green_OBUF[2]_inst 
       (.I(o_vga_green_OBUF),
        .O(o_vga_green[2]));
  OBUF \o_vga_green_OBUF[3]_inst 
       (.I(o_vga_green_OBUF),
        .O(o_vga_green[3]));
  OBUF \o_vga_red_OBUF[0]_inst 
       (.I(o_vga_red_OBUF),
        .O(o_vga_red[0]));
  OBUF \o_vga_red_OBUF[1]_inst 
       (.I(o_vga_red_OBUF),
        .O(o_vga_red[1]));
  OBUF \o_vga_red_OBUF[2]_inst 
       (.I(o_vga_red_OBUF),
        .O(o_vga_red[2]));
  OBUF \o_vga_red_OBUF[3]_inst 
       (.I(o_vga_red_OBUF),
        .O(o_vga_red[3]));
  OBUF o_vsync_OBUF_inst
       (.I(o_vsync_OBUF),
        .O(o_vsync));
  m_vga_mmio periph_vga
       (.CLK(_clkVGA),
        .D(i_ascii_code_IBUF),
        .Q({\_wdata_reg_n_0_[4] ,\_wdata_reg_n_0_[2] ,p_0_in,\_wdata_reg_n_0_[0] }),
        ._SrcImg0_reg_0(\_addr_reg_n_0_[0] ),
        ._rst_sync(_rst_sync),
        ._we(_we),
        .clk_out1(_clkSystem),
        .i_ascii_valid_IBUF(i_ascii_valid_IBUF),
        .o_hsync_OBUF(o_hsync_OBUF),
        .o_vga_blue_OBUF(o_vga_blue_OBUF),
        .o_vga_green_OBUF(o_vga_green_OBUF),
        .o_vga_red_OBUF(o_vga_red_OBUF),
        .o_vsync_OBUF(o_vsync_OBUF));
  (* IMPORTED_FROM = "/home/mendes/VGA_cararter_display/VGA_cararter_display.gen/sources_1/ip/clk_wiz_0/clk_wiz_0.dcp" *) 
  (* IMPORTED_TYPE = "CHECKPOINT" *) 
  (* IS_IMPORTED *) 
  clk_wiz_0 u_clk_wiz
       (.clk_in1(i_clk),
        .clk_out1(_clkSystem),
        .clk_out2(_clkVGA),
        .locked(_locked),
        .reset(i_rst_IBUF));
endmodule

(* CHECK_LICENSE_TYPE = "font_rom,dist_mem_gen_v8_0_17,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "dist_mem_gen_v8_0_17,Vivado 2025.1" *) 
module font_rom
   (a,
    spo);
  input [11:0]a;
  output [7:0]spo;

  wire [11:0]a;
  wire [7:0]spo;
  wire [7:0]NLW_U0_dpo_UNCONNECTED;
  wire [7:0]NLW_U0_qdpo_UNCONNECTED;
  wire [7:0]NLW_U0_qspo_UNCONNECTED;

  (* C_FAMILY = "zynq" *) 
  (* C_HAS_D = "0" *) 
  (* C_HAS_DPO = "0" *) 
  (* C_HAS_DPRA = "0" *) 
  (* C_HAS_I_CE = "0" *) 
  (* C_HAS_QDPO = "0" *) 
  (* C_HAS_QDPO_CE = "0" *) 
  (* C_HAS_QDPO_CLK = "0" *) 
  (* C_HAS_QDPO_RST = "0" *) 
  (* C_HAS_QDPO_SRST = "0" *) 
  (* C_HAS_WE = "0" *) 
  (* C_MEM_TYPE = "0" *) 
  (* C_PIPELINE_STAGES = "0" *) 
  (* C_QCE_JOINED = "0" *) 
  (* C_QUALIFY_WE = "0" *) 
  (* C_REG_DPRA_INPUT = "0" *) 
  (* c_addr_width = "12" *) 
  (* c_default_data = "0" *) 
  (* c_depth = "4096" *) 
  (* c_elaboration_dir = "./" *) 
  (* c_has_clk = "0" *) 
  (* c_has_qspo = "0" *) 
  (* c_has_qspo_ce = "0" *) 
  (* c_has_qspo_rst = "0" *) 
  (* c_has_qspo_srst = "0" *) 
  (* c_has_spo = "1" *) 
  (* c_mem_init_file = "font_rom.mif" *) 
  (* c_parser_type = "1" *) 
  (* c_read_mif = "1" *) 
  (* c_reg_a_d_inputs = "0" *) 
  (* c_sync_enable = "1" *) 
  (* c_width = "8" *) 
  (* is_du_within_envelope = "true" *) 
  font_rom_dist_mem_gen_v8_0_17 U0
       (.a(a),
        .clk(1'b0),
        .d({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dpo(NLW_U0_dpo_UNCONNECTED[7:0]),
        .dpra({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .i_ce(1'b1),
        .qdpo(NLW_U0_qdpo_UNCONNECTED[7:0]),
        .qdpo_ce(1'b1),
        .qdpo_clk(1'b0),
        .qdpo_rst(1'b0),
        .qdpo_srst(1'b0),
        .qspo(NLW_U0_qspo_UNCONNECTED[7:0]),
        .qspo_ce(1'b1),
        .qspo_rst(1'b0),
        .qspo_srst(1'b0),
        .spo(spo),
        .we(1'b0));
endmodule

module m_hsync_vga
   (o_vga_red_OBUF,
    _rst_sync_vga_reg,
    o_vga_green_OBUF,
    o_vga_blue_OBUF,
    o_hsync_OBUF,
    _endLine,
    DI,
    \_pixelCounter_reg[0]_0 ,
    \_pixelCounter_reg[8]_0 ,
    addrb,
    \_lineCounter_reg[5] ,
    \_pixelCounter_reg[9]_0 ,
    S,
    CLK,
    SR,
    _enVGA_sync,
    Q,
    \_vga_blue_reg[3]_0 ,
    spo);
  output [0:0]o_vga_red_OBUF;
  output _rst_sync_vga_reg;
  output [0:0]o_vga_green_OBUF;
  output [0:0]o_vga_blue_OBUF;
  output o_hsync_OBUF;
  output _endLine;
  output [2:0]DI;
  output \_pixelCounter_reg[0]_0 ;
  output \_pixelCounter_reg[8]_0 ;
  output [2:0]addrb;
  output [0:0]\_lineCounter_reg[5] ;
  output \_pixelCounter_reg[9]_0 ;
  output [2:0]S;
  input CLK;
  input [0:0]SR;
  input _enVGA_sync;
  input [2:0]Q;
  input [3:0]\_vga_blue_reg[3]_0 ;
  input [7:0]spo;

  wire CLK;
  wire [2:0]DI;
  wire \FSM_sequential__state[0]_i_1_n_0 ;
  wire \FSM_sequential__state[0]_i_2_n_0 ;
  wire \FSM_sequential__state[0]_i_3_n_0 ;
  wire \FSM_sequential__state[0]_i_4_n_0 ;
  wire \FSM_sequential__state[1]_i_2_n_0 ;
  wire \FSM_sequential__state[1]_i_3_n_0 ;
  wire \FSM_sequential__state_reg_n_0_[0] ;
  wire \FSM_sequential__state_reg_n_0_[1] ;
  wire [2:0]Q;
  wire [2:0]S;
  wire [0:0]SR;
  wire _enVGA_sync;
  wire _endLine;
  wire _endLine_i_1_n_0;
  wire _hsync;
  wire [0:0]\_lineCounter_reg[5] ;
  wire [9:4]_pixelCounter;
  wire \_pixelCounter[0]_i_1_n_0 ;
  wire \_pixelCounter[1]_i_1_n_0 ;
  wire \_pixelCounter[2]_i_1_n_0 ;
  wire \_pixelCounter[2]_i_2_n_0 ;
  wire \_pixelCounter[2]_i_3_n_0 ;
  wire \_pixelCounter[2]_i_4_n_0 ;
  wire \_pixelCounter[2]_i_5_n_0 ;
  wire \_pixelCounter[3]_i_1_n_0 ;
  wire \_pixelCounter[3]_i_2_n_0 ;
  wire \_pixelCounter[4]_i_2_n_0 ;
  wire \_pixelCounter[5]_i_2_n_0 ;
  wire \_pixelCounter[6]_i_2_n_0 ;
  wire \_pixelCounter[6]_i_3_n_0 ;
  wire \_pixelCounter[6]_i_4_n_0 ;
  wire \_pixelCounter[6]_i_5_n_0 ;
  wire \_pixelCounter[6]_i_6_n_0 ;
  wire \_pixelCounter[8]_i_2_n_0 ;
  wire \_pixelCounter_reg[0]_0 ;
  wire \_pixelCounter_reg[8]_0 ;
  wire \_pixelCounter_reg[9]_0 ;
  wire \_pixelCounter_reg_n_0_[0] ;
  wire \_pixelCounter_reg_n_0_[1] ;
  wire \_pixelCounter_reg_n_0_[2] ;
  wire \_pixelCounter_reg_n_0_[3] ;
  wire \_pixelCounter_reg_n_0_[4] ;
  wire \_pixelCounter_reg_n_0_[5] ;
  wire \_pixelCounter_reg_n_0_[6] ;
  wire \_pixelCounter_reg_n_0_[7] ;
  wire \_pixelCounter_reg_n_0_[8] ;
  wire \_pixelCounter_reg_n_0_[9] ;
  wire _rst_sync_vga_reg;
  wire \_vga_blue[3]_i_1_n_0 ;
  wire [3:0]\_vga_blue_reg[3]_0 ;
  wire \_vga_green[3]_i_1_n_0 ;
  wire _vga_red;
  wire \_vga_red[3]_i_2_n_0 ;
  wire \_vga_red[3]_i_3_n_0 ;
  wire \_vga_red[3]_i_4_n_0 ;
  wire \_vga_red[3]_i_5_n_0 ;
  wire [2:0]addrb;
  wire o_hsync_OBUF;
  wire [0:0]o_vga_blue_OBUF;
  wire [0:0]o_vga_green_OBUF;
  wire [0:0]o_vga_red_OBUF;
  wire [7:0]spo;
  wire u_char_buf_i_5_n_0;
  wire u_char_buf_i_6_n_0;
  wire u_char_buf_i_7_n_0;

  LUT6 #(
    .INIT(64'h47474747FF33CC00)) 
    \FSM_sequential__state[0]_i_1 
       (.I0(u_char_buf_i_6_n_0),
        .I1(\FSM_sequential__state_reg_n_0_[1] ),
        .I2(\FSM_sequential__state[1]_i_3_n_0 ),
        .I3(\FSM_sequential__state[0]_i_2_n_0 ),
        .I4(\FSM_sequential__state[0]_i_3_n_0 ),
        .I5(\FSM_sequential__state_reg_n_0_[0] ),
        .O(\FSM_sequential__state[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFEFFFFFFFEFFFE)) 
    \FSM_sequential__state[0]_i_2 
       (.I0(\_pixelCounter_reg_n_0_[9] ),
        .I1(\_pixelCounter_reg_n_0_[7] ),
        .I2(\_pixelCounter_reg_n_0_[8] ),
        .I3(\_pixelCounter_reg_n_0_[6] ),
        .I4(\FSM_sequential__state[0]_i_4_n_0 ),
        .I5(\_pixelCounter_reg_n_0_[5] ),
        .O(\FSM_sequential__state[0]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFFD)) 
    \FSM_sequential__state[0]_i_3 
       (.I0(\FSM_sequential__state[0]_i_4_n_0 ),
        .I1(\_pixelCounter_reg_n_0_[6] ),
        .I2(\_pixelCounter_reg_n_0_[8] ),
        .I3(\_pixelCounter_reg_n_0_[7] ),
        .I4(\_pixelCounter_reg_n_0_[9] ),
        .I5(\_pixelCounter_reg_n_0_[5] ),
        .O(\FSM_sequential__state[0]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h15555555)) 
    \FSM_sequential__state[0]_i_4 
       (.I0(\_pixelCounter_reg_n_0_[4] ),
        .I1(\_pixelCounter_reg_n_0_[0] ),
        .I2(\_pixelCounter_reg_n_0_[1] ),
        .I3(\_pixelCounter_reg_n_0_[2] ),
        .I4(\_pixelCounter_reg_n_0_[3] ),
        .O(\FSM_sequential__state[0]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'hB)) 
    \FSM_sequential__state[1]_i_1__1 
       (.I0(SR),
        .I1(_enVGA_sync),
        .O(_rst_sync_vga_reg));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'h38F8)) 
    \FSM_sequential__state[1]_i_2 
       (.I0(\FSM_sequential__state[1]_i_3_n_0 ),
        .I1(\FSM_sequential__state_reg_n_0_[0] ),
        .I2(\FSM_sequential__state_reg_n_0_[1] ),
        .I3(u_char_buf_i_6_n_0),
        .O(\FSM_sequential__state[1]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFEFEFEFEFE)) 
    \FSM_sequential__state[1]_i_3 
       (.I0(\_pixelCounter_reg_n_0_[8] ),
        .I1(\_pixelCounter_reg_n_0_[7] ),
        .I2(\_pixelCounter_reg_n_0_[9] ),
        .I3(\_pixelCounter_reg_n_0_[5] ),
        .I4(u_char_buf_i_5_n_0),
        .I5(\_pixelCounter_reg_n_0_[6] ),
        .O(\FSM_sequential__state[1]_i_3_n_0 ));
  (* FSM_ENCODED_STATES = "FRONT_PORCH:00,SYNC:01,BACK_PORCH:10,VISIBLE:11" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_sequential__state_reg[0] 
       (.C(CLK),
        .CE(1'b1),
        .D(\FSM_sequential__state[0]_i_1_n_0 ),
        .Q(\FSM_sequential__state_reg_n_0_[0] ),
        .R(_rst_sync_vga_reg));
  (* FSM_ENCODED_STATES = "FRONT_PORCH:00,SYNC:01,BACK_PORCH:10,VISIBLE:11" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_sequential__state_reg[1] 
       (.C(CLK),
        .CE(1'b1),
        .D(\FSM_sequential__state[1]_i_2_n_0 ),
        .Q(\FSM_sequential__state_reg_n_0_[1] ),
        .R(_rst_sync_vga_reg));
  LUT4 #(
    .INIT(16'h00B4)) 
    _char_idx_la__0_carry__0_i_3
       (.I0(\_pixelCounter_reg[8]_0 ),
        .I1(Q[1]),
        .I2(Q[2]),
        .I3(\_pixelCounter_reg[0]_0 ),
        .O(\_lineCounter_reg[5] ));
  LUT4 #(
    .INIT(16'h9A65)) 
    _char_idx_la__0_carry_i_1
       (.I0(\_pixelCounter_reg[0]_0 ),
        .I1(\_pixelCounter_reg[8]_0 ),
        .I2(Q[1]),
        .I3(Q[2]),
        .O(DI[2]));
  LUT4 #(
    .INIT(16'h00D2)) 
    _char_idx_la__0_carry_i_2
       (.I0(\_pixelCounter_reg_n_0_[7] ),
        .I1(\_pixelCounter[8]_i_2_n_0 ),
        .I2(\_pixelCounter_reg_n_0_[8] ),
        .I3(\_pixelCounter_reg_n_0_[9] ),
        .O(DI[1]));
  LUT3 #(
    .INIT(8'h41)) 
    _char_idx_la__0_carry_i_3
       (.I0(\_pixelCounter_reg_n_0_[9] ),
        .I1(\_pixelCounter[8]_i_2_n_0 ),
        .I2(\_pixelCounter_reg_n_0_[7] ),
        .O(DI[0]));
  LUT6 #(
    .INIT(64'h2465FF65DB9A009A)) 
    _char_idx_la__0_carry_i_5
       (.I0(\_pixelCounter_reg_n_0_[8] ),
        .I1(\_pixelCounter[8]_i_2_n_0 ),
        .I2(\_pixelCounter_reg_n_0_[7] ),
        .I3(\_pixelCounter_reg_n_0_[9] ),
        .I4(Q[0]),
        .I5(Q[1]),
        .O(S[2]));
  LUT5 #(
    .INIT(32'h1C34E3CB)) 
    _char_idx_la__0_carry_i_6
       (.I0(\_pixelCounter_reg_n_0_[9] ),
        .I1(\_pixelCounter_reg_n_0_[7] ),
        .I2(\_pixelCounter[8]_i_2_n_0 ),
        .I3(\_pixelCounter_reg_n_0_[8] ),
        .I4(Q[0]),
        .O(S[1]));
  LUT4 #(
    .INIT(16'h0078)) 
    _char_idx_la__0_carry_i_7
       (.I0(u_char_buf_i_5_n_0),
        .I1(\_pixelCounter_reg_n_0_[5] ),
        .I2(\_pixelCounter_reg_n_0_[6] ),
        .I3(u_char_buf_i_6_n_0),
        .O(S[0]));
  LUT6 #(
    .INIT(64'h2045FFFFFFFFFFFF)) 
    _char_idx_la__0_carry_i_8
       (.I0(\_pixelCounter_reg_n_0_[8] ),
        .I1(u_char_buf_i_7_n_0),
        .I2(\_pixelCounter_reg_n_0_[0] ),
        .I3(\_pixelCounter_reg_n_0_[7] ),
        .I4(\_pixelCounter_reg_n_0_[9] ),
        .I5(Q[0]),
        .O(\_pixelCounter_reg[8]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT5 #(
    .INIT(32'h55D57757)) 
    _char_idx_la__0_carry_i_9
       (.I0(\_pixelCounter_reg_n_0_[9] ),
        .I1(\_pixelCounter_reg_n_0_[7] ),
        .I2(\_pixelCounter_reg_n_0_[0] ),
        .I3(u_char_buf_i_7_n_0),
        .I4(\_pixelCounter_reg_n_0_[8] ),
        .O(\_pixelCounter_reg[9]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'hFC80)) 
    _endLine_i_1
       (.I0(u_char_buf_i_6_n_0),
        .I1(\FSM_sequential__state_reg_n_0_[0] ),
        .I2(\FSM_sequential__state_reg_n_0_[1] ),
        .I3(_endLine),
        .O(_endLine_i_1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    _endLine_reg
       (.C(CLK),
        .CE(1'b1),
        .D(_endLine_i_1_n_0),
        .Q(_endLine),
        .R(_rst_sync_vga_reg));
  LUT2 #(
    .INIT(4'hB)) 
    _hsync_i_1
       (.I0(\FSM_sequential__state_reg_n_0_[1] ),
        .I1(\FSM_sequential__state_reg_n_0_[0] ),
        .O(_hsync));
  FDSE #(
    .INIT(1'b1)) 
    _hsync_reg
       (.C(CLK),
        .CE(1'b1),
        .D(_hsync),
        .Q(o_hsync_OBUF),
        .S(_rst_sync_vga_reg));
  LUT6 #(
    .INIT(64'h5555004055550141)) 
    \_pixelCounter[0]_i_1 
       (.I0(\_pixelCounter_reg_n_0_[0] ),
        .I1(\FSM_sequential__state_reg_n_0_[1] ),
        .I2(\FSM_sequential__state_reg_n_0_[0] ),
        .I3(u_char_buf_i_6_n_0),
        .I4(\_pixelCounter[6]_i_3_n_0 ),
        .I5(\FSM_sequential__state[0]_i_3_n_0 ),
        .O(\_pixelCounter[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000F2FFF2FF0000)) 
    \_pixelCounter[1]_i_1 
       (.I0(_vga_red),
        .I1(u_char_buf_i_6_n_0),
        .I2(\_pixelCounter[6]_i_3_n_0 ),
        .I3(\_pixelCounter[2]_i_2_n_0 ),
        .I4(\_pixelCounter_reg_n_0_[0] ),
        .I5(\_pixelCounter_reg_n_0_[1] ),
        .O(\_pixelCounter[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hF2FF00000000F2FF)) 
    \_pixelCounter[2]_i_1 
       (.I0(_vga_red),
        .I1(u_char_buf_i_6_n_0),
        .I2(\_pixelCounter[6]_i_3_n_0 ),
        .I3(\_pixelCounter[2]_i_2_n_0 ),
        .I4(\_pixelCounter[2]_i_3_n_0 ),
        .I5(\_pixelCounter_reg_n_0_[2] ),
        .O(\_pixelCounter[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFFE)) 
    \_pixelCounter[2]_i_2 
       (.I0(\_pixelCounter_reg_n_0_[5] ),
        .I1(\_pixelCounter[2]_i_4_n_0 ),
        .I2(\_pixelCounter_reg_n_0_[4] ),
        .I3(\_pixelCounter[2]_i_5_n_0 ),
        .I4(\FSM_sequential__state_reg_n_0_[0] ),
        .I5(\FSM_sequential__state_reg_n_0_[1] ),
        .O(\_pixelCounter[2]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT2 #(
    .INIT(4'h7)) 
    \_pixelCounter[2]_i_3 
       (.I0(\_pixelCounter_reg_n_0_[1] ),
        .I1(\_pixelCounter_reg_n_0_[0] ),
        .O(\_pixelCounter[2]_i_3_n_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \_pixelCounter[2]_i_4 
       (.I0(\_pixelCounter_reg_n_0_[6] ),
        .I1(\_pixelCounter_reg_n_0_[8] ),
        .I2(\_pixelCounter_reg_n_0_[7] ),
        .I3(\_pixelCounter_reg_n_0_[9] ),
        .O(\_pixelCounter[2]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \_pixelCounter[2]_i_5 
       (.I0(\_pixelCounter_reg_n_0_[3] ),
        .I1(\_pixelCounter_reg_n_0_[2] ),
        .I2(\_pixelCounter_reg_n_0_[1] ),
        .I3(\_pixelCounter_reg_n_0_[0] ),
        .O(\_pixelCounter[2]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h5555004055550141)) 
    \_pixelCounter[3]_i_1 
       (.I0(\_pixelCounter[3]_i_2_n_0 ),
        .I1(\FSM_sequential__state_reg_n_0_[1] ),
        .I2(\FSM_sequential__state_reg_n_0_[0] ),
        .I3(u_char_buf_i_6_n_0),
        .I4(\_pixelCounter[6]_i_3_n_0 ),
        .I5(\FSM_sequential__state[0]_i_3_n_0 ),
        .O(\_pixelCounter[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'h9555)) 
    \_pixelCounter[3]_i_2 
       (.I0(\_pixelCounter_reg_n_0_[3] ),
        .I1(\_pixelCounter_reg_n_0_[2] ),
        .I2(\_pixelCounter_reg_n_0_[1] ),
        .I3(\_pixelCounter_reg_n_0_[0] ),
        .O(\_pixelCounter[3]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h00220A00AA220A00)) 
    \_pixelCounter[4]_i_1 
       (.I0(\_pixelCounter[4]_i_2_n_0 ),
        .I1(\FSM_sequential__state[0]_i_2_n_0 ),
        .I2(\FSM_sequential__state[1]_i_3_n_0 ),
        .I3(\FSM_sequential__state_reg_n_0_[0] ),
        .I4(\FSM_sequential__state_reg_n_0_[1] ),
        .I5(u_char_buf_i_6_n_0),
        .O(_pixelCounter[4]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'h6AAAAAAA)) 
    \_pixelCounter[4]_i_2 
       (.I0(\_pixelCounter_reg_n_0_[4] ),
        .I1(\_pixelCounter_reg_n_0_[0] ),
        .I2(\_pixelCounter_reg_n_0_[1] ),
        .I3(\_pixelCounter_reg_n_0_[2] ),
        .I4(\_pixelCounter_reg_n_0_[3] ),
        .O(\_pixelCounter[4]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h00220A00AA220A00)) 
    \_pixelCounter[5]_i_1 
       (.I0(\_pixelCounter[5]_i_2_n_0 ),
        .I1(\FSM_sequential__state[0]_i_2_n_0 ),
        .I2(\FSM_sequential__state[1]_i_3_n_0 ),
        .I3(\FSM_sequential__state_reg_n_0_[0] ),
        .I4(\FSM_sequential__state_reg_n_0_[1] ),
        .I5(u_char_buf_i_6_n_0),
        .O(_pixelCounter[5]));
  LUT6 #(
    .INIT(64'h6AAAAAAAAAAAAAAA)) 
    \_pixelCounter[5]_i_2 
       (.I0(\_pixelCounter_reg_n_0_[5] ),
        .I1(\_pixelCounter_reg_n_0_[4] ),
        .I2(\_pixelCounter_reg_n_0_[3] ),
        .I3(\_pixelCounter_reg_n_0_[2] ),
        .I4(\_pixelCounter_reg_n_0_[1] ),
        .I5(\_pixelCounter_reg_n_0_[0] ),
        .O(\_pixelCounter[5]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAAAA0080AAAA0282)) 
    \_pixelCounter[6]_i_1 
       (.I0(\_pixelCounter[6]_i_2_n_0 ),
        .I1(\FSM_sequential__state_reg_n_0_[1] ),
        .I2(\FSM_sequential__state_reg_n_0_[0] ),
        .I3(u_char_buf_i_6_n_0),
        .I4(\_pixelCounter[6]_i_3_n_0 ),
        .I5(\FSM_sequential__state[0]_i_3_n_0 ),
        .O(_pixelCounter[6]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'h6A)) 
    \_pixelCounter[6]_i_2 
       (.I0(\_pixelCounter_reg_n_0_[6] ),
        .I1(\_pixelCounter_reg_n_0_[5] ),
        .I2(u_char_buf_i_5_n_0),
        .O(\_pixelCounter[6]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0000001130330000)) 
    \_pixelCounter[6]_i_3 
       (.I0(\_pixelCounter[6]_i_4_n_0 ),
        .I1(\_pixelCounter[6]_i_5_n_0 ),
        .I2(\_pixelCounter[6]_i_6_n_0 ),
        .I3(\_pixelCounter_reg_n_0_[6] ),
        .I4(\FSM_sequential__state_reg_n_0_[0] ),
        .I5(\FSM_sequential__state_reg_n_0_[1] ),
        .O(\_pixelCounter[6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAAAAAAAA80000000)) 
    \_pixelCounter[6]_i_4 
       (.I0(\_pixelCounter_reg_n_0_[5] ),
        .I1(\_pixelCounter_reg_n_0_[3] ),
        .I2(\_pixelCounter_reg_n_0_[2] ),
        .I3(\_pixelCounter_reg_n_0_[1] ),
        .I4(\_pixelCounter_reg_n_0_[0] ),
        .I5(\_pixelCounter_reg_n_0_[4] ),
        .O(\_pixelCounter[6]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'hFE)) 
    \_pixelCounter[6]_i_5 
       (.I0(\_pixelCounter_reg_n_0_[9] ),
        .I1(\_pixelCounter_reg_n_0_[7] ),
        .I2(\_pixelCounter_reg_n_0_[8] ),
        .O(\_pixelCounter[6]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h1555555555555555)) 
    \_pixelCounter[6]_i_6 
       (.I0(\_pixelCounter_reg_n_0_[5] ),
        .I1(\_pixelCounter_reg_n_0_[4] ),
        .I2(\_pixelCounter_reg_n_0_[3] ),
        .I3(\_pixelCounter_reg_n_0_[2] ),
        .I4(\_pixelCounter_reg_n_0_[1] ),
        .I5(\_pixelCounter_reg_n_0_[0] ),
        .O(\_pixelCounter[6]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'h00008008)) 
    \_pixelCounter[7]_i_1 
       (.I0(\FSM_sequential__state_reg_n_0_[0] ),
        .I1(\FSM_sequential__state_reg_n_0_[1] ),
        .I2(\_pixelCounter_reg_n_0_[7] ),
        .I3(\_pixelCounter[8]_i_2_n_0 ),
        .I4(\_pixelCounter_reg_n_0_[9] ),
        .O(_pixelCounter[7]));
  LUT6 #(
    .INIT(64'h0800000808000800)) 
    \_pixelCounter[8]_i_1 
       (.I0(\FSM_sequential__state_reg_n_0_[0] ),
        .I1(\FSM_sequential__state_reg_n_0_[1] ),
        .I2(\_pixelCounter_reg_n_0_[9] ),
        .I3(\_pixelCounter_reg_n_0_[8] ),
        .I4(\_pixelCounter[8]_i_2_n_0 ),
        .I5(\_pixelCounter_reg_n_0_[7] ),
        .O(_pixelCounter[8]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT2 #(
    .INIT(4'hB)) 
    \_pixelCounter[8]_i_2 
       (.I0(u_char_buf_i_7_n_0),
        .I1(\_pixelCounter_reg_n_0_[0] ),
        .O(\_pixelCounter[8]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h08)) 
    \_pixelCounter[9]_i_1 
       (.I0(\FSM_sequential__state_reg_n_0_[0] ),
        .I1(\FSM_sequential__state_reg_n_0_[1] ),
        .I2(\_pixelCounter_reg[0]_0 ),
        .O(_pixelCounter[9]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'hFFF2DFFF)) 
    \_pixelCounter[9]_i_2 
       (.I0(\_pixelCounter_reg_n_0_[0] ),
        .I1(u_char_buf_i_7_n_0),
        .I2(\_pixelCounter_reg_n_0_[7] ),
        .I3(\_pixelCounter_reg_n_0_[8] ),
        .I4(\_pixelCounter_reg_n_0_[9] ),
        .O(\_pixelCounter_reg[0]_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \_pixelCounter_reg[0] 
       (.C(CLK),
        .CE(1'b1),
        .D(\_pixelCounter[0]_i_1_n_0 ),
        .Q(\_pixelCounter_reg_n_0_[0] ),
        .R(_rst_sync_vga_reg));
  FDRE #(
    .INIT(1'b0)) 
    \_pixelCounter_reg[1] 
       (.C(CLK),
        .CE(1'b1),
        .D(\_pixelCounter[1]_i_1_n_0 ),
        .Q(\_pixelCounter_reg_n_0_[1] ),
        .R(_rst_sync_vga_reg));
  FDRE #(
    .INIT(1'b0)) 
    \_pixelCounter_reg[2] 
       (.C(CLK),
        .CE(1'b1),
        .D(\_pixelCounter[2]_i_1_n_0 ),
        .Q(\_pixelCounter_reg_n_0_[2] ),
        .R(_rst_sync_vga_reg));
  FDRE #(
    .INIT(1'b0)) 
    \_pixelCounter_reg[3] 
       (.C(CLK),
        .CE(1'b1),
        .D(\_pixelCounter[3]_i_1_n_0 ),
        .Q(\_pixelCounter_reg_n_0_[3] ),
        .R(_rst_sync_vga_reg));
  FDRE #(
    .INIT(1'b0)) 
    \_pixelCounter_reg[4] 
       (.C(CLK),
        .CE(1'b1),
        .D(_pixelCounter[4]),
        .Q(\_pixelCounter_reg_n_0_[4] ),
        .R(_rst_sync_vga_reg));
  FDRE #(
    .INIT(1'b0)) 
    \_pixelCounter_reg[5] 
       (.C(CLK),
        .CE(1'b1),
        .D(_pixelCounter[5]),
        .Q(\_pixelCounter_reg_n_0_[5] ),
        .R(_rst_sync_vga_reg));
  FDRE #(
    .INIT(1'b0)) 
    \_pixelCounter_reg[6] 
       (.C(CLK),
        .CE(1'b1),
        .D(_pixelCounter[6]),
        .Q(\_pixelCounter_reg_n_0_[6] ),
        .R(_rst_sync_vga_reg));
  FDRE #(
    .INIT(1'b0)) 
    \_pixelCounter_reg[7] 
       (.C(CLK),
        .CE(1'b1),
        .D(_pixelCounter[7]),
        .Q(\_pixelCounter_reg_n_0_[7] ),
        .R(_rst_sync_vga_reg));
  FDRE #(
    .INIT(1'b0)) 
    \_pixelCounter_reg[8] 
       (.C(CLK),
        .CE(1'b1),
        .D(_pixelCounter[8]),
        .Q(\_pixelCounter_reg_n_0_[8] ),
        .R(_rst_sync_vga_reg));
  FDRE #(
    .INIT(1'b0)) 
    \_pixelCounter_reg[9] 
       (.C(CLK),
        .CE(1'b1),
        .D(_pixelCounter[9]),
        .Q(\_pixelCounter_reg_n_0_[9] ),
        .R(_rst_sync_vga_reg));
  LUT6 #(
    .INIT(64'h4444444444444454)) 
    \_vga_blue[3]_i_1 
       (.I0(u_char_buf_i_6_n_0),
        .I1(\_vga_red[3]_i_3_n_0 ),
        .I2(\_vga_blue_reg[3]_0 [0]),
        .I3(\_vga_blue_reg[3]_0 [1]),
        .I4(\_vga_blue_reg[3]_0 [2]),
        .I5(\_vga_blue_reg[3]_0 [3]),
        .O(\_vga_blue[3]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \_vga_blue_reg[3] 
       (.C(CLK),
        .CE(_vga_red),
        .D(\_vga_blue[3]_i_1_n_0 ),
        .Q(o_vga_blue_OBUF),
        .R(_rst_sync_vga_reg));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h44444454)) 
    \_vga_green[3]_i_1 
       (.I0(u_char_buf_i_6_n_0),
        .I1(\_vga_red[3]_i_3_n_0 ),
        .I2(\_vga_blue_reg[3]_0 [1]),
        .I3(\_vga_blue_reg[3]_0 [2]),
        .I4(\_vga_blue_reg[3]_0 [3]),
        .O(\_vga_green[3]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \_vga_green_reg[3] 
       (.C(CLK),
        .CE(_vga_red),
        .D(\_vga_green[3]_i_1_n_0 ),
        .Q(o_vga_green_OBUF),
        .R(_rst_sync_vga_reg));
  LUT2 #(
    .INIT(4'h8)) 
    \_vga_red[3]_i_1 
       (.I0(\FSM_sequential__state_reg_n_0_[1] ),
        .I1(\FSM_sequential__state_reg_n_0_[0] ),
        .O(_vga_red));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h4544)) 
    \_vga_red[3]_i_2 
       (.I0(u_char_buf_i_6_n_0),
        .I1(\_vga_red[3]_i_3_n_0 ),
        .I2(\_vga_blue_reg[3]_0 [3]),
        .I3(\_vga_blue_reg[3]_0 [2]),
        .O(\_vga_red[3]_i_2_n_0 ));
  LUT4 #(
    .INIT(16'h02A2)) 
    \_vga_red[3]_i_3 
       (.I0(\_vga_blue_reg[3]_0 [3]),
        .I1(\_vga_red[3]_i_4_n_0 ),
        .I2(\_pixelCounter_reg_n_0_[2] ),
        .I3(\_vga_red[3]_i_5_n_0 ),
        .O(\_vga_red[3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \_vga_red[3]_i_4 
       (.I0(spo[4]),
        .I1(spo[5]),
        .I2(\_pixelCounter_reg_n_0_[1] ),
        .I3(spo[6]),
        .I4(\_pixelCounter_reg_n_0_[0] ),
        .I5(spo[7]),
        .O(\_vga_red[3]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \_vga_red[3]_i_5 
       (.I0(spo[0]),
        .I1(spo[1]),
        .I2(\_pixelCounter_reg_n_0_[1] ),
        .I3(spo[2]),
        .I4(\_pixelCounter_reg_n_0_[0] ),
        .I5(spo[3]),
        .O(\_vga_red[3]_i_5_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \_vga_red_reg[3] 
       (.C(CLK),
        .CE(_vga_red),
        .D(\_vga_red[3]_i_2_n_0 ),
        .Q(o_vga_red_OBUF),
        .R(_rst_sync_vga_reg));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'h06)) 
    u_char_buf_i_2
       (.I0(u_char_buf_i_5_n_0),
        .I1(\_pixelCounter_reg_n_0_[5] ),
        .I2(u_char_buf_i_6_n_0),
        .O(addrb[2]));
  LUT6 #(
    .INIT(64'h000000007FFF8000)) 
    u_char_buf_i_3
       (.I0(\_pixelCounter_reg_n_0_[3] ),
        .I1(\_pixelCounter_reg_n_0_[2] ),
        .I2(\_pixelCounter_reg_n_0_[1] ),
        .I3(\_pixelCounter_reg_n_0_[0] ),
        .I4(\_pixelCounter_reg_n_0_[4] ),
        .I5(u_char_buf_i_6_n_0),
        .O(addrb[1]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'h00007F80)) 
    u_char_buf_i_4
       (.I0(\_pixelCounter_reg_n_0_[0] ),
        .I1(\_pixelCounter_reg_n_0_[1] ),
        .I2(\_pixelCounter_reg_n_0_[2] ),
        .I3(\_pixelCounter_reg_n_0_[3] ),
        .I4(u_char_buf_i_6_n_0),
        .O(addrb[0]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h80000000)) 
    u_char_buf_i_5
       (.I0(\_pixelCounter_reg_n_0_[0] ),
        .I1(\_pixelCounter_reg_n_0_[1] ),
        .I2(\_pixelCounter_reg_n_0_[2] ),
        .I3(\_pixelCounter_reg_n_0_[3] ),
        .I4(\_pixelCounter_reg_n_0_[4] ),
        .O(u_char_buf_i_5_n_0));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'hA8AAA8A8)) 
    u_char_buf_i_6
       (.I0(\_pixelCounter_reg_n_0_[9] ),
        .I1(\_pixelCounter_reg_n_0_[8] ),
        .I2(\_pixelCounter_reg_n_0_[7] ),
        .I3(u_char_buf_i_7_n_0),
        .I4(\_pixelCounter_reg_n_0_[0] ),
        .O(u_char_buf_i_6_n_0));
  LUT6 #(
    .INIT(64'h7FFFFFFFFFFFFFFF)) 
    u_char_buf_i_7
       (.I0(\_pixelCounter_reg_n_0_[1] ),
        .I1(\_pixelCounter_reg_n_0_[2] ),
        .I2(\_pixelCounter_reg_n_0_[6] ),
        .I3(\_pixelCounter_reg_n_0_[5] ),
        .I4(\_pixelCounter_reg_n_0_[4] ),
        .I5(\_pixelCounter_reg_n_0_[3] ),
        .O(u_char_buf_i_7_n_0));
endmodule

module m_vga_mmio
   (o_vga_red_OBUF,
    o_vga_green_OBUF,
    o_vga_blue_OBUF,
    o_hsync_OBUF,
    o_vsync_OBUF,
    clk_out1,
    CLK,
    _rst_sync,
    Q,
    i_ascii_valid_IBUF,
    _SrcImg0_reg_0,
    _we,
    D);
  output [0:0]o_vga_red_OBUF;
  output [0:0]o_vga_green_OBUF;
  output [0:0]o_vga_blue_OBUF;
  output o_hsync_OBUF;
  output o_vsync_OBUF;
  input clk_out1;
  input CLK;
  input _rst_sync;
  input [3:0]Q;
  input i_ascii_valid_IBUF;
  input _SrcImg0_reg_0;
  input _we;
  input [7:0]D;

  wire CLK;
  wire [7:0]D;
  wire [3:0]Q;
  wire _SrcImg0_i_1_n_0;
  wire _SrcImg0_reg_0;
  wire _auto_inc;
  wire _auto_inc_i_1_n_0;
  wire _char_addr;
  wire \_char_addr[0]_i_1_n_0 ;
  wire \_char_addr[0]_i_4_n_0 ;
  wire \_char_addr[0]_i_5_n_0 ;
  wire \_char_addr[0]_i_6_n_0 ;
  wire [11:0]_char_addr_reg;
  wire \_char_addr_reg[0]_i_3_n_0 ;
  wire \_char_addr_reg[0]_i_3_n_1 ;
  wire \_char_addr_reg[0]_i_3_n_2 ;
  wire \_char_addr_reg[0]_i_3_n_3 ;
  wire \_char_addr_reg[0]_i_3_n_4 ;
  wire \_char_addr_reg[0]_i_3_n_5 ;
  wire \_char_addr_reg[0]_i_3_n_6 ;
  wire \_char_addr_reg[0]_i_3_n_7 ;
  wire \_char_addr_reg[4]_i_1_n_0 ;
  wire \_char_addr_reg[4]_i_1_n_1 ;
  wire \_char_addr_reg[4]_i_1_n_2 ;
  wire \_char_addr_reg[4]_i_1_n_3 ;
  wire \_char_addr_reg[4]_i_1_n_4 ;
  wire \_char_addr_reg[4]_i_1_n_5 ;
  wire \_char_addr_reg[4]_i_1_n_6 ;
  wire \_char_addr_reg[4]_i_1_n_7 ;
  wire \_char_addr_reg[8]_i_1_n_1 ;
  wire \_char_addr_reg[8]_i_1_n_2 ;
  wire \_char_addr_reg[8]_i_1_n_3 ;
  wire \_char_addr_reg[8]_i_1_n_4 ;
  wire \_char_addr_reg[8]_i_1_n_5 ;
  wire \_char_addr_reg[8]_i_1_n_6 ;
  wire \_char_addr_reg[8]_i_1_n_7 ;
  wire [7:0]_char_ascii;
  wire [11:3]_char_idx_la;
  wire _char_idx_la__0_carry__0_n_0;
  wire _char_idx_la__0_carry__0_n_1;
  wire _char_idx_la__0_carry__0_n_2;
  wire _char_idx_la__0_carry__0_n_3;
  wire _char_idx_la__0_carry_n_0;
  wire _char_idx_la__0_carry_n_1;
  wire _char_idx_la__0_carry_n_2;
  wire _char_idx_la__0_carry_n_3;
  wire [11:0]_char_waddr;
  wire [7:0]_char_wdata;
  wire _char_we;
  wire _enVGA;
  wire _enVGA_i_1_n_0;
  wire _enVGA_meta;
  wire _enVGA_sync;
  wire _endLine;
  wire [7:0]_font_data;
  wire [4:0]_imgData_meta;
  wire [4:0]_imgData_sync;
  wire [4:0]_imgData_sys;
  wire [3:0]_lineCounter_0;
  wire _rst_meta;
  wire _rst_sync;
  wire _rst_sync_vga;
  wire _rst_sync_vga_i_1_n_0;
  wire _we;
  wire clk_out1;
  wire hsync_module_n_1;
  wire hsync_module_n_10;
  wire hsync_module_n_11;
  wire hsync_module_n_12;
  wire hsync_module_n_13;
  wire hsync_module_n_14;
  wire hsync_module_n_15;
  wire hsync_module_n_16;
  wire hsync_module_n_17;
  wire hsync_module_n_18;
  wire hsync_module_n_6;
  wire hsync_module_n_7;
  wire hsync_module_n_8;
  wire hsync_module_n_9;
  wire i_ascii_valid_IBUF;
  wire o_hsync_OBUF;
  wire [0:0]o_vga_blue_OBUF;
  wire [0:0]o_vga_green_OBUF;
  wire [0:0]o_vga_red_OBUF;
  wire o_vsync_OBUF;
  wire [4:3]p_0_in0_out;
  wire vsync_module_n_1;
  wire vsync_module_n_12;
  wire vsync_module_n_13;
  wire vsync_module_n_14;
  wire vsync_module_n_15;
  wire vsync_module_n_2;
  wire vsync_module_n_3;
  wire vsync_module_n_9;
  wire [3:3]\NLW__char_addr_reg[8]_i_1_CO_UNCONNECTED ;

  FDRE #(
    .INIT(1'b0)) 
    _SrcChar_reg
       (.C(clk_out1),
        .CE(_SrcImg0_i_1_n_0),
        .D(Q[3]),
        .Q(_imgData_sys[4]),
        .R(_rst_sync));
  LUT3 #(
    .INIT(8'h08)) 
    _SrcImg0_i_1
       (.I0(_SrcImg0_reg_0),
        .I1(_we),
        .I2(i_ascii_valid_IBUF),
        .O(_SrcImg0_i_1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    _SrcImg0_reg
       (.C(clk_out1),
        .CE(_SrcImg0_i_1_n_0),
        .D(Q[0]),
        .Q(_imgData_sys[0]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    _SrcImg1_reg
       (.C(clk_out1),
        .CE(_SrcImg0_i_1_n_0),
        .D(Q[1]),
        .Q(_imgData_sys[1]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    _SrcImg2_reg
       (.C(clk_out1),
        .CE(_SrcImg0_i_1_n_0),
        .D(Q[2]),
        .Q(_imgData_sys[2]),
        .R(_rst_sync));
  LUT6 #(
    .INIT(64'h00000000AABAAA8A)) 
    _auto_inc_i_1
       (.I0(_auto_inc),
        .I1(i_ascii_valid_IBUF),
        .I2(_we),
        .I3(_SrcImg0_reg_0),
        .I4(Q[1]),
        .I5(_rst_sync),
        .O(_auto_inc_i_1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    _auto_inc_reg
       (.C(clk_out1),
        .CE(1'b1),
        .D(_auto_inc_i_1_n_0),
        .Q(_auto_inc),
        .R(1'b0));
  LUT5 #(
    .INIT(32'hAAEAAAAA)) 
    \_char_addr[0]_i_1 
       (.I0(_rst_sync),
        .I1(_auto_inc),
        .I2(_char_addr_reg[11]),
        .I3(\_char_addr[0]_i_4_n_0 ),
        .I4(i_ascii_valid_IBUF),
        .O(\_char_addr[0]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \_char_addr[0]_i_2 
       (.I0(i_ascii_valid_IBUF),
        .I1(_auto_inc),
        .O(_char_addr));
  LUT6 #(
    .INIT(64'h00000000000055F7)) 
    \_char_addr[0]_i_4 
       (.I0(_char_addr_reg[8]),
        .I1(_char_addr_reg[6]),
        .I2(\_char_addr[0]_i_6_n_0 ),
        .I3(_char_addr_reg[7]),
        .I4(_char_addr_reg[10]),
        .I5(_char_addr_reg[9]),
        .O(\_char_addr[0]_i_4_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \_char_addr[0]_i_5 
       (.I0(_char_addr_reg[0]),
        .O(\_char_addr[0]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h000000007FFFFFFF)) 
    \_char_addr[0]_i_6 
       (.I0(_char_addr_reg[0]),
        .I1(_char_addr_reg[2]),
        .I2(_char_addr_reg[1]),
        .I3(_char_addr_reg[4]),
        .I4(_char_addr_reg[3]),
        .I5(_char_addr_reg[5]),
        .O(\_char_addr[0]_i_6_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \_char_addr_reg[0] 
       (.C(clk_out1),
        .CE(_char_addr),
        .D(\_char_addr_reg[0]_i_3_n_7 ),
        .Q(_char_addr_reg[0]),
        .R(\_char_addr[0]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \_char_addr_reg[0]_i_3 
       (.CI(1'b0),
        .CO({\_char_addr_reg[0]_i_3_n_0 ,\_char_addr_reg[0]_i_3_n_1 ,\_char_addr_reg[0]_i_3_n_2 ,\_char_addr_reg[0]_i_3_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b1}),
        .O({\_char_addr_reg[0]_i_3_n_4 ,\_char_addr_reg[0]_i_3_n_5 ,\_char_addr_reg[0]_i_3_n_6 ,\_char_addr_reg[0]_i_3_n_7 }),
        .S({_char_addr_reg[3:1],\_char_addr[0]_i_5_n_0 }));
  FDRE #(
    .INIT(1'b0)) 
    \_char_addr_reg[10] 
       (.C(clk_out1),
        .CE(_char_addr),
        .D(\_char_addr_reg[8]_i_1_n_5 ),
        .Q(_char_addr_reg[10]),
        .R(\_char_addr[0]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \_char_addr_reg[11] 
       (.C(clk_out1),
        .CE(_char_addr),
        .D(\_char_addr_reg[8]_i_1_n_4 ),
        .Q(_char_addr_reg[11]),
        .R(\_char_addr[0]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \_char_addr_reg[1] 
       (.C(clk_out1),
        .CE(_char_addr),
        .D(\_char_addr_reg[0]_i_3_n_6 ),
        .Q(_char_addr_reg[1]),
        .R(\_char_addr[0]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \_char_addr_reg[2] 
       (.C(clk_out1),
        .CE(_char_addr),
        .D(\_char_addr_reg[0]_i_3_n_5 ),
        .Q(_char_addr_reg[2]),
        .R(\_char_addr[0]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \_char_addr_reg[3] 
       (.C(clk_out1),
        .CE(_char_addr),
        .D(\_char_addr_reg[0]_i_3_n_4 ),
        .Q(_char_addr_reg[3]),
        .R(\_char_addr[0]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \_char_addr_reg[4] 
       (.C(clk_out1),
        .CE(_char_addr),
        .D(\_char_addr_reg[4]_i_1_n_7 ),
        .Q(_char_addr_reg[4]),
        .R(\_char_addr[0]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \_char_addr_reg[4]_i_1 
       (.CI(\_char_addr_reg[0]_i_3_n_0 ),
        .CO({\_char_addr_reg[4]_i_1_n_0 ,\_char_addr_reg[4]_i_1_n_1 ,\_char_addr_reg[4]_i_1_n_2 ,\_char_addr_reg[4]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\_char_addr_reg[4]_i_1_n_4 ,\_char_addr_reg[4]_i_1_n_5 ,\_char_addr_reg[4]_i_1_n_6 ,\_char_addr_reg[4]_i_1_n_7 }),
        .S(_char_addr_reg[7:4]));
  FDRE #(
    .INIT(1'b0)) 
    \_char_addr_reg[5] 
       (.C(clk_out1),
        .CE(_char_addr),
        .D(\_char_addr_reg[4]_i_1_n_6 ),
        .Q(_char_addr_reg[5]),
        .R(\_char_addr[0]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \_char_addr_reg[6] 
       (.C(clk_out1),
        .CE(_char_addr),
        .D(\_char_addr_reg[4]_i_1_n_5 ),
        .Q(_char_addr_reg[6]),
        .R(\_char_addr[0]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \_char_addr_reg[7] 
       (.C(clk_out1),
        .CE(_char_addr),
        .D(\_char_addr_reg[4]_i_1_n_4 ),
        .Q(_char_addr_reg[7]),
        .R(\_char_addr[0]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \_char_addr_reg[8] 
       (.C(clk_out1),
        .CE(_char_addr),
        .D(\_char_addr_reg[8]_i_1_n_7 ),
        .Q(_char_addr_reg[8]),
        .R(\_char_addr[0]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \_char_addr_reg[8]_i_1 
       (.CI(\_char_addr_reg[4]_i_1_n_0 ),
        .CO({\NLW__char_addr_reg[8]_i_1_CO_UNCONNECTED [3],\_char_addr_reg[8]_i_1_n_1 ,\_char_addr_reg[8]_i_1_n_2 ,\_char_addr_reg[8]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\_char_addr_reg[8]_i_1_n_4 ,\_char_addr_reg[8]_i_1_n_5 ,\_char_addr_reg[8]_i_1_n_6 ,\_char_addr_reg[8]_i_1_n_7 }),
        .S(_char_addr_reg[11:8]));
  FDRE #(
    .INIT(1'b0)) 
    \_char_addr_reg[9] 
       (.C(clk_out1),
        .CE(_char_addr),
        .D(\_char_addr_reg[8]_i_1_n_6 ),
        .Q(_char_addr_reg[9]),
        .R(\_char_addr[0]_i_1_n_0 ));
  CARRY4 _char_idx_la__0_carry
       (.CI(1'b0),
        .CO({_char_idx_la__0_carry_n_0,_char_idx_la__0_carry_n_1,_char_idx_la__0_carry_n_2,_char_idx_la__0_carry_n_3}),
        .CYINIT(1'b0),
        .DI({hsync_module_n_6,hsync_module_n_7,hsync_module_n_8,1'b0}),
        .O(_char_idx_la[6:3]),
        .S({vsync_module_n_15,hsync_module_n_16,hsync_module_n_17,hsync_module_n_18}));
  CARRY4 _char_idx_la__0_carry__0
       (.CI(_char_idx_la__0_carry_n_0),
        .CO({_char_idx_la__0_carry__0_n_0,_char_idx_la__0_carry__0_n_1,_char_idx_la__0_carry__0_n_2,_char_idx_la__0_carry__0_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,p_0_in0_out[3],vsync_module_n_9,hsync_module_n_14}),
        .O(_char_idx_la[10:7]),
        .S({p_0_in0_out[4],vsync_module_n_12,vsync_module_n_13,vsync_module_n_14}));
  FDRE #(
    .INIT(1'b0)) 
    \_char_waddr_reg[0] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(_char_addr_reg[0]),
        .Q(_char_waddr[0]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_waddr_reg[10] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(_char_addr_reg[10]),
        .Q(_char_waddr[10]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_waddr_reg[11] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(_char_addr_reg[11]),
        .Q(_char_waddr[11]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_waddr_reg[1] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(_char_addr_reg[1]),
        .Q(_char_waddr[1]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_waddr_reg[2] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(_char_addr_reg[2]),
        .Q(_char_waddr[2]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_waddr_reg[3] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(_char_addr_reg[3]),
        .Q(_char_waddr[3]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_waddr_reg[4] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(_char_addr_reg[4]),
        .Q(_char_waddr[4]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_waddr_reg[5] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(_char_addr_reg[5]),
        .Q(_char_waddr[5]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_waddr_reg[6] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(_char_addr_reg[6]),
        .Q(_char_waddr[6]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_waddr_reg[7] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(_char_addr_reg[7]),
        .Q(_char_waddr[7]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_waddr_reg[8] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(_char_addr_reg[8]),
        .Q(_char_waddr[8]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_waddr_reg[9] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(_char_addr_reg[9]),
        .Q(_char_waddr[9]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_wdata_reg[0] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(D[0]),
        .Q(_char_wdata[0]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_wdata_reg[1] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(D[1]),
        .Q(_char_wdata[1]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_wdata_reg[2] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(D[2]),
        .Q(_char_wdata[2]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_wdata_reg[3] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(D[3]),
        .Q(_char_wdata[3]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_wdata_reg[4] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(D[4]),
        .Q(_char_wdata[4]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_wdata_reg[5] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(D[5]),
        .Q(_char_wdata[5]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_wdata_reg[6] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(D[6]),
        .Q(_char_wdata[6]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    \_char_wdata_reg[7] 
       (.C(clk_out1),
        .CE(i_ascii_valid_IBUF),
        .D(D[7]),
        .Q(_char_wdata[7]),
        .R(_rst_sync));
  FDRE #(
    .INIT(1'b0)) 
    _char_we_reg
       (.C(clk_out1),
        .CE(1'b1),
        .D(i_ascii_valid_IBUF),
        .Q(_char_we),
        .R(_rst_sync));
  LUT6 #(
    .INIT(64'h00000000AABAAA8A)) 
    _enVGA_i_1
       (.I0(_enVGA),
        .I1(i_ascii_valid_IBUF),
        .I2(_we),
        .I3(_SrcImg0_reg_0),
        .I4(Q[0]),
        .I5(_rst_sync),
        .O(_enVGA_i_1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    _enVGA_meta_reg
       (.C(CLK),
        .CE(1'b1),
        .D(_enVGA),
        .Q(_enVGA_meta),
        .R(_rst_sync_vga));
  FDRE #(
    .INIT(1'b0)) 
    _enVGA_reg
       (.C(clk_out1),
        .CE(1'b1),
        .D(_enVGA_i_1_n_0),
        .Q(_enVGA),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    _enVGA_sync_reg
       (.C(CLK),
        .CE(1'b1),
        .D(_enVGA_meta),
        .Q(_enVGA_sync),
        .R(_rst_sync_vga));
  FDRE #(
    .INIT(1'b0)) 
    \_imgData_meta_reg[0] 
       (.C(CLK),
        .CE(1'b1),
        .D(_imgData_sys[0]),
        .Q(_imgData_meta[0]),
        .R(_rst_sync_vga));
  FDRE #(
    .INIT(1'b0)) 
    \_imgData_meta_reg[1] 
       (.C(CLK),
        .CE(1'b1),
        .D(_imgData_sys[1]),
        .Q(_imgData_meta[1]),
        .R(_rst_sync_vga));
  FDRE #(
    .INIT(1'b0)) 
    \_imgData_meta_reg[2] 
       (.C(CLK),
        .CE(1'b1),
        .D(_imgData_sys[2]),
        .Q(_imgData_meta[2]),
        .R(_rst_sync_vga));
  FDRE #(
    .INIT(1'b0)) 
    \_imgData_meta_reg[4] 
       (.C(CLK),
        .CE(1'b1),
        .D(_imgData_sys[4]),
        .Q(_imgData_meta[4]),
        .R(_rst_sync_vga));
  FDRE #(
    .INIT(1'b0)) 
    \_imgData_sync_reg[0] 
       (.C(CLK),
        .CE(1'b1),
        .D(_imgData_meta[0]),
        .Q(_imgData_sync[0]),
        .R(_rst_sync_vga));
  FDRE #(
    .INIT(1'b0)) 
    \_imgData_sync_reg[1] 
       (.C(CLK),
        .CE(1'b1),
        .D(_imgData_meta[1]),
        .Q(_imgData_sync[1]),
        .R(_rst_sync_vga));
  FDRE #(
    .INIT(1'b0)) 
    \_imgData_sync_reg[2] 
       (.C(CLK),
        .CE(1'b1),
        .D(_imgData_meta[2]),
        .Q(_imgData_sync[2]),
        .R(_rst_sync_vga));
  FDRE #(
    .INIT(1'b0)) 
    \_imgData_sync_reg[4] 
       (.C(CLK),
        .CE(1'b1),
        .D(_imgData_meta[4]),
        .Q(_imgData_sync[4]),
        .R(_rst_sync_vga));
  FDRE #(
    .INIT(1'b0)) 
    _rst_meta_reg
       (.C(CLK),
        .CE(1'b1),
        .D(_rst_sync),
        .Q(_rst_meta),
        .R(1'b0));
  LUT2 #(
    .INIT(4'hE)) 
    _rst_sync_vga_i_1
       (.I0(_rst_meta),
        .I1(_rst_sync),
        .O(_rst_sync_vga_i_1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    _rst_sync_vga_reg
       (.C(CLK),
        .CE(1'b1),
        .D(_rst_sync_vga_i_1_n_0),
        .Q(_rst_sync_vga),
        .R(1'b0));
  (* CHECK_LICENSE_TYPE = "font_rom,dist_mem_gen_v8_0_17,{}" *) 
  (* IMPORTED_FROM = "/home/mendes/VGA_cararter_display/VGA_cararter_display.gen/sources_1/ip/font_rom/font_rom.dcp" *) 
  (* IMPORTED_TYPE = "CHECKPOINT" *) 
  (* IS_IMPORTED *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* x_core_info = "dist_mem_gen_v8_0_17,Vivado 2025.1" *) 
  font_rom font_lut
       (.a({_char_ascii,_lineCounter_0}),
        .spo(_font_data));
  m_hsync_vga hsync_module
       (.CLK(CLK),
        .DI({hsync_module_n_6,hsync_module_n_7,hsync_module_n_8}),
        .Q({vsync_module_n_1,vsync_module_n_2,vsync_module_n_3}),
        .S({hsync_module_n_16,hsync_module_n_17,hsync_module_n_18}),
        .SR(_rst_sync_vga),
        ._enVGA_sync(_enVGA_sync),
        ._endLine(_endLine),
        .\_lineCounter_reg[5] (hsync_module_n_14),
        .\_pixelCounter_reg[0]_0 (hsync_module_n_9),
        .\_pixelCounter_reg[8]_0 (hsync_module_n_10),
        .\_pixelCounter_reg[9]_0 (hsync_module_n_15),
        ._rst_sync_vga_reg(hsync_module_n_1),
        .\_vga_blue_reg[3]_0 ({_imgData_sync[4],_imgData_sync[2:0]}),
        .addrb({hsync_module_n_11,hsync_module_n_12,hsync_module_n_13}),
        .o_hsync_OBUF(o_hsync_OBUF),
        .o_vga_blue_OBUF(o_vga_blue_OBUF),
        .o_vga_green_OBUF(o_vga_green_OBUF),
        .o_vga_red_OBUF(o_vga_red_OBUF),
        .spo(_font_data));
  (* CHECK_LICENSE_TYPE = "char_buffer_bram,blk_mem_gen_v8_4_11,{}" *) 
  (* IMPORTED_FROM = "/home/mendes/VGA_cararter_display/VGA_cararter_display.gen/sources_1/ip/char_buffer_bram/char_buffer_bram.dcp" *) 
  (* IMPORTED_TYPE = "CHECKPOINT" *) 
  (* IS_IMPORTED *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* x_core_info = "blk_mem_gen_v8_4_11,Vivado 2025.1" *) 
  char_buffer_bram u_char_buf
       (.addra(_char_waddr),
        .addrb({_char_idx_la,hsync_module_n_11,hsync_module_n_12,hsync_module_n_13}),
        .clka(clk_out1),
        .clkb(CLK),
        .dina(_char_wdata),
        .doutb(_char_ascii),
        .wea(_char_we));
  m_vsync_vga vsync_module
       (.CLK(CLK),
        .CO(_char_idx_la__0_carry__0_n_0),
        .DI({p_0_in0_out[3],vsync_module_n_9}),
        .Q({vsync_module_n_1,vsync_module_n_2,vsync_module_n_3,_lineCounter_0}),
        .S({p_0_in0_out[4],vsync_module_n_12,vsync_module_n_13,vsync_module_n_14}),
        .SR(hsync_module_n_1),
        ._char_idx_la__0_carry(hsync_module_n_9),
        ._char_idx_la__0_carry_0(hsync_module_n_15),
        ._char_idx_la__0_carry__0(hsync_module_n_10),
        ._char_idx_la__0_carry__0_0(hsync_module_n_14),
        ._endLine(_endLine),
        .\_lineCounter_reg[6]_0 (vsync_module_n_15),
        .addrb(_char_idx_la[11]),
        .o_vsync_OBUF(o_vsync_OBUF));
endmodule

module m_vsync_vga
   (o_vsync_OBUF,
    Q,
    DI,
    addrb,
    S,
    \_lineCounter_reg[6]_0 ,
    _endLine,
    CLK,
    SR,
    _char_idx_la__0_carry__0,
    CO,
    _char_idx_la__0_carry,
    _char_idx_la__0_carry_0,
    _char_idx_la__0_carry__0_0);
  output o_vsync_OBUF;
  output [6:0]Q;
  output [1:0]DI;
  output [0:0]addrb;
  output [3:0]S;
  output [0:0]\_lineCounter_reg[6]_0 ;
  input _endLine;
  input CLK;
  input [0:0]SR;
  input _char_idx_la__0_carry__0;
  input [0:0]CO;
  input _char_idx_la__0_carry;
  input _char_idx_la__0_carry_0;
  input [0:0]_char_idx_la__0_carry__0_0;

  wire CLK;
  wire [0:0]CO;
  wire [1:0]DI;
  wire \FSM_sequential__state[0]_i_1__0_n_0 ;
  wire \FSM_sequential__state[1]_i_1_n_0 ;
  wire \FSM_sequential__state[1]_i_2__0_n_0 ;
  wire \FSM_sequential__state[1]_i_3__0_n_0 ;
  wire \FSM_sequential__state[1]_i_4_n_0 ;
  wire \FSM_sequential__state[1]_i_5_n_0 ;
  wire \FSM_sequential__state[1]_i_6_n_0 ;
  wire \FSM_sequential__state[1]_i_7_n_0 ;
  wire \FSM_sequential__state_reg_n_0_[0] ;
  wire \FSM_sequential__state_reg_n_0_[1] ;
  wire [6:0]Q;
  wire [3:0]S;
  wire [0:0]SR;
  wire _char_idx_la__0_carry;
  wire _char_idx_la__0_carry_0;
  wire _char_idx_la__0_carry__0;
  wire [0:0]_char_idx_la__0_carry__0_0;
  wire _endLine;
  wire _endLine_0;
  wire [8:0]_lineCounter;
  wire \_lineCounter[4]_i_2_n_0 ;
  wire \_lineCounter[5]_i_2_n_0 ;
  wire \_lineCounter[5]_i_3_n_0 ;
  wire \_lineCounter[5]_i_4_n_0 ;
  wire \_lineCounter[8]_i_3_n_0 ;
  wire _lineCounter_1;
  wire [0:0]\_lineCounter_reg[6]_0 ;
  wire \_lineCounter_reg_n_0_[7] ;
  wire \_lineCounter_reg_n_0_[8] ;
  wire _vsync;
  wire [0:0]addrb;
  wire o_vsync_OBUF;
  wire [3:1]NLW_u_char_buf_i_1_CO_UNCONNECTED;
  wire [3:0]NLW_u_char_buf_i_1_O_UNCONNECTED;

  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'hE1)) 
    \FSM_sequential__state[0]_i_1__0 
       (.I0(\FSM_sequential__state[1]_i_3__0_n_0 ),
        .I1(\FSM_sequential__state[1]_i_2__0_n_0 ),
        .I2(\FSM_sequential__state_reg_n_0_[0] ),
        .O(\FSM_sequential__state[0]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT4 #(
    .INIT(16'hFD02)) 
    \FSM_sequential__state[1]_i_1 
       (.I0(\FSM_sequential__state_reg_n_0_[0] ),
        .I1(\FSM_sequential__state[1]_i_2__0_n_0 ),
        .I2(\FSM_sequential__state[1]_i_3__0_n_0 ),
        .I3(\FSM_sequential__state_reg_n_0_[1] ),
        .O(\FSM_sequential__state[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF00001051)) 
    \FSM_sequential__state[1]_i_2__0 
       (.I0(\FSM_sequential__state_reg_n_0_[1] ),
        .I1(\FSM_sequential__state_reg_n_0_[0] ),
        .I2(\FSM_sequential__state[1]_i_4_n_0 ),
        .I3(Q[3]),
        .I4(\FSM_sequential__state[1]_i_5_n_0 ),
        .I5(\FSM_sequential__state[1]_i_6_n_0 ),
        .O(\FSM_sequential__state[1]_i_2__0_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000004)) 
    \FSM_sequential__state[1]_i_3__0 
       (.I0(\FSM_sequential__state_reg_n_0_[0] ),
        .I1(\FSM_sequential__state_reg_n_0_[1] ),
        .I2(\_lineCounter_reg_n_0_[7] ),
        .I3(\_lineCounter_reg_n_0_[8] ),
        .I4(Q[6]),
        .I5(\FSM_sequential__state[1]_i_7_n_0 ),
        .O(\FSM_sequential__state[1]_i_3__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT2 #(
    .INIT(4'h1)) 
    \FSM_sequential__state[1]_i_4 
       (.I0(Q[2]),
        .I1(Q[1]),
        .O(\FSM_sequential__state[1]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \FSM_sequential__state[1]_i_5 
       (.I0(Q[6]),
        .I1(\_lineCounter_reg_n_0_[8] ),
        .I2(\_lineCounter_reg_n_0_[7] ),
        .I3(Q[5]),
        .I4(Q[4]),
        .O(\FSM_sequential__state[1]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h0888888888888888)) 
    \FSM_sequential__state[1]_i_6 
       (.I0(\FSM_sequential__state_reg_n_0_[1] ),
        .I1(\FSM_sequential__state_reg_n_0_[0] ),
        .I2(Q[5]),
        .I3(\_lineCounter_reg_n_0_[8] ),
        .I4(Q[6]),
        .I5(\_lineCounter_reg_n_0_[7] ),
        .O(\FSM_sequential__state[1]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAAAAAAAAAAAAAAA8)) 
    \FSM_sequential__state[1]_i_7 
       (.I0(Q[5]),
        .I1(Q[4]),
        .I2(Q[0]),
        .I3(Q[1]),
        .I4(Q[2]),
        .I5(Q[3]),
        .O(\FSM_sequential__state[1]_i_7_n_0 ));
  (* FSM_ENCODED_STATES = "FRONT_PORCH:00,SYNC:01,BACK_PORCH:10,VISIBLE:11" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_sequential__state_reg[0] 
       (.C(CLK),
        .CE(1'b1),
        .D(\FSM_sequential__state[0]_i_1__0_n_0 ),
        .Q(\FSM_sequential__state_reg_n_0_[0] ),
        .R(SR));
  (* FSM_ENCODED_STATES = "FRONT_PORCH:00,SYNC:01,BACK_PORCH:10,VISIBLE:11" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_sequential__state_reg[1] 
       (.C(CLK),
        .CE(1'b1),
        .D(\FSM_sequential__state[1]_i_1_n_0 ),
        .Q(\FSM_sequential__state_reg_n_0_[1] ),
        .R(SR));
  LUT4 #(
    .INIT(16'h9AAA)) 
    _char_idx_la__0_carry__0_i_1
       (.I0(\_lineCounter_reg_n_0_[7] ),
        .I1(_char_idx_la__0_carry__0),
        .I2(Q[5]),
        .I3(Q[6]),
        .O(DI[1]));
  (* HLUTNM = "lutpair0" *) 
  LUT3 #(
    .INIT(8'h90)) 
    _char_idx_la__0_carry__0_i_2
       (.I0(_char_idx_la__0_carry__0),
        .I1(Q[5]),
        .I2(\_lineCounter_reg_n_0_[7] ),
        .O(DI[0]));
  LUT5 #(
    .INIT(32'hBFFF4000)) 
    _char_idx_la__0_carry__0_i_4
       (.I0(_char_idx_la__0_carry__0),
        .I1(Q[5]),
        .I2(Q[6]),
        .I3(\_lineCounter_reg_n_0_[7] ),
        .I4(\_lineCounter_reg_n_0_[8] ),
        .O(S[3]));
  LUT5 #(
    .INIT(32'h771788E8)) 
    _char_idx_la__0_carry__0_i_5
       (.I0(\_lineCounter_reg_n_0_[8] ),
        .I1(Q[6]),
        .I2(Q[5]),
        .I3(_char_idx_la__0_carry__0),
        .I4(\_lineCounter_reg_n_0_[7] ),
        .O(S[2]));
  LUT6 #(
    .INIT(64'h99A9996966566696)) 
    _char_idx_la__0_carry__0_i_6
       (.I0(DI[0]),
        .I1(Q[6]),
        .I2(Q[5]),
        .I3(_char_idx_la__0_carry__0),
        .I4(\_lineCounter_reg_n_0_[7] ),
        .I5(\_lineCounter_reg_n_0_[8] ),
        .O(S[1]));
  (* HLUTNM = "lutpair0" *) 
  LUT5 #(
    .INIT(32'hD22D9669)) 
    _char_idx_la__0_carry__0_i_7
       (.I0(_char_idx_la__0_carry__0),
        .I1(Q[5]),
        .I2(\_lineCounter_reg_n_0_[7] ),
        .I3(_char_idx_la__0_carry__0_0),
        .I4(Q[6]),
        .O(S[0]));
  LUT5 #(
    .INIT(32'h5A69A55A)) 
    _char_idx_la__0_carry_i_4
       (.I0(Q[6]),
        .I1(Q[5]),
        .I2(_char_idx_la__0_carry),
        .I3(_char_idx_la__0_carry_0),
        .I4(Q[4]),
        .O(\_lineCounter_reg[6]_0 ));
  FDRE #(
    .INIT(1'b0)) 
    _endLine_reg
       (.C(CLK),
        .CE(1'b1),
        .D(_endLine),
        .Q(_endLine_0),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'h0E)) 
    \_lineCounter[0]_i_1 
       (.I0(\FSM_sequential__state[1]_i_2__0_n_0 ),
        .I1(\FSM_sequential__state[1]_i_3__0_n_0 ),
        .I2(Q[0]),
        .O(_lineCounter[0]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT4 #(
    .INIT(16'h0EE0)) 
    \_lineCounter[1]_i_1 
       (.I0(\FSM_sequential__state[1]_i_2__0_n_0 ),
        .I1(\FSM_sequential__state[1]_i_3__0_n_0 ),
        .I2(Q[0]),
        .I3(Q[1]),
        .O(_lineCounter[1]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT5 #(
    .INIT(32'h0EEEE000)) 
    \_lineCounter[2]_i_1 
       (.I0(\FSM_sequential__state[1]_i_2__0_n_0 ),
        .I1(\FSM_sequential__state[1]_i_3__0_n_0 ),
        .I2(Q[1]),
        .I3(Q[0]),
        .I4(Q[2]),
        .O(_lineCounter[2]));
  LUT6 #(
    .INIT(64'h0EEEEEEEE0000000)) 
    \_lineCounter[3]_i_1 
       (.I0(\FSM_sequential__state[1]_i_2__0_n_0 ),
        .I1(\FSM_sequential__state[1]_i_3__0_n_0 ),
        .I2(Q[0]),
        .I3(Q[1]),
        .I4(Q[2]),
        .I5(Q[3]),
        .O(_lineCounter[3]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT4 #(
    .INIT(16'hE00E)) 
    \_lineCounter[4]_i_1 
       (.I0(\FSM_sequential__state[1]_i_2__0_n_0 ),
        .I1(\FSM_sequential__state[1]_i_3__0_n_0 ),
        .I2(\_lineCounter[4]_i_2_n_0 ),
        .I3(Q[4]),
        .O(_lineCounter[4]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT4 #(
    .INIT(16'h7FFF)) 
    \_lineCounter[4]_i_2 
       (.I0(Q[2]),
        .I1(Q[1]),
        .I2(Q[0]),
        .I3(Q[3]),
        .O(\_lineCounter[4]_i_2_n_0 ));
  LUT4 #(
    .INIT(16'hE00E)) 
    \_lineCounter[5]_i_1 
       (.I0(\_lineCounter[5]_i_2_n_0 ),
        .I1(\FSM_sequential__state[1]_i_3__0_n_0 ),
        .I2(\_lineCounter[5]_i_3_n_0 ),
        .I3(Q[5]),
        .O(_lineCounter[5]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT5 #(
    .INIT(32'hAAAABAAA)) 
    \_lineCounter[5]_i_2 
       (.I0(\FSM_sequential__state[1]_i_6_n_0 ),
        .I1(\FSM_sequential__state[1]_i_5_n_0 ),
        .I2(\_lineCounter[5]_i_4_n_0 ),
        .I3(\FSM_sequential__state_reg_n_0_[0] ),
        .I4(\FSM_sequential__state_reg_n_0_[1] ),
        .O(\_lineCounter[5]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT5 #(
    .INIT(32'h7FFFFFFF)) 
    \_lineCounter[5]_i_3 
       (.I0(Q[3]),
        .I1(Q[0]),
        .I2(Q[1]),
        .I3(Q[2]),
        .I4(Q[4]),
        .O(\_lineCounter[5]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT3 #(
    .INIT(8'h01)) 
    \_lineCounter[5]_i_4 
       (.I0(Q[1]),
        .I1(Q[2]),
        .I2(Q[3]),
        .O(\_lineCounter[5]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT4 #(
    .INIT(16'hE00E)) 
    \_lineCounter[6]_i_1 
       (.I0(\FSM_sequential__state[1]_i_2__0_n_0 ),
        .I1(\FSM_sequential__state[1]_i_3__0_n_0 ),
        .I2(\_lineCounter[8]_i_3_n_0 ),
        .I3(Q[6]),
        .O(_lineCounter[6]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT4 #(
    .INIT(16'h8A20)) 
    \_lineCounter[7]_i_1 
       (.I0(\FSM_sequential__state[1]_i_2__0_n_0 ),
        .I1(\_lineCounter[8]_i_3_n_0 ),
        .I2(Q[6]),
        .I3(\_lineCounter_reg_n_0_[7] ),
        .O(_lineCounter[7]));
  LUT4 #(
    .INIT(16'h222F)) 
    \_lineCounter[8]_i_1 
       (.I0(_endLine),
        .I1(_endLine_0),
        .I2(\FSM_sequential__state[1]_i_2__0_n_0 ),
        .I3(\FSM_sequential__state[1]_i_3__0_n_0 ),
        .O(_lineCounter_1));
  LUT6 #(
    .INIT(64'hEE0EEEEE00E00000)) 
    \_lineCounter[8]_i_2 
       (.I0(\FSM_sequential__state[1]_i_2__0_n_0 ),
        .I1(\FSM_sequential__state[1]_i_3__0_n_0 ),
        .I2(Q[6]),
        .I3(\_lineCounter[8]_i_3_n_0 ),
        .I4(\_lineCounter_reg_n_0_[7] ),
        .I5(\_lineCounter_reg_n_0_[8] ),
        .O(_lineCounter[8]));
  LUT6 #(
    .INIT(64'h7FFFFFFFFFFFFFFF)) 
    \_lineCounter[8]_i_3 
       (.I0(Q[4]),
        .I1(Q[2]),
        .I2(Q[1]),
        .I3(Q[0]),
        .I4(Q[3]),
        .I5(Q[5]),
        .O(\_lineCounter[8]_i_3_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \_lineCounter_reg[0] 
       (.C(CLK),
        .CE(_lineCounter_1),
        .D(_lineCounter[0]),
        .Q(Q[0]),
        .R(SR));
  FDRE #(
    .INIT(1'b0)) 
    \_lineCounter_reg[1] 
       (.C(CLK),
        .CE(_lineCounter_1),
        .D(_lineCounter[1]),
        .Q(Q[1]),
        .R(SR));
  FDRE #(
    .INIT(1'b0)) 
    \_lineCounter_reg[2] 
       (.C(CLK),
        .CE(_lineCounter_1),
        .D(_lineCounter[2]),
        .Q(Q[2]),
        .R(SR));
  FDRE #(
    .INIT(1'b0)) 
    \_lineCounter_reg[3] 
       (.C(CLK),
        .CE(_lineCounter_1),
        .D(_lineCounter[3]),
        .Q(Q[3]),
        .R(SR));
  FDRE #(
    .INIT(1'b0)) 
    \_lineCounter_reg[4] 
       (.C(CLK),
        .CE(_lineCounter_1),
        .D(_lineCounter[4]),
        .Q(Q[4]),
        .R(SR));
  FDRE #(
    .INIT(1'b0)) 
    \_lineCounter_reg[5] 
       (.C(CLK),
        .CE(_lineCounter_1),
        .D(_lineCounter[5]),
        .Q(Q[5]),
        .R(SR));
  FDRE #(
    .INIT(1'b0)) 
    \_lineCounter_reg[6] 
       (.C(CLK),
        .CE(_lineCounter_1),
        .D(_lineCounter[6]),
        .Q(Q[6]),
        .R(SR));
  FDRE #(
    .INIT(1'b0)) 
    \_lineCounter_reg[7] 
       (.C(CLK),
        .CE(_lineCounter_1),
        .D(_lineCounter[7]),
        .Q(\_lineCounter_reg_n_0_[7] ),
        .R(SR));
  FDRE #(
    .INIT(1'b0)) 
    \_lineCounter_reg[8] 
       (.C(CLK),
        .CE(_lineCounter_1),
        .D(_lineCounter[8]),
        .Q(\_lineCounter_reg_n_0_[8] ),
        .R(SR));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT2 #(
    .INIT(4'hB)) 
    _vsync_i_1
       (.I0(\FSM_sequential__state_reg_n_0_[1] ),
        .I1(\FSM_sequential__state_reg_n_0_[0] ),
        .O(_vsync));
  FDSE #(
    .INIT(1'b1)) 
    _vsync_reg
       (.C(CLK),
        .CE(1'b1),
        .D(_vsync),
        .Q(o_vsync_OBUF),
        .S(SR));
  CARRY4 u_char_buf_i_1
       (.CI(CO),
        .CO({NLW_u_char_buf_i_1_CO_UNCONNECTED[3:1],addrb}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_u_char_buf_i_1_O_UNCONNECTED[3:0]),
        .S({1'b0,1'b0,1'b0,1'b1}));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2025.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
FdZ29m26W1vj+Cs/DLJCoTOUz/m7+OJG3sHOgt5s8NEPQ5FHtOFz4fRgqTgyrNzvNq21lk0VjpX9
UMVEbSXbJrC40crYnx5XneHRwr6z9uk6MXgKoH1FHcznnKhevagwuCchTCpQ6oqoMbhzWd2QHx/v
Pkor8V47KvEBnEHja7Q=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
DgywwNcpeS8jND8bxEa71yZJ3FJdVEzcLynb64dnb2TzUo3pKSGFBfaFrgTZF3YNHGzuUJ2QQktc
gOS5J0CcVw+n+aerigILzjTclkLc9eUIulkdUapbmj6Staw/UyV8tYP4SZZ8/c285RLhOXD7yU47
aByWm7LmxxWjooRAz26ybpmdt7lpHBQaNTc1Ljp9oCyvtSqxXf5Fzr6NwE9wCWHGozsMntKGlBWq
/Ld4jJ9UVtrIM3FKdUF21rHccua0AApkyY92z4umdT7kj4mZxPKTdC7zYiKWRUq2hGAlbh1z47nC
oAaSpPvOVZY7BQppznHPyLPhJ+OgKj6/rfTVMA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
TpTqgO7LVAmk2RI9B8mgZrp5H21SnS0bmTRlpg9WONkWIeKkOMiqYzKXNi+GTasTvmpRPk/h3m9P
wkWG5aX3dHNZUb1oSMhjGbyAcJpO+SX7mcsmzpt+efdEtPDukAHegpQfvEWKkx2SrrkkgD0X++Oj
CaqCq5FvcRl9RjvTxK4=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
sckknZF7xLyHpnPIcxIFLiAYqXW1FY2CS9FWi2Hqz5vcUlh7by0h8yYiwSXxIUNrBJPATd3AyESC
487cvtya2VioL8riKucCJWyqQBG7eDyT0O7JtdZYcpo9uNh6dkN86IV7J1BLYVlk/Z2uc+LRdLiA
I2w8Z4wc+UHp3wx4497iJfYpHaKSPNO+8A8WV/JJ1mzSLBI14cO9CDFly9KlHktwr4HKutMId1R2
VPSy/znW8qx9XUnd0EN31c/9LJnfU1yhBPG9Wx8Hd96IBwI9D/WgN7ZQyH8bSZCcHX+SYoIGPwXn
K5ZKQy1K7ELwUBUUPbGlR+ir3yvvGjob1CTeMg==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
T6BTO2RUQcpX9TpJR2JO50hT+cXyiDyIjrO2Ps17SKTmMhVBfSGD2AUMwzKJINBU1/wI4nqsnk0R
B5YRLWXrZfCSjSapre9CmGTRvLCDEK4mm3l4Jo9Ij9iBFg2OvLFfyBLP/fZtLtzCPHtMlTmKn7C3
9Ert7v3yDGnFF+1Msw/UpTjpdSZ4dNE8UGUe5ymCwpDVeCcYuoCTBe5o7BDlcM6cbXMfHvxQkBDH
BQkO5txX5aV2qeKOYfWQucZe9q7aoq4zcNG3roo8G4OrO31xnxdwAQU8tvOCztoGHXLSPEwLy86h
lybMIS19uovvmz2FF0BKAfQmf2zT2kdhs/0E/g==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2025.1-2029.x", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
qFdGo2cl1WGkQBqlM3e3YM1+NstrsuheqspzsHjhiEdsfZE7cNV3QtgmcPm0sQ6Ur85Vr+VLP+qi
kfkSBZv/cp96m2VbdU3wKRoyTYzTU2jPpW7sGFFNzWS9+RUl8sTVLht5d4t2CNOGni/aTPg72L/m
EMDSFNr5zmZHrz9ZfvCDtOuBIV7kMLfZPmDdxV5IwsKMxabGnoXOJGz+hfjGo4fS3o0ORBwIVK+l
mvU1GZj8rJVgjjtXmyh6mIw/6PchaANzWFqpNusTs0IG2f3q7OE0VBOM5Am+iaDdeW6TlD3NJO83
Fu/vCJwu/i0r7tthiRGj94Azl8RnEN2KK7tBlA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
g77N+3QvAPAYw+4OcZm63AqmcCkwUoxBBbPDHeq2Nfprvo7Bj7LixjYXj3xyrnR8haey/83rTRib
U8uD29Fgb15vpUc0WthyXJ59GM2fKf1KCeTQtG6TwZDLuOLNJNaeGFe+JU6iYvvLnOQZ3aPsmfcT
4GCJv1sKrMCf5d2VkK5yqBhV9Xik8ugmxG6gW1xkr0ULwrG4CYrZAEPhwUoiL+6RLajwaMyW0fhu
TihpJjKW17O8yAizfvC4zdrTR7abBHMBRX51n0fYXfSNTJZH84wlEZ/uaRGrT3tziopYXWPsmWSq
JJ5Q30ZViY8s/kqmcILk7jzkE5iBk7FfRk2AHw==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
KCCTN2ufL/SeejpVpXJmjN/FwrAflQw79fl4pWJPTrncXR+h72Z53BIfG+PPQuyFWo2dT+31hFh2
sUjBKcBwHP9yjxsmRjhWVA4YtsuTiFCa3GwHalwHMC9EJN8EOmcee6T0DD8eKj13S7DJ+LDuhg0a
CAhAdS+Z3c57AAFhfKZ64/xN+dwK+7T+oXbmBDtxKw+D7VXMZLVjJ7ozXveIocAFo9MLpyq0mXPL
m47fmY77h7JdJ8BnZ0qXpublK3I9ahjB6+iTR7hAu417IqmFRnmc0ICovANVgmMBsOU54gzqFRS1
4jIQ7pPGSuMMJ5F+bWiKn1kahxg2JXS+3rf9r5Jyc2Ht4bO62YYec93HOrFxzErn9LzUFSvXe8JC
M/OAkWw+gqiiLbQsh+1Hfn4j9JSiL/n8yCkGXAr8x/vdfzkIBv4QpsSo5rGTuXS2x27KOAsuV7X7
maV86bXDbpBaMN1hZLtFkWNpTJE03j5Hq7cTDh+EySOe2NSwB0potFkw

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
DB5hKjvS9FmG+/wPMbBeHe5M88req0CpR1ooQpQHlIx5dQoUMI8l84F0JQ8hAkUaWLkU1VXXMNmW
eRJoUf6rnT4CbNo5SFwNWSXohTyDSupMazp2OYDlVlTgfUyyJ+lVIViRHiC3vIbi1J7fLoZ1Bt9F
cr98l0aF9q+NPMPI9Xs8X4XYYXL9FyHNyb3bAoEI1OPmH5ywFB+fJ73hp3aEXHx9pcl2RKryf1m/
Q98GVV/ZXzQmgGNEdveABCSK3XNXC0Ro6IHFjACUVo3VTsjMMx1k2n+MWq7Zbp5l8ZcvX+F+NHY6
q/Cm8B96kJQ4bGZ0qnzIYoKDGY7YEGWVJFoWQg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 177856)
`pragma protect data_block
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
CQeqo6e+/t3h4bzXV2enHw==
`pragma protect end_protected
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2025.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
gydSV72FvW4hnoyUt6yZFJHfJqjRQWPUfYIuDKP0fpjrPOkLRbJGBr4Z9msYTvoIHRlYtXJ2YMY0
d1TIQb+FK4gKsTRru9wr397OxuFBsTRf4e+ZjpYZEdsnqYWcgMSzhN4yhPvO06GyZO15y/LKBxa8
3OKwxVlOLYXhv+sxdXg=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
WHB6Zbfa5Qi47krP9T4L8UnPOlr881dWx7UcYaZfNGIQQM0gadcoXbhucIpRaUuyOKxv6yhKveRN
h0l+N9+KX6rbZ6+TRhP9JAMuPhlpI7T42QtRv5zx9+m3ct5S0NMszbFaK8zeTAYra5BGP7BHmtkr
MpKfLK5sFyaTE/A7ACtAace9MwFTHDZdl9uUs4aY6KJlm6GaypKduiqkNugukJp5vlFPX/ZapJqG
KMtMhI6grhcuYb1FJrwRZ4jW7hs9HxddSdGLzsZ0HsBcO/qaCPTst+ZA0YIQfd5ULlFmPqq39FfO
p1P+2hEH2n+LycbMj5cn4Dxfqv2R8eucM78R3w==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
SmAzQA1VEuJXtJi5vXa2Jg7YvRqAJs6PX9HTZ1YqrJw4VfonBW3726gJ81BjlizpMkcf/Uk5sFIK
aPedVhEs4xCIZylz7gXYDshtytOA/pXUID2qV9nXr8qfI+FydSADUF3ScYDZmlkclFqlZrGq6DQ7
da3lJAzt2h/iR+cczrA=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
iAph5JWb/chMQpLPX1UoLjQDxN5l2I8McM/k2xN5wRht7HXoE6F5yV8luDjn3zkI6vnfUYo7BaI1
mogRRx+R3XcwxvhHr+lngh4+/YLVex1TFncl+kiUMAsu3M/FjFSiqGMVMdKTNLDqr35DuZJVyuiF
lTwXob/KkbQDJiJjBEoxbt+968rKRKRyJGcqIjm4mqRBdqMcgo3HOJFG74SFsWAQrxvXfBhdLSG3
OfoLfls9XDojBjp7G83k0h82g1eeWgBfydm/OcX9o48Pst93NvI4ua8WShZL8MCvRWYqWZrrjrWi
cfUjXAF5SDACjq1/OU6arz/Idz6/a7AP/jmexw==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
BY49GZBxBT/gjZDPyaSWlti/sctckoR7jK6NuWdhnF9tiyNfVU7BqjjwxSnyMi0Uucv1BKHXC18h
8hQbFWnNtrq71ilURotXux7sssHlVJ2i1CsJWU18DOcBWxm2ai89uwvxDJh3TJkBJixB5KPvsDhL
lWOjTvZWPoR+Ixy+Tzo+U5Vx7z7SOakRwTrn3u7+c3vmCEBphE+HKeJExhBAoOEd0SXK5iwXaByW
D7Wb7zq6NNUmnCyaJ2BG9kGxLVsf+md7SlocuaFsYyaRZhwPyTucxIlz1tLYwcytKzx0ovoax3no
nYgzlzP/F0/PDWk9BqXgr/tuclc4EZYX0cf4ng==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2025.1-2029.x", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
qGnCvL35qO7cbUEKCL50yDv1UvezcqBz601zctKop1954QlcjemzZWZHg1zJ00nJaToNdH2S8AKX
n8hNJvbQ+x5HEGL5DoSU9m5qjXd8xxocnZ0yzuZX/dGCT8kDn3gWJR2Gz13pT+w2LQUno1fX+MsC
ehgwvjBBT6GeYjdxHi+aybQUP9AblSxX/z3vh857SGCPohEWvghOgORCHAe45YD+ZWnL62FLxMM2
c+Ozq/Au/Q4q1Yzlzcfv8Mnsvg7OqOeEamQHbuYOfdkJUuYqOwsskEWW348u7FXtsf8m7P3pZyyz
IWyTDAW4igGguMPLHfbtK/twZx8ScJQmOKzglg==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Hz+6K8+wh5/fukU4ZWNDXGsq6hreSVCSPP67nA6kUz9Vpjy4TtTnOrrl1BWY0ivEC7Ldyw8VI60A
VO/WPlt409LdAZdMZGsEZ1JuTZ0m9LPcgu9CPCyoMECctmd8LHE+otY6etTmYABB9syY61rk2hrv
RgbcyT/HCK9TzWxSm+XMqvx2nvagCLkMDPh/JZv51fj2zcKaBPnxsz8rnDipaeo0fEyVRC3Y1F/V
U3RmXojBjIumPHSJkQ537dENJEIA0Ra65u8EM/+ItUn1bcryLcIbKy1xGadrHmHdHRUoRcAodO2C
B48bNVeL0VnGg8P9ACIB04lMNzn5p6A1tPOb4Q==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
YDpb+UeT0rJ543Q8wCo2xSS3gpVAT+JoStgBlV5IMjJoUOWkiOPn691FGChmDi3BTq5NxC73KHHR
1galACCjeTGq6cv+0Zc2Ocm1oobdrnSPHp7TMDr5Zle8FX6WywJCiGdoWBODggZSlbOASIK/PVfY
cZM2z60M6RSvzsi3TnYHiKYHpju8THVoSgRd6r31GcbiSy9TjjARERXan0OVc79jGuAg90mmDEEq
91eqmn6NZ9yLI2fgBjFUZbtFCpmJ8WGxOL1h39niWnRK3ZXnk8jcpnZUlxLbYTPO0Z3vVr1zrvcn
RVQloU0OLqg7M95zSs7NtX5Vzvb6jGbMehWV+WMMyxWmxL2XOwsAwPSeX2dI2r77pioY7X6VzH7f
/JxMAnq9udra3WGPsUkD1G0CvPkCC3zdxjpVaflY37ztX9UONhKtzMQa8lJc1IL8GhXRY3R9Lg2c
HIeXSGkpNNuFDqKT6Khe/6Casq+SjFJq+IH9IUtz6RUZTkbFb0Xhgm2P

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Q+63zFEYw/LeMgxa7g8g79GGvSyIKDKD8RvvC4DHDQuGObf6n9OGZX4e17v/E/+EDEwUhsWQHFDI
Lp/aH+6fNRmhu9BEWVjxq2WRrQSl4eQjfIaSOXu2dlYh3JjRJwiUp4LteVh8RFAf5t5sRQO4dRIK
x+h28yliSgibaWEAv5FaJQ1EFbNwmgedAaSYjgf2A3afBUcBh5Uy9VHbW/zRzdhhJdsVNBjZYcFy
CVLOcf1toCRp8J4U5FlnFMOzFegUbdXFQhq2VmIhPRxWjrfTk6iR4BcMEN9UMij/5IHRAeBdksyD
CqEKsyFxosbI5KVMRZ1Ln75Zipn0JdsGekHkxg==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
DPUa5DLPYRWvbPnX0U412yoWvvvHyuq43DrYmDJGTK0cR5U4U6th8icYgizC1/hUAEzt19kM/hVa
zZh7bXSWACYLpcfhPY8dRTVGDZVjpbkraw0ceBryLP7jc6Jt5JdNw88tZtZpprCB7nQ25lUL82Hf
WTwL1ZqgGIvtfHhxO0JF5L5ES5giedwQ6u5ffXG3UB6ELcpQD1NvpW5lAz4mfXyvVDCAPZN581TF
tlAy79iKbPKlJ2zFn1BS2cuRIHHe2JRxwPo+0n5VD5CXVgg+lCYxTnCxI8CdyFaTumbs4IfAKwVI
wSN/btbwDUhW9hAHWHIRo+BpdJ4qeGcTDPKtsA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
mf5hcf6JE6yLm0jNCQnHMVmogjLlPz6re0FwG67yvOJ3FuEorru0emIeAKEwgOoxjUYNWvcM7QAH
/UEeB2EIdjLl6glPAUda0HjtaCU2rdncVdM8k6DSMBggc4yo18Qx5F+1TD/RoBgoo0jNkMdDy6wJ
JHjqlN+R01z3yYIMQ9f2z6ZaYncbBYEp4+YAb7g1D7CSMxP5cFRpQznRpYp0JwqJfT9CHzlKgdab
8B288NxeLM66iYodiTS+GSRGLGtDWXpz9yeiuiPe6kJxae2GJyHIMSfluO/0Slc3m24DQNdbojf8
jdc0G2UnrDe5mCUTfYiDmpOWTUJOdYo0FK0N2g==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 26896)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
