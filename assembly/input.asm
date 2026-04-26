.include "../tools/abi.inc"

; ============================================================
; Interrupt Vector Table  (0x0020 – 0x00DF)
;   Each slot is 32 bytes = 16 instruction words.
;   Unused vectors loop forever so a spurious IRQ can't
;   execute random memory.  The PARIO slot (0x0060) jumps
;   to the real handler located after _start.
; ============================================================

.org 0x0020
_vec_timer0:    BR _vec_timer0      ; Timer0 — not used

.org 0x0040
_vec_timer1:    BR _vec_timer1      ; Timer1 — not used

.org 0x0060
_vec_pario:     J  _isr_pario       ; Button 3 (Y16) start/stop  [2 insns: IMM + JAL]

.org 0x0080
_vec_uart:      BR _vec_uart        ; UART — not used

.org 0x00A0
_vec_i2c:       BR _vec_i2c         ; I2C — not used

.org 0x00C0
_vec_i2s:       BR _vec_i2s         ; I2S FIFO almost-empty — not used

; ============================================================
; Main program  (0x0100)
; ============================================================

.org 0x0100
_start:
    LI sp, 0x0400

    ; Keep IRQs masked during early init to avoid taking unhandled vectors.
    CLI

    ; Disable Timer1 IRQ source (default reset state can assert quickly).
    LI a0, 0x4080           ; Timer1 CR0 (byte 0x8100)
    LI a1, 0x0000           ; int_en=0, timer_mode=0
    SW a1, a0, 0
    LI a0, 0x4081           ; Timer1 CR1 (byte 0x8102), write to clear int_req
    SW a1, a0, 0

    ; Enable only PARIO IRQ (bit2) for this program.
    LI a0, 0x4782           ; IRQ_MASK (byte 0x8F04)
    LI a1, 0x0004           ; unmask PARIO only
    SW a1, a0, 0
    LI a0, 0x4786           ; IRQ_CLEAR (byte 0x8F0C)
    LI a1, 0x00FF           ; clear any stale pending bits
    SW a1, a0, 0

    ; 1. Trigger SSM2603 codec init via CTRL[4]
    LI a0, 0x4383
    LI a1, 0x0010           ; bit 4 = init_trigger
    SW a1, a0, 0

wait_codec:
    ; 2. Poll STATUS[1] = codec_init_done
    LI a0, 0x4382
    LW a1, a0, 0
    LI a2, 0x0002           ; bit 1
    AND a1, a2
    CMP a1, zero            ; AND does not update flags in this ISA
    BEQ wait_codec

    ; 3. Enable TX immediately — button 3 toggles pause/resume.
    LI a0, 0x4383
    LI a1, 0x0001           ; bit 0 = tx_enable
    SW a1, a0, 0

    ; Re-enable interrupts after startup config is complete.
    STI

main_loop:
    BR main_loop

; ============================================================
; PARIO ISR — Button 3 (Y16) start/stop toggle
;
;  Reads I2S CTRL, flips bit 0 (tx_enable), writes back.
;  Preserves a0, a1 and condition codes around the body.
;  ISR_PRO saves lr + CC and re-enables interrupts (STI)
;  so higher-priority IRQs (I2S) can still preempt.
; ============================================================

_isr_pario:
    ISR_PRO                  ; PUSH lr; PUSH_CC; STI
    PUSH a0
    PUSH a1
    LI   a0, 0x4383          ; I2S CTRL word address (byte 0x8706)
    LW   a1, a0, 0           ; a1 = current CTRL value
    XORI a1, #1              ; toggle bit 0 (tx_enable)
    SW   a1, a0, 0           ; write back
    POP  a1
    POP  a0
    IRET                     ; POP_CC; POP lr; RET (detected as IRET by CPU)
