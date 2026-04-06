# DATA HAZARDS

## 1.WHAT IS A DATA HAZARD?

In a pipelined processor, multiple instructions are in different stages of execution simultaneously. A data hazard occurs when an instruction depends on the result of a previous instruction that has not yet completed its Writeback stage in the register file.

Since the pipeline overlaps execution, an instruction in the Decode or Execute stage may attempt to read a register that a preceding instruction has not yet updated. Without intervention, the pipeline reads stale data and produces an incorrect result.

The most common type in an in-order pipeline is RAW (Read After Write): instruction B tries to read a register that instruction A will write, but instruction A has not yet reached the Writeback stage.

## 2.WHEN DO RAW HAZARDS OCCUR?

In a classic 5-stage pipeline (Fetch -> Decode -> Execute -> Memory -> Writeback), it is assumed that writing to the register file happens in the first half of the clock cycle (WB stage) and reading occurs in the second half (ID stage).

This means the hazard affects the two instructions immediately following the instruction that writes the data.

**Practical Example (Adapted for our 2-Address Architecture)**:
In our ISA, instructions use 2 addresses, meaning the first register acts as both the destination and the first source operand (e.g., add Rd, Rs means Rd = Rd + Rs). Let's look at a sequence where $s0 is the cause of the hazard:

- **1st instruction:** "add $s0, $s3" (calculates $s0 + $s3 and writes to $s0). The new value is calculated in cycle 3 (Execute) but only written to the register file in cycle 5 (Writeback).

- **2nd instruction:** "and $t0, $s0" tries to read $s0 in cycle 3 (Decode stage). (Hazard!) The correct data has not been written to the register file yet.

- **3rd instruction:** "or $t1, $s0" tries to read $s0 in cycle 4 (Decode stage). (Hazard!) The correct data is still not in the register file, as the add instruction is only in the Memory stage.

- **4th instruction:** "sub $t2, $s0" tries to read $s0 in cycle 5 (Decode stage). (No Hazard) Since our register file reads in the second half of cycle 5 and writes in the first half, the sub instruction successfully reads the updated value just written by the add instruction.

## 3.RESOLUTION METHODS

### 3.1. Forwarding (Bypassing)

The main hardware solution for data hazards is forwarding (or bypassing). Instead of waiting for the Writeback stage, the processor routes the result directly from where it was calculated in the pipeline to where it is needed next.

Forwarding is necessary when an instruction in the Execute stage has a source register that matches the destination register of an instruction in the Memory or Writeback stage.

**Implementation:** Multiplexers are added before the ALU inputs to select the operand from:

- **The Register File** (normal path, from the Decode stage).

- **The EX/MEM pipeline register** (output of the Execute stage).

- **The MEM/WB pipeline register** (output of the Memory stage).

This way, the result of the add instruction (available right after the ALU in cycle 3) is intercepted and injected directly into the ALU input for the next and instruction in cycle 4, solving the hazard without stalling the pipeline.

#### 3.1.1 Control Logic (The Hazard Unit)

To control these multiplexers, the processor uses a dedicated Hazard Unit. The Hazard Unit compares the source registers of the current instruction in the Execute stage (rsE, rtE) with the destination registers of the instructions in the Memory (WriteRegM) and Writeback (WriteRegW) stages.

A special edge case handled by this logic is the Double Data Hazard. This occurs when two consecutive instructions both write to the same register, and a third instruction needs to read it. In this scenario, the hardware must prioritize the most recent value (the one in the Memory stage) over the older value (in the Writeback stage).

This priority is directly implemented in the hardware logic using an if ... else if structure, ensuring the MEM stage hazard is evaluated and caught first. The logic below illustrates the control signals for the ForwardAE multiplexer (controlling the first ALU input):
```
if ((rsE != 0) AND (rsE == WriteRegM) AND RegWriteM) then
    ForwardAE = 10  // Priority to the most recent value (MEM stage)
else if ((rsE != 0) AND (rsE == WriteRegW) AND RegWriteW) then
    ForwardAE = 01  // Forwarding from the WB stage
else
    ForwardAE = 00  // Normal path from the Register File
```
The exact same logic applies to the ForwardBE signal for the second ALU input, checking rtE instead of rsE.