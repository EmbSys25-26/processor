`timescale 1ns / 1ps

module tb_harvard_mem_isolation;

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;

    reg _rom_en = 1'b0;
    reg [9:1] _rom_addr = 9'd0;
    wire [7:0] _rom_dout_h;
    wire [7:0] _rom_dout_l;

    reg _ram_en = 1'b0;
    reg _ram_we_h = 1'b0;
    reg _ram_we_l = 1'b0;
    reg [9:1] _ram_addr = 9'd0;
    reg [7:0] _ram_din_h = 8'h00;
    reg [7:0] _ram_din_l = 8'h00;
    wire [7:0] _ram_dout_h;
    wire [7:0] _ram_dout_l;

    reg [15:0] _rom_before;
    reg [15:0] _rom_after;
    reg [15:0] _ram_after;

    integer _errors = 0;

    localparam [9:1] _probe_addr = 9'd128;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Clock Generation and DUTs
 ************************************************************************************/
    always #5 _clk = ~_clk;

    brom_1kb_be u_rom (
        .i_clk(_clk),
        .i_rst(_rst),
        .i_en(_rom_en),
        .i_addr(_rom_addr),
        .o_dout_h(_rom_dout_h),
        .o_dout_l(_rom_dout_l)
    );

    bram_1kb_be u_mem (
        .i_clk(_clk),
        .i_rst(_rst),
        .i_en(_ram_en),
        .i_we_h(_ram_we_h),
        .i_we_l(_ram_we_l),
        .i_addr(_ram_addr),
        .i_din_h(_ram_din_h),
        .i_din_l(_ram_din_l),
        .o_dout_h(_ram_dout_h),
        .o_dout_l(_ram_dout_l)
    );

/*************************************************************************************
 * 2.2 Read/Write Helpers
 ************************************************************************************/
    task _rom_read;
        input [9:1] _addr;
        output [15:0] _word;
        begin
            _rom_en <= 1'b1;
            _rom_addr <= _addr;
            @(posedge _clk);
            @(posedge _clk);
            _word = {_rom_dout_h, _rom_dout_l};
        end
    endtask

    task _ram_write_word;
        input [9:1] _addr;
        input [15:0] _word;
        begin
            _ram_en <= 1'b1;
            _ram_addr <= _addr;
            _ram_we_h <= 1'b1;
            _ram_we_l <= 1'b1;
            _ram_din_h <= _word[15:8];
            _ram_din_l <= _word[7:0];
            @(posedge _clk);
            _ram_we_h <= 1'b0;
            _ram_we_l <= 1'b0;
        end
    endtask

    task _ram_read_word;
        input [9:1] _addr;
        output [15:0] _word;
        begin
            _ram_en <= 1'b1;
            _ram_addr <= _addr;
            _ram_we_h <= 1'b0;
            _ram_we_l <= 1'b0;
            @(posedge _clk);
            @(posedge _clk);
            _word = {_ram_dout_h, _ram_dout_l};
        end
    endtask

/*************************************************************************************
 * 2.3 Harvard Isolation Scenario
 ************************************************************************************/
    initial begin
        repeat (3) @(posedge _clk);
        _rst <= 1'b0;

        // Read ROM at probe address.
        _rom_read(_probe_addr, _rom_before);

        // Write RAM at the same address with a known pattern.
        _ram_write_word(_probe_addr, 16'hABCD);

        // Read RAM back.
        _ram_read_word(_probe_addr, _ram_after);

        // Read ROM again and compare with first sample.
        _rom_read(_probe_addr, _rom_after);

        $display("WAVE harvard probe addr=%0d rom_before=0x%04h ram_after=0x%04h rom_after=0x%04h", _probe_addr, _rom_before, _ram_after, _rom_after);

        if (_ram_after !== 16'hABCD) begin
            $display("FAIL tb_harvard_mem_isolation: RAM write/read mismatch got=0x%04h", _ram_after);
            _errors = _errors + 1;
        end

        if (_rom_after !== _rom_before) begin
            $display("FAIL tb_harvard_mem_isolation: ROM changed after RAM write before=0x%04h after=0x%04h", _rom_before, _rom_after);
            _errors = _errors + 1;
        end

        if (_errors == 0) begin
            $display("PASS tb_harvard_mem_isolation");
        end else begin
            $display("FAIL tb_harvard_mem_isolation errors=%0d", _errors);
            $fatal(1);
        end

        $finish;
    end

endmodule
