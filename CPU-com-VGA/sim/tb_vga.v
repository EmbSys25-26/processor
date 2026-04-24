`timescale 1ns / 1ps

module tb_vga();

    // Entradas do teu módulo
    reg clk_sys;
    reg clk_vga;
    reg rst;
    reg sel;
    reg we;
    reg re;
    reg [1:0] addr;
    reg [15:0] wdata;
    reg mode_switch;

    // Saídas do teu módulo
    wire [15:0] rdata;
    wire rdy;
    wire [3:0] vga_red;
    wire [3:0] vga_green;
    wire [3:0] vga_blue;
    wire hsync;
    wire vsync;

    // Instanciar o teu módulo principal
    m_vga_mmio uut (
        .i_clkSystem(clk_sys),
        .i_clkVGA(clk_vga),
        .i_rst(rst),
        .i_sel(sel),
        .i_we(we),
        .i_re(re),
        .i_addr(addr),
        .i_wdata(wdata),
        .i_mode_switch(mode_switch),
        .o_rdata(rdata),
        .o_rdy(rdy),
        .o_vga_red(vga_red),
        .o_vga_green(vga_green),
        .o_vga_blue(vga_blue),
        .o_hsync(hsync),
        .o_vsync(vsync)
    );

    // 1. Gerador de Relógio Principal (125 MHz)
    initial begin
        clk_sys = 0;
        forever #4 clk_sys = ~clk_sys; 
    end

    // 2. Gerador de Relógio VGA (25 MHz)
    initial begin
        clk_vga = 0;
        forever #20 clk_vga = ~clk_vga; 
    end

    // 3. O Processador Virtual (A nossa sequência de comandos)
    initial begin
        // Tudo a zero (Reset ativado)
        rst = 1; sel = 0; we = 0; re = 0; addr = 0; wdata = 0; mode_switch = 0;

        // Espera 100ns e desliga o Reset
        #100;
        rst = 0;

        // Dá tempo ao teu hardware para escrever o 'm' na memória
        #200;

        // Escreve via MMIO para LIGAR o ecrã
        @(posedge clk_sys);
        sel = 1;
        we = 1;
        addr = 2'b00;         // Registo CNTRL
        wdata = 16'h0001;     // Bit 0 = 1 (Ligar o ecrã)
        
        @(posedge clk_sys);
        sel = 0;
        we = 0;

        // Deixa a simulação correr para desenhar a imagem
        #100000;
        $display("Simulacao concluida!");
        $finish;
    end

endmodule