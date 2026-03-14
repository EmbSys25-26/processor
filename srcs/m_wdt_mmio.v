`timescale 1ns / 1ps

module wdt_core (
    input  wire        i_clk,
    input  wire        i_rst,
    input  wire        i_rst_ext,

    // Control inputs (from MMIO)
    input  wire        i_wen,
    input  wire        i_rsten,
    input  wire        i_ien,
    input  wire [15:0] i_reload,
    input  wire [15:0] i_prescaler_limit,

    // Commands (from MMIO)
    input  wire        i_kick,
    input  wire        i_stop,
    input  wire        i_ctrl_write,    // strobe: CTRL reg being written this cycle

    // Status flag clears (from MMIO, write-1-to-clear)
    input  wire        i_clr_wdtif,
    input  wire        i_clr_rstf,

    // Outputs (to MMIO)
    output reg         o_wen,
    output reg         o_rsten,
    output reg         o_ien,
    output reg  [15:0] o_reload,
    output reg  [15:0] o_prescaler_limit,
    output reg  [15:0] o_cnt,
    output reg         o_wdtif,
    output reg         o_rstf,
    output reg         o_rst_pulse
);

/*************************************************************************************
 * Internal signals
 ************************************************************************************/
    reg  [15:0] _prescaler_cnt;

    wire _ps_tick  = (_prescaler_cnt >= o_prescaler_limit);
    wire _timeout  = (o_cnt == 16'h0000);

/*************************************************************************************
 * Control and Counter Logic
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst_ext) begin
            o_wen             <= 1'b0;
            o_rsten           <= 1'b0;
            o_ien             <= 1'b0;
            o_wdtif           <= 1'b0;
            o_rstf            <= 1'b0;
            o_reload          <= 16'h0000;
            o_prescaler_limit <= 16'h0000;
            o_rst_pulse       <= 1'b0;
            _prescaler_cnt    <= 16'h0000;
            o_cnt             <= 16'h0000;
        end
        else if (i_rst) begin           // rstf and wdtif do NOT change on WDT reset
            o_wen             <= 1'b0;
            o_rsten           <= 1'b0;
            o_ien             <= 1'b0;
            o_reload          <= 16'h0000;
            o_prescaler_limit <= 16'h0000;
            _prescaler_cnt    <= 16'h0000;
            o_cnt             <= 16'h0000;
            o_rst_pulse       <= 1'b0;
        end
        else begin
            // --- Reset pulse (one cycle) ---
            o_rst_pulse <= (_timeout && o_wen && o_rsten);

            // --- Status / interrupt flags ---
            if (_timeout && o_wen) begin
                if (o_ien)   o_wdtif <= 1'b1;
                if (o_rsten) o_rstf  <= 1'b1;
            end else begin
                if (i_clr_wdtif) o_wdtif <= 1'b0;  // write-1-to-clear
                if (i_clr_rstf)  o_rstf  <= 1'b0;
            end

            // --- Control register (CTRL write or auto-disable on DEAD / reset timeout) ---
            if (i_stop || (_timeout && o_wen && o_rsten)) begin
                o_wen             <= 1'b0;
                o_rsten           <= 1'b0;
                o_ien             <= 1'b0;
                o_reload          <= 16'h0000;
                o_prescaler_limit <= 16'h0000;
                _prescaler_cnt    <= 16'h0000;
                o_cnt             <= 16'h0000;
            end else if (i_ctrl_write) begin
                o_wen   <= i_wen;
                o_rsten <= i_rsten;
                o_ien   <= i_ien;
            end

            // --- Configuration latching ---
            // Prescaler limit and reload are latched directly from MMIO inputs
            // when MMIO writes them; reflected here only through o_prescaler_limit /
            // o_reload so the counter can use them.  The MMIO top level drives
            // i_prescaler_limit / i_reload combinatorially from its own write logic.
            if (!i_stop && !(_timeout && o_wen && o_rsten)) begin
                o_prescaler_limit <= i_prescaler_limit;
                o_reload          <= i_reload;
            end

            // --- Counter / prescaler ---
            if (i_kick || (i_ctrl_write && i_wen && !o_wen)) begin
                _prescaler_cnt <= 16'h0;
                o_cnt          <= i_reload;
            end else if (o_wen) begin
                if (_ps_tick) begin
                    _prescaler_cnt <= 16'h0;
                    if (o_cnt != 16'h0000)
                        o_cnt <= o_cnt - 1'b1;
                end else begin
                    _prescaler_cnt <= _prescaler_cnt + 1'b1;
                end
            end
        end
    end

endmodule
