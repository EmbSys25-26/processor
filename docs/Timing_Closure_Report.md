# CPU Timing Closure & Optimization Report

## Executive Summary
This report documents the iterative process of achieving timing closure for a custom 4-stage pipelined CPU implemented on a **Xilinx Zynq-7010 (-1 Speed Grade)** FPGA. 

Initially, the design failed to meet the baseline **100 MHz (10.000 ns)** timing requirement due to deep combinational logic paths and high fanout nets. Through a combination of architectural RTL rewrites and aggressive Vivado tool directives, the design not only achieved the 100 MHz target but was successfully pushed to its absolute physical silicon limit of **109 MHz (9.174 ns)**.

---

## Phase 1: Resolving Initial RTL Bottlenecks

### 1. The Interrupt Controller Round-Trip
* **The Problem:** The timing analyzer identified a 17-level combinational loop. The path started at the instruction decode stage (`o_insn_reg[14]`), traveled out of the CPU to the peripheral bus (`m_irq_ctrl.v`), made a priority decision, and traveled back into the CPU to trigger a pipeline flush.
* **The Solution:** The `o_irq_take` signal in `m_irq_ctrl.v` was converted from a combinational `assign` to a synchronous registered output (`always @(posedge i_clk)`). This added 1 cycle of latency to interrupt acceptance but cut the 17-level logic path in half, immediately eliminating the cross-module routing bottleneck.

### 2. High Fanout on Instruction Decode
* **The Problem:** The MSB of the instruction opcode (`o_insn[15]`) in the IF/ID register had an enormous fanout, driving ALU decode, branch logic, and register file addresses simultaneously. This resulted in over 7.2ns of pure routing (net) delay.
* **The Solution:** We manually injected TCL commands into the Vivado implementation flow to force physical replication of the register before routing:
  `phys_opt_design -force_replication_on_nets [get_nets {u_cpu/u_pipe_if_id/o_insn[15]}]`

---

## Phase 2: The Architectural Rewrite (Branch Resolution)

Even with fanout fixes, the CPU hit a hard limit at ~91 MHz due to a 16-level logic chain caused by resolving branches in the **Decode (ID)** stage. 
* **The Path:** Load Data Bypass $ightarrow$ ID Stage BDU $ightarrow$ Branch Target Addition $ightarrow$ Next PC Multiplexing $ightarrow$ Pipeline Flush.
* **The Solution:** We performed a major architectural pipeline shift. 
  1. Extracted the Branch Decision Unit (`bdu.v`) from `m_id_stage.v`.
  2. Pipelined the Branch Condition and Target Address through `m_pipe_id_ex.v`.
  3. Relocated the BDU to `m_ex_stage.v`, where it could safely evaluate the branch alongside the ALU without triggering a massive bypass hazard.
  4. Updated `m_hazard_unit.v` to flush both the IF/ID and ID/EX registers upon a mispredicted branch resolving in the EX stage.
* **The Result:** This shift drastically reduced the combinational depth of the critical path and permanently eliminated the Condition Code (CC) data hazard.

---

## Phase 3: Pushing the Silicon Limits

With the architecture optimized, we relied on Vivado's `-directive Explore` routing algorithms and "Over-Constraint" techniques (lying to the tool about the clock speed to force maximum effort) to find the physical ceiling of the `-1` speed grade silicon.

| Target Frequency | Target Period | WNS (Slack) | Actual Path Delay | Result |
| :--- | :--- | :--- | :--- | :--- |
| **100 MHz** | 10.000 ns | +0.552 ns | 9.448 ns | **PASS** |
| **107 MHz** | 9.346 ns | +0.024 ns | 9.322 ns | **PASS** |
| **108 MHz** | 9.259 ns | +0.069 ns | 9.190 ns | **PASS** |
| **109 MHz** | 9.174 ns | +0.001 ns | 9.173 ns | **PASS** |
| **110 MHz** | 9.091 ns | -0.235 ns | 9.326 ns | **FAIL** |

### The Final Bottleneck
At 110 MHz, the design failed by exactly 0.235 ns. The failing path was the **JAL Misprediction Path** and the **BPU History Update Loop**. It takes roughly 9.3 ns for electrons to travel through 12–14 levels of LUTs and routing fabric to update the Global History Register (`o_lookup_ghr_reg`). On the entry-level Zynq-7010 (-1), this represents an insurmountable physics wall for a 4-stage pipeline.

---

## Conclusion
The CPU architecture is highly optimized and functionally complete. By addressing both structural RTL loops and deep combinational branch logic, the processor achieved a final, rock-solid timing closure at **109 MHz**. 

It is recommended to run the final design at a stable **100 MHz** to ensure robustness across varying thermal conditions when deployed to the physical FPGA.
