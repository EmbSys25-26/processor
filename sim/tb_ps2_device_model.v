`timescale 1ns / 1ps
`default_nettype none

/*************************************************************************************
 * PS2 DEVICE MODEL
 *  Simulates a PS/2 device for H2D (host to device) testing.
 *
 *  H2D frame sequence:
 *   1. Host pulls CLK low >= 100us (inhibit)
 *   2. Host releases CLK - device takes control of CLK
 *   3. Host pulls DATA low (start bit)
 *   4. Device generates 11 CLK pulses: start + 8 data + parity + stop
 *   5. Device sends ACK by pulling DATA low for one CLK cycle
 ************************************************************************************/

module tb_ps2_device_model (
    input  wire       i_clk,          // system clock (for timeout counting)
    input  wire       i_rst,
    inout  wire       io_ps2_clk,
    inout  wire       io_ps2_data,
    output reg        o_frame_done,   // pulses high when full frame received
    output reg        o_start_ok,     // start bit was 0
    output reg        o_parity_ok,    // parity was correct
    output reg        o_stop_ok,      // stop bit was 1
    output reg [7:0]  o_data          // received data byte
);

    // PS/2 half period ~40us
    localparam PS2_HALF = 40000;

    // open-drain drive
    reg _clk_oe  = 1'b0;
    reg _data_oe = 1'b0;

    assign io_ps2_clk  = _clk_oe  ? 1'b0 : 1'bz;
    assign io_ps2_data = _data_oe ? 1'b0 : 1'bz;

    reg [9:0] _captured; // [7:0]=data [8]=parity [9]=stop
    reg       _start_bit;
    integer   i;
    reg       _expected_parity;
    integer   _timeout;

    initial begin
        o_frame_done    = 1'b0;
        o_start_ok      = 1'b0;
        o_parity_ok     = 1'b0;
        o_stop_ok       = 1'b0;
        o_data          = 8'h00;
        _clk_oe         = 1'b0;
        _data_oe        = 1'b0;
    end

    task receive_frame(input [7:0] expected_byte);
        begin
            o_frame_done = 1'b0;

            // wait for host to pull CLK low (inhibit)
            _timeout = 20000;
            while (io_ps2_clk !== 1'b0 && _timeout > 0) begin
                @(posedge i_clk);
                _timeout = _timeout - 1;
            end
            if (_timeout == 0) begin
                $display("FAIL ps2_device_model: timeout waiting for inhibit");
                disable receive_frame;
            end
            $display("PS2_MODEL: inhibit detected");

            // wait for host to release CLK - device takes CLK control immediately
            _timeout = 20000;
            while (io_ps2_clk === 1'b0 && _timeout > 0) begin
                @(posedge i_clk);
                _timeout = _timeout - 1;
            end
            if (_timeout == 0) begin
                $display("FAIL ps2_device_model: timeout waiting for CLK release");
                disable receive_frame;
            end
            $display("PS2_MODEL: CLK released, taking CLK control");

            // generate 11 CLK pulses: start + 8 data + parity + stop
            for (i = 0; i <= 10; i = i + 1) begin
                // pull CLK low
                _clk_oe = 1'b1;
                #(PS2_HALF);

                // sample DATA while CLK is low
                if (i == 0) begin
                    _start_bit = io_ps2_data;
                end else begin
                    _captured[i-1] = io_ps2_data;
                end

                // release CLK (rising edge)
                _clk_oe = 1'b0;
                #(PS2_HALF);
            end

            // send ACK: pull DATA low for one CLK cycle
            _clk_oe  = 1'b1;
            _data_oe = 1'b1;
            #(PS2_HALF);
            _clk_oe  = 1'b0;
            #(PS2_HALF);
            _data_oe = 1'b0;
            
            $display("PS2_MODEL: ACK sent");

            // evaluate results                      
            o_data           = _captured[7:0];
            o_start_ok       = (_start_bit == 1'b0);
            _expected_parity = ~(^expected_byte);
            o_parity_ok      = (_captured[8] == _expected_parity);
            o_stop_ok        = (_captured[9] == 1'b1);
            o_frame_done     = 1'b1;
           

            $display("PS2_MODEL: frame done data=0x%02h start_ok=%b parity_ok=%b stop_ok=%b",
                o_data, o_start_ok, o_parity_ok, o_stop_ok);

            // clear frame_done after one delta
            #1;
            o_frame_done = 1'b0;
        end
    endtask

endmodule
