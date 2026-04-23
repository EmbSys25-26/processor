# Register Allocation

This branch contains the initial steps of the backend of our compiler. 
The compiler processes `.c` source files, drives them through lexical analysis, syntax parsing, semantic validation, Intermediate Representation (IR) generation, and finally, the Register Allocation stages.

The `main.c` executes the following stages sequentially:

Stages 1, 2, and 3 of Register Allocation are implemented. Stages 4 and 5 are missing.

1. **Frontend:** Lexical Analysis (Flex) & Syntax Analysis (Bison) → Abstract Syntax Tree (AST) generation.
2. **Middle-end:** Semantic Analysis (type and symbol checking) → IR Lowering (3-address code generation).
3. **Backend (Register Allocation):**
   * **Stage 1: Liveness Analysis:** Computes the exact lifetimes of all virtual registers (`use`, `def`, `live_in`, `live_out`, `live_after` sets) using dataflow equations.
   * **Stage 2: Interference Graph:** Builds an undirected graph where edges connect virtual registers that are simultaneously live. This ensures they are not assigned the same physical register.
   * **Stage 3: Pre-Coloring (ABI Compliance):** Enforces strict Application Binary Interface (ABI) rules. Specific virtual registers are pre-assigned to mandatory physical registers (e.g., forcing function return values and call results into `r1` / `a0`).
   * **MISSING Stage 4: Graph Coloring:** Implementation of the Chaitin-Briggs graph coloring algorithm to assign remaining physical registers.
   * **MISSING Stage 5: Spilling:** Full Spill implementation utilizing a cost/degree heuristic to handle cases where not enough physical registers are available.

## 🚀 How to Compile

$ make

$ ./compiler "test".c

Available "test" files

1. linear.c

Purpose: Tests basic instruction-level liveness in straight-line code with no control flow.

2. iftest.c

Purpose: Tests liveness propagation across basic blocks and control-flow splits (if/else branches).

3. looptest.c

Purpose: Tests dataflow equation convergence over back-edges (while loops), ensuring variables survive across loop iterations.

4. store_test.c

Purpose: Tests pointer tracking and memory access (*p = ...). Ensures the compiler correctly handles addresses and consumed values in memory operations.

5. overlap_simple.c

Purpose: Two variables are alive at the exact same time, guaranteeing the creation of an interference edge between them in the graph.

6. move_coalescing.c

Purpose: Tests simple assignments (dst = src). Ensures no interference edge is created between the source and destination, paving the way for register coalescing in Stage 4.

7. params.c

Purpose: Tests that the first three function parameters are correctly pre-colored to physical registers r1, r2, and r3 according to ABI calling conventions.

8. params_capped.c

Purpose: Tests ABI register limits. Ensures only the first 3 arguments go to registers and the remaining arguments are left uncolored (stack-bound).

9. call_result.c

Purpose: Tests function calls. Ensures the result returned by the callee is correctly mapped/forced into r1.

10. combined.c

Purpose: The ultimate ABI test. Combines incoming arguments, a function call, and a return statement in the same scope, ensuring the return register (r1) is safely reused across different lifetimes without interference conflicts.
