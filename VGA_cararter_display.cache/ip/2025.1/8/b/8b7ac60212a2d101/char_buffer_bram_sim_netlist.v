// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (lin64) Build 6140274 Wed May 21 22:58:25 MDT 2025
// Date        : Sat Mar 21 18:48:24 2026
// Host        : panda running 64-bit Ubuntu 22.04.5 LTS
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ char_buffer_bram_sim_netlist.v
// Design      : char_buffer_bram
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "char_buffer_bram,blk_mem_gen_v8_4_11,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_11,Vivado 2025.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  (* C_DEFAULT_DATA = "20" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
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
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_11 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 26880)
`pragma protect data_block
9QOX4P91a+xrxs/IhA20Nbkql59Zy9izS4Wr2aiSCLqVx0UNf85/aqT5VWYKy5xqJIse3aNRgxKh
fSG/v/0ZsYAr5ld+1M/GKzuJRuT5nImzVdb7nfh8NOyzpz0q+7zoZiTyp5XDNaIATTfFMOJp945X
qcXyRyvqeF+x6admbg4vcZPmdPE5F89BAiavyDs182tXugqJoPi1K+uR/KBoFJkxr2aC80CK5riL
t6UvqraSnAjhnV1lsILft9MYTdVurZKpp42EbV3x9b6TX636Mc32EWLx5FzfKpEadq5BqQoU1vmP
SuOCZfxNsAx8z5tnEnx7YH1WejmXCZ+h0XqoL/RzG4zw9rcFUh+P8/r+v3OoY5SZKv6PVokXhTdZ
vMK3LmT0dEmf7tF6Oz3pvVdbT1KaGK4ppE2Ljt6ab9SfjzGKQkqVZ55F5WCWHvW7tUWI/9/MqUA+
K0ADeLd1fDTLEkPTf5YeoBkFlISj7qm0/ZgFJg+hP2ldfh6hpPCFqYJI2T4BVYcD+TdcgWs2ZhGt
0JTdclqmWJot5owa7ftcval7sTH648khFs2AGtxnSFa/EWyGFnHMLQfTN1IMVGpb0PSkml7ETv9L
lupM2A3Mo7tFGdr/y0p8ff9XNJHR/bGLgdx7ncADp/QTl2/qXdOy1iLZILfsNyPRNs1go1MaOvml
Cb0onU1ioQaYO7NJgnaikWyrzccrchO1G3ugN1APFju1vg/+Pdpm1vhgDvLmA7nftZZDOcQXSh+v
8Hxf9Ckq/xPslQY9JeVznUBFgTxzD0gx7NEjmIjkNv0Sgb/FAjP7jvF+CkpjcLwXZE+DcqK76kg3
rKdNXqtMUaQcNUqIXogn7WjlNOp6uqu7MFqbvhh6SSE/OQuBGeyKoKGkYC2QXQ/N00eOyed/niEl
q9FKPgJZSM4os8hFjic0wh9C3zVnnGbvd4EpxlD4xcNB4VcoVA7on53mDStnFgHuqoo0VwIV5hsG
sLJ85GNq84l1UZhCK0DQouGL7fikIrrckPBbBUtxPW0Zx2/Ti49CELcGyAO6sSxis4EqNYvCktLV
7qGDB6P5SdWDM7EnUlgTM8HVka1pJXVcJODGYdtwpFxdg5mSTN9Y3Z0M8vac9XF3HpIlo5BLtMKL
+iZ+4kTYlvlugkjDztHf/m06Y0taEbclBlT4aovar+itFBUFNhVF30tjrZ4reHRfRJLrkRFsI84k
ifZwoB2usCm9Y6gfECsBWuLXgYlN3IvGdUMYxFfoOPiLKrdKOnFqJXwa9u+YJExwtQtq74r1is0n
lMn/y91P4J9RWVUK5kyzBCstI71Uok2vyiPVd4/y0tC2Pxv6er8CNCND0GVyz2IpU7DhZ9TzP3Dh
ojEHw9dn9ZQPeQyBLDPYOiDYYSQOeEim8+o6eUfp+Z402X/S/6AznNJkonvFiaFrYNz12XL4PYU6
MerP1fwV8DE9RRE/P8ie9xyN+PrT75XXyiwNys3xS14thmCilBRNQVzcLWFMi1N/mO6MH/jyyPeh
OJqc4mkIi0zL5RU//8ap0k540rBIlg1avFK7Oz744ja5tWeOrOH9SFflYrolQ6RoO/AAJoPD8hI7
Hb+7OlLM9MvDW5/nhhoCsdjsmshjI92axH4F5KBiLzR0C1FOpbf6PgVF06cTMm8+ykdTx4lQlhbg
AFNLNcMTKHDBf9HGF6O5XDjybqWpvasEg06uX/cFCHXe+fgAeiQdRj6JYd71kQuvPwC7BEu0mYi+
tmnr8atNWgJccBhnHhxusXB4FEL7WnY3gT4Ks7bSRqbJDsmmMPQQnsdUCKNgaLs4jbwjPVD2UtQJ
VTZAQ8GsSfsvaXS6IM4Iwy8+8xsFypCKJHv6cpr5L3VwH/i/aQ8eB4isH8A8P5682YtF8DNHJp9X
fAfAk+e4pwRczJhZHLliAKNRgy7iDWaTYsY5cLxz9CqI5GaJI4dbfyLExMgymjIUbim7GpvAO+K2
F4qkdP39UurAJgzrgbRK2a0czqqGnxfsFkuGLnV8eYQ1o1YGT75uJNnd6dGQsyoKoNtW3a4WppdV
/FT86q8UGtHCYBMlzOCQ3LtFWLjJ2VqaOVYQQ/vv3/JMPzsRdx+Gh4AoEXYApG8X68U3WtKabB7d
687C1i/dvu+vm1GnK4wWoxCN9sV9I/lPlcY7Io5tkU6lGVpwo90vP5xqwiRjI5SOADuy5mB/4urT
oDXthMBk0qrnrIridwQ9UF0izJejhOXJL8nRbMsDVJ/yhyifTMIoZnvO8IPPOCqKB9O1kUx/1XZV
uDezDGcV1Q7E8L9Xv19B2kqt6FKP9Vl3Ehz4Rtz4JcgexCWbhWgYhE8g+gfxbI9HA3KBLMnsbyCT
Gp6dGrNPfjbYUeMl6pK0Nq0iR7pmpgs7E8+hs30cT3vezBgDDZGJCMcx8z7HTA3+rOS6zps2269h
BRqnQAbe+xjXmlI9gwoMWo3FsZQ4fp0v79mutmenusitWLgipksglR2nPzx+IEwxdno2MKV+e3cL
q17FmRZ0jEXoWf5zmeSIc4rFBy4necxQcoqDRjL4H2ms4+4vTYBNVuxqr5oSexd8URZSjGGkB9Pb
OSq/g+Ebeh1ILRLa5la2Kwwh0kgLQSVmuOVt52QfVkyRT68nGqebiHPMpk9az2FgTwprHiU0GE5y
hNcPPmanFtS3vsQJPPYEmEXyOjJNc3rukmLT2frzDtKrCEEFT1amBjWzNYttX/WDRJse8E12+EiO
dRZTm0JLY7jMd7y8pr9o01D/fRIKudGfe+KE+7OTas6HxJXB4EXvLaHhyHdQDQnrSpaWuvA/KPSN
cUf2CpJBcyHcTjJc+xsjLIHo3FEF3Wfa1R7XCKYQE8JCve8/U66swf/v9VcRf/JxzgGW3q4hIufs
hgxxBJ+uyis5PnWlPcrsr0UT72Y4qJtqMz9XCgUdRIXElYpp9f3Uv8bS+tzJJAfcCeNn97dVRXjZ
bO7hS4JntulLUODlYjIRg82raJfUA5GS4rzNaoOZrpuKifGk4/0l73s5sMCiE5lt3NZ59sBJ4WGS
yZWqjyfN6KX+CYrmZXA31ietePx5TNn5IC3l1EveihQ7gtOU/lEt0riu19HlrypLQpRCTaW/v/Pp
ivDWZ215a89CRrRUEPR9VF2P8GFKeV0zGctuOXJOopBqGno0Hxavfh+vszj4Z099vr6LP4Bnr+Hc
rNz+WwteWK7ao+E+VeAdxDpJJsjKsmLJcKoWPsYynkfNkJ7N2PsNpxRxwMphMml4tTyBkf+ZQyZ0
63WnIzJgnIP2OQvTbM5FMFXHwdtiiHCFUmqso4jQ7WcMfm9UdzfMTCIfI0DPrtnWGLRydWMYMjz6
kfzDMy4BetsKEoWR+zko5y2FHiGJGl67WKcAsPVWgk55mklQdvRnvzllzzo6Q94KBwsyKD1vhFQe
bxPrEB4uT67+uHrhkcD6vVCRO0Tw07Fn1BwIE4/tZTMgZvV0OL14RBOCwNX2xXsHrIiGWNUpYDca
we540LX2fWwM95Ad97JyvyGC1hLmk13c/1UqWMG+q2WVt6ImjSG6T3Pr+v7Kr7foS8ywwL3a4XIJ
rGuDMVciDbWhO/Mx6QEcWik7bSxKEacmxRcmgnwT3T76prq/pju63aNsZg9M8Z5rG0qz8y0Na9eL
xwkBj/+17eWKjCs0gUctKtHaND4lbbZWEcaXBDOm1xLIPtujXdCSBFL5Gw4zuUu4HKDjzlwGdhLZ
XK4lqFcxl8pXpnWLl+QhzPCv/wZ1c5kzd66VM2UMvqMd4LTYTRRB/edmcvGML3r8mUJ1m07xlbmf
p5Z9EPvzE9tHGy2aEdrVyNgjp/uku7w5IXlAcdDLJuxp7r2AhCGRdLdz1j8V1LUAUzr2FLto68zs
oOCKXnfBHeXMclZA3IcrGz/jz94Js3fojsKyLLeTftiykdkMGWLaGZ/1KT/IfDKM+bXnhHFof3Mq
NtbAUA13lXr3hFuCBlsQIaoC8CG/BUIDZsfQA3fcuiutbuY5R7pUxieCAGxSEj1a6laShal0jQQi
lEd+mLfwQmDn79XhvCWn8XOc+IqZrIEyrYxSSsiBX4BcdlvCfETz+6iRH/rrOah4q2wmupWRZ3NC
nR87xq973CME4YDQF0xP3V1rzBVyVvATBvLO4H+5q1C86H7k8Htf7cUIJAzD//IcJso3tEF+5KK1
bv+vfIK8zylN9I3/HhZRbhc7MdFLYGFBHFtWjOAmGEBBVLPHT6vmdnjkv8EeVemiH8hjKsp2NtUP
iK4j1G/UDNMw88car2BsXpfvdCQ+PY04mg3uMLllDTRZphIkRaPnEHRPpkZj2yGts2fS37xnr8VR
a/BlBHNOHKBCQznP6MSqaEC5qKaY8K8fr9LVVfP6kD9aXCCIOjc5zmOajnvCi3EgNxjjXKL/qFZv
OcfhYfKeDx/AOIRuhTrom3oivmrDhnZQB87FHS6AIk/R0VI7PZUcEDCdtDOVVRUtD65OogaY1k73
4Tx5tPNg2BPbRiYi32n524+xHIWpma+SJ4q4lN3z9hpQpTkJ5Mn9ETP3WfG/ltbWgFC1YaNv9P1Z
wUlcCGt8wWFsoHsYIr16V8ORjDR7NlOVZPIQlQQwCuqqguuFsqsgdltFGrcIxRtY5NoaoS+1fCz1
oequbJ3eaHxj9AdjJL13iwt7QnYVR75Vwr5KQOmLQZZv1f2lUI8N1kY4RbnWBosbiwW24Nv9CrNk
YVdOUQ36rQ2DNuhdHJMaznu9AJt96F34Hisv7xYmde+0eIbjXwj1XMaQX/gcW4qjwoJTcr2ROmIm
RAUnNYwkai1xdUxX7cWmFIsJ7BcPbpZ0aYPmHlzeSVuubmRMdmKG/IJ0cplI76+N+or36DsyfExU
LNMv7CkhfiKyFx0BykcrMZVRdlKfKgLoVUqlrgmpl1tjkxMkDrfveSNTHWBV9GccZ5e76ee7dTBT
0556AZn7Q1YmHpSsmd+epy3k58Jcw4ehnfHNyEcsvvu5l5JGJUr0QdIMXvuRKriCVWbCfOOzmGLG
+kQhREOv4Nc0Ig7XxlTXyhOckc/ksCFz/ihUof8wVkQETZiQ9FeoJfzSrg5ES8Wxlo6zlEzhqvqb
zZBwwInv4RqJEZAG7kD3vk7hWcSWIlIaAeOJmTPUhYM5GJvR6q5AfcfDAX82m/lP/JmgwAPNB4sC
iG95pBy+geqlVpuQmQ1i63bIggu5oykPxw5lOpIheHwnUkIZEFTiEpbCMXMRfU4B+afAsivVbQAk
7SYDfwSK0VgW0L2X1lcNrbiIIdneNicyWH/bJuBDXGk1cQ+0qxCMg8u5U2BHrx446F4Ozc63FipQ
6z8Z7GOGMMYkkn9dJEj7dxvn6jGaso2OiIzJxf9CVOBsUqLqCGVVHC0E3DeGFHpPZ/A/qcEhb7zW
NHc1exkhaXco4whbzuiExuzBW3dgUrG+RBqDxeOCHrQ/bJbHm71VkfAdh+gb7+YgPNyQzF+ceb6h
aRLPBWuNF3dWD7T7IKCnrzZ8aMDDwRMsqgpME/JIWS9kbLX0usp1mNCPkbbYSv2SUvCl8gashz6L
PU6/cFIqXgkCDMkdBQp7ggbC8ev3SVYBjVtcdUq09i8oMmctHxmEA4w+QRAQYqSTFPvEZwVF8Gsm
xawz1HVtN0BuOERsUCZaLA5+/pO+JHiG1iXudihuDdejp7NbhzHz+2IdDAPmpNLsJHCYqEQCKNql
xUTxGy5V6nx3cpHpqP1hmfAiNC5K/A2ge6DSPZXIyPlRMdB5YfdxrdG0F9hbhHdGnsK1C/0tps7V
vHXgFzkYJNm0EQRhfRPAfoJmeJdJpiKE9BxmG0u1pqSKLdPo8Smo79ND+gqaF/wdEt4rB9R2xCxg
y8wyFPd7yRX/b2PzpzH3hGVCHNjnmP3zDr3zp1WIoyED8UJ9MmMqhmG0Kryzs2SpowlEPiHrTJn1
BRCe7TYSCXWKDrAHnTMquWquBt0CP6zvEqga/u6FGQcO19zsiKOoCDFBX465EuU8S6fytj6JNy5w
XTmtkEWGgqrdKd10/q5RK1RpHSvRRaDdQrcTqYOvfvJobXxMYqDoIphuAKalD6uzTpHv8EUXtDMV
V9iaBUApQqxuPncRgIW/HcMYrhiTzumKmm8ikmvC79/VTAR7vwupj8zgfSe2SKSkBp8gXFEKXSdC
wg1XsBbMH8TwBEk9Gs1HnlYGEmgDJp4fBCLByCftZmE6dtSQsB5W8bA7ru+FDmIg2HPiRLSQTkyP
5c+lodaRC14R6w3e+ggsEHPJokWTSKg28i6V2H8Lgd9f7TSDkhssbErIKvriXlh9yiAe3QmfrLp/
7iS3Aj0fFZz+5OguTks53CwEWEFwWNPLacYxy2tE9/i6azAw1JIcUEtTujHIER7fTL4nHaibdLSQ
toUKbAJomXA9fCn6bl5kldIc20zzQ3lHlvdJcQTwwXgqLZJ+9S2nzLsKVOfoTzDvT95L5DHpnSBW
ABUPqBKrTaibxd2JHFp1KLFAOs6/olnGLbZY58p2e2LleKzoCrKDdTvk6RIk9LA2GOXzS0XG7CS1
8gnSPSFtrN2k7VnyZha2ZCJZxxQRZM3FMvLJZrijwThjUfyg8pKIbu8omI59NDzYx4RT45sFHVTr
hv1RXNtjf/TYS9UjxdDwI9S0ca0H5EDLxKnr2hJIcRPt8C+AkTrDauF9Tubmmi00/nnrqVcL7foq
5ZESDACT8cxd3tfANYXqi/29Y0WVis5fgS0yDhcrHfCwZU1VUv4acznY+3r4P75KTNcnUeZpLS/o
gK4FJEMOi9fIJJyW1R/cbUpeZsCBB26KwPDCOj2ypPh1MKb3/p7C4lc2eOVAgMgAAGHO0bPqaxWO
mITkgcXG6ptcvItl1mLbC58kGVb3jvB85KR1dwor3ZD7LaPP3f5rPlK6Z/+panB62PBXhr9SYppO
6xtylJUnV4/T0l+NN24NnuztIgyGK2pWjOOcklvj5BYPHXJ1Ri1BvuGNa7efcGFIqcJAtJGStmkH
R4xmodZAumSlBDsALp8ojh20aWx1LUOKpIVtiLThiXBqRekevjcR/r1IQ6TxLG++gvjOvDPl6Rrf
q3xV7ZkEopd+9qdO6OlHBJfTW8pXuznso9yd8hpoJMwCug2fC3ppn2JhV+JB/5hniytOysFAyWbs
qBvsR4sKAe2RLiPqWurszqJd/GbNgsyTa9zJWO7yKlwYkTXh6BXsx19laO/EC1Kn3up+4koMQoxZ
m9emtlKoMhEphF3WooaYVTHayR/F6Nk/fVGBOXSbDg5l946KiAs9z/EbKcsBaCBc0JFOLc6ZjyQ8
laonOQTmwAZimENSn1nB25jnPUAEC79qMFpr9akeqqdXGtzfZ8fY/tI13/CPDKXr+3AlL1cnm5iM
HwiUGEHmWgZJF/SbpnipEIvWQkypZvJS/nf9azsyAgs7kk6h3C/7HPTFt9nj9FvZvn1HWFZMOyku
p7Om4jAGRqEkelNtMrSVBhp0gm68GGo1vg5i0ewGq+h1hO5pQpowZa6sATZLFkagKotzPS/4jwa6
1r7dbpb3VHVHPp2H5SzNZGeU/gr0otjaOkKex3wfSX3AbaP/1d8lJJWnwUZOG4RvkbvqiwZJ4jM0
TE/ESe5ac1r+VAekmKSk5Iw9lEs5Ok5YGCFGdGIJrVpUOONEVb5fIwqX5TKtg5EXw/PhFCxEArzU
Fzt6iVUIOA2S0oMixc8UU1RiZChfVSr9U2/wePqFwcqApoLGmSUfUEdE8Fm3Z5h8xBREkUFxkAJ6
D73pTFtbn4vtWSQmSjC6Py6wPza/o+oProYEpVxQZDuo08U4bSClNwNXu0VoxvsIxNwNsaf4g+9r
aI2Kn4evAUTUoek7HnTxqKs+4F4rKlyRQesZDAdml+MjkEm+NHkQbpliVZtVVkoii0c4F99718Ld
kCk1S7pObyhbK5bsgwhztr1lko7AJ+pxNl+UUpLGReqXtK0BkvmmbFzW00KXu1HYPS4I381JaZf1
UEQ/7g6o7WbSJJqhXtEnGXQaXdYaY5rSGNVI+nJT8J3f8HczsExJeL2uv83pfd+owsBjhSsbzpJ5
4f9tShY2eiYVrlWIrNu+CtF8ydzgLF4TVEgUHgsnJOQAlApSMAButzVtdpp2py1iwkP7U5hZGgJI
BjXBtmE5KhHQeFaSnHzPsndlQKEEzuz/VJgDXTmL0tS9GKDO5QkKLjnJXZK0xOn+WS3emrRsSsWA
q1G5F54esvqKMOovHXucDPQYULLQajt5Zepkjp1AkjxezSnxvfEeZKb4Jkq/o9TzRVJf1Km2Cumu
uI2Aqx00yzzKF/0apd9NLQCIC9db4I4C921UqmVuMIIGKRCOqC37JLjUmmQY3bzEjPp6jkVlRuMI
LMND2PqBgyUl8eWfL8O4OAFL/jGSvbWd6LqOaYiZJduCXmwauS3Q7ZL3+z3Y9J2XOQfsaxLXLiAk
r57e135MOvIgBAHJyLz3mYR5z6oMWx7yI15q7nARQ2ojzG207bwgxSgh/Qu/2o7QMBhSwToyZOFq
HLWZPlD/msktpML2DqmwU5wrUg021y0sJ+6//x2mf0VSm4RqUrVgxba3OUzKISKAVTcgnSgsdZBw
vtRbsBEhXNpsO9+GmR0K80XCfs6XEBKpjJ2hdn40/ew3b9l0yzVJd2Xs8iAEHPfd+M2ANb0AfMzk
xoEqdQwmrXZ5JOerc2dCa/5bZTomOVuLKrP1zfyJqRJlH3IuAy+pch13yA+tfiPk8hkLR27QwfjT
u3XaEoJPFEXUubctafPZjD4tFsibHNcWQmkZXQvnv0+qBKG78ah/J7v4TDoK8aUBMjRpPDFlj55j
JgPSvT8hloKmuNGrcdL9f/MMgH47Im2jA1+BbwlXX1Qir/WF6gPesoQqzFgJLKWK+F3ohLPOfK9F
MqQ9r1ds/Q4f9P5+COFaLt0KoDBveTfCg+0jMwsbb2b1EwtHoCJXQroRclrjQhO7urgjwZ/hWqsD
uVrk5X+KARRDnhblVyRekzZwd8mmH1QjfKlhhXfk5zztLCIJCzim9+/31tRF/Lr/MHRVmsM/1NqL
x9erhEH86MqFX8uAEkEsqifvEdmdA6rcGvIaQWNY/LcW+ZazaP7h4iISnUUfRcfCspalCWnN22bv
q4i11u7YD/ujIFzwVRys4OERHEq4Dn/O30hiU+rPvz1jDHUDwryt4ZFWXfuNe0/cuoZh60vBg3Mh
aTwqXTIyUHwCgEUjCr2Uz/teilfiNW2P8vZH//1ebSG/p94Tx1ZnG1GIF/3SEVZAzjK2enq7WS5X
dlW+MLvRH2HMiy1K5x7qOnrXwZBC6Y1+cD4Jm8tbIYYB4EUOFJsS+azKYlmBJjFAmc6CC10DpYzt
7mNWNH/tk6fYFCqcqdcfFK/BuzrhZR7HNyCuBTbn437zydpom6QEkdMq8yLXPB1/AqNr7clXGHN7
mq1wCi40k3CTb80P64xhl2xrfV6CzNV8YZNVkVvUY5lZz2lRPCtVGVbbM7/VYddqGsCMw1/yHpNw
sRVx+DY2MSisoU8RdGYxZwk46Md+KLnqn49Sw2DnQx/CNVxcMbyygc6Nk3FnWJvso8Z7bwawu1IK
rPdIdrRg12ylee7+nd5/Lc0dcg1vfiTA/Wln71H1X2Dnbi8499B89wqFIUiGBJHZgZ3kDVXZEyhy
7jRv3epTBnsSW+wv3Z4FhDN1qTPd+PNCV7TCUQ9r+drKyDU4hs4ZUF0yHY1hUFbONS6jHF3ZagYB
H1A79GAjQ2wAB0mLO6gr9Vg4tGUd/MpivQQdbaJ1BiwoOyXfPrwwp0GIno1yzoceDUQLVE0C/n2c
cyLlZ4yNBBWqOvRv6RK71aW3zff9ceO5ySAwRjVkdLBYmwEyCLc2HtJwOftFO+aHUBV1LtWa3S9L
mMBk33WkBZ2d9OQ87LxNeQ1jkmzPi79Xm1MkpjyiMm9fW8M3Oinl5NQsCHWdKCVi3RU2hKxeI3a0
eGKgGksAbpGZnqOzTUKtiOvzFAgL4bGSX4UEKWTET5rLrQe5Q14T/K3voRADNhpHAIAFNc1yopcM
lWBp3/57lTGjT4aaw7h2SuZXVU5G9xNNPrxTEwUMpQFalPJtnMELLOKcMOE0zccw9CbjeikO9+BC
4ru5AhnsE49G63txOFSCHvdESmx/n8twOYl8of4Tx2J2EFATJXXX01kGBtBb4l2W9HqmzvcdZ+Sz
MrAll/TAKnPA2KmgyrWzo8XhNya8kXnxLH7Q6xaBpdpdFqPGBBY1ORQOz/T2k6H7agQBQRwTp2Bn
f2ffZ39J5kwsJA+yzwf4ffEAUgx5TBy/4zgHkU+Ykle70HHCvRMeQsWGK67ap7xZ0gIs/KruNsLF
dySloK7gR8ak3CCkRggabwgiqJwZJDxSwWt8/lyakGbBN5+r45HPPjIZRuZ6JdZzWeqqccGkcG6P
zyPGse0M1dhLUKSUJHJ6iDBUl7Of/7sY9/h5aw3vjpiB1OJnP8ioXVJxF3EZ+0VzxLaWh35GYO9S
juI7nHkCj2797+G6dBUXmI60jVNXZGqTFN0xPV9SJGCDRy0VZBkesZbsm1mi2W7CgiGHm8j6W8ei
vsnfqTXklOg0SHfeGhj/+qQb0+J6Fxplyc8/22iaflFHCvwBTLYN0g9+oYY952t4gFSApvw9nvyg
23E1boAkGrQb0LpqoK5+6B5hIjMn7EG75D8GFyAetC7JlYBtJ+VcakLVgqp1EFJ8ZReFfkHTcG9S
yWMD6lQIANAmRJciAkiTnNuHwLHub4p7KNv2P9gF1QXIMOduJIePjZmVhtUunmdCn/HeAmW99nbV
l22a7uEKE9hf2gWOX/0F/u6S+8oVIUOOJVbDrMDGrR9T+ryf5qEOMnJFVGB4JW1cNTXeywb5SpjL
MBTb5hyfhYfTBxlsRwgJYlBxZG/PKTrgo+xmyBV2rBinjvuWktsr1J5FUxPxae9XJ7cDf4zSVK0c
oVHv8cHGO8GiQxA4kcBi1LxlQPk4gtbadwSbglzZEln0oVcl2Neb5+sKW4Oeu4+duvCQ2zC1WRgn
uEofgCQeaz3MVsw5P7CZFbk8oi20ELuQau0CvDsKL59ljXfFUQpagLESK1GH7JDg4tlcKHMMYMuZ
Ji8cCaARHrYIcOk1mTUNFKNeCJVs6lX1jmepwOpO8VuweOMe1kqqgWzqvB2dZjhiJ91j1yjDDhfv
X8Vx16XZ9+O0lmXD+zObeRpGsuLQCOP6bSGBAOGa8XBAPJxmNYjDWU85LY1eTEa+KPR3tx0RHnX6
ItAeJzuB1m+goJ2DHvi5ogXcfKMxJyJuAAKZ97e+AUGZ5ehQnRvahPr9FZqrvuofvuK3qcMueux7
4G08j+6hBDDb1OjqUF6bkc7Qzj8mNs427OwJJxdEXCDtFmFFuw1A9kiWPyZPwHSwitrG/67fwVYf
Q+u4tEe0hlONm0ElPqGZKDKi3a8PtzKT4PK9JQDaLz+JgEzjySUqtOCFrF5aH0IWlr3egIT9e7Dr
akkS39vWdIUFzsGMS5XgZHVXyYgAKMgKpXi1fYTvhWzo9eXYFy0dZKgILh+XuGV4SE9QxhisSnXS
WfCQDsdutWi2YHFRm/LRoYM7zx5TSNNdL/baEvGMqWz4q9ty20SnyPy8ie709rtXugWo2apNmDlJ
IK71P1OvMtTyAdv36HEi6TPBrwxSrghv1QieUiszwxB2zLWbCrFc0nTocjrZeEy7QU+ZLZ3zNQmx
Kieq0eHZYyLDpHF5THRqI/excRO1UoxJn3ij8gsCiPRkxZBrRlLBKbMOKi4xFHsuv2/DX2CqCBcN
CZUBM/flo1GcGX5T5ZtIJQqJJKWEuwX7PbYvDbC2G8gmaRJmcA7F/e7CseIoR2B5qYLvfOtvVMI9
Yh8TRYH4JLm1ndAoXUKYZ4NhbOa9eytZup3uHliTTnlm5hi87ejhVOoUuH2fVcqZ2fFG6lVFM704
iDKTM9SS6dVQuqz3WeqlZ2FJB7PBLayhWVrJXNqxxxekpRUzsJOQv8IivSDHoSnqCgrEc4Hhkudf
MTjAeGHV9cEZcZEqY286SUWwOFNVOpYQggQ5vySrkKgGM05dn37/PDmhrha0AZS7/MF2n9klYOcK
eQha96AozBkC6JJ36aIWJZLwMGaj5R/QgHsEOQM/BupEeBnCDeWMd59Ws95/VxjIirzitiNoD+TY
ls1CcBfUVKRa/6i65R7nZC6gNeIPZJsBNjtZsqXeanPXA0XOTN1Msy8qWT7VISNs+/+3LnKP028y
vxOUw25cJ1UwreAldAxc65aq3Fx9nWaLafKbMm2/a8+oaXhBgBC5vyAkCeR+LAyIOwIBJHD3LkhE
Tu8sYjhcVKrAUBAXbIoPVK/BO4vJdTKQL9/aTd0xyEx24n1mu2vUEKen0neiDzwm+3l/x+zxHLdz
itouRXeMKMF9W7LeVksBIXX27QUhBjokc13JXcjB7DmuMwpEH6E159V0hH3G4T5ptTTg8jbPJBgI
gl2oPlccxraXSBuij1w1pi/fT+1i3vrOXwgGwXjTrd+ageQHJC+JctIybW9mCsW0zkW+sRLKLA/F
UPW2efaAXP8ldgg0LvaElqHNggnRQVI+EFVVAUdkyEzFXd5VDqkjHlbMd4zXWMpU4gOhyuYJe0X6
5IthshuZ4N+oi3pwpKjDTIynQNonMF1Nun7EN0tKVljyrJd7KKQb4QX6ZIzFVgEs213hJ1F6YVM2
bLzmHZaYF2t0MMCUnWHzAKnz6Xy5/WoI+9NcHpmPxz7XiLjiWyWCCN3ZG/cHeZ+GO8RHZivVJrv7
NuaegRYSF13mcv5iQSfvdY3IUP3ttcE68KNA+XqF2wBGUv4xsoPie8aSayGUkNJhFxr7ce2L7nng
2syRVsuJ6ls8NL7UNYf3/GWzd+CBK3/hYZz6FTaURphp0xKH9gMfcnG/aQp5TUZDCB+vO1yU1ntQ
QgLd936cxiOdpZG1vFTyOAEDv07xA7H19cr5wfjk2qL20QZ/eIPGZ4c2l7viFH/UxSGfcIt2S02e
xZBEYclkucE/qNSYIqjTy2X2PYO0vTYzGL7FK7pLuJkX4P17a71wmu1sElkie92xuHgw/yDMm5Ca
d2CJRiAzQ2BYhPXdJrAix+NdJPnSX7YOPGMC9WAV9flk1I5zwKLBa2HaNDDYcbVxSCwkpRdvFxRR
Ndht0ehsd2aPe3g3uOUHeozkxmIK8hHgcw2qdOGlD0WAUxG8wOKvT9ZfFqDk2niyH9OBTDN9zo8W
ElDNSEO2oiVRAjcuZ8GlIJvEFP+n+uFs2zqwqIlQyLVdKC8o2WmggbciLjX1/H42+q9grQXBbFt6
5vuTsAcqyJjxC71uH6wnxQ1KhBu5LTQzwK9HBTQm9rw/vfX3/scCdJdUv6a14DDO/nrzX77JAlQG
RdnUrjb6L6mCjV45wTUpQHJiGAMpdbFT5hqdZc/n6WgKmcwnIGjWSaveleUIETtu+YNTZPcxcTVM
cIVHnmEmQFpP9EtdYYfKq83BKMFLzZSpe6KciefGNkLT286mu4w2fTOLUMm8Gmx3J64pByRnRo8G
8/Vylv3RL7oWxmViZDS8FYB91N6a04sxukeEtd7IuZM98KdLza3glg0BS6aBqHCzLeYvFQTGN81T
ja3JVmy/ueXzo+xI2GGQ//SrsnMWqtqCenJgqQsncYExzvE421fn5e3vfgV67tinq97mAZK4rqsv
t2vB3XSsseYPoCRbRSnb+oMOvIrXBZepXgVOVlsM5Pw9vDI6ckV9cosgUh9+aMy7M7VHZ9CqKgyR
nts6dT0tu+PvRzxCbOooo5aiazqcGmS+YtXovu3DJerXkS1i9eSjnj0w0GLEziNV1VUbQmTBe20w
r8BJZxF7sWq+yr/2gEcFzZw9XrkEp8B/2PoO9JQu3EHZvY7/zc5jackNJ9tKw18jWkYyqGxrx+37
ewracSZFTp1dPxQYKHurHx+1vamPuIYmR4tC1cWYC7SiQYFBBa5zRIsrkkOqJl8EnFnq6D6v3K4z
4ZLFUIogwRNZdo+6hF1aPKZgq6aDTumZSkyWLJauRpzGv3oiBIFGByPyQyrFa11v8RHnnI3m5Du0
jrEo9Cnp9VDBzGFkHoSszRjalnIWUsMne6852Oh7o1zd766bpUcOmCPd/MV/CPwwyu8wXz0nuKkv
zWhAmsYGF1RAr0ZJq6sdPDN/QMhkZlY9jHkOAPYa2KVHID490OuCcjDeEuCZ2y4Cs/J0Yc64fqDa
Lmhq7IXfc4yXohqDFlTS032WI6Ce9RQayGJF7L4iicv4NfONIZXVdmdkjnBWDUTuqjkXAOJDGFXi
+3NydFqzrbhO73ta78CUbuhk3St1NtNbLm7vRAvUwx7CBm0kdESJXHqqwneNqmGy1LN75DRBFdKk
ak+66uqrav+bfYwqMYrubhyHIf0ueo6+vl9Pkb+dv7RRjN6gFmhCZLmfNOZvLkmDmaZRjuc/XKMd
qRkyKiP7dAUGKwkKxMqQihyiBzOMD/bRpFQHKNPK3cFFtXdXWUtBP7QPdM3C4BMoqN+cdDWN/zuI
f+jwbZjMpotaG47Y5MH2arwylp/3OYTUwR07LFL2wN0L2FEw9IOS3n9AtT0BOR4XKMEeTOPc6p3q
UxtBXcYrHGVmRvn73WaqUPBICXPsyD8O0QbSlAIJXVoTCkOEa8VTHrep7E9l0mwYaIbNYUK+4lsK
R1nCTfxxAZAwUBfJIpSpC3bV2i3qHrPXQBF4f3Q0r++LPEI/7oFlFOfWJLhadAmli4nfSrBpHBST
6KUlRzzgv6ptbcJkcNim2+grAgkRpJXQDgdO8vz+/0P+LfuGXTt+5IvzNSTdkG6rDuB7zkLc7g2l
gjTv2rVjPdwpi0LPfiPcoMZUfUO4c+W6q8W5E8YNq0JTG/uyl+VM65LuF/SfeDPIfhFlIkXkOQGK
NdRMc4y33xfzWwLBcv4YGX/EXQq5jZ5c8uY6CyXCuOWps0m0bA6gm70o2gNuLOkiuDU/N6FVP1vD
gEnPK8D9fS/O29y30MooxauLiidOLOYuvwIqdKpKKbHwmHrSNYhTm67q+D4OhGSvhfA1fyHLyVad
o1Zui8Lg+VxGNfp86aGkIDOUSVkj0HOxDoTYjiOuoF3ZWbmDFRxLlreensB8ixaP6TqFqxrgn158
2/eJqcPHd3Z8KwHZFKBFBdDUAvqMtaWsFsGKBmEnB+ro53ovthrHTtkSU6s4/XZhXlpxYqPgkxXO
FT/hxdxH8RWMujuAceuDuocFW4nuMptcJC8TpVeZqz48sfPUHJhhKdkeBcc5o2XUKgynVE0VZ24o
oUrkEWEY38y6EYDoeFioWCHoApJRRUiJSc48b3YYf1Wmqj4ePL7RgAXw1KTws7Fzi+vV9y40itW/
X7zhhCEsaNxHpSw1OPqbUVKSder6WHeCWFS9V+U5Xdw0qVNcJPDfdWZ93MMDEo2K1j6leMdBVkrj
Qta7PduXux9MIaViNTdrfYahH63gWw+rnibKnH7URx/k99HvGrMid/cdjUfd4sq1npBLdUxGwaaA
Do+iEwy1g8kOiFhB+l2bHH6ecCjP3AVmC3QyIwNThQUyaCB2IeL5FZQgevJ6B7lbej2x4zQKuQJX
2HXHoqi1w0D22sOpb1Crcx+HLZ4uAaAYN/QjjKcwW7HdYD1MQVwKVqZ/DoFAPyJpliiwiUeQiJld
j0hJcrB50xXvZQJ0OUri+jVfdH6HwnXQjvAFHCYOLM3i6z+AAbngJH4kYNpVIBzuDU4BnyIJj7A1
qfJxO9e7a+HhM24vY2oovDZfOLjB4T1b092CiIZflx2leY5a9nzZPPaVv2hxA/1u7pMGGNh4PGRZ
8omh84Zf9tHtjuB2/PQk4Q1lLh6M3/4jehOecYOfgkbhWikNWgJFGiPLHYovWFt9+i/enbW+DV4m
/Ldu4PLJ6Hcey4eAf5eMivW7dUYDBmLIGTPegN/JWLW8vxYhcXItLBmmzGvriqvmuzIKzxLn8qPt
hCefFZAVa4ZPdtRsq70xwtDMazIyyVsbZzccNYckE6egqQ70t9LahP6OG6l/f32FWDmIRw9oawOX
d+APPBHx1Vn8NCvNKAYT5MfzCXFgpu/03Gpe1M1iJ4lzYu7yHaJhO/c4BLDw+15QUw7arBETkn69
APusdgFaE/urZ4svPHU7qOO2yQJRpRqzOo93yvS/UMqflC3TjL5gd96/CnZ5f3Vpv3XX45LpjKRm
E5YLaG1H+JGSnqqK1UUNOIG8d4xJ2JmHQsUqMFw3kFufHo3A13jrg+kZzYEzdrSFFAxG0GH+THFY
lMQRzaINONOHM1K1NrzyUVgP92fBamwjryCUOP/Cf+MB99o2UrtB+iQo5jH9QcSnDJdsLXFUOftw
5dGjZ5eyP/Ay8xLmgnafsnUhuel8Xe8FUNa41lrzDqLcidtG1B+cJHrlKQnK8sIxaLd/GVCiMn9r
0VFSsLCiMbl+Btio/nCyobxMkTYvyNZ0Wvr3HcEP0HHBG2ezAI3qRBX1ZGK/B/gSUJr/nYbqef4l
GKmXdTFLqd536BoRONvwdZUL5FcXPhGgd8SxfmuiCT9ljUcFPSlqxnvmJ1TxCz9lsosSDfcJ1jbs
qjM6oks7BjlsyDkOzuhUWAiJBS+hu0FV1jWEDaAPx6LFilhtcfTggMrpgMULvV77p9sNz8fviATc
4yU69lEPXd4rDZVY4Z0iMhGTCLJtJXch0+GCRMrTtubDYOgbgnEiTDZfi1U9SMiouaHh/A3Yuf78
W2mnjOBjYSqwydE1kZmS7b4elBXcv2CDYKcArq414C5QWFPc02FEPtJGsz3zBEq7p4046Z6LDwj3
YMblo3XkpyPus0xiuSsPoMQ6Wp3C47XGQZxUsNJCqwWDjeyZ0TFBOYt/mOPor3Y8gu8HDCcIr0oM
2aaSCOGGBABde0HHCO1bK85eB86iTqU0f4/lOE3J5HFQgzzI5hohe8Fts/OwdEMwx7BFkW9ZgiTg
BXkjsmi7I6Jm7mS9Qw+ajyEwlkHsVlXTjKbSSKtn+6yyVGjHKQuWWjjSN2PzMT18i5S9/Up5Cy8B
coNSjA000kP0/Dis7Rt9d3aFmCY2tN6f6p58+4o4heAurB5Shn+24l4u9KAdGWO8Cct/7jwFcwyf
kHfwwgMfTsuv881+fsTsmNGBql2DOo4DV7f/xZ05i05PkoaD4ast22sosXXRp9pMUfe8t28oFP2o
QvTxKgsWiBmsIB0T8pbvG6/5BlODjxh5biud2j6kSbq/R7TO1maTTz6RsycoXYmKguIytIDuYdjG
yuxAGOAYxHbon9A1RCUt/Dy848eFxu/gEkFOanFE+EsrZfql+62vJfgimYqKouU+OfCo9DjNsvur
YWUXe8+heB2VPtw4Jj32Zf+8xVwALURjR4IDA1j9dKqkklZ4uInThlI07Nmhxs/XIgj3zaHTDlrk
ybhKAa042a+ETpeDeHR3JQ05PeIRhhqpTBOuEAxdCHfYZLtNOux/Iyjoc5fOdHAVv8RT/eQ/bRZf
KHePioiJnnbcbb/wcoepRUo18XFXOU/fW0KWMTIFEuU32TRy84SHcP9H7t7ST1aO7W/Z4BB9k64B
odvYfuaeklmPuGlBa95o/Cta+NijMAY7EWuivr4tw8+/DQRbZO4nffGlctGSEqmHJ6no6P6R9okw
l6w7RoGEsp9WujIzR5oDk+Ae7om3GjAWXZXFxIKzlkYPvHWa2nUf8HccvccROVYJ2McksihB3fc0
E7IBSHfXlaN0fn1o+BJmovj3f+SJkEz3X8JyNWmGz6ehyns3S2k2nYQRRyo2G24vUBRHyW+gETW8
OZPxSLcifqq3ObtTGBV5Oe6UJUfFGofMX/QRTajYlf78MJOkujhYbpwExFQFBgGHM6ptEiXm5uQz
FKpPnnQgiO2wkVJefSIlYnpYtoeda+Uln6YnSQ/X5SB1/80ugP6fe1pc2X5tccHzmbm0TDXrScr0
KZHJ+CjWyfYPCIcP2h1UpCIDT0U66VjMHgtUBT0kmzFjYQFIqvDNyDfy2FAXAITemQeqZSGPE3rH
4Gu0iAZul9laP/+EyH6BpGQCHUJdORuLlbMxFuyXgDzKns7u6vOmGhxwIzbtNLKziKYGkXWe5hD0
sGQMLu9VEebEMtuvFZoYyAJN5zC4rha/BXVsBI3QjJBTP5tXz59OE342NcrHGUmS49YpkDb9uMGV
X5h8s+QOe4Hpmx7Z9n5Ll9NrzBnHAsuaAor+m+fJXaOEvL+S0dWL+X6W76V8mLlJE6Db9/A4m97m
lCiEqgI8xEuoL9laheWTEK6ceVhb+7DhkySeVIpcw+AwbuYzPUEgalx9dx2U5VN8gZ8/4oy2jTsp
Uvmd/CVHLha9HQhyZiq3wQt8SBfxlyhVVi1d3uDMqzCur0MvQKfpl16urrjsVKQXzklhAE/3oB21
FksQ4VuEIA6WyxKybRk4s1Gq7f0behlLwUq+FAb3x89oYDElWCZcjoejijYVqqyomOBJkNCCsCLy
hG2ixSp53xZOCuDV56AeAxiIOvusqefE9+fIh+HCI3agAUC6tW6IJ3+tEGuRxf4RccovnHo8vraS
o+7ym3+QrZha1tDgBorxhPEiKQEL7TfHHKMdrkNkmRnY+tnu3BkP4veT73U9kgB7KtcbDPI1I31w
R97j7dcMxy/TluyqigeGFKwZjOMtH7fXcKq0jBxQoZGQoQF8ZhiVgrj6ZJHimQRZwUrh5mE8xxsC
geADYTWArWzhDSSlLotl7aTj+1ruRlxvFDPTdxrFV4IAgsUzB4qM8NRIprsF6imBuQ2UDWt5Ae3A
TxY9Gkxejs+OXGyy/dQQhWm6k8aXYAgcq5kMACPYV8979/wSHmxTcbN7b2ay3ACsosvkw3SgyCWt
plBPUSNECFH1GU8cq/I/wQPVlhvDprMJPWvHWZ97OnDWWgdDeLl2sAyPknBdS9gu83qc9OTiVuV9
klkgvlGQY/B6t1i2rC9u5y1Bz9A/HjwmFSbfxRYrfv9u2MifJYZktS3pgF3YJGce6NlaJu2YOiGe
MmGBYzLEWflv+SQikm5WH1TagDPhlzPGq5e/pn8u07wnja4mwB69wiYfmlY9Lg5mF27jgkyaG9Jn
H5JcPZSasGZ0iT3RZ7cydeekaeLPh7uHXt9GUFirvr5Yc17VudbISJ7RV8wnvel4dnwjznI4BAeM
448rm51xGlH5Hs4PyOhr5KzPdiqNkikG4HGE60kscboRHEg2iYjhRqkXeOzJo1UADsW2txaOr2wu
W/rwNsApl0rP+ZSWG1WnIdRUB7WqPIG5XA0udLuIVziWKODs2gA1gCVnEB6Tjr1IwxU+gWy2FBrV
xCcFaE+Az6e6Sdrzl+fe30rMokxHdNGXQduwM/uRXUJTvRKwaOufrPKartf+/B+xShQhkMwBi8t2
gDWce9JHLVp8JDBqv28NdxhMHy4NlwawcQ7fXz39dN1AJnWB5h8gGcm9Cqi9pTGWD8pnITVnjAXU
Twswo5h28e1OQtJLgT2MqnGwL4+RuDC1GPFpYQRLk6yiJlSSBql1wxquzN9gK83mhIISf0pZRAIh
z/qbQ2mS7C3WhgxU9vVtfR+uCWzXE9/FVd59S4pGLTOYpOq/YCe9gch1OHF0JqwReXPQuGKiQpQo
L7P4ILUH2ZD8071Xu1Fyzmy9pGHSlJYq+n4HDQiXlC4tOieYAX81Bji6WjvbvMH21bw4CcBDKNU2
6MT3nwKXr8OAD1ImBrFcT6g7tyxxzo/WHkoiMf7oE15urCXyo+PjIr0dmPDEIaUxRADFUcom/jOy
QKuE4gosyAg+ysGRYAShAVIBKWt1Pl5H0yM9stalQ8J4JVyKjCID6TLJS4EL1OxqRAYSAUB62VlJ
0Z5oaq346wWPCGHyZO1vCPhgYp8JwGleMfBifnFKjJ12lz2tM+Ddjj/trW5zP6yPpSX4DTxGGal9
FqBskjB8A75TI5cF86aP22B9mDY/w+C/gkODO3IZCPFVl1XkIrD32Z+A56rxFPdyXKrHzBfjHnwM
LBv91z6k3a/y4p9n1PCgDJRi08Y24+X9Ea/BYAlvufEmhOwBa4W7k0J41YSU0el4krOJI0rDrWZa
iXGxs7ZfsCaqv1whrDAwAL4LURRf6cQPo1XZtdVX7J+jgub8XQQzBplrxqH3e3M1aPvE4a1vmE1/
qA8tX+G2MyUo/w7vndkgJOtsG2Y1ZJBDr0SCyuAdc2rdERqW/s5yupzWyNIcidrD1MsoOJR2oFV/
tQmpIYT4qP94Ro3cltxt8FGdJJOKZx2T2Q/YhCPXZPHqEfTWnF1WJy81qbZz4v3Y4OKvhFq6Qytb
su62n4UvBVfZMvk7nWcI6gBwrF/hMnKv1DM6m0k16RO9I124atlhtks9qNFil+8XHvaawdwH3PHG
dk1z3LUyAoVpZKbEkZdrlbyO5G5Q+GSgAW8lRPfh9zdjd57E+pWy67Peu+LNtOCURf4sSIO8Om2/
W4gt3hkm5h20S34hElMnQc2oI24Rna3RFvRomFj4eTRodIt31kv3sV0vlm/vMqfFf4mgg21pzpMJ
VuEhhcREYc8zNPA5HYr0+051kMuBgR5SvbN1Nwdl/oA9wkHViovv5w7wU3l3MxjM0062wwYTDCe5
5dYMZslK/aLPq87JUe1m060N5niG4mV2M11TzQiseN6DQNA5ArXSKwxGgNeDSs4RpOvPvliF/vIr
ae6ZUlv0DhN71nM021A7XBtocfXRIrKeyriufnz6mnlApPX+l53gzRo8PFrCHMWkc9H7beb9PjuJ
nX19WHrOz15jvNAk8rlI5Q+yplP5Lu7wzIhMyndHTI80nLoO0+2L10A1xsdbsZTy86v9LmaGmKz1
gSo1FFMkzElO03OEMacsMURrL5dICQEDnEtsU0/V9rKNvvqWh/AjNW57cSLikhzuTfKVj8FqjfQu
aa8IOdEqd0GyVn2ZlagKoM8FtFFDu13lMfWYBeIWnxo55yGmcXvXc76lJH5aAFWWRLw/x6jntSDT
x1pfP0blQP97y/ekTJJZ8cohrCWpT/BRrP4YkwuHD1kAFda690M+kWrBrDbOYA2SrJhWHpToMTlS
5EU29fz8RlPNovTgHTGHdN7CKDFkW+G1ObBXYZAojQCUU9xrQQf+zG9gMWjsxbKAzN1nMfbmftUN
ixlNqq886t9MwRHv9O6ktwN+OcL/Il/x2gv8/mSzF+CdzC1a5aVylMpKPRWA1nV5i6gYfuj9SxRA
NmkRJ48JqGaUcNMiiPfelBZricLyt4LcDL14TDjsvWRd0SK6yOIorEcKzgoY1P+1xGNL/MZr4OJa
k4Hm0T+DhaRpMzvgY35pjnMlCsEFzZzLLdlSMFgIR3hBmoVM1WV59W6GuNfroB6v8NOVJmKERwRc
dkdfG0v71KYKxXP6a087bdS86hAl8n2I8ClkV+8sk7jujE6hLSj2YhHlKSKS6laSYePhkZEt6IEY
3m3t56VV8aLNqPa7XLwFpGslLRFhi88KknfS2YbWR6355tCPEs9PaGTUGxYDKitn12VfbWUMFBX0
/LgNtxBkDuOaiYT9raFjBK9GtT0+PlGYOiCLv3+NdqLTwKWsrR24pUM/OXu2NdSQ8sZesA9mWWt1
4M/CkYYD/NlA3lEEquoEZ6PWW3kmUGKAsUPN/QlkWKy2qbU2xld9NL0WrAaZItplWs+bQa9Anv/p
Z/gb8x6okXyxDkUgAlfQmi/atSNBxVh9WUhUxz1vF4Jg5bXx9k6VhWtQQsxE+EM6qOIwKuLkJMVx
j9fz6jf+Y5fiQLOhU2+fnW0H/R/4bNIJtmQIaAEJ15bs0JSXEQOGWq4EbjWz/YjtEVRorjk9ho10
HI9cPiUq1H/jwkuTD1Da4Q39Ye8sbl+HeM96YlJQikWVtBcy0lolZTsyZxUdKGVYE/pYP7ySUQ3m
kT0Ue+DhnTHPujmAPgZSzrq3asWzx5ncAtIlo1URhW53imYvNaCHUa8BYD0Hd7mGeiJ9Ycjt1D60
bF9qQotZ04QqUfGWnQQ+tBOkOTCj/ovbQsBO0etvdacxaF2PGi3dtNfqKCbVtlIjRUuOFR9GbYw4
XyKni/qDfgrv5gPs+ci5m5e6q0nMUX6BW8FAN95OKkOG6fb3KRzAPX6waeWNPNHznpNwN1rYqgHR
PwRlo34LiUneqQOG+yT7OXf2ze0Lzg10OFRz3AA5Dl6H1O4M9jY8MDsxaolC8KZlh14WcHL+y3Ly
/vqFVNt6+csuSnGHQkUEolgMUZor2P5AHe5vNUiAsOXirDrPAk6TLRp9S30LDxw1UbAFHCVyWM5b
L9tBiTtnS9IfZZgCjx7BZ3uTd8tQ9YmZdH7LBTrrn5tD5g1Cph4eYeO/5RaWExfrlsv28b1d3qLO
IDxvtGSaQGNRnDUdWGbCJce51cwb7IoFFCE59E9qZI5RHYqcXSaQu+Nx0tqFNOJhUb82ROS5KEhO
msu9SqOmz0hQ6hwbScrP9hPSYevTUbTaAmLWktvoAR7QsPG2bP4xd6kKQdZxNIDKXa5OkI+Hpmhq
7q7mCfWbBr2Fddsem5CreUOq7KJEWu6wNLyXPL1EQ38WFH4bKC9H5wnLH4SxVNp9FBe0BCAQKbCX
gahAkAWbR+PHGgHhx0kRQrEGMu5pKXsQol0C+vliHl5Cm4fkN2cpb97G59x6VHZC/Yo211M/3ecr
MkY0W0uZA1lNV67L1W/rwhD8zbogaAyaU1Ntykm8iTQFIhg1FZnZTq6mF3xmRXmY0f2pRiPQwxin
5IpQgtkQqUpM2X+EkjGbLA9caY/p53O/HMCT7A3VHmqG7utiiDd19gkbsJ0PfiSOY/RKwDaaucQL
wqQkZl6o7WnV0u4DpruCBAlnkTYdnaaW2vw/Y50U7OxXxhSL2TmlV/t7x8gxORhQKJoj3AmU5hZZ
GvSLOH44rWfNRf7Dw4fNEp5OpsCowur/aIxbMHqQmZfzI8XHjaozxgu9NNqJgnY7Q8xLk6ukFybc
CTF66f0iTz2MTXxmNIxfxRWJ9b2mTqaj6o3KWkqKUUnT918pucOeTYWZC+THQ31uwsw6V5QNm3Z4
hOs+kyOtC5XI4FBOBlfeRZj+RTIY0Nqp9AdK8w3bMygLtRydNITCNUq27fpCR64u/Dd4ox46BUcL
Fxwfoa79SML4kKcFMwyi3bL9/lywyT1hX5FQNnP23FySdgVOJW+k5QoGV2C0+wNs1fJCVw5JAD94
OIBIvXtxxZ9+rTPcki1FZ7NNfTSf4lhmp+xg52S1cHzsfQtJSP3T186MYWahoSQ1tLLfG6BOYSzL
qkllC6LoyM0VvSbT0EnAFq+jdRYc2/jA4n8lQs9TaxdisnBpSCB+5ROoPzIfg3z4ATTFmAKXzuoH
BBr0ffD6ejbmvCgh7gMFBHmaUVQGvfxFD3N++85ipVMM4HWRPqXC9o09YVwf1ZIjqA6COsy6418x
/0TXKhfk1B4dECm1Uxc7bSjnyruf2yeKrmwsgYnSzLfDjpaLu3rthbkFA6p+TYu8/U9p6qb5GE9+
RCgCgltpMK2T/N4HnVSLkWzbdKZwMDtVoo43sToyuwsosUd20VFJ/s9md0FaROIQn6BgaEbpS2Xl
C5WO3o0hMlVkQE2yGdeUtKEIPlxOgx7f2vk93PFX2V+9XwrTvR7o5s6f3wVDxew6i7lxSNu9BHFF
mSWbz83B+INmrN6RbFu5JC6VrXYqeiFPVaByla3uIQcKHCQGPwGwXq+U9LXg9g68eFzF2Hft2fJ2
9Ng6DMHyPHe68qWzX5VNd4h2hv+lKuhKp9631wlCyjFjeF9ij0uEvX+ficQBC6w8a7kLyvIFoN1S
zBRB6rlD4PTWEk8w9eueC8Pun0ek2IsZrGAtuHHz3olIC3BIAXfXPArDlasnxQb/4e5kWZu4Z2yc
Ls+67tmE3ybsmEhZMtAUdqFE6TY8CzTE76r9RzkI3/8f6OroK6TLLMZXJovLy0sCrXVPI/6ce+wY
nK3oKA5oxUUTWqqeFmmws4aTl6k3QwTth8ywq+DKnmNpvtl2BzYK0aTX6iJg0OKtc9oMZZKL4YTs
iX0NOvcJLDu31RTap2w7EUwEN1aCs16J+wvRrzeVXUtCeeoMKnxIwWXOcwCW332K7hT1kqa5ZcaY
POx4dAI72tdIS6NQDtJv0i7trwXXEDot2XpiuPJAibWueO/TwbnqRD+zxg1clkcczYIXIHCrwbWn
Bsrd0QVJMXDxZZv/N+jRVxwaGFWTp/izDG1fDxaNgmOhCiJn61dPWbRcMP3S8aCWXLemUfPIcgvg
YHq3ckVNhuAXRzqAcQUR6GYS62vtW7lCe5o/g6GyDzvbKB3m3h0pR73PcIvoi8u6o7pFwVYnbvuD
TkSGtGCC73qpLI7K3B74SXdqATSArhBVk5MaoDZ/DN84qOFZRZQ55Bi/C3VX+G5jUv6a+4LJFSb+
/hBZJhoke+WI+G7yRdpUlrOblHKx1Pt3rLJH4ZeYVahytnWlDrHPNkPXmPIyivj2UdkGznuw5x9U
ELXfR/KNsba9NU+VofTVKGKsfiaYsseAYSJq169UfwKMs4JcCRCbPDFlJRTcw1WHre6qZhvrVhVw
DQfX/MoQWduQpbelGU7Cpml4GVdgO3jBRIXUSnc7oKkcDpaL9xSo0c5Pqsz7dQ9nrychh+6Bq+c/
+9gDWvxd1N9qrCqUAziA/DzWv9+AYlh0DNfNP1zMN83lv45KyhlUGgDqs8Zwas33ZY2iwMXhrRKX
AetM3RpGH7NDClXeDcS3fpmnZiptq9WAlbjw1sF+YTzy24iSmF6k493+3+aAy1cgdGo5w3UdyA18
cA8BLXTQr3XnqnIZ74MtJvvrYGvo75EejbUhJbUWpwc/ItxI9C8z0MzRnqV3A5PP6dAHs3Kq9O+G
Y4t1NMP5n27dliQXbB/IeMuGv8+4tuGZN81uMpXTDhucuCll/vXnZXzt1R5wR88CnwAWR1Wh8mli
ybApa3OmpB+bT5Iv9yYMUizwMRI/DFxivhC9aGcnUtQ4fu2fJ5+FyPm/UAbJSH04DCgYOA3caZ9v
PCMDm1Yy09g906orcbg95GPIPfgbzFHHbDgpLFRSKk2G8jKfleOdK4vsuWa5+YgsdX73TzBJ/m+n
pWC9jBwn8iRRAHOvLFxj5qfKEZZ9ru9/gXR0CmL08640BxkhKxqUVBzIOonpAG2bZi7JsLVP+5xV
EDzrIKITiiIS3L/Ro3tp7sST4FL1xp3wSVpk4JOytXEG+PKnDLbk00d5+OCAcI6eOO0A2X9hRBME
4v4Du4FfNFGJq2imY5aMVr05bMimPDq3ptxzSjot3WuSqDvxBV8pNibV3bp/L0B8r5yN8MKNJAnX
IN5n14an7H8GWMFu9OGy39VwPlZA6bvZEowFJVkh9urniylsW15ERsbGdmlHPIOgq2z9VNB04PF+
AmfwBMtoWNWAHVZ0IkyiW2q8h3ncb4Y+cCFhlziE/v99yOVf3P/Jfsf46WBomNUQnWFpfM/c/M5O
sTafahEdTkZeHrP+kMA6d2sy4wi5R5/MA0O0f4s8cSmrZBzvngxDwOws1P+TIQEsAh/ZOba2vLM7
6GqF3Efw2SVM08BUcX3Ymk6QCGk1Eie1OswJBBjNmzCSIKQApNbkZM9TqhNSJW6/LhnAqK38lS4I
DU6f9hGZm9PRUIgjOCFnJ+Eylqb7Nu+qVH+xdD+vur5PRtyFBeH72yd3KL4vcdh21/EIFKsLdORz
7Z7CDD6ab8ozsVJ+1IQvN7ORRmCfBju73osJtNyBIv4+yQo2tP8wK0flLxpPeb3UDySKl/4W5Hcg
atGboMFBDOJSK3gEPFs5nx8USNngIh2Wj8hjxIgTFikk2IYXQ6+F+r3OAWK+DIXlF2Rjo8dOMgKY
Z9VUB5Zk93otn6vs/nogdsVENc/jFviGbFKWJQhzIqpxvU5SxeHetTWpLCsHmyErznwM60VwJsiq
LUlZm60y7PUmhW1ZBMJmJDk8hKcPNG3Lc7I1PrlGdrnD8ZpQQYIjwt+XX3VrzMMEfuuUpKT+L1+j
Sr1nq0fsRlxQNesUQodsnkN04MqnFaNpuPm8PR2Nr5TfP3qYf3Vd6rh1237Tp0b8mYJ9sLNebbpj
CwkVmvn1eVPSHLeqmPVf0MIQKdnnLtP2mhXaJFp+GcY2vU0oAxbXJ599ZFTzyiE8XGmEcTqRfoMl
Matgz387wKCXqJvLXCWwgAAZjdJrbJsLi9X31bHo2ivRCF3FdeXayheT24CcYr9aAEqlG4MeGMB1
7VF/yHXqGir8wrLZFtrIWT13xIQMLJT3tRQqEfE7ayXmnDftZbjWVWX1ytITEXdu4Rq8kCVunlyS
WPyU/fEQtqTeo10lc0PvoeIzQk+MJjaUz4fNqt7VwdL744n6ipc/mKEUW1sGfH5I/PmHjISb2MW1
VCfl6exyk9HSuYSnH2ipvRnM8wp0LFsNNTcseL139bLfeLrZmfAF6CHXa1ORon6UBqRtGZu6dlfh
ZCWwe8t2X3os34N1UeerT724K0+j1y3dXgluBaOG21I1Qx/UfPHbF43vBL5l0C2jWMa6cQ18U+Yt
d85Kmt2fAEkzimkAUvyiWcyOKZ/1+JHEOqcLPugGgpJ2fhoXRRwU5oAU7dpCsN43P7Z47N2x6I2i
SYFt1fYj1HmKG7kGFwGxK5pUxLqh2W7F3UrkvETF/wgt5tKaTpX0RV0wXfwasjo5WxeFOKTsZvKT
553D4naEXDGvG0XuYE2LlkIZNLj97BBWBt/Ox3iI4/mXPkFq4jQAjG0HRfLzXKfhsePLKrgCeAkx
4U4C38zgookrt+EIfXIMGEAvWu/P1WTuScuAz7FkYWAxjkbLif8Mlu/G4m9pvSB1yg3HhrOKFjHD
Etrrprc7An1rHAZQ9bv3rODglG9PxrDiHXk0P4M2nAHKnrz6unnXPF9fMukGh34t9kkXjCTiLWAD
8vGsq6y+JqAhtxswfTELxtOrXV7jBUpbZNnK2bFULNfs9nHHMobByQ2xpJMx9/d9N9x0IiT6Xo+n
QbZ8kq7CrIlbwHEGDMSp8lZ7zEIc6uTxq9H/c74ArrAl89+ZZuHTHRK6K9XYxHivg6oevBGVHGsh
COU44nVcfYBsb9yI5nrFmJWdtGYvZlXimh5+7y+Lr/k4NXpKvAfqkxlXEQ5gFWsBKTKNbeUblhIA
7hZHsXjCEETRCeMqD7V2wLSMoc3vic9AoOBDOQWCMZrJnykLgp9btJWhaK6bhceowp5C4iiVFK5M
30RZHYErtCFriQjrYtts9aWUWx7ghI1I+iFrelmLF3/MrTVibL9u4ZyPrVBf6kSMMJa5gRYgLU0R
XSd6y+KiTbZirLc15w4V2f/6ftqPeYqj89+dnNpAL16xGOP+fDP4ZffpWuRK8Hq5+4HSxBysQQ2U
mNrcnyXY9pFL9S7TwxVvU/qWXog9CCBbSpMAo+H8vtdZUXzMVDiTVbNAphuUGBLj69OTETyk41p4
1MVxZ+QMoBFoFPcIQHrnkiBYc6TjctzODDw13Heqj469OXuI8Dj82aXRqEZ3FcWcgMRfcSE9ASBl
XxKSNtW9bQf9zWtxIs1Hx1fT+DUNJIJ/VgkqduR15jGw5Fy83AGLDVmuqyjGBGhr26etTsVexBrB
iRPAPyQ6qr0PR8zjZbnxAkDrtc7ACCnfhb6BxDt4qRGVCz+XYJIMlXhi4RWAuZeFzini8dzuX6GC
LPbOVIhQB+GirlguSbJs8GIVolOTscVQqzT1BdlWSjvStaZGBMQ6HZHKfy1FlZ4S1lqgN4BoTsqA
w9JO+e8cCM+fqJcVOR1b9fb3dxJIpBOkfz34b/40ktsvOLVXJyyZbxWhGv2szBkxdZoZTvQdvPSt
ar0uJFM1Gj0cu8lJIXvbyfDLGgzrBXNo2qOLiiXj0V6R7Z2+ZKivdDL0Sz6vBwtmtlWNhWOIXfsg
k6NFkSOS8LXn8Y+6u+0INASOkVZX7VvzDVNuj0Pn/x1H5vQD0UcN2Serse9x9dYOsgA4HvMsqUZ+
W7QyLChdNGFyraNKw/+ogRc4pLdKFw2dtfYxh/ixoz0Gf9zNZt7lSY0EqDRxj2CLcyoAKGC/4ZPR
bVWy5WXIc9njUQFg2wFuomGvOuwoJhcs4vOB27Krnurq6tm800kw1S4iiKVjWQXIHwwylxlAR0do
oA8YnHV+yxDbQPriv9CdO4rbmq3d7GUdRyGrSYqDzQEddYvL+8scnLqpa/J7XxB3fT0pa6E3+zmf
zpBBAzFmml9zUe2x/MNrJPF5PeJ38PxqDpFYHPthxnw7XXORaPMDDGv4EmTTlzja2yzE3aHd+/a9
Be190vbiA3vHK37cWQg5AFVDhQvbJwasDnndDiSFt63AjNR/Jlv4ngCo/Q8bWzkq9wHmheZ+yfhl
VcCJIMvZiDbf1etyWVQV91mPAJX06jCN5jnhuHpHN9xhdFWVD6zIXInd4kW40H427FsTgAHrWsJT
NGioll1NTwosigJPXQQTdUcRP5bfgEXw9z9oFEDWyhOiTGlqICWMGIWouf+HfkTYXg+N0kiPmewD
x/c+1cJktMmWVhkXGYjKWXrsfQJ+m6oqoUM+NMQucO9TaZf5Y5xL8QOAcXXScXiSNJcWx2+nZFeH
ANZxvmzTjplD+mzyuKNMLqaHyrrV2bj558vOiTSOupUiYUVRME26h00aL+oZfXMMkL9kaGBwTLeK
99y2d8pcChFIQ5QK2vU5kRhDk/PfKwiLaqkaPbuiHBz9ex5IoWcg0KUrBjDGXbvRUZAFMGQQQXJx
tTqe14eIB3jy3u1CUaOy7bayKz8Y3zjeBC0tiuwKj+88S/DqkStXyx7jDFEBKtsNYQLyU7hLBPvG
nOY1aloQZVzPdrO64gKrhu/tolhWZ1PiBF2vay/E1CPIgNBgFr/X2CAPsgkL4l4+g9/wwyBS1SCl
BTxfc2TEp+K+QvjIzVhkBVomQKEtRqqIT9Epaa9Rq0nje+1Vmi7RSTJ7E4eSW0THYBETyf+sK9VF
ktruRumV7HS7D1pTgCnbiAFoK8g4Xq1GgJKpawfyMjgfRNx+Hm/FPWMmiZVPr86AbqljLniCn7Mn
Ep4z2RBddAvoDIpmktiHsTr+uGKzuBeSsiHGZC5wHQZTUz2WYi4SJpaWBuUmNX4TgjAQgFj9gpM4
qI5PCbcbTzaFQYdG5RGihSU0CAX55vrmzAeF1jWAvtj59A6cWzKzC8VsGV4JYpBpCRSninYjGlGu
9E6KYrVOwaDQD2GmnOAqex7R02KUGBTLyn6xtWFXwwmnfFU7F+jh7LBRdx622+aHzFBWefVs14B6
B9UP7cL3aR4DkHc80XlZJ+ZZzeo5Qu+u+b+f3fkwR4iU08QETbk1Zth9S1Z0xvLkMV/U+BeeBedt
G8PovbV1SC9MOvUTn+aS9CE/MDqvdcm5NCJz3jMxhjZ5Z/hWMOj0wobZab/5Jo0uT8eMXOVNKx9X
Sb4Ku1A1Fdo3YNFdHffYHzrFJPIaY2Ek5xTe3jklEjlRgdpQMbkhkA7im+5dWoXNFimOOJgn+0hI
usl+F7m31cJ0MD5lsSEZwmGrI2OnNgf87w43LBSj8DtHdfzlhCfZW2b81fbqBXm69VBZflkbD5GR
rSMKkOE3h/iMiMHh0TD4PxZ/5tZ/dt6ysOnCmPjXZ9SFnLVnyJa1TdDmYky9b7WZR0QzJsUPzZKS
Kz7PuE3Eq3kREh0v5VpnVshLt2d6Sq8k4gDvGHEfkAsrWjW2A+yto7pto0vA6pBnUYohYp9LBcHc
JwWKIK+Cch1qEbfbFY4Ib46bWmKdY8+yh/1blFoCOOaGZIMdriB5ieBUGCE3r03wa1thYTQI90Do
akJFHH3bbY4rr+P21Daz1wkBQfk8kjm5WKq6kotvq7J9iMLYk+yNYLGmohEBsSLl6oXiEHMwKkti
KDKQ29pu76BYDwaVhBtSLF99O+uDpDqej3qh4iEBP4MVuOjXAdbRajDrUoXB9TMhG8puZTfPwNyP
ttNkpYBk/9BG82C34Ddva2gBkSaG2J8BK7pEx+HtNMN8rzR9v1CfsB3Nfr/6l+vRC5rcf+aCyvcG
fjkKWvotjHu6tFTB9/tNthIm3Ru8n1XEzhE3w5rgD4KHLbIZInCLFc96apYy0KadPPGARHMQKPWo
4N3gMLYoNyHDecaN6qgJss1qhfURP06OMBPnkJZcZ8LUBeu4uY7JV/hZVDil4Wd6ujdV4CLAzGjT
A661XP9dfsg71f+F0txJZFsB82ukLxJtaFRz7h46g+JvQs1fmazbdJxHMSvGmBmOO6TApk9fzz3b
8wsyly3SlVCgd3Lz1XyU98eSSsD9LKXlsRP+avTv11s2plIf94JF1wF1WrETPUncDYY0i6bnA61d
3+PsORhJFDkTQWSrWOr2/z7uqTDKNftCMZuW0Q7NUGVlGGDtUbXxaVkhYJ6aSSL+NWmcIGlmCULm
eCKM5ZRjxUbgBHwQMbBcMRErPx1g4BW+EKzBXuoIID75WFjgdPHOdTBRt6JN0I1s8uBF07ghwnZM
tl5zhGCJlnEfnlay3OyUx45ssAN3yQbrCMj0F2Db6jksDlvm0M5bGPSL1slHfH9jSQtal/yHywAe
V1jCxrg1Qf+CqLbbGOIe/BonfPOlJ5Fnb+37OOI4hja7O+rhi8TnV1h4WJodMZH6GPvgbXImKkvu
5AhyvNI5u8J4+SIRh895j4SkqNdI6/NP5NnuhR/UggSgqpDb7pNj8f3phsf+fPlLZgMGnYnpRowD
h9jQFLKjWlnEPrpZPr2SubwX4L8lCMI0aOrvtMruM9F9zHxMPI7wnLrCq53V2LDoJdfc3Vga4Arb
7ei95f/CChMeb4RJ1vwuKh6jbzWjGDZAVoFxmZKh0BncWvVZbzcdCDgOSvJ785L6ZYgOFkEnFp3V
2NWlG3oCiLoIa3nvgWIJ7tUdqUAdz08w6Zvu1cfR0zwYNKY0FjG1K0NWuy00hfi4KuzcYCKKMe6M
lh4V2hQuzVCvaDRKlRmhrT81nUgyHUvmTqfIKvJ8PcKawA3dUC4lImwM27b/P1PIgeaRgjcp2IXY
zBFcz0y+xlMdqLsGcPg+A/6R+MVjn8mVmLZJGymdqXLVs22V4V7znEsNBu83eAbDVcdBFGkRPzJS
UyKFISjiZ+y1nwuVDHDrRok/4vPHm81CQPtlj3N7XQ0tEIiu2iHumR2Hfl9bfDlgIr6xshb1p0q2
MebSRquDLinq0KjQYluY1JoUTK7y7JmQRIB03o0ZIfTB5VDkwODuVnCHBCOaAFjHfKTNM0OX7AVi
810HhD6zX00J5aW65HDAz3c6xL+kvSmP37xwD/IYpmK3RfPALrBqwK6VjKIOXWR2ocp7vT8mSe7E
mm2FrSM0SZYVv/mSx6fumPY+aMvDLKHENVTiTjWGZWfFlNlH61ax3igEagUZfevlJutuMP8PfcqN
wFxumFwv38xZdpPYT8UZG5WFdT5wd8DEYUFc5g9UJs7ltUrjx/pPWc0wwMnLgPk2i4k4n1q+xi6E
Y367LLhdgr+N1VLuWCDE0b6cOr9uC/0esB2wEquZu63PyDhX6eY978H35oM7dieanq3HxqMrETZ/
lf89ale9vPTsmfyX0msKru0vhjc5R2IZ0iUASv5IihVXoV35l9nG8FP5ypNAuZgMJ+YYgpqbXty0
Gfk9oxhFBZsLvcSBoLXU5ZZ3LhdmCXXfWq4LqHuBlTsf+kRhnPIkuKUMAvMO8MwAxtV9AO8dYDHl
2joYduk3s1BkcvOMSR1VzzCLicpGW2OkEiUw73NMu8kjn/1HgaGFg4IawOU27WCCAHSbEUeKaPsz
amb8VKaDEs/p5EeIjFwlf1+Qx1NFQ5CDTQ/fyO8Xo1zIOjlnn5XbWxlOy2Bw6qfhpi3o7qcX72p3
n3Yie2mnbcW5jnu1mxtHaBkbe8WKTISAubOJbV6DdOrosJqHYJkYKwMwiaUC3ia2VsQ3ruJ3mTvA
G4+o9qfPyOtx6UD4sA6AZdmXsFveZBMLpxl4Xm60i9U7IsOxoYBC1ZGWXTwPmVmVDMUVWyJWSA9E
bG5FSxTYRGxh3auCMgOsv8a8Xtdj8HjwTWpOUdDiSuIztAgwQv9U+06MfTPeQBd9mlV5r28iYjw+
9F6PscXZIVnDoP47OZQGhNUAZGgVDZ27nEEKekCR/XuED3uwOn4ItqiQ2wVqmmCRZrdWVu5P9Tii
rqPJl0qk+MK4mbj+v10AmRf3/Nb9Dmo06UhHt1wQGW+AF9+3DpVTWeL8+s6bIs+ZsPZvKMA+dWFP
zWrcFuLHAHBIPLIEDtOPeTxX4yBe0VD0az2A1/07ThpHjHoZy9zX/leCyg/WArOieepei61aRdK/
SFm/z7cxa33j6uNByo5bG4fNEX6nT1xfwNF4TiASNqfK88gJpFFpsWv3+F9IBvgYZ+vLcmvkmmWp
iMR5Zqfr3hQRIgZsWCrAj+Vf/klA4gFkUY0mZMqVwAqq6u2FpAtfAskzaUb8BsUXaZrMA/49xWJd
h6j9xysBb1wmY/6siewVTjHTWrwKQ728FK1vvoZSA3JXGffgpkI35XA7AwTshiCZhW58oi9VgPl8
y3JBSt2HFYANZoDysOl2M3s8OUjOqsXtSagTcLqxQwGoGpV7DSCBsB7docXwJQ9JZ8v/gIetNQ6m
Yx8jWhsjroU1gvbIILZaJIzzPr0ElCUSUgBbQUTX9D707a7YBFbTS+rDNjrwLPYLxGpC4/CzDfvn
EmeyNVSPTxW1PVBcuQHVcn0ozS631cset+spXHztAaaFk01ptDJKTuv6SYm7nyj+5XqA+5hGpFZp
u9q5Z0S/LMjUVBeSvJSDk8Hhck0a75twGZccj66VZQa8hDeADat19wpP8GfkZs0hvC3JgWLeDH92
/PprN3hYfDAdse4KVjzkBNKUlkTBUJX8/zqxiFoHMv/8oAGY7DqPrkVt56N39xI6Sb3CWCvAj8Bl
KaL0LdN44HHvf1JpljgibdAHZx0CljaEDSw23LBmwO8Byz1wRj4757ScJvzdsTcH/BHfJcZn6vuE
496ON5QDU/j6tM2y22aLESKF+sGYrC/dX9oXzzBLPAduGFM6jKPbdDezFSOafmzgIfNy8mN2aTC1
CJD0pLQ0uObz8Pk4vGnnsoKQK3Pfv7YylfWkExqhzS1bvm9zTLoeOaduh65e6kFxF5OX91znodNq
pqwzjkQpqa7g4Ii6nf3P//RlBat9uem5Smi6Zde2qNbgQxxhUNZRT7AML4gYinOQ1jhi0uTO7l+M
BDGaPXEuDR5pN/2LPowO1nlzshUUHYZWLu86tAkzh3poQCNspNERGyqVzV60kLZSWl653GsogL2w
SqXbSL9YsMr0eJt0AZn96Rh9bhFGyMeEeCw0ECEVkAkR/0zNQNKdzatdtHF2hUTKhYYzxlLfgljy
ZaiSZeJ2nte7jedU4ebnEuYGYKhoQzM/6yaNLvXPdc9geAS+eioFCSuoFbA3Z4ue0+ASxqNzC3cf
kNJALRJ00/Aw4zs+Vi8oiOr+PQxSTXEW9kJmAlB3Qbt30AKMIPti8N80JMQyndsYz81XxjoR4mQe
XJxOBgfyMl8BgbDdklc97SW4X3uarx7/HukcL+Lnm/9aLvsee4+blO6LH9DEzgLb6nJTIw+3ja2E
FzLP+T4phPH8rClmOLHYbq2ZQVbfUZ0qVMO92TKjm7Ny7RGO/VTiilDC5hCJVDO9F0/sPF1rq/vP
aLhGR9CK4kge+g6AleAN1Q3nFabfspHYKG302G6wfznOBbkfzDAsfYAa8OHqAzFZTdEv8PhkiTm0
1q3TOUW6ZOQ9ZxJOg7H33qo+YpoA/9DNexDLMkvGK490gIc+wmdcZhIWTMPkKrEMIAjOb4/9yUlf
Kj+0jSrt7777nOgwciYUruzT5ezR5vostiz9Ct5PIpn/mXn6P82emGIkP2ZDLg3XhLNI4hOeTdc3
sD0SgXgFwyayIz4IxRlaFuLEYQHDU2HoWF8Ce135hZ+pj0drWBq/Zjzo2dk/eLwhWACungNLWm2E
gdN4El5L689WBBIkw6ir8OVtmVVTfEgkf24UKaX8qfjc7zy5y4qnsZSz0ggMy8x512rT0W1POjfn
f8vDU7eAKgATpmazBFAKEwvQuEjLC/YsjFk5ToW8WgmC/2cnCP7Ds9/zUPgosYXdmFRae0HYuQME
dHMJCRiqtEfO8QJ0Fodsa7KGFTBd3FytKtsWl+gtxlWiWAtflYg8fwYUenHmuf4mv7KZYHfhBbIS
BhUZ8uQ++1MfTUSuAWYd9mvU7aFvw+FWQ7iZ8CZwM385iXZywjhIPhb6YQu8HuuBeqtqJi+00QZk
+/E6JFsUJabNY2uC3iLs9ms9rs6Pv6y1k007fPNYZqOJBi/UAiZfklEncmRErOoJWnja1/p955Wu
zZYl1aYG+EVbtxBeDXq0RG7g2jVf5N1BQIaAppH53d1c1EP2/EvS1DjD5+oMTPzXt0Hun2/K7/wA
h4A2rhyZ0gTy7ldn+8iJSf1RPfqJYizjhf24u6xSywzNGjMYiIWpCMKO+X3735+EwtnyWrZtEB3g
K6pGKHrWSseMJOKhIZgwIHalUJ7Q7Wwx1MikQeDK1aw34IoQe/563ESNgIZo//+85jn3US5LHoiW
vopacvHJ3sjSJK4bK1B7SDFKEpmmTmFfFhXLtYk1MWQ9KKuHQbPmXOLGs1Y+Q/eyem06bFoBdgwv
R8SLSo6DxIfGSs1XmVIWbet7KMaed++evjH+hKmqS29+s465s6e5hh8mR4vl91HUyXUokGCvOmVJ
iiogrnpZDwS7iIgfCC49EOqv3fg/gPCCTcTMZD+yQLDjZCUnGsQINXasJk3GnSZLKbaGgKi2rt3+
TtsEdIP1pxekD7nUoCq5d4mCSz3GJSuUwWv3D1ND55QETL2fOaZHeSO+/hG1taVYFXG4fTKNXGpF
D+AF+73wdhyxMBINwVmxdW0pId/cVUs3HzMf2d4ZAB3hFYDeA+klvC4UZZN6agWh4tuS3mreIsNN
trOaTP2ewcs2YZRI5pwxnZY2WuyvIzB0cEBUfHc+f++/6BFIDY6mEcaZBa5AAt7Nr/MkhGg6iKnP
nfJE/VO8Qz/69VVPT8gz6G9KaHNe7FiYTZCMnIMqSfSTZt0+ctuS5p4Y8h0ZBk45YRO4RkSv06So
YoAOXqO1Rf7TBH96ok1G3KqD0mJPudiP4eN7gEsmNE4Qmeg1bPJv/o3e2VqPxUGhJuehB7yUvyWS
w5QjDdYe5Darb7nrECevp0Cm3vIw6JgkR7BgU4ft4lxrkSjhRyImzGKb1alfLmwV28Ce5SwKuHfx
A6VB+auFgRMtn/Ul67gIBT2W2WwdrvJQ3y5fMW7c2e7o1Y9bWofbiBZ9JWxJ2cJiBXIWASl62e7Q
yALobKuwDzHxWMWjJcDwP5BzRWBWn+fsrm6S/YvZjCkOcJmZyUr6BambuyMpRK3wkCIOL7iJjABS
Kx2JHmc7riwg8NXkMG4jeTRBwn/q15q/bJyh4PMkEYcGP2ELGfe42qWoY03fsqkhVNULsLoTK/kJ
p0ar2qADdl2T5919WA62XrpvhLpM8KUIRvPiKH2ucqUOhs7JjXL6vFDqAgqyExkr4jwc6pBrvN70
lEvBd2SI3ehKQVA8w+O6bfG9MNaO/job36amPRj1KoiJ1S8GTbTWpxmv2sXK0C83uB0aTn1B2Hbf
gBzp4yA4FrnUjEvyI5dYUf4sbiT5uFAepDehn+Eyyt6PlVyZ0biAeXMnFjKFZHTGPPrFyNdNoN5O
e64dpcMQa9O6rejIF9ZVx0+gjAD5J1QKHi0derUd1pxPfEPKaNRT3886jRvwn9CdCsNOGz1E4AtM
N/5JPpSOegaNJ6rbxgkGGUg/4w5orXrOwlLYH27bLzrq
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
