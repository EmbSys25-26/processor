`timescale 1ns / 1ps
`default_nettype none

module tb_i2c_mmio_regs;

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;

    reg _sel = 1'b0;
    reg _we = 1'b0;
    reg _re = 1'b0;
    reg [2:0] _addr = 3'b000;
    reg [15:0] _wdata = 16'h0000;

    wire [15:0] _rdata;
    wire _rdy;
    wire _irq_req;

    tri1 _i2c_sda;
    tri1 _i2c_scl;

    integer _errors = 0;
    integer _timeout;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 DUT and clock generation
 ************************************************************************************/
    always #5 _clk = ~_clk;

    i2c_mmio dut (
        .i_clk(_clk),
        .i_rst(_rst),
        .i_sel(_sel),
        .i_we(_we),
        .i_re(_re),
        .i_addr(_addr),
        .i_wdata(_wdata),
        .o_rdata(_rdata),
        .o_rdy(_rdy),
        .o_irq_req(_irq_req),
        .io_i2c_sda(_i2c_sda),
        .io_i2c_scl(_i2c_scl)
    );

/*************************************************************************************
 * 2.2 MMIO helpers
 ************************************************************************************/
    task mmio_write(input [2:0] i_addr, input [15:0] i_data);
        begin
            _addr <= i_addr;
            _wdata <= i_data;
            _sel <= 1'b1;
            _we <= 1'b1;
            _re <= 1'b0;
            @(posedge _clk);
            _sel <= 1'b0;
            _we <= 1'b0;
            _addr <= 3'b000;
            _wdata <= 16'h0000;
        end
    endtask

    task mmio_read(input [2:0] i_addr, output [15:0] o_data);
        begin
            _addr <= i_addr;
            _sel <= 1'b1;
            _we <= 1'b0;
            _re <= 1'b1;
            #1;
            o_data = _rdata;
            @(posedge _clk);
            _sel <= 1'b0;
            _re <= 1'b0;
            _addr <= 3'b000;
        end
    endtask

/*************************************************************************************
 * 2.3 Stimulus and checks
 ************************************************************************************/
    reg [15:0] _rd;
    initial begin
        repeat (5) @(posedge _clk);
        _rst <= 1'b0;

        mmio_read(3'd0, _rd);
        if (_rd[3:0] !== 4'b0000) begin
            $display("FAIL tb_i2c_mmio_regs: CTRL reset mismatch 0x%04h", _rd);
            _errors = _errors + 1;
        end

        mmio_write(3'd2, 16'h0002);
        mmio_write(3'd3, 16'h0084);
        mmio_write(3'd4, 16'h0001);

        mmio_read(3'd2, _rd);
        if (_rd !== 16'h0002) begin
            $display("FAIL tb_i2c_mmio_regs: DIV readback mismatch 0x%04h", _rd);
            _errors = _errors + 1;
        end

        mmio_read(3'd3, _rd);
        if (_rd[7:0] !== 8'h84) begin
            $display("FAIL tb_i2c_mmio_regs: ADDR readback mismatch 0x%04h", _rd);
            _errors = _errors + 1;
        end

        mmio_read(3'd4, _rd);
        if (_rd[7:0] !== 8'h01) begin
            $display("FAIL tb_i2c_mmio_regs: LEN readback mismatch 0x%04h", _rd);
            _errors = _errors + 1;
        end

        // EN=1, START=1, RW=0, IRQ_EN=1.
        mmio_write(3'd0, 16'h000B);

        _timeout = 400;
        mmio_read(3'd0, _rd);
        while ((_timeout > 0) && (_rd[1] == 1'b1)) begin
            mmio_read(3'd0, _rd);
            _timeout = _timeout - 1;
        end
        if (_rd[1] !== 1'b0) begin
            $display("FAIL tb_i2c_mmio_regs: START did not self-clear");
            _errors = _errors + 1;
        end

        _timeout = 2000;
        _rd = 16'h0000;
        while ((_timeout > 0) && (_rd[1] == 1'b0)) begin
            mmio_read(3'd1, _rd);
            _timeout = _timeout - 1;
        end

        $display("WAVE i2c status after run: 0x%04h", _rd);

        if (_rd[1] !== 1'b1) begin
            $display("FAIL tb_i2c_mmio_regs: DONE not set");
            _errors = _errors + 1;
        end
        if (_rd[2] !== 1'b1) begin
            $display("FAIL tb_i2c_mmio_regs: ACK_ERR not set on missing slave ACK");
            _errors = _errors + 1;
        end
        if (_rd[4] !== 1'b1 || _irq_req !== 1'b1) begin
            $display("FAIL tb_i2c_mmio_regs: IRQ pending not asserted");
            _errors = _errors + 1;
        end

        // W1C: DONE, ACK_ERR, IRQ_PEND.
        mmio_write(3'd1, 16'h0016);
        @(posedge _clk);
        mmio_read(3'd1, _rd);

        if (_rd[4:1] !== 4'b0000) begin
            $display("FAIL tb_i2c_mmio_regs: STATUS W1C clear failed status=0x%04h", _rd);
            _errors = _errors + 1;
        end

        if (_errors == 0) begin
            $display("PASS tb_i2c_mmio_regs");
        end else begin
            $display("FAIL tb_i2c_mmio_regs errors=%0d", _errors);
            $fatal(1);
        end
        $finish;
    end

endmodule
