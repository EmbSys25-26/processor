; ============================================================
; 05_branches — verify every BR cond, signed disp encoding, and the
; BLEU/BLETU encoding (this is the regression for the bug-fix swap).
;
; Encoding: op=9, op<<12 | cond<<8 | disp[7:0]
;
; Hardware cond table (verilog ground truth):
;   0xC -> BLTU (strict < unsigned)
;   0xE -> BLEU (≤        unsigned)
;
; Software-stack convention (compiler-emitted mnemonics):
;   BLEU  mnemonic -> 0xC   (strict < unsigned)
;   BLETU mnemonic -> 0xE   (≤        unsigned)
;
; BLTU is provided as a hardware-name alias for BLEU (same encoding 0xC).
; ============================================================
.org 0x0000
back:
NOP             ; 0xF000  at 0x0000
BR  back        ; 0x90FE  cond=0, disp=(0x0000-0x0002)/2 = -1 = 0xFF?
                ; actually disp formula in code_generator: (label-stmt_lc)/2
                ;   label=0x0000, stmt_lc=0x0002 -> disp = -1 = 0xFF
BEQ back        ; 0x92FD  disp=(0-4)/2=-2 = 0xFE
BC  back        ; 0x94FC
BV  back        ; 0x96FB
BLT back        ; 0x98FA
BLE back        ; 0x9AF9
BLEU back       ; 0x9CF8  <-- compiler mnemonic for "< unsigned" -> cond 0xC
BLETU back      ; 0x9EF7  <-- compiler mnemonic for "≤ unsigned" -> cond 0xE
BLTU back       ; 0x9CF6  <-- hardware alias of BLEU
