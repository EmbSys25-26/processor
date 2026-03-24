.include "../tools/abi.inc"

; ==============================================================================
; I2S INTERRUPT VECTOR (0x00C0)
; Jump to the Interrupt Service Routine (ISR) when the I2S hardware requests it
; ==============================================================================
.org 0x00C0
    J _isr_i2s_body 

; ==============================================================================
; CPU RESET VECTOR / ENTRY POINT (0x0100)
; ==============================================================================
.org 0x0100
_start:
    ; 1. Initialize Stack Pointer at the top of the RAM (0x0400, word-aligned)
    LI sp, 0x0400
    
    ; Initialize the audio phase accumulator (will hold our sawtooth wave value)
    LI s0, 0         

    ; 2. Trigger Audio Codec Initialization via I2C (Manual Trigger)
    LI a0, 0x4384    ; Load I2C_INIT register address
    LI a1, 1         ; Set trigger bit
    SW a1, a0, 0     

wait_i2c:
    ; Poll STATUS register bit 1 (codec_init_done) to ensure I2C is finished
    LI a0, 0x4382    ; Load STATUS register address
    LW a1, a0, 0     
    LI a2, 2         ; Bit mask for Bit 1
    AND a1, a2       
    BEQ wait_i2c     ; Loop until bit is set

    ; 3. Pre-fill I2S FIFO with 16 samples of silence
    LI a0, 0x4380    ; TX_LEFT MMIO Address
    LI a1, 0x4381    ; TX_RIGHT MMIO Address
    LI t0, 0         ; Data to write (0 = Silence)
    LI t2, 16        ; Loop maximum (FIFO Depth = 16)
    LI t3, 0         ; Loop counter
    LI t1, 1         ; Increment value (Safely avoids ADDI immediate syntax)

prefill_loop:
    SW t0, a0, 0     ; Push to Left Channel
    SW t0, a1, 0     ; Push to Right Channel (Commits the stereo pair to FIFO)
    ADD t3, t1       ; Increment counter: t3 = t3 + 1
    CMP t3, t2       ; Compare counter with 16
    BLT prefill_loop ; Branch back if Less Than 16

    ; 4. Enable I2S Transmission and I2S Hardware Interrupts
    LI a0, 0x4383    ; Load CTRL register address
    LI a1, 3         ; Set Bit 0 (TX_EN) and Bit 1 (IRQ_EN)
    SW a1, a0, 0

    ; 5. Unmask I2S Interrupt in the Global Interrupt Controller
    LI a0, 0x4782    ; Load IRQ_MASK register
    LI a1, 0x0020    ; Enable bit 5 (IRQ Channel 5 = I2S)
    SW a1, a0, 0

    ; 6. Clear any residual pending IRQs for safety
    LI a0, 0x4786    ; Load IRQ_CLEAR register
    LI a1, 0xFFFF    ; Clear all channels
    SW a1, a0, 0

    ; 7. Enable Global CPU Interrupts
    STI              

main_loop:
    ; CPU idles here. Audio generation is fully handled by the ISR.
    BR main_loop     

; ==============================================================================
; I2S INTERRUPT SERVICE ROUTINE (ISR)
; Triggers when the I2S FIFO is almost empty (<= 2 samples remaining)
; ==============================================================================
_isr_i2s_body:
    ; Prologue: Save CPU context
    PUSH lr
    PUSH t0
    PUSH t1
    PUSH t2
    PUSH t3
    PUSH a0
    PUSH a1

    ; Setup pointers and wave pitch
    LI a0, 0x4380    ; TX_LEFT Address
    LI a1, 0x4381    ; TX_RIGHT Address
    LI t1, 0x0200    ; Sawtooth wave pitch increment
    
    ; Loop: Inject 8 new audio samples into the hardware FIFO
    LI t2, 8         ; Loop maximum (8 samples)
    LI t3, 0         ; Loop counter
    LI t0, 1         ; Increment value
    
isr_push_loop:
    ADD s0, t1       ; Advance the phase of the sawtooth wave
    SW s0, a0, 0     ; Write Left Channel
    SW s0, a1, 0     ; Write Right Channel
    ADD t3, t0       ; Increment counter: t3 = t3 + 1
    CMP t3, t2       ; Compare counter with 8
    BLT isr_push_loop; Branch back if Less Than 8

    ; ==========================================================
    ; CDC DELAY LOOP (Clock Domain Crossing)
    ; Waste cycles to allow the slower I2S clock (3 MHz) to 
    ; safely synchronize the FIFO flags back to the 100 MHz domain.
    ; ==========================================================
    LI t0, 0          
    LI t2, 1000       
    LI t1, 1
wait_cdc:
    ADD t0, t1       ; Increment: t0 = t0 + 1
    CMP t0, t2
    BLT wait_cdc      

    ; Clear the IRQ pending flag inside the I2S peripheral
    LI a0, 0x4383    ; CTRL register
    LI a1, 7         ; Keep (TX_EN | IRQ_EN) and pulse bit 2 (IRQ_CLR W1C)
    SW a1, a0, 0

    ; Clear the IRQ flag in the Global Interrupt Controller
    LI a0, 0x4786    ; IRQ_CLEAR register
    LI a1, 0x0020    ; Clear bit 5 (I2S)
    SW a1, a0, 0

    ; Epilogue: Restore CPU context
    POP a1
    POP a0
    POP t3
    POP t2
    POP t1
    POP t0
    POP lr
    
    ; Re-enable global interrupts and exit ISR safely
    STI
    JAL r0, lr, 0    ; Return from interrupt
