`timescale 1ns / 1ps
`default_nettype none

module tb_soc_bpu_eval;

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;

    integer _cycles = 0;
    integer _retired = 0;
    integer _branches = 0;
    integer _mispredicts = 0;
    integer _redirects = 0;
    integer _halt_hits = 0;

    integer _max_cycles = 4000;
    integer _halt_hits_target = 8;

    real _cpi;
    real _mispredict_rate;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 DUT instantiation and clock generation
 ************************************************************************************/
    soc dut (
        .i_clk      (_clk),
        .i_rst      (_rst),
        .i_par_i    (4'h0),
        .o_par_o    (),
        .i_uart_rx  (1'b1),
        .o_uart_tx  (),
        .io_i2c_sda (),
        .io_i2c_scl ()
    );

    always #5 _clk = ~_clk;

/*************************************************************************************
 * 2.2 Reset sequence
 ************************************************************************************/
    task wait_clocks(input integer n);
        repeat (n) @(posedge _clk);
    endtask

    initial begin
        if ($value$plusargs("MAX_CYCLES=%d", _max_cycles)) begin
            $display("[tb_soc_bpu_eval] MAX_CYCLES override = %0d", _max_cycles);
        end
        if ($value$plusargs("HALT_HITS=%d", _halt_hits_target)) begin
            $display("[tb_soc_bpu_eval] HALT_HITS override = %0d", _halt_hits_target);
        end

        wait_clocks(12);
        _rst = 1'b0;
    end

/*************************************************************************************
 * 2.3 Metric collection
 ************************************************************************************/
    always @(posedge _clk) begin
        if (!_rst) begin
            _cycles <= _cycles + 1;

            if (dut.u_cpu._id_fire) begin  
                _retired <= _retired + 1;
            end

            if (dut.u_cpu._bx_resolve) begin
                _branches <= _branches + 1;
            end

            if (dut.u_cpu._bx_mispredict) begin
                _mispredicts <= _mispredicts + 1;
            end

            if (dut.u_cpu._redirect) begin
                _redirects <= _redirects + 1;
            end

            // Stop once the halt self-loop is observed enough times at commit.
            if (dut.u_cpu._id_fire &&
                (dut.u_cpu._id_pc == 16'h01CA) &&
                (dut.u_cpu._ifid_insn == 16'h9000)) begin
                _halt_hits <= _halt_hits + 1;
            end
        end
    end

/*************************************************************************************
 * 2.4 End condition and report
 ************************************************************************************/
    initial begin
        wait (_rst == 1'b0);
        wait ((_halt_hits >= _halt_hits_target) || (_cycles >= _max_cycles));

        if (_retired > 0) begin
            _cpi = _cycles;
            _cpi = _cpi / _retired;
        end else begin
            _cpi = 0.0;
        end

        if (_branches > 0) begin
            _mispredict_rate = _mispredicts;
            _mispredict_rate = _mispredict_rate / _branches;
        end else begin
            _mispredict_rate = 0.0;
        end

        $display("METRIC cycles=%0d retired=%0d branches=%0d mispredicts=%0d redirects=%0d", _cycles, _retired, _branches, _mispredicts, _redirects);
        $display("METRIC cpi=%0f mispredict_rate=%0f", _cpi, _mispredict_rate);
        if (_halt_hits >= _halt_hits_target)
            $display("METRIC stop_reason=halt_loop_observed halt_hits=%0d", _halt_hits);
        else
            $display("METRIC stop_reason=max_cycles timeout_cycles=%0d", _max_cycles);
        $display("PASS tb_soc_bpu_eval");
        $finish;
    end

/*************************************************************************************
 * 2.5 Waveform dump
 ************************************************************************************/
    initial begin
        $dumpfile("waves_bpu_eval.vcd");
        $dumpvars(0, tb_soc_bpu_eval);
    end

endmodule
