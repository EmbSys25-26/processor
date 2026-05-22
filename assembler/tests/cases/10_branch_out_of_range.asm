; ============================================================
; 10_branch_out_of_range — NEGATIVE test (this case is the only one
; the runner expects to FAIL). Branch displacement to a label more
; than 127 instructions away must trigger a Pass-2 error and the
; assembler must exit non-zero (G12 fix).
; ============================================================
.org 0x0000
near:
NOP

.org 0x0400      ; 0x400 / 2 = 512 instructions away
BR near          ; disp = -512 — out of [-128, 127]
