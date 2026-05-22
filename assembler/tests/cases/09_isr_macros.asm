; ============================================================
; 09_isr_macros — interrupt prologue / epilogue / PUSH_CC / POP_CC.
; The IRET sequence ends with the canonical JAL r0, lr, #0 (0x00E0),
; which the gr0040 CPU detects as the interrupt-return marker.
; ============================================================
.org 0x0000
PUSH_CC         ; GETCC t0 ; PUSH(t0)
POP_CC          ; POP(t0)  ; SETCC t0
ISR_PRO         ; PUSH(lr) ; PUSH_CC ; STI
IRET            ; POP_CC ; POP(lr) ; RET  (ends with 0x00E0)
