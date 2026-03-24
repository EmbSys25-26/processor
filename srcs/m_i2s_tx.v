`timescale 1ns / 1ps

/*************************************************************************************
 * I2S TX MODULE (Playback)
 * Serializes stereo PCM words from the asynchronous FIFO to the codec (PBDAT).
 *
 * Core Features:
 * - 5-State FSM to strictly comply with the Philips I2S Standard.
 * - Generates the LRCLK internally to prevent clock domain race conditions.
 * - Enforces exactly 1 BCLK cycle delay between LRCLK toggle and the MSB transmission.
 ************************************************************************************/
module i2s_tx (
    input  wire        i_bclk,          // 3.072 MHz bit clock (Serial Clock)
    input  wire        i_rst,           // Active-high reset
    input  wire        i_enable,        // TX enable signal from MMIO (100MHz domain)
    input  wire [31:0] i_fifo_rdata,    // Data from FIFO: {left[15:0], right[15:0]}
    input  wire        i_fifo_empty,    // FIFO empty flag (BCLK domain)
    output reg         o_fifo_rd_en,    // 1-cycle pulse to pop data from FIFO
    output reg         o_underrun,      // 1-cycle pulse if FIFO is empty when needed
    output reg         o_pbdat,         // Serial audio data output to Codec
    output reg         o_lrclk          // Left/Right Channel Clock (FSM is the master)
);

    // FSM State Definitions
    localparam [2:0] IDLE    = 3'd0;
    localparam [2:0] LOAD_L  = 3'd1;
    localparam [2:0] SHIFT_L = 3'd2;
    localparam [2:0] LOAD_R  = 3'd3;
    localparam [2:0] SHIFT_R = 3'd4;

    reg [2:0]  _state;                  // Current FSM state
    reg [31:0] _shift_reg;              // Shift register for serialization
    reg [31:0] _stereo_word;            // Holds the full 32-bit fetched from FIFO
    reg [4:0]  _bit_cnt;                // Counts the 31 bits being shifted
    
    // CDC (Clock Domain Crossing) registers for the enable signal
    reg _enable_s1, _enable_s2;

    always @(negedge i_bclk) begin
        if (i_rst) begin
            _state       <= IDLE;
            _shift_reg   <= 32'd0;
            _stereo_word <= 32'd0;
            _bit_cnt     <= 5'd0;
            _enable_s1   <= 1'b0;
            _enable_s2   <= 1'b0;
            o_pbdat      <= 1'b0;
            o_lrclk      <= 1'b0;
            o_fifo_rd_en <= 1'b0;
            o_underrun   <= 1'b0;
        end else begin
            // 2-Flop Synchronizer: Safely brings 'i_enable' into the 3MHz BCLK domain
            _enable_s1 <= i_enable;
            _enable_s2 <= _enable_s1;
            
            // Default pulse values (active for 1 cycle only)
            o_fifo_rd_en <= 1'b0;
            o_underrun   <= 1'b0;

            case (_state)
                IDLE: begin
                    o_pbdat <= 1'b0;
                    if (_enable_s2) begin
                        // If enabled, check if we have audio samples available
                        if (!i_fifo_empty) begin
                            _stereo_word <= i_fifo_rdata;
                            o_fifo_rd_en <= 1'b1; // Pop the sample from FIFO
                        end else begin
                            _stereo_word <= 32'd0; // Play silence if no data
                            o_underrun   <= 1'b1;  // Flag an underrun error
                        end
                        _state <= LOAD_L;
                    end
                end

                // LOAD_L: Prepares Left Channel.
                // Philips I2S Rule: Must delay 1 clock cycle before sending the first bit.
                LOAD_L: begin
                    _shift_reg <= {_stereo_word[31:16], 16'h0000}; // Load left 16 bits
                    o_lrclk    <= 1'b0;                            // Set Left Channel
                    _bit_cnt   <= 5'd0;
                    _state     <= SHIFT_L;                         // Delay accomplished
                end

                // SHIFT_L: Serializes Left Channel data
                SHIFT_L: begin
                    o_pbdat    <= _shift_reg[31];                  // Output MSB
                    _shift_reg <= {_shift_reg[30:0], 1'b0};        // Shift left
                    _bit_cnt   <= _bit_cnt + 5'd1;
                    if (_bit_cnt == 5'd30) begin
                        _state <= LOAD_R;                          // Move to Right Channel
                    end
                end

                // LOAD_R: Prepares Right Channel.
                // Philips I2S Rule: Must delay 1 clock cycle before sending the first bit.
                LOAD_R: begin
                    _shift_reg <= {_stereo_word[15:0], 16'h0000};  // Load right 16 bits
                    o_lrclk    <= 1'b1;                            // Set Right Channel
                    _bit_cnt   <= 5'd0;
                    _state     <= SHIFT_R;                         // Delay accomplished
                end

                // SHIFT_R: Serializes Right Channel data
                SHIFT_R: begin
                    o_pbdat    <= _shift_reg[31];                  // Output MSB
                    _shift_reg <= {_shift_reg[30:0], 1'b0};        // Shift left
                    _bit_cnt   <= _bit_cnt + 5'd1;
                    if (_bit_cnt == 5'd30) begin
                        if (_enable_s2) begin
                            // Continuous streaming: Fetch next sample seamlessly
                            if (!i_fifo_empty) begin
                                _stereo_word <= i_fifo_rdata;
                                o_fifo_rd_en <= 1'b1; // Pop next sample
                            end else begin
                                _stereo_word <= 32'd0; // Underflow: insert silence
                                o_underrun   <= 1'b1;
                            end
                            _state <= LOAD_L;
                        end else begin
                            _state <= IDLE;           // Stop if disabled
                        end
                    end
                end

                default: _state <= IDLE;
            endcase
        end
    end
endmodule