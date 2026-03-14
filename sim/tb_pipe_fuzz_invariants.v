`timescale 1ns / 1ps
`default_nettype none

`include "constants.vh"

module tb_pipe_fuzz_invariants;

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;

    reg [15:0] _insn;
    reg _rdy = 1'b1;
    reg _irq_take = 1'b0;

    reg [15:0] _prog [0:511];
    integer _i;
    integer _cycles;
    integer _seed;
    integer _cycles_limit;

    wire _insn_ce;
    wire [15:0] _i_ad;
    wire [15:0] _d_ad;
    wire _sw;
    wire _sb;
    wire _lw;
    wire _lb;
    wire [15:0] _data_out;
    wire _in_irq;
    wire _int_en;
    wire _iret_detected;
    wire _br_taken;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Helpers and DUT
 ************************************************************************************/
    function [15:0] enc_rri;
        input [3:0] i_op;
        input [3:0] i_rd;
        input [3:0] i_rs;
        input [3:0] i_imm;
        begin
            enc_rri = {i_op, i_rd, i_rs, i_imm};
        end
    endfunction

    function [15:0] enc_ri;
        input [3:0] i_rd;
        input [3:0] i_fn;
        input [3:0] i_imm;
        begin
            enc_ri = {`OP_RI, i_rd, i_fn, i_imm};
        end
    endfunction

    function [15:0] enc_rr;
        input [3:0] i_rd;
        input [3:0] i_rs;
        input [3:0] i_fn;
        begin
            enc_rr = {`OP_RR, i_rd, i_rs, i_fn};
        end
    endfunction

    function [15:0] rand_insn;
        input integer s;
        reg [3:0] _rd;
        reg [3:0] _rs;
        reg [3:0] _imm;
        reg [3:0] _sel;
        begin
            _sel = $urandom(s) & 4'hF;
            _rd = $urandom(s) & 4'hF;
            _rs = $urandom(s) & 4'hF;
            _imm = $urandom(s) & 4'hF;
            case (_sel)
                4'h0: rand_insn = enc_rri(`OP_ADDI, _rd, _rs, _imm);
                4'h1: rand_insn = enc_rr(_rd, _rs, `FN_ADD);
                4'h2: rand_insn = enc_rr(_rd, _rs, `FN_SUB);
                4'h3: rand_insn = enc_ri(_rd, `FN_ADC, _imm);
                4'h4: rand_insn = enc_ri(_rd, `FN_SBC, _imm);
                4'h5: rand_insn = enc_rri(`OP_LW, _rd, _rs, _imm);
                4'h6: rand_insn = enc_rri(`OP_SW, _rd, _rs, _imm);
                4'h7: rand_insn = {`OP_IMM, ($urandom(s) & 12'hFFF)};
                4'h8: rand_insn = {`OP_BX, `BR_BR, ($urandom(s) & 8'h0E)};
                4'h9: rand_insn = `CPU_NOP_INSN;
                default: rand_insn = enc_rr(_rd, _rs, `FN_XOR);
            endcase
        end
    endfunction

    always #5 _clk = ~_clk;

    cpu dut (
        .i_clk(_clk),
        .i_rst(_rst),
        .i_i_ad_rst(16'h0100),
        .o_insn_ce(_insn_ce),
        .o_i_ad(_i_ad),
        .i_insn(_insn),
        .i_hit(1'b1),
        .o_d_ad(_d_ad),
        .i_rdy(_rdy),
        .o_sw(_sw),
        .o_sb(_sb),
        .o_lw(_lw),
        .o_lb(_lb),
        .o_data_out(_data_out),
        .i_data_in(16'h55AA),
        .i_irq_take(_irq_take),
        .i_irq_vector(16'h0020),
        .o_in_irq(_in_irq),
        .o_int_en(_int_en),
        .o_iret_detected(_iret_detected),
        .o_br_taken(_br_taken)
    );

/*************************************************************************************
 * 2.2 Program Drive and Invariants
 ************************************************************************************/
    always @(*) begin
        _insn = _prog[_i_ad[9:1]];
    end

    initial begin
        _seed = 32'h1C0FFEE;
        _cycles_limit = 2200;

        if (!$value$plusargs("seed=%d", _seed)) begin end
        if (!$value$plusargs("cycles=%d", _cycles_limit)) begin end

        for (_i = 0; _i < 512; _i = _i + 1) begin
            _prog[_i] = rand_insn(_seed + _i);
        end

        // Keep IRQ vector deterministic.
        _prog[16'h0020 >> 1] = `CPU_IRET_INSN;
        _prog[16'h0022 >> 1] = `CPU_IRET_INSN;
    end

    always @(posedge _clk) begin
        if (!_rst) begin
            _cycles <= _cycles + 1;

            // Deterministic backpressure and IRQ pulses.
            _rdy <= ((_cycles % 7) != 0);
            _irq_take <= ((_cycles % 41) == 9) || ((_cycles % 41) == 10);

            // Invariants
            if ((^_i_ad) === 1'bx) begin
                $display("FAIL tb_pipe_fuzz_invariants: X detected on i_ad");
                $fatal(1);
            end

            if (_i_ad[0] !== 1'b0) begin
                $display("FAIL tb_pipe_fuzz_invariants: PC not word aligned, i_ad=0x%04h", _i_ad);
                $fatal(1);
            end

            if (dut.u_regfile._r0 !== 16'h0000) begin
                $display("FAIL tb_pipe_fuzz_invariants: r0 corrupted to 0x%04h", dut.u_regfile._r0);
                $fatal(1);
            end

            if (dut._mem_wait && !(dut._stall_if && dut._stall_id && dut._stall_ex)) begin
                $display("FAIL tb_pipe_fuzz_invariants: mem_wait without full stall bundle");
                $fatal(1);
            end

            if (dut._accept_irq && dut._mem_wait) begin
                $display("FAIL tb_pipe_fuzz_invariants: accept_irq asserted while mem_wait high");
                $fatal(1);
            end

            if ((^_d_ad) === 1'bx) begin
                $display("FAIL tb_pipe_fuzz_invariants: X detected on d_ad");
                $fatal(1);
            end

            if (_cycles > _cycles_limit) begin
                $display("PASS tb_pipe_fuzz_invariants");
                $finish;
            end
        end else begin
            _cycles <= 0;
            _rdy <= 1'b1;
            _irq_take <= 1'b0;
        end
    end

    initial begin
        repeat (3) @(posedge _clk);
        _rst = 1'b0;
    end

endmodule
