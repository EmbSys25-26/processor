`timescale 1ns / 1ps

// ================================================================
//  tb_vga  -  Testbench para m_hsync_vga + m_vsync_vga
//
//  Testes cobertos:
//    TC1  - Reset: outputs em estado correcto após reset
//    TC2  - Sequência de timing horizontal completa (1 linha)
//           Verifica FP=16, SYNC=96, BP=48, VISIBLE=640 ciclos
//           e que hsync só fica LOW durante SYNC
//    TC3  - Pixel data: RGB444 correctamente mapeado
//    TC4  - tvalid=0 (VDMA stall): counter não avança, pixel não muda
//    TC5  - tlast normal (pixel 639): linha fecha correctamente
//    TC6  - tlast antecipado (pixel <639): linha fecha mais cedo
//    TC7  - tuser desalinhado: resync forçado para BACK_PORCH
//    TC8  - tuser alinhado (pixel 0): ignorado correctamente
//    TC9  - enVGA=0: FSM fica em reset, tready=0
//    TC10 - Integração hsync+vsync: contagem de linhas e vsync
//           Verifica que vsync pulsa depois de 480+10+2+33 linhas
//
//  Como correr no Vivado:
//    1. Adiciona este ficheiro como simulation source
//    2. Cria constants.vh com `define VGA_CHANNEL_SIZE 3
//    3. Run Simulation → Run Behavioral Simulation
// ================================================================

// --- constants.vh inline (se não tiveres o ficheiro na sim) -----
// Comenta este bloco se já tens constants.vh no projecto
`ifndef VGA_CHANNEL_SIZE
  `define VGA_CHANNEL_SIZE 3
`endif
// ----------------------------------------------------------------

module tb_vga;

// ----------------------------------------------------------------
// Parâmetros de timing VGA (devem ser iguais ao RTL)
// ----------------------------------------------------------------
localparam FP      = 16;
localparam SYNC_W  = 96;
localparam BP      = 48;
localparam VISIBLE = 640;
localparam H_TOTAL = FP + SYNC_W + BP + VISIBLE;  // 800

localparam V_FP      = 10;
localparam V_SYNC_W  = 2;
localparam V_BP      = 33;
localparam V_VISIBLE = 480;
localparam V_TOTAL   = V_FP + V_SYNC_W + V_BP + V_VISIBLE;  // 525

// ----------------------------------------------------------------
// Clock: 25 MHz → período 40 ns
// ----------------------------------------------------------------
localparam CLK_PERIOD = 40;

// ----------------------------------------------------------------
// DUT signals
// ----------------------------------------------------------------
reg         clk;
reg         rst;
reg         enVGA;
reg  [15:0] tdata;
reg         tvalid;
reg         tlast;
reg         tuser;

wire        tready;
wire        endLine;
wire [3:0]  vga_red;
wire [3:0]  vga_green;
wire [3:0]  vga_blue;
wire        hsync;
wire        vsync;
wire [1:0]  hsync_state;
wire [1:0]  vsync_state;

// ----------------------------------------------------------------
// Contadores de erros
// ----------------------------------------------------------------
integer errors = 0;
integer test_num = 0;

// ----------------------------------------------------------------
// Instâncias DUT
// ----------------------------------------------------------------
m_hsync_vga u_hsync (
    .i_clk         (clk),
    .i_rst         (rst),
    .i_enVGA       (enVGA),
    .i_axis_tdata  (tdata),
    .i_axis_tvalid (tvalid),
    .i_axis_tlast  (tlast),
    .i_axis_tuser  (tuser),
    .o_axis_tready (tready),
    .o_endLine     (endLine),
    .o_vga_red     (vga_red),
    .o_vga_green   (vga_green),
    .o_vga_blue    (vga_blue),
    .o_hsync       (hsync),
    .o_state_debug (hsync_state)
);

m_vsync_vga u_vsync (
    .i_clk         (clk),
    .i_rst         (rst),
    .i_enVGA       (enVGA),
    .i_endLine     (endLine),
    .o_vsync       (vsync),
    .o_state_debug (vsync_state)
);

// ----------------------------------------------------------------
// Clock generation
// ----------------------------------------------------------------
initial clk = 0;
always #(CLK_PERIOD/2) clk = ~clk;

// ----------------------------------------------------------------
// Tarefa: aplicar reset
// ----------------------------------------------------------------
task do_reset;
    begin
        rst    = 1;
        enVGA  = 0;
        tvalid = 0;
        tlast  = 0;
        tuser  = 0;
        tdata  = 16'h0000;
        repeat(4) @(posedge clk);
        #1;
        rst = 0;
    end
endtask

// ----------------------------------------------------------------
// Tarefa: enviar N pixels normais (sem stall, sem tlast/tuser)
// ----------------------------------------------------------------
task send_pixels;
    input integer n;
    input [15:0] pixel_val;
    integer i;
    begin
        tdata  = pixel_val;
        tvalid = 1;
        tlast  = 0;
        tuser  = 0;
        for (i = 0; i < n; i = i + 1) begin
            @(posedge clk); #1;
        end
        tvalid = 0;
    end
endtask

// ----------------------------------------------------------------
// Tarefa: enviar um pixel com tlast
// ----------------------------------------------------------------
task send_pixel_last;
    input [15:0] pixel_val;
    begin
        tdata  = pixel_val;
        tvalid = 1;
        tlast  = 1;
        tuser  = 0;
        @(posedge clk); #1;
        tvalid = 0;
        tlast  = 0;
    end
endtask

// ----------------------------------------------------------------
// Tarefa: esperar N ciclos de clock
// ----------------------------------------------------------------
task wait_cycles;
    input integer n;
    begin
        repeat(n) @(posedge clk);
        #1;
    end
endtask

// ----------------------------------------------------------------
// Tarefa: avançar uma linha completa com pixels válidos
// (FP+SYNC+BP já foram consumidos pelo counter interno,
//  esta tarefa só trata o VISIBLE e depois espera o blanking)
// ----------------------------------------------------------------
task run_full_line;
    integer i;
    begin
        // Espera entrar em VISIBLE (FP+SYNC+BP = 160 ciclos)
        wait_cycles(FP + SYNC_W + BP);
        // Envia 640 pixels
        tvalid = 1;
        tdata  = 16'hA5A0;
        for (i = 0; i < VISIBLE - 1; i = i + 1) begin
            tlast = 0; tuser = 0;
            @(posedge clk); #1;
        end
        // último pixel com tlast
        tlast = 1;
        @(posedge clk); #1;
        tvalid = 0; tlast = 0;
    end
endtask

// ----------------------------------------------------------------
// Tarefa: CHECK com mensagem
// ----------------------------------------------------------------
task check;
    input condition;
    input [255:0] msg;
    begin
        if (!condition) begin
            $display("FAIL [TC%0d] %s  (time=%0t)", test_num, msg, $time);
            errors = errors + 1;
        end else begin
            $display("PASS [TC%0d] %s", test_num, msg);
        end
    end
endtask

// ----------------------------------------------------------------
// Variáveis auxiliares para contagem
// ----------------------------------------------------------------
integer cnt;
integer hsync_low_cnt;
integer endline_cnt;
integer vsync_low_cnt;
reg     prev_endLine;
reg     prev_vsync;

// ================================================================
// STIMULUS PRINCIPAL
// ================================================================
initial begin
    $display("=== Testbench VGA (hsync + vsync) ===");
    $dumpfile("tb_vga.vcd");
    $dumpvars(0, tb_vga);

    // ------------------------------------------------------------
    // TC1 - Reset
    // ------------------------------------------------------------
    test_num = 1;
    do_reset;
    @(posedge clk); #1;
    check(hsync       == 1'b1,  "TC1: hsync=1 apos reset");
    check(vsync       == 1'b1,  "TC1: vsync=1 apos reset");
    check(tready      == 1'b0,  "TC1: tready=0 apos reset (enVGA=0)");
    check(endLine     == 1'b0,  "TC1: endLine=0 apos reset");
    check(vga_red     == 4'h0,  "TC1: red=0 apos reset");
    check(vga_green   == 4'h0,  "TC1: green=0 apos reset");
    check(vga_blue    == 4'h0,  "TC1: blue=0 apos reset");
    check(hsync_state == 2'b00, "TC1: hsync FSM em FRONT_PORCH apos reset");
    check(vsync_state == 2'b00, "TC1: vsync FSM em FRONT_PORCH apos reset");

    // ------------------------------------------------------------
    // TC2 - Sequência de timing horizontal: conta ciclos de cada fase
    // ------------------------------------------------------------
    test_num = 2;
    do_reset;
    enVGA  = 1;
    tvalid = 0;

    // --- FRONT PORCH: hsync deve ficar HIGH durante 16 ciclos ---
    cnt = 0;
    repeat(FP) begin
        @(posedge clk); #1;
        if (hsync == 1'b1) cnt = cnt + 1;
    end
    check(cnt == FP, "TC2: hsync=1 durante todos os ciclos de FRONT_PORCH");
    check(tready == 1'b0, "TC2: tready=0 em FRONT_PORCH");

    // --- SYNC: hsync deve ficar LOW durante 96 ciclos ---
    // Espera 1 ciclo para entrar em SYNC
    @(posedge clk); #1;
    cnt = 0;
    hsync_low_cnt = 0;
    repeat(SYNC_W) begin
        if (hsync == 1'b0) hsync_low_cnt = hsync_low_cnt + 1;
        @(posedge clk); #1;
    end
    check(hsync_low_cnt == SYNC_W, "TC2: hsync=0 durante todos os ciclos de SYNC (96)");

    // --- BACK PORCH: hsync HIGH, tready=0 ---
    cnt = 0;
    repeat(BP) begin
        if (hsync == 1'b1 && tready == 1'b0) cnt = cnt + 1;
        @(posedge clk); #1;
    end
    check(cnt == BP, "TC2: hsync=1 e tready=0 durante BACK_PORCH");

    // --- VISIBLE: tready=1 durante os 640 ciclos ---
    // (com tvalid=0 o counter não avança - testamos duração real abaixo em TC4)
    @(posedge clk); #1;
    check(tready == 1'b1, "TC2: tready=1 no inicio de VISIBLE");
    check(hsync  == 1'b1, "TC2: hsync=1 em VISIBLE");

    // ------------------------------------------------------------
    // TC3 - Pixel data RGB444 correctamente mapeado
    // ------------------------------------------------------------
    test_num = 3;
    do_reset;
    enVGA  = 1;
    tvalid = 0;
    // Avança até VISIBLE
    wait_cycles(FP + SYNC_W + BP + 1);
    // Envia pixel com valor conhecido: R=A, G=5, B=3, pad=F
    tdata  = 16'hA53F;
    tvalid = 1;
    tlast  = 0;
    tuser  = 0;
    @(posedge clk); #1;
    // Amostra no ciclo seguinte (o registo actualiza no posedge anterior)
    check(vga_red   == 4'hA, "TC3: vga_red  = 0xA");
    check(vga_green == 4'h5, "TC3: vga_green= 0x5");
    check(vga_blue  == 4'h3, "TC3: vga_blue = 0x3");
    tvalid = 0;

    // ------------------------------------------------------------
    // TC4 - tvalid=0: counter não avança, cor não muda
    // ------------------------------------------------------------
    test_num = 4;
    do_reset;
    enVGA  = 1;
    tvalid = 0;
    wait_cycles(FP + SYNC_W + BP + 1);
    // Envia 1 pixel vermelho
    tdata  = 16'hF000;
    tvalid = 1;
    @(posedge clk); #1;
    tvalid = 0;
    // Guarda cor e estado actual
    begin : tc4_block
        reg [3:0] r_saved;
        reg [9:0] ctr_saved;
        r_saved   = vga_red;
        ctr_saved = u_hsync._pixelCounter;
        // Espera 5 ciclos sem tvalid
        repeat(5) @(posedge clk);
        #1;
        check(vga_red              == r_saved,   "TC4: cor nao muda com tvalid=0");
        check(u_hsync._pixelCounter == ctr_saved, "TC4: pixelCounter nao avanca com tvalid=0");
        check(tready               == 1'b1,      "TC4: tready continua=1 mesmo com stall");
    end

    // ------------------------------------------------------------
    // TC5 - tlast normal no pixel 639
    // ------------------------------------------------------------
    test_num = 5;
    do_reset;
    enVGA  = 1;
    tvalid = 0;
    wait_cycles(FP + SYNC_W + BP + 1);
    // Envia 639 pixels normais
    tdata  = 16'hBBB0;
    tvalid = 1;
    repeat(VISIBLE - 1) begin
        tlast = 0; tuser = 0;
        @(posedge clk); #1;
    end
    // Pixel 639 com tlast
    tlast = 1;
    @(posedge clk); #1;
    check(endLine == 1'b1, "TC5: endLine=1 quando tlast chega no pixel 639");
    check(hsync_state == 2'b00, "TC5: FSM vai para FRONT_PORCH apos tlast no pixel 639");
    tvalid = 0; tlast = 0;
    @(posedge clk); #1;
    check(endLine == 1'b0, "TC5: endLine=0 no ciclo seguinte (pulse de 1 ciclo)");

    // ------------------------------------------------------------
    // TC6 - tlast antecipado (linha curta): linha fecha antes do pixel 639
    // ------------------------------------------------------------
    test_num = 6;
    do_reset;
    enVGA  = 1;
    tvalid = 0;
    wait_cycles(FP + SYNC_W + BP + 1);
    // Envia apenas 100 pixels e depois tlast
    tdata  = 16'hCCC0;
    tvalid = 1;
    repeat(99) begin
        tlast = 0; tuser = 0;
        @(posedge clk); #1;
    end
    tlast = 1;
    @(posedge clk); #1;
    check(endLine == 1'b1, "TC6: endLine=1 quando tlast antecipado (pixel 99)");
    check(hsync_state == 2'b00, "TC6: FSM vai para FRONT_PORCH apos tlast antecipado");
    tvalid = 0; tlast = 0;

    // ------------------------------------------------------------
    // TC7 - tuser desalinhado: resync forçado
    //        Simula VDMA a começar um novo frame quando o nosso
    //        counter já está em metade da linha (pixel ~100)
    // ------------------------------------------------------------
    test_num = 7;
    do_reset;
    enVGA  = 1;
    tvalid = 0;
    wait_cycles(FP + SYNC_W + BP + 1);
    // Avança 100 pixels sem tuser
    tdata  = 16'hDDD0;
    tvalid = 1;
    repeat(100) begin
        tlast = 0; tuser = 0;
        @(posedge clk); #1;
    end
    check(u_hsync._pixelCounter == 10'd100, "TC7: counter=100 antes do tuser");
    // Agora chega tuser=1 (VDMA começa novo frame no meio da linha)
    tuser = 1;
    @(posedge clk); #1;
    check(hsync_state == 2'b10, "TC7: FSM vai para BACK_PORCH ao receber tuser desalinhado");
    check(endLine     == 1'b0,  "TC7: endLine NAO pulsou (linha incompleta nao conta)");
    check(u_hsync._pixelCounter == 10'd0, "TC7: pixelCounter resetado para 0");
    tvalid = 0; tuser = 0;

    // ------------------------------------------------------------
    // TC8 - tuser alinhado (pixel 0): deve ser aceite normalmente
    //        sem forçar resync
    // ------------------------------------------------------------
    test_num = 8;
    do_reset;
    enVGA  = 1;
    tvalid = 0;
    wait_cycles(FP + SYNC_W + BP + 1);
    // Envia pixel 0 com tuser=1 (correcto - inicio de frame)
    tdata  = 16'hEEE0;
    tvalid = 1;
    tuser  = 1;
    tlast  = 0;
    @(posedge clk); #1;
    check(hsync_state == 2'b11, "TC8: FSM permanece em VISIBLE com tuser no pixel 0");
    check(vga_red     == 4'hE,  "TC8: pixel aceite correctamente com tuser=1 alinhado");
    check(u_hsync._pixelCounter == 10'd1, "TC8: pixelCounter avancou para 1");
    tvalid = 0; tuser = 0;

    // ------------------------------------------------------------
    // TC9 - enVGA=0: FSM deve resetar, tready=0
    // ------------------------------------------------------------
    test_num = 9;
    do_reset;
    enVGA  = 1;
    tvalid = 0;
    // Avança até VISIBLE
    wait_cycles(FP + SYNC_W + BP + 1);
    check(tready == 1'b1, "TC9: tready=1 antes de desligar enVGA");
    // Desliga enVGA
    enVGA = 0;
    @(posedge clk); #1;
    check(tready      == 1'b0,  "TC9: tready=0 imediatamente apos enVGA=0");
    check(hsync_state == 2'b00, "TC9: FSM volta a FRONT_PORCH com enVGA=0");
    check(hsync       == 1'b1,  "TC9: hsync=1 com enVGA=0");

    // ------------------------------------------------------------
    // TC10 - Integração: conta linhas e verifica vsync
    //         Corre uma frame completa e verifica que:
    //           - endLine pulsa exactamente 525 vezes (V_TOTAL)
    //           - vsync fica LOW exactamente durante 2 linhas
    // ------------------------------------------------------------
    test_num = 10;
    $display("TC10: a correr frame completa (pode demorar alguns segundos de simulacao)...");
    do_reset;
    enVGA       = 1;
    tvalid      = 0;
    endline_cnt = 0;
    vsync_low_cnt = 0;
    prev_endLine  = 0;
    prev_vsync    = 1;

    // Fork: monitoriza endLine e vsync enquanto corremos a frame
    fork
        begin : frame_runner
            integer line_i, px_i;
            // Corre V_TOTAL linhas completas
            for (line_i = 0; line_i < V_TOTAL; line_i = line_i + 1) begin
                // Espera entrar em VISIBLE
                wait_cycles(FP + SYNC_W + BP);
                @(posedge clk); #1;
                // Envia VISIBLE pixels
                tdata  = {4'hA, 4'hB, 4'hC, 4'h0};
                tvalid = 1;
                for (px_i = 0; px_i < VISIBLE - 1; px_i = px_i + 1) begin
                    tlast = 0; tuser = 0;
                    @(posedge clk); #1;
                end
                tlast = 1;
                @(posedge clk); #1;
                tvalid = 0; tlast = 0;
            end
        end
        begin : monitor
            // Corre durante V_TOTAL * H_TOTAL + margem ciclos
            repeat(V_TOTAL * H_TOTAL + 1000) begin
                @(posedge clk); #1;
                // Conta rising edges de endLine
                if (endLine && !prev_endLine) endline_cnt = endline_cnt + 1;
                prev_endLine = endLine;
                // Conta ciclos de vsync=0
                if (vsync == 1'b0) vsync_low_cnt = vsync_low_cnt + 1;
            end
        end
    join

    // Um endLine por cada linha: V_TOTAL linhas
    check(endline_cnt == V_TOTAL,
          "TC10: endLine pulsou exactamente V_TOTAL (525) vezes numa frame");

    // vsync LOW durante V_SYNC_W linhas × H_TOTAL ciclos por linha
    // (cada linha tem FP+SYNC+BP+VISIBLE = 800 ciclos de pixel clock)
    check(vsync_low_cnt == V_SYNC_W * H_TOTAL,
          "TC10: vsync=0 durante exactamente 2 linhas (2x800=1600 ciclos)");

    // ------------------------------------------------------------
    // Resultado final
    // ------------------------------------------------------------
    $display("=========================================");
    if (errors == 0)
        $display("TODOS OS TESTES PASSARAM (0 erros)");
    else
        $display("FALHAS: %0d erro(s) detectado(s)", errors);
    $display("=========================================");
    $finish;
end

// ----------------------------------------------------------------
// Timeout de segurança (evita simulação infinita)
// ----------------------------------------------------------------
initial begin
    #(V_TOTAL * H_TOTAL * CLK_PERIOD * 3);
    $display("TIMEOUT: simulacao demorou demasiado");
    $finish;
end

endmodule