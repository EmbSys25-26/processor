`timescale 1ns / 1ps
`default_nettype none

/*************************************************************************************
 * PS2 DEVICE MODEL (CORRIGIDO PARA OS 11 PULSOS REAIS)
 ************************************************************************************/

module tb_ps2_device_model (
    input  wire       i_clk,          
    input  wire       i_rst,
    inout  wire       io_ps2_clk,
    inout  wire       io_ps2_data,
    output reg        o_frame_done,   
    output reg        o_start_ok,     
    output reg        o_parity_ok,    
    output reg        o_stop_ok,      
    output reg [7:0]  o_data          
);

    localparam PS2_HALF = 40000;

    reg _clk_oe  = 1'b0;
    reg _data_oe = 1'b0;

    assign io_ps2_clk  = _clk_oe  ? 1'b0 : 1'bz;
    assign io_ps2_data = _data_oe ? 1'b0 : 1'bz;

    reg [9:0] _captured; 
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

            // 1. Espera pelo Inhibit (CLK low)
            _timeout = 20000;
            while (io_ps2_clk !== 1'b0 && _timeout > 0) begin
                @(posedge i_clk);
                _timeout = _timeout - 1;
            end
            if (_timeout == 0) disable receive_frame;

            // 2. Espera que o host liberte o CLK
            _timeout = 20000;
            while (io_ps2_clk === 1'b0 && _timeout > 0) begin
                @(posedge i_clk);
                _timeout = _timeout - 1;
            end
            if (_timeout == 0) disable receive_frame;

            // LER START BIT AQUI (Antes dos flancos começarem!)
            #(PS2_HALF / 2);
            _start_bit = io_ps2_data;

            // 3. Gerar EXATAMENTE 11 Pulsos: 8 Data + 1 Parity + 1 Stop + 1 ACK
            for (i = 0; i < 11; i = i + 1) begin
                
                // No 11º pulso (i=10), o teclado puxa a linha DATA para baixo (ACK)
                if (i == 10) _data_oe = 1'b1; 

                // Pull CLK low (Flanco Descendente)
                _clk_oe = 1'b1;
                #(PS2_HALF);

                // Release CLK (Flanco Ascendente)
                _clk_oe = 1'b0;

                // Sample DATA (No flanco ascendente o host já meteu os dados)
                if (i < 8)       _captured[i] = io_ps2_data;   // Bits 0-7
                else if (i == 8) _captured[8] = io_ps2_data;   // Parity
                else if (i == 9) _captured[9] = io_ps2_data;   // Stop

                #(PS2_HALF);
                
                // Liberta a linha DATA no fim do pulso 11 (Fim do ACK)
                if (i == 10) _data_oe = 1'b0; 
            end

            // 4. Avaliar resultados                      
            o_data           = _captured[7:0];
            o_start_ok       = (_start_bit == 1'b0);
            _expected_parity = ~(^expected_byte);
            o_parity_ok      = (_captured[8] == _expected_parity);
            o_stop_ok        = (_captured[9] == 1'b1);
            o_frame_done     = 1'b1;

            #1;
            o_frame_done = 1'b0;
        end
    endtask

endmodule