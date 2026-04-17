`timescale 1ns / 1ps

module system_top (
    // ── Zynq PS Ports (DDR & FIXED_IO) ─────────────────────
    inout [14:0] DDR_addr,
    inout [2:0]  DDR_ba,
    inout        DDR_cas_n,
    inout        DDR_ck_n,
    inout        DDR_ck_p,
    inout        DDR_cke,
    inout        DDR_cs_n,
    inout [3:0]  DDR_dm,
    inout [31:0] DDR_dq,
    inout [3:0]  DDR_dqs_n,
    inout [3:0]  DDR_dqs_p,
    inout        DDR_odt,
    inout        DDR_ras_n,
    inout        DDR_reset_n,
    inout        DDR_we_n,
    inout        FIXED_IO_ddr_vrn,
    inout        FIXED_IO_ddr_vrp,
    inout [53:0] FIXED_IO_mio,
    inout        FIXED_IO_ps_clk,
    inout        FIXED_IO_ps_porb,
    inout        FIXED_IO_ps_srstb,

    // ── SoC External Ports (m_soc.v) ────────────────
    input  wire        i_clk,
    input  wire        i_rst,
    input  wire [3:0]  i_par_i,
    output wire [3:0]  o_par_o,
    input  wire        i_uart_rx,
    output wire        o_uart_tx,
    inout  wire        io_i2c_sda,
    inout  wire        io_i2c_scl,

    // I2S Ports
    output wire        o_i2s_mclk,
    output wire        o_i2s_bclk,
    output wire        o_i2s_lrclk,
    output wire        o_i2s_pbdat,
    output wire        o_i2s_mute,
    inout  wire        io_i2s_sda,
    inout  wire        io_i2s_scl
);

    // ── Internal AXI-Stream Wires ────────────────
    wire [31:0] axis_i2s_tdata;
    wire        axis_i2s_tvalid;
    wire        axis_i2s_tready;

    // ── Zynq Block Design Wrapper Instance ─────────────────
    design_1_wrapper u_design_1 (
        .DDR_addr          (DDR_addr),
        .DDR_ba            (DDR_ba),
        .DDR_cas_n         (DDR_cas_n),
        .DDR_ck_n          (DDR_ck_n),
        .DDR_ck_p          (DDR_ck_p),
        .DDR_cke           (DDR_cke),
        .DDR_cs_n          (DDR_cs_n),
        .DDR_dm            (DDR_dm),
        .DDR_dq            (DDR_dq),
        .DDR_dqs_n         (DDR_dqs_n),
        .DDR_dqs_p         (DDR_dqs_p),
        .DDR_odt           (DDR_odt),
        .DDR_ras_n         (DDR_ras_n),
        .DDR_reset_n       (DDR_reset_n),
        .DDR_we_n          (DDR_we_n),
        .FIXED_IO_ddr_vrn  (FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp  (FIXED_IO_ddr_vrp),
        .FIXED_IO_mio      (FIXED_IO_mio),
        .FIXED_IO_ps_clk   (FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb  (FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb (FIXED_IO_ps_srstb),

        // AXI-Stream output from DMA
        .M_AXIS_MM2S_0_tdata  (axis_i2s_tdata),
        .M_AXIS_MM2S_0_tkeep  (), // Não precisamos do tkeep para áudio contínuo
        .M_AXIS_MM2S_0_tlast  (), // Não precisamos do tlast para áudio contínuo
        .M_AXIS_MM2S_0_tready (axis_i2s_tready),
        .M_AXIS_MM2S_0_tvalid (axis_i2s_tvalid)
    );

    // ── Processor & Peripherals Instance ───────────────────
    soc u_soc (
        .i_clk          (i_clk),
        .i_rst          (i_rst),
        .i_par_i        (i_par_i),
        .o_par_o        (o_par_o),
        .i_uart_rx      (i_uart_rx),
        .o_uart_tx      (o_uart_tx),
        .io_i2c_sda     (io_i2c_sda),
        .io_i2c_scl     (io_i2c_scl),

        // I2S Ports
        .o_i2s_mclk     (o_i2s_mclk),
        .o_i2s_bclk     (o_i2s_bclk),
        .o_i2s_lrclk    (o_i2s_lrclk),
        .o_i2s_pbdat    (o_i2s_pbdat),
        .o_i2s_mute     (o_i2s_mute),
        .io_i2s_sda     (io_i2s_sda),
        .io_i2s_scl     (io_i2s_scl),

        // AXI-Stream input to I2S
        .s_axis_tdata   (axis_i2s_tdata),
        .s_axis_tvalid  (axis_i2s_tvalid),
        .s_axis_tready  (axis_i2s_tready)
    );

endmodule