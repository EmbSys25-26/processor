## The four distinct type systems

There are four completely separate notions of "type" in the codebase, each serving a different layer of the pipeline.

---

### 1. `NodeType_t` — what kind of syntax node is this

Defined in `ASTree.h`. This is the tag on every `TreeNode_t` that says what syntactic construct the node represents.

```c
typedef enum {
    NODE_TRANSLATION_UNIT,
    NODE_BLOCK,
    NODE_OPERATOR,
    NODE_IDENTIFIER,
    NODE_INTEGER,
    NODE_FUNCTION,
    NODE_IF,
    NODE_WHILE,
    NODE_VAR_DECLARATION,
    NODE_ARRAY_DECLARATION,
    // ... etc
} NodeType_t;
```

Every node in the AST has exactly one of these. It is set by the parser when the node is created and never changes (in `TreeNode_t`: `NodeType_t  nodeType;`). It answers the question **"what is this node structurally?"** — is it an operator, a declaration, a loop, an identifier.

---

### 2. `VarType_t` — legacy type annotation directly on the node

Also defined in `ASTree.h`. Stored directly in `TreeNode_t.nodeVarType`.

```c
typedef enum {
    TYPE_CHAR,
    TYPE_SHORT,
    TYPE_INT,
    TYPE_LONG,
    TYPE_FLOAT,
    TYPE_DOUBLE,
    TYPE_STRING,
    TYPE_VOID,
    TYPE_STRUCT,
    TYPE_UNION,
    TYPE_ENUM
} VarType_t;
```

This was an early attempt to attach type information directly to AST nodes. It is used by the parser in `NODE_TYPE` nodes to record what primitive type was written in the source — `int`, `float`, `struct`, etc. The semantic passes read it from `NODE_TYPE` children when building `type_t` objects, but they do not write to it. IR lowering ignores it entirely and uses the annotation table instead. Think of it as a parser-level hint, not a full type system.

---

### 3. `type_t` — the full semantic type system

Defined in `type.h`. This is the real type system, built by the semantic passes and consumed by IR lowering.

```c
typedef enum {
    TYPE_INVALID,
    TYPE_BUILTIN,
    TYPE_POINTER,
    TYPE_ARRAY,
    TYPE_FUNCTION,
    TYPE_STRUCT_TAG,
    TYPE_UNION_TAG,
    TYPE_ENUM_TAG
} type_kind_t;
```

Each `type_t` is a tagged union that can represent any C type recursively:

```
int           → TYPE_BUILTIN { builtin=BUILTIN_INT }
int *         → TYPE_POINTER { base → TYPE_BUILTIN(BUILTIN_INT) }
int[10]       → TYPE_ARRAY   { elem → TYPE_BUILTIN(BUILTIN_INT), size=10 }
int(int,int)  → TYPE_FUNCTION{ return → BUILTIN_INT, params=[BUILTIN_INT, BUILTIN_INT] }
struct Point  → TYPE_STRUCT_TAG { tag="Point" }
```

These are arena-allocated by `type_context_t` during pass 1 and pass 2. They live in `persistent_arena` and are valid until `semantic_context_destroy` is called. This is the type that gets stored in:

- `symbol_t.type` — the type of a declared symbol
- `sem_node_info_t.type` — the inferred type of an expression node

---

### 4. `ir_type_t` — the IR type system

Defined in `ir.h`. A simplified flat type system for the IR layer. It does not need the full richness of `type_t` — it only needs to know what size and shape of data an instruction operates on.

```c
typedef enum {
    IR_TYPE_VOID,
    IR_TYPE_I1,    // predicate / boolean
    IR_TYPE_I8,    // byte
    IR_TYPE_I16,   // native word (target is 16-bit)
    IR_TYPE_I32,   // extended
    IR_TYPE_PTR,   // pointer
    IR_TYPE_ARRAY, // arr<T, N>
    IR_TYPE_STRUCT,// struct<tag>
    IR_TYPE_UNION  // union<tag>
} ir_type_kind_t;
```

These are not heap allocated — they are small structs passed by value. The conversion from `type_t` to `ir_type_t` happens in `ir_type_from_sem` in `ir_lower.c`:

```c
TYPE_BUILTIN + BUILTIN_INT   → IR_TYPE_I16  (target is 16-bit)
TYPE_BUILTIN + BUILTIN_CHAR  → IR_TYPE_I8
TYPE_BUILTIN + BUILTIN_LONG  → IR_TYPE_I32
TYPE_BUILTIN + BUILTIN_VOID  → IR_TYPE_VOID
TYPE_POINTER                 → IR_TYPE_PTR
TYPE_ARRAY                   → IR_TYPE_ARRAY
TYPE_STRUCT_TAG              → IR_TYPE_STRUCT
```

---

### 5. `OperatorType_t` — what operation a NODE_OPERATOR performs

Defined in `NodeTypes.h`. Stored in `nodeData.dVal` of a `NODE_OPERATOR` node.

```c
typedef enum {
    OP_PLUS,
    OP_MINUS,
    OP_MULTIPLY,
    OP_DIVIDE,
    OP_EQUAL,
    OP_ASSIGN,
    OP_PLUS_ASSIGN,
    // ... etc
} OperatorType_t;
```

Not a type in the C language sense — it describes the operation, not the data. But it is a classification system that lives alongside the type systems. Pass 2 reads it to decide how to type-check a binary expression. IR lowering reads it to decide which `ir_opcode_t` to emit.

---

## How they all relate

```
Source text
    │
    ▼ lexer + parser
    
TreeNode_t
├── nodeType  : NodeType_t     ← what syntax construct
├── nodeData  : NodeData_t     ← raw value (long, double, char*)
└── nodeVarType: VarType_t     ← parser-level type hint (NODE_TYPE nodes only)
    │
    ▼ semantic pass 1
    
symbol_t
└── type : type_t*             ← full semantic type, arena allocated
    │
    ▼ semantic pass 2
    
sem_node_info_t  (annotation table entry, keyed by TreeNode_t*)
├── type    : type_t*          ← inferred type of this expression
├── symbol  : symbol_t*        ← which symbol this node refers to
├── value_kind                 ← LVALUE / RVALUE
└── flags                      ← CODEGEN_BLOCKED, CONST_EXPR, etc.
    │
    ▼ IR lowering
    
ir_type_t                      ← flattened type for instruction emission
ir_value_t                     ← typed virtual register / slot / immediate
ir_instr_t                     ← typed three-address instruction
```

---

## The key transitions

**`VarType_t` → `type_t`** happens in pass 1. When pass 1 sees a `NODE_TYPE` node with `nodeVarType = TYPE_INT`, it calls `type_new_builtin(tcx, BUILTIN_INT, qualifiers)` to create a proper `type_t`. The `VarType_t` is consumed here and never used again downstream.

**`type_t` → `ir_type_t`** happens in IR lowering via `ir_type_from_sem`. The rich semantic type is flattened to the minimal information the backend needs — mostly just the width in bits and whether it is a pointer.

**`OperatorType_t` → `ir_opcode_t`** happens in `ir_lower_expr.c` via `binop_opcode`. The operator kind plus the signedness of the operands determines which IR instruction to emit — `OP_DIVIDE` becomes either `IR_OP_DIVS` or `IR_OP_DIVU` depending on whether the type is signed or unsigned.