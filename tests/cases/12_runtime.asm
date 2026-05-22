; ============================================================
; 12_runtime — the project runtime library (mul/div/mod helpers).
; Path is relative to the assembler/ directory, which is where the
; m4 process is invoked from (see run_tests.sh: `m4 $M4_INC $src`,
; m4 resolves include() relative to its CWD).
; ============================================================
include(`../runtime/runtime.asm')dnl
