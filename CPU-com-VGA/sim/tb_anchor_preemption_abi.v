`timescale 1ns / 1ps
`default_nettype none

module tb_anchor_preemption_abi;

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;
    reg [3:0] _par_i = 4'h0;
    reg _uart_rx = 1'b1;
    tri1 _i2c_sda;
    tri1 _i2c_scl;

    wire [3:0] _par_o;
    wire _uart_tx;

    integer _cycles = 0;
    integer _errors = 0;
    localparam integer _max_cycles = 12000;

    wire _irq_take;
    wire [15:0] _irq_vector;
    wire _in_irq;

    wire [1:0] _cpu_irq_depth;
    wire [15:0] _rf_s0;
    wire [15:0] _rf_s1;

    reg _seen_timer0_take = 1'b0;
    reg _seen_timer1_take = 1'b0;
    reg _seen_nested_timer1 = 1'b0;

    reg _seen_baseline = 1'b0;
    reg _seen_mutation = 1'b0;
    reg _seen_restored = 1'b0;

    reg [15:0] _last_s0 = 16'h0000;
    reg [15:0] _last_s1 = 16'h0000;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 DUT and Clk
 ************************************************************************************/
    always #5 _clk = ~_clk;

    soc dut (
        .i_clk(_clk),
        .i_rst(_rst),
        .i_par_i(_par_i),
        .o_par_o(_par_o),
        .i_uart_rx(_uart_rx),
        .o_uart_tx(_uart_tx),
        .io_i2c_sda(_i2c_sda),
        .io_i2c_scl(_i2c_scl)
    );

    assign _irq_take = dut._irq_take;
    assign _irq_vector = dut._irq_vector;
    assign _in_irq = dut._in_irq;

    assign _cpu_irq_depth = dut.u_cpu._irq_depth;
    assign _rf_s0 = dut.u_cpu.u_datapath.u_regfile._s0;
    assign _rf_s1 = dut.u_cpu.u_datapath.u_regfile._s1;

/*************************************************************************************
 * 2.2 Anchor Monitors
 ************************************************************************************/
    always @(posedge _clk) begin
        if (_rst) begin
            _cycles <= 0;
            _last_s0 <= 16'h0000;
            _last_s1 <= 16'h0000;
        end else begin
            _cycles <= _cycles + 1;

            // Preemption anchor:
            // IRQ0 (0x0020) should be taken and then IRQ1 (0x0040) should preempt while already in IRQ context.
            if (_irq_take) begin
                if (_irq_vector == 16'h0020) begin
                    _seen_timer0_take <= 1'b1;
                    $display("ANCHOR IRQ take TIMER0 at cycle=%0d depth=%0d in_irq=%0b", _cycles, _cpu_irq_depth, _in_irq);
                end
                if (_irq_vector == 16'h0040) begin
                    _seen_timer1_take <= 1'b1;
                    $display("ANCHOR IRQ take TIMER1 at cycle=%0d depth=%0d in_irq=%0b", _cycles, _cpu_irq_depth, _in_irq);
                    if (_in_irq || (_cpu_irq_depth != 0)) begin
                        _seen_nested_timer1 <= 1'b1;
                        $display("ANCHOR PREEMPTION observed: TIMER1 taken while already in IRQ context");
                    end
                end
            end

            // ABI anchor: baseline -> mutation inside calls -> restored values.
            if ((_rf_s0 == 16'h0123) && (_rf_s1 == 16'h4567)) begin
                if (!_seen_baseline) begin
                    _seen_baseline <= 1'b1;
                    $display("ANCHOR ABI baseline seen cycle=%0d s0=0x%04h s1=0x%04h", _cycles, _rf_s0, _rf_s1);
                end else if (_seen_mutation && !_seen_restored) begin
                    _seen_restored <= 1'b1;
                    $display("ANCHOR ABI restored after mutation cycle=%0d s0=0x%04h s1=0x%04h", _cycles, _rf_s0, _rf_s1);
                end
            end

            if (_seen_baseline && ((_rf_s0 != 16'h0123) || (_rf_s1 != 16'h4567))) begin
                if (!_seen_mutation) begin
                    _seen_mutation <= 1'b1;
                    $display("ANCHOR ABI mutation observed cycle=%0d s0=0x%04h s1=0x%04h", _cycles, _rf_s0, _rf_s1);
                end
            end

            // Print on s0/s1 changes for waveform-style evidence.
            if ((_rf_s0 != _last_s0) || (_rf_s1 != _last_s1)) begin
                $display("WAVE ABI cycle=%0d s0=0x%04h s1=0x%04h", _cycles, _rf_s0, _rf_s1);
                _last_s0 <= _rf_s0;
                _last_s1 <= _rf_s1;
            end

            if (_cycles >= _max_cycles) begin
                if (!_seen_timer0_take) begin
                    $display("FAIL ANCHOR: TIMER0 irq_take not observed");
                    _errors = _errors + 1;
                end
                if (!_seen_timer1_take) begin
                    $display("FAIL ANCHOR: TIMER1 irq_take not observed");
                    _errors = _errors + 1;
                end
                if (!_seen_nested_timer1) begin
                    $display("FAIL ANCHOR: TIMER1 preemption over TIMER0 not observed");
                    _errors = _errors + 1;
                end

                if (!_seen_baseline) begin
                    $display("FAIL ANCHOR: ABI baseline values not seen");
                    _errors = _errors + 1;
                end
                if (!_seen_mutation) begin
                    $display("FAIL ANCHOR: ABI mutation inside calls not seen");
                    _errors = _errors + 1;
                end
                if (!_seen_restored) begin
                    $display("FAIL ANCHOR: ABI restore to 0x0123/0x4567 not seen after mutation");
                    _errors = _errors + 1;
                end

                if (_errors == 0) begin
                    $display("PASS tb_anchor_preemption_abi");
                end else begin
                    $display("FAIL tb_anchor_preemption_abi errors=%0d", _errors);
                    $fatal(1);
                end
                $finish;
            end
        end
    end

/*************************************************************************************
 * 2.3 Stimulus
 ************************************************************************************/
    initial begin
        repeat (5) @(posedge _clk);
        _rst = 1'b0;

        repeat (200) @(posedge _clk);
    end

endmodule
