; ──────────────────────────────────────────────────────────
; @classify(a, b)  [12 vregs, 3 slots]
; ──────────────────────────────────────────────────────────
classify:
    ; Frame slots (fp-based):
    ;   %slot2 (c) @ fp-3
    ;   %slot1 (b) @ fp-2
    ;   %slot0 (a) @ fp-1

    ; --- Prologue ---
    PUSH(fp) 
    MOV(fp, sp) 
    PUSH(lr) 
    ; Allocate 3 local slot(s)
    ADDI sp, sp, #-3

bb0:
    ADDI t0, fp, #-1
    SW a0, t0, #0
    ADDI t0, fp, #-2
    SW a1, t0, #0
    ADDI t2, fp, #-3
    ADDI t0, fp, #-1
    LW t1, t0, #0
    ADDI t0, fp, #-2
    LW t0, t0, #0
    ADD t0, t1
    SW t0, t2, #0
    ADDI t0, fp, #-3
    LW a0, t0, #0
    MOV(r1, a0)
    ; --- Epilogue ---
    MOV(sp, fp)  
    POP(lr) 
    POP(fp) 
    RET

bb1:
    ; --- Epilogue ---
    MOV(sp, fp)  
    POP(lr) 
    POP(fp) 
    RET

