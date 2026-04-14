`timescale 1ns / 1ps

/*************************************************************************************
 * PS2ScanToAscii.v
 *
 * Converte scancode PS/2 Set 2 para ASCII.
 * Suporta: normal, shift, ctrl, extended (setas, home, end, etc.)
 *
 * IMPORTANTE: default devolve 8'h00 (não 0x2E).
 * O ps2_to_ascii_filter usa 0x00 como sentinela para NÃO emitir ascii_valid.
 * Assim nenhum carácter desconhecido chega ao VGA.
 ************************************************************************************/

module PS2ScanToAscii(
    input  wire       shift,
    input  wire       ctrl,
    input  wire       alt,
    input  wire       extend,
    input  wire [7:0] sc,
    output reg  [7:0] ascii
);

always @(sc or shift or ctrl or extend) begin
    if (extend) begin
        case (sc)
            8'h75: ascii = 8'h90;   // cima
            8'h74: ascii = 8'h91;   // direita
            8'h72: ascii = 8'h92;   // baixo
            8'h6b: ascii = 8'h93;   // esquerda
            8'h6c: ascii = 8'h94;   // home
            8'h69: ascii = 8'h95;   // end
            8'h7d: ascii = 8'h96;   // pg up
            8'h7a: ascii = 8'h97;   // pg down
            8'h70: ascii = 8'h98;   // insert
            8'h71: ascii = 8'h7f;   // delete
            8'h4a: ascii = 8'h2f;   // numpad /
            8'h5a: ascii = 8'h0d;   // numpad enter
            default: ascii = 8'h00; // desconhecido → não emitir
        endcase

    end else if (ctrl) begin
        case (sc)
            8'h0d: ascii = 8'h09;   // tab
            8'h15: ascii = 8'h11;   // ctrl+Q
            8'h1a: ascii = 8'h1a;   // ctrl+Z
            8'h1b: ascii = 8'h13;   // ctrl+S
            8'h1c: ascii = 8'h01;   // ctrl+A
            8'h1d: ascii = 8'h17;   // ctrl+W
            8'h21: ascii = 8'h03;   // ctrl+C
            8'h22: ascii = 8'h18;   // ctrl+X
            8'h23: ascii = 8'h04;   // ctrl+D
            8'h24: ascii = 8'h05;   // ctrl+E
            8'h29: ascii = 8'h20;   // space
            8'h2a: ascii = 8'h16;   // ctrl+V
            8'h2b: ascii = 8'h06;   // ctrl+F
            8'h2c: ascii = 8'h14;   // ctrl+T
            8'h2d: ascii = 8'h12;   // ctrl+R
            8'h31: ascii = 8'h0e;   // ctrl+N
            8'h32: ascii = 8'h02;   // ctrl+B
            8'h33: ascii = 8'h08;   // ctrl+H
            8'h34: ascii = 8'h07;   // ctrl+G
            8'h35: ascii = 8'h19;   // ctrl+Y
            8'h3a: ascii = 8'h0d;   // ctrl+M
            8'h3b: ascii = 8'h0a;   // ctrl+J
            8'h3c: ascii = 8'h15;   // ctrl+U
            8'h41: ascii = 8'h3c;   // <
            8'h42: ascii = 8'h0b;   // ctrl+K
            8'h43: ascii = 8'h09;   // ctrl+I
            8'h44: ascii = 8'h0f;   // ctrl+O
            8'h4a: ascii = 8'h3f;   // ?
            8'h4b: ascii = 8'h0c;   // ctrl+L
            8'h4d: ascii = 8'h10;   // ctrl+P
            8'h5a: ascii = 8'h0d;   // enter
            8'h66: ascii = 8'h08;   // backspace
            8'h76: ascii = 8'h1b;   // escape
            default: ascii = 8'h00;
        endcase

    end else if (shift) begin
        case (sc)
            8'h0d: ascii = 8'h09;   // tab
            8'h0e: ascii = 8'h7e;   // ~
            8'h15: ascii = 8'h51;   // Q
            8'h16: ascii = 8'h21;   // !
            8'h1a: ascii = 8'h5a;   // Z
            8'h1b: ascii = 8'h53;   // S
            8'h1c: ascii = 8'h41;   // A
            8'h1d: ascii = 8'h57;   // W
            8'h1e: ascii = 8'h40;   // @
            8'h21: ascii = 8'h43;   // C
            8'h22: ascii = 8'h58;   // X
            8'h23: ascii = 8'h44;   // D
            8'h24: ascii = 8'h45;   // E
            8'h25: ascii = 8'h24;   // $
            8'h26: ascii = 8'h23;   // #
            8'h29: ascii = 8'h20;   // space
            8'h2a: ascii = 8'h56;   // V
            8'h2b: ascii = 8'h46;   // F
            8'h2c: ascii = 8'h54;   // T
            8'h2d: ascii = 8'h52;   // R
            8'h2e: ascii = 8'h25;   // %
            8'h31: ascii = 8'h4e;   // N
            8'h32: ascii = 8'h42;   // B
            8'h33: ascii = 8'h48;   // H
            8'h34: ascii = 8'h47;   // G
            8'h35: ascii = 8'h59;   // Y
            8'h36: ascii = 8'h5e;   // ^
            8'h3a: ascii = 8'h4d;   // M
            8'h3b: ascii = 8'h4a;   // J
            8'h3c: ascii = 8'h55;   // U
            8'h3d: ascii = 8'h26;   // &
            8'h3e: ascii = 8'h2a;   // *
            8'h41: ascii = 8'h3c;   // <
            8'h42: ascii = 8'h4b;   // K
            8'h43: ascii = 8'h49;   // I
            8'h44: ascii = 8'h4f;   // O
            8'h45: ascii = 8'h29;   // )
            8'h46: ascii = 8'h28;   // (
            8'h49: ascii = 8'h3e;   // >
            8'h4a: ascii = 8'h3f;   // ?
            8'h4b: ascii = 8'h4c;   // L
            8'h4c: ascii = 8'h3a;   // :
            8'h4d: ascii = 8'h50;   // P
            8'h4e: ascii = 8'h5f;   // _
            8'h52: ascii = 8'h22;   // "
            8'h54: ascii = 8'h7b;   // {
            8'h55: ascii = 8'h2b;   // +
            8'h5a: ascii = 8'h0d;   // enter
            8'h5b: ascii = 8'h7d;   // }
            8'h5d: ascii = 8'h7c;   // |
            8'h66: ascii = 8'h08;   // backspace
            8'h76: ascii = 8'h1b;   // escape
            default: ascii = 8'h00;
        endcase

    end else begin
        // Sem modificadores
        case (sc)
            // Teclas de função
            8'h05: ascii = 8'ha1;   // F1
            8'h06: ascii = 8'ha2;   // F2
            8'h04: ascii = 8'ha3;   // F3
            8'h0c: ascii = 8'ha4;   // F4
            8'h03: ascii = 8'ha5;   // F5
            8'h0b: ascii = 8'ha6;   // F6
            8'h83: ascii = 8'ha7;   // F7
            8'h0a: ascii = 8'ha8;   // F8
            8'h01: ascii = 8'ha9;   // F9
            8'h09: ascii = 8'haa;   // F10
            8'h78: ascii = 8'hab;   // F11
            8'h07: ascii = 8'hac;   // F12
            // Caracteres imprimíveis
            8'h0d: ascii = 8'h09;   // tab
            8'h0e: ascii = 8'h60;   // `
            8'h15: ascii = 8'h71;   // q
            8'h16: ascii = 8'h31;   // 1
            8'h1a: ascii = 8'h7a;   // z
            8'h1b: ascii = 8'h73;   // s
            8'h1c: ascii = 8'h61;   // a
            8'h1d: ascii = 8'h77;   // w
            8'h1e: ascii = 8'h32;   // 2
            8'h21: ascii = 8'h63;   // c
            8'h22: ascii = 8'h78;   // x
            8'h23: ascii = 8'h64;   // d
            8'h24: ascii = 8'h65;   // e
            8'h25: ascii = 8'h34;   // 4
            8'h26: ascii = 8'h33;   // 3
            8'h29: ascii = 8'h20;   // space
            8'h2a: ascii = 8'h76;   // v
            8'h2b: ascii = 8'h66;   // f
            8'h2c: ascii = 8'h74;   // t
            8'h2d: ascii = 8'h72;   // r
            8'h2e: ascii = 8'h35;   // 5
            8'h31: ascii = 8'h6e;   // n
            8'h32: ascii = 8'h62;   // b
            8'h33: ascii = 8'h68;   // h
            8'h34: ascii = 8'h67;   // g
            8'h35: ascii = 8'h79;   // y
            8'h36: ascii = 8'h36;   // 6
            8'h3a: ascii = 8'h6d;   // m
            8'h3b: ascii = 8'h6a;   // j
            8'h3c: ascii = 8'h75;   // u
            8'h3d: ascii = 8'h37;   // 7
            8'h3e: ascii = 8'h38;   // 8
            8'h41: ascii = 8'h2c;   // ,
            8'h42: ascii = 8'h6b;   // k
            8'h43: ascii = 8'h69;   // i
            8'h44: ascii = 8'h6f;   // o
            8'h45: ascii = 8'h30;   // 0
            8'h46: ascii = 8'h39;   // 9
            8'h49: ascii = 8'h2e;   // .
            8'h4a: ascii = 8'h2f;   // /
            8'h4b: ascii = 8'h6c;   // l
            8'h4c: ascii = 8'h3b;   // ;
            8'h4d: ascii = 8'h70;   // p
            8'h4e: ascii = 8'h2d;   // -
            8'h52: ascii = 8'h27;   // '
            8'h54: ascii = 8'h5b;   // [
            8'h55: ascii = 8'h3d;   // =
            8'h5a: ascii = 8'h0d;   // enter
            8'h5b: ascii = 8'h5d;   // ]
            8'h5d: ascii = 8'h5c;   // backslash
            8'h66: ascii = 8'h08;   // backspace
            8'h76: ascii = 8'h1b;   // escape
            // Numpad (num lock ligado - valores numéricos)
            8'h69: ascii = 8'h31;   // numpad 1
            8'h6b: ascii = 8'h34;   // numpad 4
            8'h6c: ascii = 8'h37;   // numpad 7
            8'h70: ascii = 8'h30;   // numpad 0
            8'h71: ascii = 8'h2e;   // numpad .
            8'h72: ascii = 8'h32;   // numpad 2
            8'h73: ascii = 8'h35;   // numpad 5
            8'h74: ascii = 8'h36;   // numpad 6
            8'h75: ascii = 8'h38;   // numpad 8
            8'h79: ascii = 8'h2b;   // numpad +
            8'h7a: ascii = 8'h33;   // numpad 3
            8'h7b: ascii = 8'h2d;   // numpad -
            8'h7c: ascii = 8'h2a;   // numpad *
            8'h7d: ascii = 8'h39;   // numpad 9
            // ACK do teclado - não emitir
            8'hfa: ascii = 8'h00;
            // Teclas modificadoras - não emitir (tratadas pelo filtro)
            8'h12: ascii = 8'h00;   // left shift
            8'h59: ascii = 8'h00;   // right shift
            8'h14: ascii = 8'h00;   // ctrl
            8'h11: ascii = 8'h00;   // alt
            8'h58: ascii = 8'h00;   // caps lock
            8'h77: ascii = 8'h00;   // num lock
            8'h7e: ascii = 8'h00;   // scroll lock
            default: ascii = 8'h00; // desconhecido → filtro não emite
        endcase
    end
end

endmodule