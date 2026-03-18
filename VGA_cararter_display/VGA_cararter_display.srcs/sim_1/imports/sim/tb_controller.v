`timescale 1ns / 1ps

`include "constants.vh"

`timescale 1ns / 1ps

`include "constants.vh"

module tb_controller();

/*************************************************************************************
 * SECÇÃO 1 - DECLARAÇÃO DE SINAIS
 ************************************************************************************/

    reg        _clk          = 1'b0;
    reg        _rst          = 1'b1;
    reg [4:0]  _imgSel       = 5'b0;
    reg [7:0]  _ascii_code   = 8'd0;
    reg        _ascii_valid  = 1'b0;

    wire [`VGA_CHANNEL_SIZE:0] _vga_red;
    wire [`VGA_CHANNEL_SIZE:0] _vga_green;
    wire [`VGA_CHANNEL_SIZE:0] _vga_blue;
    wire _hsync, _vsync;

    integer _timeout;

/*************************************************************************************
 * SECÇÃO 2 - RELÓGIO E DUT
 ************************************************************************************/

    always #5 _clk = ~_clk;

    controller dut (
        .i_clk          (_clk),
        .i_rst          (_rst),
        .i_imgSel       (_imgSel),
        .i_ascii_code   (_ascii_code),
        .i_ascii_valid (_ascii_valid),
        .o_vga_red      (_vga_red),
        .o_vga_green    (_vga_green),
        .o_vga_blue     (_vga_blue),
        .o_hsync        (_hsync),
        .o_vsync        (_vsync)
    );

/*************************************************************************************
 * SECÇÃO 3 - CAPTURA DE PIXELS (REMOVIDA)
 ************************************************************************************/
    // Esta secção foi removida conforme solicitado.
    // Não é possível aceder a sinais internos como dut.periph_vga.hsync_module._state
    // na simulação pós-síntese.

/*************************************************************************************
 * SECÇÃO 4 - ESTÍMULO
 ************************************************************************************/

    initial begin
        _imgSel      = 5'b00000;
        _ascii_code  = 8'd0;
        _ascii_valid = 1'b0;
        _rst         = 1'b1;

        // 1. Solta o reset
        repeat (20) @(posedge _clk);
        _rst <= 1'b0;

        // 2. Espera clk_wiz estabilizar + FSM terminar arranque
        repeat (2000) @(posedge _clk);

        // 3. Activa modo texto
        $display("--> A ACTIVAR MODO TEXTO (SrcChar)");
        _imgSel <= 5'b10000;
        repeat (100) @(posedge _clk);

        // 4. Envia 'b'
        // NOTA: Em pós-síntese, dut._clkSystem pode não estar acessível.
        // O ideal é usar o clock principal _clk ou expor o clock do sistema como saída.
        repeat (5) @(posedge _clk);
        _ascii_code  <= 8'd98;
        _ascii_valid <= 1'b1;
        repeat (1) @(posedge _clk);
        _ascii_valid <= 1'b0;
        repeat (10) @(posedge _clk);

        // 5. Envia 'o'
        repeat (5) @(posedge _clk);
        _ascii_code  <= 8'd111;
        _ascii_valid <= 1'b1;
        repeat (1) @(posedge _clk);
        _ascii_valid <= 1'b0;
        repeat (10) @(posedge _clk);

        // 6. Envia 'a'
        repeat (5) @(posedge _clk);
        _ascii_code  <= 8'd97;
        _ascii_valid <= 1'b1;
        repeat (1) @(posedge _clk);
        _ascii_valid <= 1'b0;
        repeat (10) @(posedge _clk);

        // 7. Envia 's'
        repeat (5) @(posedge _clk);
        _ascii_code  <= 8'd115;
        _ascii_valid <= 1'b1;
        repeat (1) @(posedge _clk);
        _ascii_valid <= 1'b0;
        repeat (10) @(posedge _clk);

        // espaços
        repeat (5) @(posedge _clk); _ascii_code <= 8'd32; _ascii_valid <= 1'b1;
        repeat (1) @(posedge _clk); _ascii_valid <= 1'b0; repeat(10) @(posedge _clk);

        repeat (5) @(posedge _clk); _ascii_code <= 8'd32; _ascii_valid <= 1'b1;
        repeat (1) @(posedge _clk); _ascii_valid <= 1'b0; repeat(10) @(posedge _clk);

        repeat (5) @(posedge _clk); _ascii_code <= 8'd32; _ascii_valid <= 1'b1;
        repeat (1) @(posedge _clk); _ascii_valid <= 1'b0; repeat(10) @(posedge _clk);

        // 't'
        repeat (5) @(posedge _clk); _ascii_code <= 8'd116; _ascii_valid <= 1'b1;
        repeat (1) @(posedge _clk); _ascii_valid <= 1'b0; repeat(10) @(posedge _clk);
        // 'y'
        repeat (5) @(posedge _clk); _ascii_code <= 8'd121; _ascii_valid <= 1'b1;
        repeat (1) @(posedge _clk); _ascii_valid <= 1'b0; repeat(10) @(posedge _clk);
        // 'p'
        repeat (5) @(posedge _clk); _ascii_code <= 8'd112; _ascii_valid <= 1'b1;
        repeat (1) @(posedge _clk); _ascii_valid <= 1'b0; repeat(10) @(posedge _clk);
        // 'e'
        repeat (5) @(posedge _clk); _ascii_code <= 8'd101; _ascii_valid <= 1'b1;
        repeat (1) @(posedge _clk); _ascii_valid <= 1'b0; repeat(10) @(posedge _clk);
        // ' '
        repeat (5) @(posedge _clk); _ascii_code <= 8'd32; _ascii_valid <= 1'b1;
        repeat (1) @(posedge _clk); _ascii_valid <= 1'b0; repeat(10) @(posedge _clk);
        // 's'
        repeat (5) @(posedge _clk); _ascii_code <= 8'd115; _ascii_valid <= 1'b1;
        repeat (1) @(posedge _clk); _ascii_valid <= 1'b0; repeat(10) @(posedge _clk);
        // 'h'
        repeat (5) @(posedge _clk); _ascii_code <= 8'd104; _ascii_valid <= 1'b1;
        repeat (1) @(posedge _clk); _ascii_valid <= 1'b0; repeat(10) @(posedge _clk);
        // 'i'
        repeat (5) @(posedge _clk); _ascii_code <= 8'd105; _ascii_valid <= 1'b1;
        repeat (1) @(posedge _clk); _ascii_valid <= 1'b0; repeat(10) @(posedge _clk);
        // 't'
        repeat (5) @(posedge _clk); _ascii_code <= 8'd116; _ascii_valid <= 1'b1;
        repeat (1) @(posedge _clk); _ascii_valid <= 1'b0; repeat(10) @(posedge _clk);

        $display("--> Caracteres enviados. A aguardar frame completo...");

        // 8. Espera ~2.7 frames
        _timeout = 4500000;
        while (_timeout > 0) begin
            @(posedge _clk);
            _timeout <= _timeout - 1;
        end

        $finish;
    end

endmodule

/*
module tb_controller();

/*************************************************************************************
 * SECÇÃO 1 - DECLARAÇÃO DE SINAIS
 ************************************************************************************/
/*
    reg        _clk          = 1'b0;
    reg        _rst          = 1'b1;
    reg [4:0]  _imgSel       = 5'b0;
    reg [7:0]  _ascii_code   = 8'd0;
    reg        _ascii_valid  = 1'b0;

    wire [`VGA_CHANNEL_SIZE:0] _vga_red;
    wire [`VGA_CHANNEL_SIZE:0] _vga_green;
    wire [`VGA_CHANNEL_SIZE:0] _vga_blue;
    wire _hsync, _vsync;

    integer _timeout;
    integer file;

/*************************************************************************************
 * SECÇÃO 2 - RELÓGIO E DUT
 ************************************************************************************/

  /*  always #5 _clk = ~_clk;

    controller dut (
        .i_clk         (_clk),
        .i_rst         (_rst),
        .i_imgSel      (_imgSel),
        .i_ascii_code  (_ascii_code),
        .i_ascii_valid (_ascii_valid),
        .o_vga_red     (_vga_red),
        .o_vga_green   (_vga_green),
        .o_vga_blue    (_vga_blue),
        .o_hsync       (_hsync),
        .o_vsync       (_vsync)
    );

/*************************************************************************************
 * SECÇÃO 3 - CAPTURA DE PIXELS
 ************************************************************************************/
/*
    initial begin
        file = $fopen("vga_output.txt", "w");
    end

    always @(posedge dut._clkVGA) begin
        if (dut.periph_vga.hsync_module._state == 2'b11 &&
            dut.periph_vga.vsync_module._state == 2'b11)
        begin
            $fwrite(file, "%b%b%b\n",
                dut.o_vga_red[3],
                dut.o_vga_green[3],
                dut.o_vga_blue[3]);
        end
    end

/*************************************************************************************
 * SECÇÃO 4 - ESTÍMULO
 ************************************************************************************/
/*
    initial begin
        _imgSel      = 5'b00000;
        _ascii_code  = 8'd0;
        _ascii_valid = 1'b0;
        _rst         = 1'b1;

        // 1. Solta o reset
        repeat (20) @(posedge _clk);
        _rst <= 1'b0;

        // 2. Espera clk_wiz estabilizar + FSM terminar arranque
        repeat (2000) @(posedge _clk);

        // 3. Activa modo texto
        $display("--> A ACTIVAR MODO TEXTO (SrcChar)");
        _imgSel <= 5'b10000;
        repeat (100) @(posedge _clk);

        // 4. Envia 'b' - pulso de 1 ciclo de clkSystem
        @(posedge dut._clkSystem);
        _ascii_code  <= 8'd98;
        _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem);
        _ascii_valid <= 1'b0; 
        repeat (10) @(posedge dut._clkSystem);

        // 5. Envia 'o'
        @(posedge dut._clkSystem);
        _ascii_code  <= 8'd111;
        _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem);
        _ascii_valid <= 1'b0;
        repeat (10) @(posedge dut._clkSystem);

        // 6. Envia 'a'
        @(posedge dut._clkSystem);
        _ascii_code  <= 8'd97;
        _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem);
        _ascii_valid <= 1'b0;
        repeat (10) @(posedge dut._clkSystem);

        // 7. Envia 's'
        @(posedge dut._clkSystem);
        _ascii_code  <= 8'd115;
        _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem);
        _ascii_valid <= 1'b0;
        repeat (10) @(posedge dut._clkSystem);

        // espaços
        @(posedge dut._clkSystem); _ascii_code <= 8'd32; _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem); _ascii_valid <= 1'b0; repeat(10) @(posedge dut._clkSystem);

        @(posedge dut._clkSystem); _ascii_code <= 8'd32; _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem); _ascii_valid <= 1'b0; repeat(10) @(posedge dut._clkSystem);

        @(posedge dut._clkSystem); _ascii_code <= 8'd32; _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem); _ascii_valid <= 1'b0; repeat(10) @(posedge dut._clkSystem);
        
         // 4. Envia 'b' - pulso de 1 ciclo de clkSystem
        @(posedge dut._clkSystem);
        _ascii_code  <= 8'd98;
        _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem);
        _ascii_valid <= 1'b0; 
        repeat (10) @(posedge dut._clkSystem);

        // 5. Envia 'o'
        @(posedge dut._clkSystem);
        _ascii_code  <= 8'd111;
        _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem);
        _ascii_valid <= 1'b0;
        repeat (10) @(posedge dut._clkSystem);

        // 6. Envia 'a'
        @(posedge dut._clkSystem);
        _ascii_code  <= 8'd97;
        _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem);
        _ascii_valid <= 1'b0;
        repeat (10) @(posedge dut._clkSystem);

        // 7. Envia 's'
        @(posedge dut._clkSystem);
        _ascii_code  <= 8'd115;
        _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem);
        _ascii_valid <= 1'b0;
        repeat (10) @(posedge dut._clkSystem);
        
        // 't'
        @(posedge dut._clkSystem); _ascii_code <= 8'd116; _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem); _ascii_valid <= 1'b0; repeat(10) @(posedge dut._clkSystem);
        // 'y'
        @(posedge dut._clkSystem); _ascii_code <= 8'd121; _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem); _ascii_valid <= 1'b0; repeat(10) @(posedge dut._clkSystem);
        // 'p'
        @(posedge dut._clkSystem); _ascii_code <= 8'd112; _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem); _ascii_valid <= 1'b0; repeat(10) @(posedge dut._clkSystem);
        // 'e'
        @(posedge dut._clkSystem); _ascii_code <= 8'd101; _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem); _ascii_valid <= 1'b0; repeat(10) @(posedge dut._clkSystem);
        // ' '
        @(posedge dut._clkSystem); _ascii_code <= 8'd32; _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem); _ascii_valid <= 1'b0; repeat(10) @(posedge dut._clkSystem);
        // 's'
        @(posedge dut._clkSystem); _ascii_code <= 8'd115; _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem); _ascii_valid <= 1'b0; repeat(10) @(posedge dut._clkSystem);
        // 'h'
        @(posedge dut._clkSystem); _ascii_code <= 8'd104; _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem); _ascii_valid <= 1'b0; repeat(10) @(posedge dut._clkSystem);
        // 'i'
        @(posedge dut._clkSystem); _ascii_code <= 8'd105; _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem); _ascii_valid <= 1'b0; repeat(10) @(posedge dut._clkSystem);
        // 't'
        @(posedge dut._clkSystem); _ascii_code <= 8'd116; _ascii_valid <= 1'b1;
        @(posedge dut._clkSystem); _ascii_valid <= 1'b0; repeat(10) @(posedge dut._clkSystem);

        $display("--> Caracteres enviados. A aguardar frame completo...");

        // 8. Espera ~2.7 frames para captura completa
        _timeout = 4500000;
        while (_timeout > 0) begin
            @(posedge _clk);
            _timeout <= _timeout - 1;
        end

        $fclose(file);
        $finish;
    end

endmodule

*/