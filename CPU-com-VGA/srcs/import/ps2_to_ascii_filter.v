`timescale 1ns / 1ps

/*************************************************************************************
 * ps2_to_ascii_filter.v
 *
 * O QUE FAZ:
 *   Recebe os bytes raw do ps2_mmio (o_rx_data + o_rx_valid) e filtra/converte
 *   para ASCII antes de enviar ao m_vga_mmio.
 *
 * FILTRAGEM:
 *   0xF0 → break prefix: o byte seguinte é key-release, ignorar e actualizar shift
 *   0xE0 → extended prefix: o byte seguinte é extended scancode
 *   0x12 / 0x59 → shift esquerdo/direito: actualizar flag _shift, não emitir
 *   0x14 → ctrl: actualizar flag _ctrl, não emitir
 *   0x11 → alt: actualizar flag _alt, não emitir
 *   Qualquer outro make code → converter com PS2ScanToAscii e emitir se != 0x00
 *
 * LIGAÇÃO:
 *   ps2_mmio.o_rx_data  → i_scancode
 *   ps2_mmio.o_rx_valid → i_valid
 *   o_ascii             → m_vga_mmio.i_ascii_code
 *   o_ascii_valid       → m_vga_mmio.i_ascii_valid
 ************************************************************************************/

module ps2_to_ascii_filter (
    input  wire       i_clk,
    input  wire       i_rst,
    input  wire [7:0] i_scancode,    // byte raw do ps2_mmio
    input  wire       i_valid,       // pulso 1 ciclo por byte
    output reg  [7:0] o_ascii,       // ASCII convertido
    output reg        o_ascii_valid  // pulso 1 ciclo - só quando carácter válido
);

/*************************************************************************************
 * SECTION 1 - FLAGS DE ESTADO DO TECLADO
 ************************************************************************************/

    reg _shift;   // shift esquerdo ou direito premido
    reg _ctrl;    // ctrl premido
    reg _alt;     // alt premido
    reg _extend;  // próximo byte é extended (prefixo 0xE0 recebido)
    reg _break;   // próximo byte é key-release (prefixo 0xF0 recebido)

/*************************************************************************************
 * SECTION 2 - INSTÂNCIA DO CONVERSOR (combinacional)
 ************************************************************************************/

    wire [7:0] _ascii_raw;

    // O conversor é combinacional - responde imediatamente a i_scancode/_shift/_ctrl
    // Quando registamos o_ascii no clk, o _ascii_raw já tem o valor correcto
    PS2ScanToAscii u_conv (
        .shift  (_shift),
        .ctrl   (_ctrl),
        .alt    (_alt),
        .extend (_extend),
        .sc     (i_scancode),
        .ascii  (_ascii_raw)
    );

/*************************************************************************************
 * SECTION 3 - FSM DE FILTRAGEM
 *
 * TIMING:
 *   Ciclo N: i_valid=1, i_scancode=0xF0  → _break<=1, nada emitido
 *   Ciclo M: i_valid=1, i_scancode=0x1C  → _break=1 → key release de 'a'
 *                                           actualiza shift se necessário, não emite
 *   Ciclo P: i_valid=1, i_scancode=0x1C  → make code 'a' → _ascii_raw=0x61 → emite
 ************************************************************************************/

    always @(posedge i_clk) begin
        if (i_rst) begin
            _shift        <= 1'b0;
            _ctrl         <= 1'b0;
            _alt          <= 1'b0;
            _extend       <= 1'b0;
            _break        <= 1'b0;
            o_ascii       <= 8'h00;
            o_ascii_valid <= 1'b0;
        end else begin
            o_ascii_valid <= 1'b0;  // default: sem emissão

            if (i_valid) begin

                // ── Prefixo break (key-release) ──────────────────────────
                if (i_scancode == 8'hF0) begin
                    _break <= 1'b1;

                // ── Prefixo extended ──────────────────────────────────────
                end else if (i_scancode == 8'hE0) begin
                    _extend <= 1'b1;

                // ── Byte após prefixo break ───────────────────────────────
                end else if (_break) begin
                    _break <= 1'b0;
                    // Actualiza modificadores no key-release
                    if (i_scancode == 8'h12 || i_scancode == 8'h59)
                        _shift <= 1'b0;
                    else if (i_scancode == 8'h14)
                        _ctrl  <= 1'b0;
                    else if (i_scancode == 8'h11)
                        _alt   <= 1'b0;
                    // Reset extend também (extended break: E0 F0 xx)
                    _extend <= 1'b0;

                // ── Make code normal ou extended ──────────────────────────
                end else begin
                    // Actualiza modificadores no make
                    if (i_scancode == 8'h12 || i_scancode == 8'h59) begin
                        _shift  <= 1'b1;
                        _extend <= 1'b0;
                    end else if (i_scancode == 8'h14) begin
                        _ctrl   <= 1'b1;
                        _extend <= 1'b0;
                    end else if (i_scancode == 8'h11) begin
                        _alt    <= 1'b1;
                        _extend <= 1'b0;
                    end else begin
                        // Carácter normal - converter e emitir se != 0x00
                        // _ascii_raw é combinacional: já reflecte i_scancode
                        // e os flags _shift/_ctrl/_extend actuais (do ciclo anterior)
                        // que estão correctos porque os prefixos foram tratados antes
                        _extend <= 1'b0;
                        if (_ascii_raw != 8'h00) begin
                            o_ascii       <= _ascii_raw;
                            o_ascii_valid <= 1'b1;
                        end
                        // Se _ascii_raw == 0x00: scancode desconhecido, não emite
                    end
                end

            end // if (i_valid)
        end
    end

endmodule
