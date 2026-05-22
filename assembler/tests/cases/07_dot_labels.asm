; ============================================================
; 07_dot_labels — REGRESSION for G1: compiler emits dot-prefixed
; local labels (.cmp_true_N, .cmp_done_N, .land, .lor, etc.).
; This test exercises label declaration AND reference forms.
; ============================================================
.org 0x0000
.entry:
    NOP
    BR .skip
    NOP
.skip:
    BEQ .entry
.land:
    BR .lor
.lor:
    NOP
