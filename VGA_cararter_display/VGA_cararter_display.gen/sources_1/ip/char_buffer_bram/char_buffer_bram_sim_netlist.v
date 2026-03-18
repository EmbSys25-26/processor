// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (lin64) Build 6140274 Wed May 21 22:58:25 MDT 2025
// Date        : Wed Mar 18 11:19:26 2026
// Host        : mendes-Katana-GF66-12UGS running 64-bit Ubuntu 22.04.5 LTS
// Command     : write_verilog -force -mode funcsim
//               /home/mendes/Documentos/processor/project_vga.gen/sources_1/ip/char_buffer_bram/char_buffer_bram_sim_netlist.v
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
