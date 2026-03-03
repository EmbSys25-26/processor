`timescale 1ns / 1ps

/*************************************************************************************
 * TESTBENCH — i2s_tx
 *
 *  A FSM do i2s_tx e triggerada no negedge do BCLK.
 *  O codec amostra PBDAT no posedge do BCLK.
 *
 *  Sequencia de estados por negedge:
 *    negedge 0: IDLE  -> LOAD_L  (enable=1)
 *    negedge 1: LOAD_L -> SHIFT_L  (LRCLK=0, shift_reg carregado, bit_cnt=0)
 *    negedge 2: SHIFT_L bit 31 colocado em PBDAT
 *    negedge 3: SHIFT_L bit 30
 *    ...
 *    negedge 33: SHIFT_L bit 0 (bit_cnt=31 -> transita LOAD_R)
 *    negedge 34: LOAD_R -> SHIFT_R (LRCLK=1)
 *    negedge 35: SHIFT_R bit 31
 *    ...
 *    negedge 66: SHIFT_R bit 0 (sample_req=1, transita DONE)
 *    negedge 67: DONE -> LOAD_L (sample_req=0)
 *
 *  O testbench amostra PBDAT no posedge — o bit esta valido entre o negedge
 *  que o coloca e o posedge seguinte (exatamente como o codec faria).
 *
 *  Verifica:
 *    TEST 1 — Reset
 *    TEST 2 — IDLE sem enable
 *    TEST 3 — LRCLK=0 no posedge antes do bit 31 esquerdo
 *    TEST 4 — 16 bits LEFT corretos MSB-first
 *    TEST 5 — 16 bits de padding zero no canal esquerdo
 *    TEST 3b— LRCLK=1 no posedge antes do bit 31 direito
 *    TEST 6 — 16 bits RIGHT corretos MSB-first
 *    TEST 7 — Padding zero no canal direito
 *    TEST 8 — sample_req pulsa exatamente 1 ciclo BCLK
 *    TEST 9 — Segundo frame usa novos i_left / i_right
 ************************************************************************************/

module tb_i2s_tx;

/*************************************************************************************
 * SECTION 1. SINAIS
 ************************************************************************************/
    reg        _bclk;
    reg        _rst;
    reg        _enable;
    reg [15:0] _left;
    reg [15:0] _right;

    wire       _pbdat;
    wire       _lrclk;
    wire       _sample_req;

    reg [31:0] _cap_l;
    reg [31:0] _cap_r;
    reg [31:0] _cap_l2;
    reg [31:0] _cap_r2;

    integer _i;
    integer _fails;
    reg     _sreq_at_bit0;

/*************************************************************************************
 * SECTION 2. DUT
 ************************************************************************************/
    i2s_tx dut (
        .i_bclk      (_bclk),
        .i_rst       (_rst),
        .i_enable    (_enable),
        .i_left      (_left),
        .i_right     (_right),
        .o_pbdat     (_pbdat),
        .o_lrclk     (_lrclk),
        .o_sample_req(_sample_req)
    );

/*************************************************************************************
 * SECTION 3. CLOCK  (periodo ~326 ns, ~3.072 MHz)
 ************************************************************************************/
    localparam HP = 163; // half-period em ns

    initial _bclk = 1'b1;
    always #(HP) _bclk = ~_bclk;

/*************************************************************************************
 * SECTION 4. TASKS
 ************************************************************************************/
    task check;
        input [200:0] name;
        input         cond;
        begin
            if (cond) $display("  PASS | %s", name);
            else begin
                $display("  FAIL | %s", name);
                _fails = _fails + 1;
            end
        end
    endtask

    // Amostra PBDAT nos proximos N posedges do BCLK e acumula em 'out' MSB-first
    task sample_pbdat;
        input  integer    n;
        output reg [31:0] out;
        integer k;
        begin
            out = 32'h0;
            for (k = 0; k < n; k = k + 1) begin
                @(posedge _bclk); #1;
                out = {out[30:0], _pbdat};
            end
        end
    endtask

/*************************************************************************************
 * SECTION 5. STIMULUS
 ************************************************************************************/
    initial begin
        _rst    = 1'b1;
        _enable = 1'b0;
        _left   = 16'hA5C3;
        _right  = 16'h3C5A;
        _fails  = 0;

        $display("========================================");
        $display(" TB i2s_tx — inicio");
        $display("========================================");

        //------------------------------------------------------------------
        // TEST 1 — Reset
        //------------------------------------------------------------------
        $display("\n[ TEST 1 ] Reset");
        repeat(4) @(posedge _bclk); #1;
        check("PBDAT = 0 em reset",       (_pbdat      == 1'b0));
        check("LRCLK = 0 em reset",       (_lrclk      == 1'b0));
        check("sample_req = 0 em reset",  (_sample_req == 1'b0));

        //------------------------------------------------------------------
        // TEST 2 — IDLE sem enable
        //------------------------------------------------------------------
        $display("\n[ TEST 2 ] IDLE sem enable");
        _rst = 1'b0;
        repeat(4) @(posedge _bclk); #1;
        check("PBDAT = 0 em IDLE",       (_pbdat      == 1'b0));
        check("sample_req = 0 em IDLE",  (_sample_req == 1'b0));

        //------------------------------------------------------------------
        // Ativar TX
        // negedge 0: IDLE -> LOAD_L
        // negedge 1: LOAD_L -> SHIFT_L  (LRCLK=0, bit31 pronto no PBDAT)
        // posedge apos negedge 1: codec ve bit31 com LRCLK=0  <- TEST 3
        //------------------------------------------------------------------
        _enable = 1'b1;
        @(negedge _bclk); // negedge 0: IDLE -> LOAD_L
        @(negedge _bclk); // negedge 1: LOAD_L -> SHIFT_L, LRCLK=0, PBDAT=bit31

        //------------------------------------------------------------------
        // TEST 3 — LRCLK deve ser 0 no posedge antes do bit 31 esquerdo
        //------------------------------------------------------------------
        $display("\n[ TEST 3 ] Timing LRCLK canal esquerdo");
        @(posedge _bclk); #1;
        check("LRCLK = 0 antes do bit 31 esquerdo", (_lrclk == 1'b0));

        //------------------------------------------------------------------
        // TEST 4 + 5 — Capturar 32 bits do canal esquerdo
        //  Ja estamos no posedge do bit 31 — capturamos este + 31 mais
        //------------------------------------------------------------------
        $display("\n[ TEST 4 ] Dados LEFT 16 bits");
        $display("[ TEST 5 ] Padding LEFT 16 bits zero");

        // O posedge do TEST 3 apanhou o bit ainda a transitar (1 ciclo cedo).
        // Fazemos loop completo de 32 posedges a partir do proximo.
        _cap_l = 32'h0;
        for (_i = 31; _i >= 0; _i = _i - 1) begin
            @(posedge _bclk); #1;
            _cap_l[_i] = _pbdat;
        end

        $display("  DEBUG | _cap_l    = 0x%08X (esperado 0x%04X0000)", _cap_l, _left);
        check("LEFT[31:16] = i_left",   (_cap_l[31:16] == _left));
        check("LEFT[15:0]  = 0",        (_cap_l[15:0]  == 16'h0000));

        // Neste momento acabamos de amostrar o posedge do bit 0 esquerdo.
        // No negedge seguinte a FSM faz LOAD_R (LRCLK=1).
        // No posedge apos esse negedge o codec ve bit 31 direito com LRCLK=1.
        @(negedge _bclk); // SHIFT_L(bit_cnt=31) -> LOAD_R: LRCLK=1
        @(negedge _bclk); // LOAD_R -> SHIFT_R: PBDAT = bit31 direito

        //------------------------------------------------------------------
        // TEST 3b + TEST 6 + 7
        // Fazemos o loop de 32 posedges — o primeiro tambem serve para
        // verificar o LRCLK (evita consumir o posedge do bit 31 duas vezes)
        //------------------------------------------------------------------
        $display("\n[ TEST 3b ] Timing LRCLK canal direito");
        $display("\n[ TEST 6 ] Dados RIGHT 16 bits");
        $display("[ TEST 7 ] Padding RIGHT 16 bits zero");

        _cap_r = 32'h0;
        for (_i = 31; _i >= 0; _i = _i - 1) begin
            @(posedge _bclk); #1;
            if (_i == 31)
                check("LRCLK = 1 antes do bit 31 direito", (_lrclk == 1'b1));
            _cap_r[_i] = _pbdat;
            if (_i == 0) _sreq_at_bit0 = _sample_req;
        end

        $display("  DEBUG | _cap_r    = 0x%08X (esperado 0x%04X0000)", _cap_r, _right);
        check("RIGHT[31:16] = i_right",  (_cap_r[31:16] == _right));
        check("RIGHT[15:0]  = 0",        (_cap_r[15:0]  == 16'h0000));

        //------------------------------------------------------------------
        // TEST 8 — sample_req
        //  No negedge onde bit_cnt=31 em SHIFT_R, sample_req vai a 1.
        //  No posedge seguinte deve ser 1; no posedge depois deve ser 0.
        //------------------------------------------------------------------
        $display("\n[ TEST 8 ] sample_req");
        // sample_req e capturado no _i=0 do loop RIGHT (ja estava a 1 nesse posedge)
        check("sample_req = 1 no fim do frame",   (_sreq_at_bit0 == 1'b1));

        // Atualizar valores do proximo frame imediatamente (sem ambiguidade de timing)
        _left  = 16'hDEAD;
        _right = 16'hBEEF;

        // Negedge: SHIFT_R(bit31)->DONE  (sample_req ja assertido, estado=DONE)
        @(negedge _bclk);
        // Posedge de DONE: sample_req ainda 1
        // Negedge: DONE->LOAD_L  (carrega i_left=0xDEAD no shift_reg)
        @(negedge _bclk);
        @(posedge _bclk); #1;
        check("sample_req = 0 no ciclo seguinte", (_sample_req == 1'b0));

        //------------------------------------------------------------------
        // TEST 9 — Segundo frame com novos valores
        // Estamos no posedge de LOAD_L. Proximo negedge: LOAD_L->SHIFT_L.
        //------------------------------------------------------------------
        $display("\n[ TEST 9 ] Segundo frame com novos valores");
        @(negedge _bclk); // LOAD_L -> SHIFT_L

        _cap_l2 = 32'h0;
        for (_i = 31; _i >= 0; _i = _i - 1) begin
            @(posedge _bclk); #1;
            if (_i == 31)
                check("LRCLK = 0 no 2o frame esquerdo", (_lrclk == 1'b0));
            _cap_l2[_i] = _pbdat;
        end

        $display("  DEBUG | _cap_l2 = 0x%08X (esperado 0xDEAD0000)", _cap_l2);
        check("2o LEFT[31:16] = 0xDEAD",  (_cap_l2[31:16] == 16'hDEAD));
        check("2o LEFT[15:0]  = 0",       (_cap_l2[15:0]  == 16'h0000));

        @(negedge _bclk); // -> LOAD_R
        @(negedge _bclk); // -> SHIFT_R

        _cap_r2 = 32'h0;
        for (_i = 31; _i >= 0; _i = _i - 1) begin
            @(posedge _bclk); #1;
            _cap_r2[_i] = _pbdat;
        end

        check("2o RIGHT[31:16] = 0xBEEF", (_cap_r2[31:16] == 16'hBEEF));
        check("2o RIGHT[15:0]  = 0",      (_cap_r2[15:0]  == 16'h0000));

        //------------------------------------------------------------------
        // Sumario
        //------------------------------------------------------------------
        $display("\n========================================");
        if (_fails == 0)
            $display(" RESULTADO: TODOS OS TESTES PASSARAM");
        else
            $display(" RESULTADO: %0d TESTE(S) FALHARAM", _fails);
        $display("========================================\n");

        $finish;
    end

    // Timeout de seguranca
    initial begin
        #10_000_000;
        $display("TIMEOUT");
        $finish;
    end

endmodule
