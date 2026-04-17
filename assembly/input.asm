.include "../tools/abi.inc"

.org 0x0100
_start:
    LI sp, 0x0400

    ; 1. Trigger I2C init via CTRL[4]
    LI a0, 0x4383
    LI a1, 0x0010       ; bit 4 = init_trigger
    SW a1, a0, 0

wait_i2c:
    ; 2. Poll STATUS[1] = codec_init_done
    LI a0, 0x4382
    LW a1, a0, 0
    LI a2, 0x0002       ; bit 1
    AND a1, a2
    BEQ wait_i2c

    ; 3. Enable TX (CTRL[0] = TX_EN), limpa o trigger bit
    LI a0, 0x4383
    LI a1, 0x0001       ; bit 0 = TX_EN
    SW a1, a0, 0

main_loop:
    BR main_loop
