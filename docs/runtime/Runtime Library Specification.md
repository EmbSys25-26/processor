## Software Runtime Library

**File:** `runtime/runtime.asm`
**Purpose:** provide assembly implementations of the arithmetic operations the target ISA does not support in hardware, so that the IR opcodes `IR_OP_MUL`, `IR_OP_DIVS`, `IR_OP_DIVU`, `IR_OP_MODS`, `IR_OP_MODU` can be lowered to ordinary `CALL` instructions during IR generation.
**Linkage:** the runtime is assembled separately and linked alongside compiled output. Five public symbols are exported: `__mul`, `__divu`, `__modu`, `__divs`, `__mods`. The IR layer (`ir_lower_expr.c::needs_runtime_call`) selects the right callee based on the operator and the unsigned flag.

This document covers each helper's algorithm, ABI, clobber set, and edge cases.

---

### Why a software runtime?

The target 16-bit RISC has add, sub, shift, bitwise, compare, and branch — but no multiply or divide. Trying to lower MUL/DIV/MOD as inline shift-and-add macros would require maintaining a worst-case 16-iteration loop at every multiplication site in user code, which is huge. A software helper amortises that cost into a single function call per arithmetic operation.

The IR opcodes themselves (`IR_OP_MUL`, etc.) never reach the codegen — they are rewritten to `IR_OP_CALL` by the expression lowering pass, so the codegen sees a plain function call with its normal calling convention. This means liveness analysis correctly sees the call boundary and treats caller-saved registers as clobbered.

---

### ABI summary

All helpers follow the project's ABI (`abi_spec.md`):

| Register | Mnemonic | Role |
|---|---|---|
| `r0` | `r0` | Hardwired zero |
| `r1` | `a0` / `v0` | Argument 0 / return value (input dividend / multiplicand; output result) |
| `r2` | `a1` | Argument 1 (input divisor / multiplier) |
| `r3-r7` | `t0-t3` (`r4-r7`) | Caller-saved temporaries (free to clobber inside leaf helpers) |
| `r8-r11` | `s0-s3` | Callee-saved (must be PUSH/POP'd if used) |
| `r14` | `lr` | Return address |

**Calling convention for these helpers specifically:**
- `r1` in: dividend or multiplicand. `r1` out: result (quotient, product, or remainder).
- `r2` in: divisor or multiplier.
- All other caller-saved registers may be clobbered.
- The signed variants are non-leaf (they internally call the unsigned variants), so they save `r8` + `lr`.

---

### Branch convention reminder

The mnemonics on this ISA mean:

| Mnemonic | Meaning |
|---|---|
| `BLT`  | branch if strictly less-than (signed) |
| `BLE`  | branch if less-or-equal (signed) |
| `BLEU` | branch if **strictly less-than (unsigned)** — despite the U suffix |
| `BLETU`| branch if less-or-equal (unsigned) |
| `BEQ`  | branch if equal |

This convention bites everyone who reads it — the LLVM/RISC-V instinct is `BLEU = ≤ unsigned`. The runtime helpers and the codegen comparison ladder both rely on the project convention. **Do not flip one without flipping the other; the unit-tested behaviour is what's documented here.**

---

### Divide-by-zero policy

Both `__divu` and `__modu` test the divisor early and return 0 if it's zero (no trap, no bus error). The signed variants funnel through these helpers, so they inherit the same policy: `x / 0 == 0` and `x % 0 == 0`. This matches "no behaviour" rather than C's "undefined behaviour" — pragmatic for an embedded target without an OS to deliver SIGFPE.

---

## §1 `__mul`

```
r1_out = r1_in * r2_in     (signed and unsigned identical at 16-bit width)
```

| Property | Value |
|---|---|
| Leaf? | yes (no PUSH/POP, just RET) |
| Clobbers | `r1`–`r6` |
| Iterations | 16 (one per dividend bit) |

**Algorithm (shift-and-add):**

```
r3 ← 0          ; accumulator
r4 ← 16         ; loop counter
r5 ← 1          ; right-shift amount
loop:
    r6 ← r2 & 1            ; current LSB of multiplier
    if r6 != 0:
        r3 += r1           ; accumulate shifted multiplicand
    r1 <<= 1               ; multiplicand doubles
    r2 >>= 1 (logical)     ; consume next multiplier bit
    r4 -= 1
    if r4 != 0: goto loop
r1 ← r3
RET
```

Signed and unsigned multiplication produce identical low-16 bits at this width because we discard any overflow into bit 16+. Callers that need a wider result must use a different ABI (none currently provided).

---

## §2 `__divu` — unsigned 16-bit division

```
r1_out = r1_in / r2_in     (unsigned)
```

| Property | Value |
|---|---|
| Leaf? | yes |
| Clobbers | `r1`–`r7` |
| Iterations | 16 |
| Special case | divisor == 0 → returns 0 |

**Algorithm (restoring long division, MSB-first):**

```
remainder ← 0
quotient  ← 0
for i = 0..15:
    remainder = (remainder << 1) | (dividend >> 15)   ; bring in next dividend MSB
    dividend  <<= 1
    if remainder >= divisor:        ; tested as "BLEU rem, divisor → skip subtract"
        remainder -= divisor
        quotient |= 1               ; ADDI quotient, quotient, #1 (LSB only)
    quotient <<= 1                  ; (skipped on the LAST iteration in the actual asm to keep the bit in place)
return quotient
```

The asm uses `LI(r6, 0x000F)` to load the 15-bit shift amount for `SRA r7, r6` (which arithmetic-right-shifts the dividend by 15 to extract its MSB), then `ANDI r7, #1` to mask to the single bit. The `SLL(quotient)` happens BEFORE the conditional add of 1, so the order in the asm is:

```
loop:
    SLL(remainder)
    SLL(quotient)
    bring in dividend MSB
    if remainder >= divisor: SUB & ADDI quotient, quotient, #1
    decrement loop counter
    branch or fall-through to done
```

The branch test uses `CMP rem, divisor; BLEU __divu_no_sub` — and recall **BLEU is strictly less-than unsigned**, so the BLEU branches when `rem < divisor`, i.e. we skip the subtract. When `rem >= divisor` we fall through and subtract, then set the quotient LSB.

---

## §3 `__modu` — unsigned 16-bit remainder

```
r1_out = r1_in % r2_in     (unsigned)
```

| Property | Value |
|---|---|
| Leaf? | yes |
| Clobbers | `r1`–`r7` |
| Special case | divisor == 0 → returns 0 |

Identical loop to `__divu`, but the quotient register is dropped (we don't bother updating it) and the return value is the remainder. Saves a few cycles per iteration.

---

## §4 `__divs` — signed 16-bit division (truncated toward zero)

```
r1_out = r1_in / r2_in     (signed, truncated toward zero)
```

| Property | Value |
|---|---|
| Leaf? | no (calls `__divu`) |
| Clobbers | `r1`–`r7`, plus `r8` saved/restored |
| Frame | saves `fp`, `lr`, `r8` |

**Algorithm (sign-normalise then `__divu`):**

```
sign_flag ← 0
if dividend < 0:  dividend = -dividend; sign_flag ^= 1
if divisor  < 0:  divisor  = -divisor;  sign_flag ^= 1
quotient ← __divu(|dividend|, |divisor|)
if sign_flag: quotient = -quotient
return quotient
```

The sign flag lives in `r8` (callee-saved, so it survives the inner call to `__divu`). The flag is XOR-toggled per negative operand: a single negative gives `r8 = 1` (negate); two negatives give `r8 = 2 → ANDI r8, #1 = 0` (don't negate).

Special case: dividend == 0 → return 0 directly (avoids the `__divu` call).

---

## §5 `__mods` — signed 16-bit remainder (sign matches dividend)

```
r1_out = r1_in % r2_in     (signed; per C99 the sign of the result matches the dividend)
```

| Property | Value |
|---|---|
| Leaf? | no (calls `__modu`) |
| Clobbers | `r1`–`r7`, plus `r8` saved/restored |
| Frame | saves `fp`, `lr`, `r8` |

**Algorithm:**

```
neg_flag ← 0
if dividend < 0:  dividend = -dividend; neg_flag = 1
if divisor  < 0:  divisor  = -divisor          ; sign of divisor is irrelevant
remainder ← __modu(|dividend|, |divisor|)
if neg_flag: remainder = -remainder
return remainder
```

Differences from `__divs`:
1. Only the dividend's sign affects the result, so the divisor's sign-normalisation does NOT toggle the flag.
2. We test the flag as `CMP r8, r0; BEQ`, not as XOR-of-two-bits; one negative dividend always produces a negative result (or zero, which negates to itself).

Special case: dividend == 0 → return 0.

---

### Performance characteristics

All helpers are O(16) — bounded by the word width. Approximate cycle counts (assuming 1 cycle per instruction, no instruction-fetch stalls):

| Helper | Worst case |
|---|---|
| `__mul` | ~120 instructions |
| `__divu` | ~150 instructions |
| `__modu` | ~140 instructions |
| `__divs` | ~10 prologue + 1 `__divu` call + ~10 epilogue ≈ ~170 instructions |
| `__mods` | similar to `__divs` |

These are per-call costs, paid once per multiplication or division in user code. Inlining a shift-and-add at every `*` site would explode code size; the helper trade-off favours small text segments at the cost of call overhead.

---

### Test coverage

The runtime is exercised end-to-end by tests in `test_files/IR_checks/`:

- `test_arith.c` — covers `*` `/` `%` with both signed and unsigned operands and compound assignments (`*=`, `/=`, `%=`).
- `test_unsigned.c` — confirms the unsigned dispatch reaches `__divu` / `__modu` (regression test for the unsigned propagation bug).
- `test_arrays_structs.c` — uses arithmetic in the array-sum loop.

Manual verification traces for `8 / 4 = 2`, `100 / 7 = 14 r 2`, `-10 / 3 = -3`, `-10 % 3 = -1` were performed against the `__divs` / `__mods` algorithms during initial development and remain part of the helper docstrings in `runtime.asm`.

---

### Build integration

The runtime is currently a standalone `.asm` source. The expected workflow is:

1. `make` produces `compiler` (the C → asm translator).
2. `./compiler input.c` writes `output.asm`.
3. The user assembles `output.asm` and `runtime/runtime.asm` together with the project's assembler and links the result.

There is no `runtime.o` produced by `make`; the runtime is a source artefact only. If the link step changes, the runtime would need a corresponding rule.

---

### Limitations

1. **Width is fixed at 16 bits.** A 32-bit version would require a wider loop counter and would not fit the existing single-register input/output ABI.
2. **No NaN / overflow signalling.** Signed overflow (e.g. `INT_MIN / -1`) silently wraps because `NEG(INT_MIN) == INT_MIN` and the flag toggling produces a positive sign — the result is `INT_MIN` (the only fixed point of negation at this width). Real C says this is undefined behaviour; the runtime treats it as "you get what you get".
3. **No SIMD or batched division.** Each call processes one operand pair.
4. **Divide-by-zero returns 0,** not a trap. A real OS would deliver SIGFPE; this target has no OS, so the convention is "result is zero, life goes on". User code that needs a guard must check `b == 0` before calling.
