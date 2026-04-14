`timescale 1ns / 1ps

// ============================================================================
// Module  : m_mouse_init
// Project : PS/2 Mouse Controller
// File    : m_mouse_init.v
//
// Description:
//   Executes the PS/2 mouse power-on initialisation sequence and identifies
//   the connected device.  Once initialisation completes, o_ready is asserted
//   permanently and o_is_mouse reflects whether a mouse was detected.
//
// Initialisation sequence (per PS/2 specification):
//
//   1.  Send 0xFF  (Reset command)
//   2.  Wait for 0xFA (ACK) from the device
//   3.  Wait for 0xAA (Basic Assurance Test complete)
//   4.  Wait up to 500 ms for a spontaneous device ID byte
//         - Some mice send their ID immediately after BAT
//         - If nothing arrives within 500 ms, send 0xF2 (Identify) explicitly
//   5.  (If 0xF2 was sent) Wait for 0xFA ACK, then wait for the ID byte reply
//   6.  Classify the device ID:
//         0x00  standard mouse        -> send 0xF4 (Enable Data Reporting)
//         0x03  scroll-wheel mouse    -> send 0xF4
//         0x04  5-button mouse        -> send 0xF4
//         other (keyboard, etc.)      -> assert ready, set o_is_mouse = 0
//   7.  Wait for 0xFA ACK to 0xF4
//   8.  Assert o_is_mouse = 1 and o_ready = 1 permanently
//
//   Any 1-second timeout while waiting restarts the sequence from step 1.
//
// FSM design notes:
//   The FSM is fully flat – there is no return_state register.
//   Each command (0xFF, 0xF2, 0xF4) has its own dedicated SEND state that
//   waits until the transmitter is free and then fires the byte.  This makes
//   every state transition explicit and readable without tracing a second
//   register.
//
// FSM states:
//   SEND_RESET      – wait for TX idle, send 0xFF
//   WAIT_ACK        – expect 0xFA  ACK to 0xFF
//   WAIT_BAT        – expect 0xAA  BAT complete
//   WAIT_ID         – wait 500 ms for spontaneous ID byte
//   SEND_IDENTIFY   – wait for TX idle, send 0xF2
//   WAIT_ID_ACK     – expect 0xFA  ACK to 0xF2
//   WAIT_ID_REPLY   – expect ID byte returned by device
//   CLASSIFY        – decide mouse vs keyboard from stored ID
//   SEND_ENABLE     – wait for TX idle, send 0xF4
//   WAIT_ENABLE_ACK – expect 0xFA  ACK to 0xF4
//   READY           – terminal state, outputs held
//
// Parameters:
//   CLK_FREQ – System clock frequency in Hz (default 50 000 000).
//              Used to compute 500 ms and 1 s timeout thresholds.
//
// Port list:
//   i_clk      System clock, rising-edge sensitive
//   i_rst      Synchronous active-high reset
//   i_rx_data  8-bit byte received from the PS/2 device
//   i_rx_valid 1-cycle pulse: i_rx_data contains a new valid byte
//   i_tx_busy  High while the PS/2 transmitter is busy sending a byte
//   o_tx_data  8-bit byte to transmit to the PS/2 device
//   o_tx_valid 1-cycle pulse: request transmitter to send o_tx_data
//   o_is_mouse Asserted when the identified device is a mouse
//   o_ready    Asserted permanently once initialisation finishes
// ============================================================================

module m_mouse_init #(
    parameter CLK_FREQ = 50_000_000   // System clock frequency in Hz (50 MHz)
)(
    input  wire       i_clk,
    input  wire       i_rst,
    input  wire [7:0] i_rx_data,
    input  wire       i_rx_valid,
    input  wire       i_tx_busy,
    output reg  [7:0] o_tx_data,
    output reg        o_tx_valid,
    output reg        o_is_mouse,
    output reg        o_ready
);

    // -------------------------------------------------------------------------
    // Timeout thresholds
    // 26 bits is sufficient: ceil(log2(50_000_000)) = 26
    // -------------------------------------------------------------------------
    localparam [25:0] T_500MS = CLK_FREQ / 2;   // 25 000 000 cycles at 50 MHz
    localparam [25:0] T_1S    = CLK_FREQ;        // 50 000 000 cycles at 50 MHz

    // -------------------------------------------------------------------------
    // FSM state encoding
    // -------------------------------------------------------------------------
    localparam [3:0]
        SEND_RESET      = 4'd0,
        WAIT_ACK        = 4'd1,
        WAIT_BAT        = 4'd2,
        WAIT_ID         = 4'd3,
        SEND_IDENTIFY   = 4'd4,
        WAIT_ID_ACK     = 4'd5,
        WAIT_ID_REPLY   = 4'd6,
        CLASSIFY        = 4'd7,
        SEND_ENABLE     = 4'd8,
        WAIT_ENABLE_ACK = 4'd9,
        READY           = 4'd10;

    // -------------------------------------------------------------------------
    // Internal registers
    // -------------------------------------------------------------------------
    reg  [3:0]  _state;       // Current FSM state
    reg  [25:0] _timer;       // Watchdog counter, reset on each state entry
    reg  [7:0]  _device_id;   // Device ID captured from the PS/2 byte stream

    // Timeout flags – combinational, driven by _timer
    wire _t500ms = (_timer >= T_500MS);   // True once 500 ms have elapsed
    wire _t1s    = (_timer >= T_1S);      // True once 1 s has elapsed

    // =========================================================================
    // Synchronous FSM process
    // =========================================================================
    always @(posedge i_clk) begin
        if (i_rst) begin
            // -----------------------------------------------------------------
            // Reset: return to first state and clear all driven outputs
            // -----------------------------------------------------------------
            _state     <= SEND_RESET;
            o_tx_data  <= 8'h00;
            o_tx_valid <= 1'b0;
            o_is_mouse <= 1'b0;
            o_ready    <= 1'b0;
            _timer     <= 26'd0;
            _device_id <= 8'hFF;   // 0xFF is not a valid device ID
        end else begin
            // -----------------------------------------------------------------
            // Defaults applied every cycle.
            // o_tx_valid is a 1-cycle pulse: de-assert unless a state sets it.
            // _timer increments every cycle; states reset it on transitions.
            // -----------------------------------------------------------------
            o_tx_valid <= 1'b0;
            _timer     <= _timer + 1;

            case (_state)

                // =============================================================
                // SEND_RESET
                //   Load 0xFF into o_tx_data and wait until the PS/2
                //   transmitter signals it is idle (i_tx_busy = 0).
                //   Fire o_tx_valid for one clock, then wait for ACK.
                //   No timeout: transmitter will always become free eventually.
                // =============================================================
                SEND_RESET: begin
                    o_tx_data <= 8'hFF;          // Prepare Reset command
                    if (!i_tx_busy) begin
                        o_tx_valid <= 1'b1;      // Trigger transmission
                        _timer     <= 26'd0;
                        _state     <= WAIT_ACK;
                    end
                end

                // =============================================================
                // WAIT_ACK
                //   The device acknowledges the Reset command with 0xFA.
                //   1 s timeout with no response -> retry from the beginning.
                // =============================================================
                WAIT_ACK: begin
                    if (i_rx_valid && i_rx_data == 8'hFA) begin
                        _timer <= 26'd0;
                        _state <= WAIT_BAT;
                    end
                    if (_t1s) begin
                        _timer <= 26'd0;
                        _state <= SEND_RESET;    // Timeout: restart
                    end
                end

                // =============================================================
                // WAIT_BAT
                //   After acknowledging the reset, the device performs its
                //   Basic Assurance Test (BAT) and sends 0xAA on success.
                //   1 s timeout -> restart.
                // =============================================================
                WAIT_BAT: begin
                    if (i_rx_valid && i_rx_data == 8'hAA) begin
                        _timer <= 26'd0;
                        _state <= WAIT_ID;
                    end
                    if (_t1s) begin
                        _timer <= 26'd0;
                        _state <= SEND_RESET;
                    end
                end

                // =============================================================
                // WAIT_ID
                //   Some mice transmit their device ID automatically after the
                //   BAT without being prompted.  Listen for up to 500 ms.
                //   If a byte arrives -> capture it and classify immediately.
                //   If 500 ms elapse with no byte -> send 0xF2 to ask for ID.
                // =============================================================
                WAIT_ID: begin
                    if (i_rx_valid) begin
                        // Spontaneous ID received – bypass the identify command
                        _device_id <= i_rx_data;
                        _timer     <= 26'd0;
                        _state     <= CLASSIFY;
                    end else if (_t500ms) begin
                        // No spontaneous ID – request it explicitly
                        _timer <= 26'd0;
                        _state <= SEND_IDENTIFY;
                    end
                end

                // =============================================================
                // SEND_IDENTIFY
                //   Send the 0xF2 (Identify) command.
                //   Wait for the transmitter to become free, then fire 0xF2.
                // =============================================================
                SEND_IDENTIFY: begin
                    o_tx_data <= 8'hF2;          // Prepare Identify command
                    if (!i_tx_busy) begin
                        o_tx_valid <= 1'b1;      // Trigger transmission
                        _timer     <= 26'd0;
                        _state     <= WAIT_ID_ACK;
                    end
                end

                // =============================================================
                // WAIT_ID_ACK
                //   Wait for the device to acknowledge 0xF2 with 0xFA.
                //   1 s timeout -> restart.
                // =============================================================
                WAIT_ID_ACK: begin
                    if (i_rx_valid && i_rx_data == 8'hFA) begin
                        _timer <= 26'd0;
                        _state <= WAIT_ID_REPLY;
                    end
                    if (_t1s) begin
                        _timer <= 26'd0;
                        _state <= SEND_RESET;
                    end
                end

                // =============================================================
                // WAIT_ID_REPLY
                //   After the 0xFA ACK the device sends one byte containing
                //   its type identifier.  Capture it and move to CLASSIFY.
                //   1 s timeout -> restart.
                // =============================================================
                WAIT_ID_REPLY: begin
                    if (i_rx_valid) begin
                        _device_id <= i_rx_data;   // Store the device ID
                        _timer     <= 26'd0;
                        _state     <= CLASSIFY;
                    end
                    if (_t1s) begin
                        _timer <= 26'd0;
                        _state <= SEND_RESET;
                    end
                end

                // =============================================================
                // CLASSIFY
                //   Inspect the stored device ID and branch accordingly.
                //
                //   Mouse IDs (PS/2 specification):
                //     0x00  Standard two/three-button PS/2 mouse
                //     0x03  IntelliMouse (scroll wheel)
                //     0x04  IntelliMouse Explorer (scroll + 4th/5th buttons)
                //
                //   Any other ID (e.g. 0xAB = keyboard) is not a mouse.
                //   In that case assert ready without enabling data reporting.
                // =============================================================
                CLASSIFY: begin
                    case (_device_id)
                        8'h00, 8'h03, 8'h04: begin
                            // Recognised mouse ID – enable data reporting
                            _timer <= 26'd0;
                            _state <= SEND_ENABLE;
                        end
                        default: begin
                            // Unknown or keyboard device – finalise without 0xF4
                            o_is_mouse <= 1'b0;
                            o_ready    <= 1'b1;
                            _state     <= READY;
                        end
                    endcase
                end

                // =============================================================
                // SEND_ENABLE
                //   Send the 0xF4 (Enable Data Reporting) command.
                //   The mouse will start streaming 3-byte movement packets
                //   only after it receives and acknowledges this command.
                //   Wait for the transmitter to become free, then fire 0xF4.
                // =============================================================
                SEND_ENABLE: begin
                    o_tx_data <= 8'hF4;          // Prepare Enable Reporting command
                    if (!i_tx_busy) begin
                        o_tx_valid <= 1'b1;      // Trigger transmission
                        _timer     <= 26'd0;
                        _state     <= WAIT_ENABLE_ACK;
                    end
                end

                // =============================================================
                // WAIT_ENABLE_ACK
                //   Wait for the mouse to acknowledge 0xF4 with 0xFA.
                //   On success assert o_is_mouse and o_ready and move to the
                //   terminal READY state.
                //   1 s timeout -> restart.
                // =============================================================
                WAIT_ENABLE_ACK: begin
                    if (i_rx_valid && i_rx_data == 8'hFA) begin
                        o_is_mouse <= 1'b1;   // Device confirmed as a mouse
                        o_ready    <= 1'b1;   // Initialisation complete
                        _state     <= READY;
                    end
                    if (_t1s) begin
                        _timer <= 26'd0;
                        _state <= SEND_RESET;
                    end
                end

                // =============================================================
                // READY
                //   Terminal state – initialisation is complete.
                //   o_ready is held asserted; no further transitions occur.
                //   The always block continues to re-assert o_ready each cycle
                //   to prevent synthesis optimisation from removing the flop.
                // =============================================================
                READY: begin
                    o_ready <= 1'b1;   // Hold permanently
                end

                // =============================================================
                // Default safety net
                //   An illegal state encoding causes an immediate return to
                //   SEND_RESET so the initialisation sequence can recover.
                // =============================================================
                default: _state <= SEND_RESET;

            endcase
        end
    end

endmodule
