# Module Documentation Template (for new peripherals / pipeline blocks)

Copy this template when documenting a new Verilog module or a refactored block.

**File:** <path>
**Module:** <name>

### Purpose
- What the module is responsible for (one paragraph max).

### Inputs
- List each input signal:
  - name, width, meaning, timing expectations (combinational vs registered), reset behavior.

### Outputs
- List each output signal:
  - name, width, meaning, timing expectations, reset behavior.

### Contract
- MUST/SHOULD rules that define correct usage (memory mapping, expectations about input)
- Any assumptions about alignment, endianness, or valid ranges.
- What happens on invalid inputs (ignored, masked, NOP, error flag, etc).

### Verification notes
- Minimal directed tests that should exist.
- Suggested wave signals to inspect.

These 5 points are the most important. The following are optional, but nonetheless encouraged.

### Timing / Latency
- What is combinational vs registered?
- Does the module have internal state?
- Any handshake protocol (`valid/ready`, `rdy`, wait states).

### Reset behavior
- Which signals/state reset to what values?
- Is reset synchronous or asynchronous?

### Side effects / Hazards
- Memory writes, MMIO writes, interrupts, and any "do not duplicate" requirements under stalls.

### MMIO / Programming model (if applicable)
- Base address / decode region.
- Register map (offset, R/W, bit definitions, reset value).
- IRQ behavior (when asserted, how ack/clear works).

### References
- Link to the design note / issue / spec section that motivated the module.
