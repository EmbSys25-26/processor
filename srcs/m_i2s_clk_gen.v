`timescale 1ns / 1ps

/*************************************************************************************
 * I2S CLOCK GENERATOR MODULE
 *  Generates the three I2S clock signals from the 125 MHz system oscillator:
 *    - MCLK  = 12.288 MHz  (256 × Fs,  Fs = 48 kHz)
 *    - BCLK  =  3.072 MHz  ( 64 × Fs,  32-bit frames, 2 channels)
 *    - LRCLK =     48 kHz  (  1 × Fs)
 *
 *  NOTE: MCLK is produced by the MMCM (Clock Wizard IP) instantiated in the top
 *  level (m_soc.v / wrapper). This module receives MCLK as input and derives
 *  BCLK and LRCLK via synchronous clock-enable dividers.
 *
 *  Clock relationships (all derived from the same source to stay phase-locked):
 *    BCLK  = MCLK / 4      (12.288 MHz / 4 = 3.072 MHz)
 *    LRCLK = MCLK / 256    (12.288 MHz / 256 = 48 kHz)
 ************************************************************************************/

module i2s_clk_gen (
    input  wire i_mclk,     // 12.288 MHz master clock (from MMCM)
    input  wire i_rst,
    output reg  o_bclk,     // 3.072 MHz bit clock
    output reg  o_lrclk     // 48 kHz left/right clock
);

/*************************************************************************************
 * SECTION 1. DECLARE VARIABLES
 ************************************************************************************/
    // BCLK divider: divide MCLK by 4 -> toggle every 2 cycles
    reg [1:0]  _bclk_cnt;

    // LRCLK divider: divide MCLK by 256 -> toggle every 128 cycles
    reg [7:0]  _lrclk_cnt;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

    // BCLK: toggle every 2 MCLK cycles => period = 4 MCLK cycles = 3.072 MHz
    always @(posedge i_mclk) begin
        if (i_rst) begin
            _bclk_cnt <= 2'd0;
            o_bclk    <= 1'b0;
        end else begin
            if (_bclk_cnt == 2'd1) begin
                _bclk_cnt <= 2'd0;
                o_bclk    <= ~o_bclk;
            end else begin
                _bclk_cnt <= _bclk_cnt + 2'd1;
            end
        end
    end

    // LRCLK: toggle every 128 MCLK cycles => period = 256 MCLK cycles = 48 kHz
    always @(posedge i_mclk) begin
        if (i_rst) begin
            _lrclk_cnt <= 8'd0;
            o_lrclk    <= 1'b0;
        end else begin
            if (_lrclk_cnt == 8'd127) begin
                _lrclk_cnt <= 8'd0;
                o_lrclk    <= ~o_lrclk;
            end else begin
                _lrclk_cnt <= _lrclk_cnt + 8'd1;
            end
        end
    end

endmodule
