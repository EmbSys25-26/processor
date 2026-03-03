`timescale 1ns / 1ps

/*************************************************************************************
 * I2S TX MODULE (Playback)
 *  Serializes 16-bit PCM stereo samples to the SSM2603 codec via PBDAT.
 *
 *  Protocol:
 *    - Each I2S frame = 32 bits per channel (16-bit data + 16-bit zero padding)
 *    - Left  channel: LRCLK = 0
 *    - Right channel: LRCLK = 1
 *    - LRCLK transitions on the falling edge of BCLK BEFORE the MSB is sent
 *    - Data is placed on PBDAT on the falling edge of BCLK
 *    - The codec samples PBDAT on the rising edge of BCLK
 *    - Data order: MSB first, followed by zero padding to complete 32-bit frame
 *
 *  FSM States:
 *    IDLE    -> waits for i_enable
 *    LOAD_L  -> loads left sample into shift register, asserts LRCLK=0 (1 BCLK cycle)
 *    SHIFT_L -> serializes 32 bits of left channel (bit_cnt 0..31)
 *    LOAD_R  -> loads right sample into shift register, asserts LRCLK=1 (1 BCLK cycle)
 *    SHIFT_R -> serializes 32 bits of right channel. At bit_cnt=31: asserts sample_req
 *    DONE    -> pulses sample_req for 1 cycle, loops back to LOAD_L
 ************************************************************************************/

module i2s_tx (
    input  wire        i_bclk,        // 3.072 MHz bit clock
    input  wire        i_rst,
    input  wire        i_enable,      // Enable TX (from CTRL register)
    input  wire [15:0] i_left,        // Left  channel PCM sample
    input  wire [15:0] i_right,       // Right channel PCM sample
    output reg         o_pbdat,       // Playback data to SSM2603
    output reg         o_lrclk,       // Left/Right clock to SSM2603
    output reg         o_sample_req   // Pulses HIGH for 1 BCLK cycle when next sample needed
);

/*************************************************************************************
 * SECTION 1. DECLARE/DEFINE VARIABLES
 ************************************************************************************/

/****************************************************************************
 * 1.1 FSM STATES
 ***************************************************************************/
    localparam [2:0] IDLE    = 3'd0;
    localparam [2:0] LOAD_L  = 3'd1;
    localparam [2:0] SHIFT_L = 3'd2;
    localparam [2:0] LOAD_R  = 3'd3;
    localparam [2:0] SHIFT_R = 3'd4;
    localparam [2:0] DONE    = 3'd5;

/****************************************************************************
 * 1.2 REGISTERS
 ***************************************************************************/
    reg [2:0]  _state;
    reg [31:0] _shift_reg;  // 32-bit shift register (16-bit sample + 16-bit padding)
    reg [4:0]  _bit_cnt;    // Bit counter: 0..31

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 *  Triggered on negedge BCLK: data placed on PBDAT is sampled by codec on posedge.
 ************************************************************************************/
    always @(negedge i_bclk) begin
        if (i_rst) begin
            _state      <= IDLE;
            _shift_reg  <= 32'd0;
            _bit_cnt    <= 5'd0;
            o_pbdat     <= 1'b0;
            o_lrclk     <= 1'b0;
            o_sample_req <= 1'b0;
        end else begin
            o_sample_req <= 1'b0; // Default: deassert

            case (_state)

                IDLE: begin
                    o_pbdat  <= 1'b0;
                    if (i_enable) begin
                        _state <= LOAD_L;
                    end
                end

                // Load left sample. LRCLK transitions to 0 here, BEFORE MSB is sent.
                // This state lasts exactly 1 BCLK cycle (per I2S spec timing).
                LOAD_L: begin
                    _shift_reg <= {i_left, 16'h0000}; // 16-bit data + 16-bit zero padding
                    o_lrclk    <= 1'b0;
                    _bit_cnt   <= 5'd0;
                    _state     <= SHIFT_L;
                end

                // Serialize 32 bits of left channel, MSB first
                SHIFT_L: begin
                    o_pbdat    <= _shift_reg[31];
                    _shift_reg <= {_shift_reg[30:0], 1'b0};
                    _bit_cnt   <= _bit_cnt + 5'd1;
                    if (_bit_cnt == 5'd31) begin
                        _state <= LOAD_R;
                    end
                end

                // Load right sample. LRCLK transitions to 1 here, BEFORE MSB is sent.
                // This state lasts exactly 1 BCLK cycle (per I2S spec timing).
                LOAD_R: begin
                    _shift_reg <= {i_right, 16'h0000};
                    o_lrclk    <= 1'b1;
                    _bit_cnt   <= 5'd0;
                    _state     <= SHIFT_R;
                end

                // Serialize 32 bits of right channel, MSB first
                SHIFT_R: begin
                    o_pbdat    <= _shift_reg[31];
                    _shift_reg <= {_shift_reg[30:0], 1'b0};
                    _bit_cnt   <= _bit_cnt + 5'd1;
                    if (_bit_cnt == 5'd31) begin
                        o_sample_req <= 1'b1; // Request next sample from MMIO
                        _state       <= DONE;
                    end
                end

                // Signal that next sample pair is needed. Loop back immediately.
                DONE: begin
                    o_sample_req <= 1'b0;
                    _state       <= LOAD_L;
                end

                default: _state <= IDLE;

            endcase
        end
    end

endmodule
