`timescale 1ns / 1ps

`include "constants.vh"

module soc(
    input wire i_clk,       // 125 MHz oscilador externo (so para Clock Wizard)
    input wire i_rst,
    input wire [3:0] i_par_i,
    output wire [3:0] o_par_o,
    input wire i_uart_rx,
    output wire o_uart_tx,
    inout wire io_i2c_sda,
    inout wire io_i2c_scl,
    output wire o_i2s_mclk,
    output wire o_i2s_bclk,
    output wire o_i2s_lrclk,
    output wire o_i2s_pbdat,
    output wire o_i2s_mute,
    inout  wire io_i2s_sda,
    inout  wire io_i2s_scl,
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
    inout        FIXED_IO_ps_srstb
);

    localparam [15:0] _default_nop = `CPU_NOP_INSN;
    localparam [15:0] _reset_vec   = `CPU_RESET_VEC;

    // ── Clock wires ──────────────────────────────────────────────────────────
    wire _fclk;         // 100 MHz do Zynq PS (usado por CPU, periph_bus, DMA)
    wire _i2s_mclk;     // 12.288 MHz do Clock Wizard (usado so pelo I2S)
    wire _mmcm_locked;

    // ── CPU / bus wires ──────────────────────────────────────────────────────
    wire _insn_ce;
    wire [15:0] _PC;
    wire _hit;

    (* mark_debug = "true" *) wire [15:0] _d_ad;
    wire _sw, _sb, _lw, _lb;

    (* mark_debug = "true" *) wire [15:0] _cpu_do;
    (* mark_debug = "true" *) wire [15:0] _cpu_di;

    wire [7:0] _imem_dout_h, _imem_dout_l;
    wire [7:0] _dmem_dout_h, _dmem_dout_l;
    wire [15:0] _i_ad_rst;

    (* mark_debug = "true" *) reg [15:0] _insn_q;
    wire _br_taken;

    (* mark_debug = "true" *) wire [15:0] _imem_dout;
    wire _imem_invalid;

    reg _loaded;
    wire _mem_rdy;

    wire _is_io, _byte_lane;
    wire _mem_we_h, _mem_we_l;
    wire [7:0] _mem_din_h, _mem_din_l;
    (* mark_debug = "true" *) wire [15:0] _mem_dout;
    wire [15:0] _mem_load_data;

    wire _io_sel, _io_we, _io_re;
    wire [15:0] _io_wdata, _io_rdata;
    wire _io_rdy, _rdy;

    wire _irq_take;
    wire [15:0] _irq_vector;
    (* mark_debug = "true" *) wire _in_irq;
    wire _int_en_cpu, _iret_detected;

    // ── AXI-Stream: DMA -> i2s_mmio ─────────────────────────────────────────
    wire [31:0] axis_i2s_tdata;
    wire        axis_i2s_tvalid;
    wire        axis_i2s_tready;

    // ── Static assignments ───────────────────────────────────────────────────
    assign _hit          = ~i_rst;
    assign _i_ad_rst     = _reset_vec;
    assign _imem_dout    = {_imem_dout_h, _imem_dout_l};
    assign _imem_invalid = ~|_imem_dout;
    assign o_i2s_mute    = 1'b1;
    assign o_i2s_mclk    = _i2s_mclk;

    // ── Clock Wizard: 125 MHz -> 12.288 MHz ─────────────────────────────────
    // Continua a usar i_clk (125 MHz do oscilador externo)
    clk_wiz_0 u_clk_wiz (
        .clk_in1  (i_clk),
        .reset    (i_rst),
        .locked   (_mmcm_locked),
        .clk_out1 (_i2s_mclk)
    );

    // ── Instruction fetch latch (usa _fclk) ──────────────────────────────────
    always @(posedge _fclk) begin
        if (i_rst | _imem_invalid)
            _insn_q <= _default_nop;
        else if (_insn_ce) begin
            _insn_q <= _imem_dout;
            if (_br_taken)
                _insn_q <= _default_nop;
        end
    end

    // ── Load ready tracking (usa _fclk) ──────────────────────────────────────
    always @(posedge _fclk) begin
        if (i_rst)
            _loaded <= 1'b0;
        else if (_insn_ce)
            _loaded <= 1'b0;
        else
            _loaded <= (_lw | _lb);
    end

    assign _mem_rdy = ~((_lw | _lb) & ~_loaded);

    // ── Data/IO split ────────────────────────────────────────────────────────
    assign _is_io       = _d_ad[15];
    assign _byte_lane   = _d_ad[1];
    assign _mem_we_h    = (_sw | (_sb & ~_byte_lane)) & ~_is_io;
    assign _mem_we_l    = (_sw | (_sb &  _byte_lane)) & ~_is_io;
    assign _mem_din_h   = _sw ? _cpu_do[15:8] : _cpu_do[7:0];
    assign _mem_din_l   = _cpu_do[7:0];
    assign _mem_dout    = {_dmem_dout_h, _dmem_dout_l};
    assign _mem_load_data = _lb ? (_byte_lane ? {8'h00, _dmem_dout_l}
                                               : {8'h00, _dmem_dout_h})
                                 : _mem_dout;
    assign _io_sel   = _is_io;
    assign _io_we    = _is_io & (_sw | _sb);
    assign _io_re    = _is_io & (_lw | _lb);
    assign _io_wdata = _cpu_do;
    assign _cpu_di   = _is_io ? _io_rdata : _mem_load_data;
    assign _rdy      = _is_io ? _io_rdy   : _mem_rdy;

    // ── CPU (usa _fclk - mesmo clock que o DMA) ───────────────────────────────
    cpu u_cpu (
        .i_clk          (_fclk),
        .i_rst          (i_rst),
        .i_i_ad_rst     (_i_ad_rst),
        .o_insn_ce      (_insn_ce),
        .o_PC           (_PC),
        .i_insn         (_insn_q),
        .i_hit          (_hit),
        .o_d_ad         (_d_ad),
        .i_rdy          (_rdy),
        .o_sw           (_sw),
        .o_sb           (_sb),
        .o_lw           (_lw),
        .o_lb           (_lb),
        .o_data_out     (_cpu_do),
        .i_data_in      (_cpu_di),
        .i_irq_take     (_irq_take),
        .i_irq_vector   (_irq_vector),
        .o_in_irq       (_in_irq),
        .o_int_en       (_int_en_cpu),
        .o_iret_detected(_iret_detected),
        .o_br_taken     (_br_taken)
    );

    // ── ROM (usa _fclk) ───────────────────────────────────────────────────────
    brom_1kb_be u_rom (
        .i_clk   (_fclk),
        .i_rst   (i_rst),
        .i_en    (_insn_ce),
        .i_addr  (_PC[9:1]),
        .o_dout_h(_imem_dout_h),
        .o_dout_l(_imem_dout_l)
    );

    // ── RAM (usa _fclk) ───────────────────────────────────────────────────────
    bram_1kb_be u_mem (
        .i_clk   (_fclk),
        .i_rst   (i_rst),
        .i_en    (_sw | _sb | _lw | _lb),
        .i_addr  (_d_ad[9:1]),
        .i_we_h  (_mem_we_h),
        .i_we_l  (_mem_we_l),
        .i_din_h (_mem_din_h),
        .i_din_l (_mem_din_l),
        .o_dout_h(_dmem_dout_h),
        .o_dout_l(_dmem_dout_l)
    );

    // ── Peripheral Bus (usa _fclk - mesmo clock que DMA e PS) ────────────────
    periph_bus u_periph (
        .i_clk        (_fclk),
        .i_rst        (i_rst),
        .i_addr       (_d_ad),
        .i_sel        (_io_sel),
        .i_we         (_io_we),
        .i_re         (_io_re),
        .i_wdata      (_io_wdata),
        .o_rdata      (_io_rdata),
        .o_rdy        (_io_rdy),
        .i_par_i      (i_par_i),
        .o_par_o      (o_par_o),
        .i_uart_rx    (i_uart_rx),
        .o_uart_tx    (o_uart_tx),
        .io_i2c_sda   (io_i2c_sda),
        .io_i2c_scl   (io_i2c_scl),
        .i_i2s_mclk   (_i2s_mclk),
        .o_i2s_mclk   (),
        .o_i2s_bclk   (o_i2s_bclk),
        .o_i2s_lrclk  (o_i2s_lrclk),
        .o_i2s_pbdat  (o_i2s_pbdat),
        .io_i2s_sda   (io_i2s_sda),
        .io_i2s_scl   (io_i2s_scl),
        .i_s_axis_tdata  (axis_i2s_tdata),
        .i_s_axis_tvalid (axis_i2s_tvalid),
        .o_s_axis_tready (axis_i2s_tready),
        .i_int_en     (_int_en_cpu),
        .i_in_irq     (_in_irq),
        .o_irq_vector (_irq_vector),
        .o_irq_take   (_irq_take),
        .i_irq_ret    (_iret_detected)
    );

    // ── Zynq PS Block Design Wrapper ──────────────────────────────────────────
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
        .M_AXIS_MM2S_0_tdata  (axis_i2s_tdata),
        .M_AXIS_MM2S_0_tkeep  (),
        .M_AXIS_MM2S_0_tlast  (),
        .M_AXIS_MM2S_0_tready (axis_i2s_tready),
        .M_AXIS_MM2S_0_tvalid (axis_i2s_tvalid),
        .FCLK_CLK0            (_fclk)   // ← 100 MHz do PS para todo o sistema
    );

endmodule