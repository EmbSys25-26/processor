// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (lin64) Build 6140274 Wed May 21 22:58:25 MDT 2025
// Date        : Sat Mar 21 18:48:25 2026
// Host        : panda running 64-bit Ubuntu 22.04.5 LTS
// Command     : write_verilog -force -mode funcsim
//               /home/mariana/Desktop/project_2nd_Semester/processor/VGA_cararter_display.gen/sources_1/ip/char_buffer_bram/char_buffer_bram_sim_netlist.v
// Design      : char_buffer_bram
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "char_buffer_bram,blk_mem_gen_v8_4_11,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_11,Vivado 2025.1" *) 
(* NotValidForBitStream *)
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
