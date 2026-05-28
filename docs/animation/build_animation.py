"""
build_animation.py — CodeGen pipeline animation for presentation.

Visualizes the journey from a C source through the Chaitin-Briggs register
allocator (liveness, interference graph, simplification, color selection,
spill) into the ShivAT assembly, BROM hex pair, and finally a flash into
the FPGA SoC.

Renders ~100s of 30 fps animation at 1280x720 into regalloc_pipeline.mp4
using matplotlib + ffmpeg.

The example C function and IR mirror what this compiler's lowering would
actually produce for a small straight-line program; the liveness and
interference numbers are computed by hand and verified to match what the
CodeGen/RegAlloc/* algorithms would emit on the same IR.
"""

from __future__ import annotations

import math
import os
from dataclasses import dataclass
from typing import Callable

import matplotlib
matplotlib.use("Agg")

import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation, FFMpegWriter
from matplotlib.patches import FancyBboxPatch, Circle, Rectangle, FancyArrowPatch
from matplotlib.lines import Line2D
import numpy as np


# ---------------------------------------------------------------------------
# global theme
# ---------------------------------------------------------------------------

BG          = "#0E1117"
PANEL       = "#161B22"
GRID        = "#30363D"
INK         = "#E6EDF3"
INK_DIM     = "#8B949E"
ACCENT_ORG  = "#F5A623"
ACCENT_BLU  = "#5BC0EB"
ACCENT_GRN  = "#9BC53D"
ACCENT_PNK  = "#FC6DAB"
ACCENT_VIO  = "#A084E8"
ACCENT_RED  = "#E55934"

PHYS_PALETTE = {
    # ABI register → visual colour (used as the "node colour" once allocated)
    "t0": "#5BC0EB",  # r4 — caller-saved scratch
    "t1": "#9BC53D",  # r5
    "t2": "#F5A623",  # r6
    "t3": "#FC6DAB",  # r7
    "s0": "#A084E8",  # r8 — callee-saved
    "SPILL": "#E55934",
    "UNCOLORED": "#3A3F47",
}


FPS = 30
W_IN, H_IN = 12.8, 7.2     # 1280 x 720 at dpi=100


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * max(0.0, min(1.0, t))


def smoothstep(t: float) -> float:
    t = max(0.0, min(1.0, t))
    return t * t * (3.0 - 2.0 * t)


def panel(ax, x, y, w, h, *, fc=PANEL, ec=GRID, lw=1.2, alpha=1.0, radius=0.06):
    p = FancyBboxPatch(
        (x, y), w, h,
        boxstyle=f"round,pad=0.005,rounding_size={radius}",
        linewidth=lw, edgecolor=ec, facecolor=fc, alpha=alpha,
    )
    ax.add_patch(p)
    return p


def fade_alpha(t: float, t0: float, t_in: float = 0.6, hold: float = 1.0, t_out: float = 0.6) -> float:
    """Trapezoidal fade envelope in seconds, anchored at t0 (start)."""
    rel = t - t0
    if rel < 0 or rel > t_in + hold + t_out:
        return 0.0
    if rel < t_in:
        return smoothstep(rel / t_in)
    if rel < t_in + hold:
        return 1.0
    return 1.0 - smoothstep((rel - t_in - hold) / t_out)


# ---------------------------------------------------------------------------
# scene schedule (seconds)
# ---------------------------------------------------------------------------

@dataclass
class Scene:
    name: str
    start: float
    end: float
    draw: Callable[[plt.Axes, float], None]   # draw(ax, t_in_scene)

    @property
    def dur(self) -> float:
        return self.end - self.start


# ---------------------------------------------------------------------------
# data: the running example
# ---------------------------------------------------------------------------

C_SRC = [
    "int dot(int x, int y) {",
    "    int a = x + y;",
    "    int b = x - y;",
    "    int c = a + b;",
    "    int d = a + c;",
    "    return d;",
    "}",
]

# IR (matches what this compiler's lowering produces, modulo cosmetic names)
IR_OPS = [
    ("v0", "arg 0",       "; x"),
    ("v1", "arg 1",       "; y"),
    ("v2", "add v0, v1",  "; a"),
    ("v3", "sub v0, v1",  "; b"),
    ("v4", "add v2, v3",  "; c"),
    ("v5", "add v2, v4",  "; d"),
    ("",   "ret v5",      ""),
]

# live_after sets for each IR instruction (computed by backward dataflow)
LIVE_AFTER = [
    ("v0 = arg 0",       {"v0"}),
    ("v1 = arg 1",       {"v0", "v1"}),
    ("v2 = add v0, v1",  {"v0", "v1", "v2"}),
    ("v3 = sub v0, v1",  {"v2", "v3"}),
    ("v4 = add v2, v3",  {"v2", "v4"}),
    ("v5 = add v2, v4",  {"v5"}),
    ("ret v5",           set()),
]

# Interference edges (derived: edge between two vregs that co-live at any
# instruction's live_after, with the move-coalescing exception applied)
IFG_EDGES = [
    ("v0", "v1"),
    ("v0", "v2"),
    ("v1", "v2"),
    ("v2", "v3"),
    ("v2", "v4"),
]

VREGS = ["v0", "v1", "v2", "v3", "v4", "v5"]

# Layout for the interference graph (fixed positions, presentation friendly)
NODE_POS = {
    "v0": (-1.6,  0.9),
    "v1": (-1.6, -0.9),
    "v2": ( 0.0,  0.0),
    "v3": ( 1.6,  0.9),
    "v4": ( 1.6, -0.9),
    "v5": ( 0.0, -2.2),
}


def adjacency():
    adj = {v: set() for v in VREGS}
    for a, b in IFG_EDGES:
        adj[a].add(b)
        adj[b].add(a)
    return adj


# Simplification trace for K = 3 (push order; degrees recomputed greedily,
# matching the Chaitin-style "low-degree first" rule)
SIMPLIFY_K3 = [
    # (pushed, working_degree_at_push)
    ("v5", 0),
    ("v3", 1),
    ("v4", 1),
    ("v0", 2),
    ("v1", 1),
    ("v2", 0),
]

# Color order with K=3: pop the stack, scan neighbours' colors, pick first free
# Manually verified consistent with regalloc.c's preference order.
COLOR_ASSIGN_K3 = [
    ("v2", "t0"),
    ("v1", "t1"),
    ("v0", "t2"),
    ("v4", "t1"),
    ("v3", "t1"),
    ("v5", "t0"),
]

# Spill trace for K = 2: v2 (the hub) is forced to spill
SIMPLIFY_K2 = [
    ("v5", 0),
    ("v3", 1),
    ("v4", 1),
    ("v2", 2, True),     # spill candidate (highest degree of remaining)
    ("v0", 1),
    ("v1", 1),
]

COLOR_ASSIGN_K2 = [
    ("v1", "t0"),
    ("v0", "t1"),
    ("v2", "SPILL"),
    ("v4", "t0"),
    ("v3", "t0"),
    ("v5", "t0"),
]


# Final assembly emitted by codegen using the K=3 colour assignment.
# dot() is an ultra-leaf (no slots, no callee-saveds, no CALL) so codegen
# skips the frame entirely. Two-address rewrites follow emit_binop_rr /
# emit_binop_rr_nc: SUB with dst==b becomes NEG;ADD (no scratch needed).
ASM_LINES = [
    "dot:",
    "    ; ultra-leaf: no frame",
    "    MOV(t2, a0)         ; v0 = x  (arg copy)",
    "    MOV(t1, a1)         ; v1 = y",
    "    MOV(t0, t2)         ; v2 = v0 + v1  (a)",
    "    ADD  t0, t1",
    "    NEG(t1)             ; v3 = v0 - v1  (b)",
    "    ADD  t1, t2         ;   dst==b → NEG;ADD",
    "    ADD  t1, t0         ; v4 = v2 + v3  (c)",
    "    ADD  t0, t1         ; v5 = v2 + v4  (d)",
    "    MOV(a0, t0)         ; return d",
    "    RET",
]

# A subset of the BROM hex words (cosmetic; close to what the assembler emits)
HEX_WORDS = [
    "12FE", "1100", "0900", "0290", "0000", "0410", "0290", "0000",
    "0410", "0290", "0000", "1100", "0100", "00E0", "00E0", "00E0",
    "00E0", "00E0", "00E0", "00FE", "DEAD", "BEEF", "C0DE", "FACE",
]


# ---------------------------------------------------------------------------
# drawing primitives
# ---------------------------------------------------------------------------

def setup_axes(ax):
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 9)
    ax.set_aspect("equal")
    ax.set_axis_off()
    ax.set_facecolor(BG)


def title_bar(ax, text, subtitle=None, alpha=1.0):
    ax.text(8, 8.4, text,
            ha="center", va="center", color=INK, alpha=alpha,
            fontsize=18, fontweight="bold", family="DejaVu Sans")
    if subtitle:
        ax.text(8, 7.95, subtitle,
                ha="center", va="center", color=INK_DIM, alpha=alpha,
                fontsize=11, family="DejaVu Sans")


def draw_node(ax, xy, label, fill, *, r=0.32, edge=INK, lw=1.6,
              text_color=None, alpha=1.0, label_offset=(0, 0)):
    if text_color is None:
        text_color = INK
    c = Circle(xy, r, facecolor=fill, edgecolor=edge, linewidth=lw, alpha=alpha, zorder=3)
    ax.add_patch(c)
    ax.text(xy[0] + label_offset[0], xy[1] + label_offset[1],
            label, ha="center", va="center", color=text_color,
            alpha=alpha, fontsize=10, fontweight="bold", zorder=4)


def draw_edge(ax, p, q, *, color=INK_DIM, lw=1.6, alpha=1.0, zorder=2):
    ax.plot([p[0], q[0]], [p[1], q[1]], color=color, lw=lw, alpha=alpha, zorder=zorder)


def code_block(ax, x, y, w, h, lines, *,
               title=None, highlight_idx=None, color_overrides=None,
               alpha=1.0, mono_size=11):
    panel(ax, x, y, w, h, alpha=alpha)
    if title:
        ax.text(x + 0.2, y + h - 0.32, title,
                color=INK_DIM, fontsize=10, alpha=alpha,
                family="DejaVu Sans", fontweight="bold")
        text_top = y + h - 0.7
    else:
        text_top = y + h - 0.3
    line_h = 0.32
    for i, ln in enumerate(lines):
        ty = text_top - i * line_h
        if ty < y + 0.2:
            break
        is_hi = highlight_idx is not None and i in (
            highlight_idx if isinstance(highlight_idx, (list, set)) else {highlight_idx}
        )
        if is_hi:
            ax.add_patch(Rectangle(
                (x + 0.08, ty - 0.13), w - 0.16, 0.26,
                facecolor=ACCENT_ORG, alpha=0.18 * alpha, edgecolor="none", zorder=1))
        col = INK
        if color_overrides and i in color_overrides:
            col = color_overrides[i]
        ax.text(x + 0.25, ty, ln,
                color=col, alpha=alpha,
                fontsize=mono_size, family="DejaVu Sans Mono",
                fontweight="bold" if is_hi else "normal", zorder=2)


# ---------------------------------------------------------------------------
# scene 1 — title
# ---------------------------------------------------------------------------

def scene_title(ax, t):
    a = smoothstep(t / 1.2) if t < 3.2 else 1.0 - smoothstep((t - 3.2) / 0.8)
    ax.text(8, 5.6, "CodeGen Pipeline",
            ha="center", va="center", color=INK, alpha=a,
            fontsize=34, fontweight="bold")
    ax.text(8, 4.75, "Chaitin-Briggs register allocation, from C to FPGA",
            ha="center", va="center", color=INK_DIM, alpha=a, fontsize=14)

    # Compact "C → vreg → phys → hex" motif: 4 stylised tokens with arrows.
    tokens = [
        ("a = x + y;",    ACCENT_BLU,  "C"),
        ("v2 = v0 + v1",  ACCENT_VIO,  "IR"),
        ("ADD t0, t1",    ACCENT_ORG,  "asm"),
        ("0410",          ACCENT_GRN,  "hex"),
    ]
    n = len(tokens)
    span = 11.0
    x0 = 8 - span / 2
    step = span / (n - 1)
    for i, (txt, col, lbl) in enumerate(tokens):
        appear = smoothstep((t - 0.6 - i * 0.35) / 0.5)
        cx = x0 + i * step
        cy = 3.1
        bw, bh = 2.0, 0.7
        panel(ax, cx - bw / 2, cy - bh / 2, bw, bh,
              fc=PANEL, ec=col, lw=1.6, alpha=a * appear)
        ax.text(cx, cy, txt, ha="center", va="center",
                color=col, family="DejaVu Sans Mono",
                fontsize=10, fontweight="bold", alpha=a * appear)
        ax.text(cx, cy + bh / 2 + 0.25, lbl, ha="center", va="center",
                color=INK_DIM, fontsize=9, alpha=a * appear * 0.9)
        if i < n - 1:
            ax.add_patch(FancyArrowPatch(
                (cx + bw / 2 + 0.05, cy),
                (cx + step - bw / 2 - 0.05, cy),
                arrowstyle="-|>", color=INK_DIM, lw=1.4,
                alpha=a * appear, mutation_scale=14))

    ax.text(8, 1.5, "ShivAT  ·  16-bit pipelined RISC SoC",
            ha="center", va="center", color=INK_DIM, alpha=a * 0.8, fontsize=11)


# ---------------------------------------------------------------------------
# scene 2 — pipeline overview
# ---------------------------------------------------------------------------

PIPELINE_STAGES = [
    (".c",      ACCENT_BLU),
    ("Lex",     ACCENT_BLU),
    ("Parse",   ACCENT_BLU),
    ("Sem",     ACCENT_BLU),
    ("IR",      ACCENT_VIO),
    ("CodeGen", ACCENT_ORG),
    ("Asm",     ACCENT_GRN),
    (".hex",    ACCENT_GRN),
    ("FPGA",    ACCENT_PNK),
]


def scene_pipeline(ax, t):
    title_bar(ax, "Compilation pipeline",
              "C source down to a BROM image flashed onto the SoC")
    n = len(PIPELINE_STAGES)
    margin = 0.6
    span = 16 - 2 * margin
    box_w = span / n - 0.18
    box_h = 0.95
    y = 4.6
    for i, (name, col) in enumerate(PIPELINE_STAGES):
        x = margin + i * (box_w + 0.18)
        lit = smoothstep((t - 0.4 - i * 0.5) / 0.5)
        base = 0.15 + 0.85 * lit
        fc = col if lit > 0.05 else PANEL
        panel(ax, x, y, box_w, box_h, fc=fc, ec=col, alpha=base, lw=1.6)
        ax.text(x + box_w / 2, y + box_h / 2, name,
                ha="center", va="center",
                color=BG if lit > 0.5 else INK,
                fontsize=10, fontweight="bold")
        # arrow to next
        if i < n - 1:
            ax.add_patch(FancyArrowPatch(
                (x + box_w + 0.01, y + box_h / 2),
                (x + box_w + 0.17, y + box_h / 2),
                arrowstyle="->", color=col, lw=1.6 * base, alpha=base,
                mutation_scale=10))

    # captions under each phase, fade in once enough stages are lit
    caps = [
        (0,  "source"),
        (4,  "virtual regs"),
        (5,  "alloc + spill"),
        (7,  "BROM image"),
        (8,  "behavioural sim"),
    ]
    for idx, txt in caps:
        a = smoothstep((t - 0.6 - idx * 0.5) / 0.6)
        x = margin + idx * (box_w + 0.18) + box_w / 2
        ax.text(x, y - 0.35, txt, ha="center", va="center",
                color=INK_DIM, fontsize=9, alpha=a)

    # bottom call-out: where the animation drills into
    spotlight = smoothstep((t - 4.5) / 0.6)
    if spotlight > 0:
        x = margin + 5 * (box_w + 0.18) - 0.05
        ax.add_patch(Rectangle((x, y - 1.7), box_w + 0.1, 3.2,
                               facecolor=ACCENT_ORG, alpha=0.08 * spotlight,
                               edgecolor=ACCENT_ORG, linewidth=1.3 * spotlight))
        ax.text(x + box_w / 2 + 0.05, y - 2.0, "we open this box",
                ha="center", va="center", color=ACCENT_ORG,
                fontsize=11, alpha=spotlight, fontweight="bold")


# ---------------------------------------------------------------------------
# scene 3 — C → IR
# ---------------------------------------------------------------------------

def scene_c_to_ir(ax, t):
    title_bar(ax, "C  →  IR",
              "every expression result becomes a virtual register (vreg)")
    # C source (left)
    code_block(ax, 0.7, 1.6, 6.8, 5.0, C_SRC, title="dot.c", mono_size=13)

    # IR (right) — lines stream in
    ir_lines = []
    for i, (dst, op, comment) in enumerate(IR_OPS):
        if dst:
            line = f"  {dst} = {op:<14} {comment}"
        else:
            line = f"  {op:<22} {comment}"
        ir_lines.append(line)

    # progressive reveal
    show_count = int(max(0.0, min(len(ir_lines), (t - 0.6) / 0.6)))
    visible = ir_lines[:show_count]
    code_block(ax, 8.5, 1.6, 6.8, 5.0, visible,
               title="IR (after lowering)", mono_size=12)

    # arrow C → IR
    a = smoothstep((t - 0.2) / 0.6)
    ax.add_patch(FancyArrowPatch(
        (7.55, 4.1), (8.45, 4.1),
        arrowstyle="-|>", color=ACCENT_ORG, lw=2.0, alpha=a,
        mutation_scale=18))


# ---------------------------------------------------------------------------
# scene 4 — liveness
# ---------------------------------------------------------------------------

def fmt_set(s):
    if not s:
        return "{ }"
    return "{ " + ", ".join(sorted(s)) + " }"


def scene_liveness(ax, t):
    title_bar(ax, "Liveness analysis",
              "live_after(I) = uses(next) ∪ (live_after(next) \\ def(next))   — backward")

    # left panel: IR with current focus
    n = len(LIVE_AFTER)
    # walk one instruction every 2.3 s, in reverse (matches backward pass)
    cursor_pos = (t - 0.5) / 2.2
    walked = int(min(n, max(0, cursor_pos)))
    walked = n - walked - 1   # walk from bottom to top
    walked = max(-1, walked)

    ir_lines = [f"  {ln}" for ln, _ in LIVE_AFTER]
    hi = set()
    if 0 <= walked < n:
        hi.add(walked)
    code_block(ax, 0.5, 1.0, 7.5, 6.0, ir_lines,
               title="instructions (visit bottom-up)",
               highlight_idx=hi, mono_size=12)

    # right panel: live_after sets revealed in reverse order
    revealed = set()
    for i in range(n - 1, -1, -1):
        if i >= walked:
            revealed.add(i)

    set_lines = []
    for i, (ln, s) in enumerate(LIVE_AFTER):
        marker = "►" if i == walked else " "
        set_lines.append(f"{marker} {fmt_set(s)}")

    # apply per-line alpha by overriding color
    colour_map = {}
    for i in range(n):
        if i not in revealed:
            colour_map[i] = "#3A3F47"
        elif i == walked:
            colour_map[i] = ACCENT_ORG
        else:
            colour_map[i] = ACCENT_GRN

    code_block(ax, 8.3, 1.0, 7.2, 6.0, set_lines,
               title="live_after(I)",
               color_overrides=colour_map, mono_size=12)

    # bottom note: explain what's happening
    if walked >= 0:
        ln, s = LIVE_AFTER[walked]
        msg = (f"at  {ln:<18}   →   anything live in {fmt_set(s)} cannot share a register "
               f"with the value being defined")
        ax.text(8, 0.55, msg, ha="center", va="center",
                color=INK_DIM, fontsize=10, family="DejaVu Sans Mono")


# ---------------------------------------------------------------------------
# scene 5 — interference graph build
# ---------------------------------------------------------------------------

def scene_interference(ax, t):
    title_bar(ax, "Interference graph",
              "edge (a, b)  ⇔  a and b are live at the same point")

    # Right side: the live_after table (static reference)
    ref_lines = [f"  {ln:<22} live_after = {fmt_set(s)}"
                 for ln, s in LIVE_AFTER]
    code_block(ax, 8.4, 1.0, 7.1, 6.0, ref_lines,
               title="liveness summary", mono_size=11)

    # Left: graph in its own subview
    # Map graph coords (-2..2, -3..2) into ax coords (0.4..7.6, 0.8..6.5)
    def to_ax(p):
        gx, gy = p
        ax_x = 0.5 + (gx + 2.5) / 5.0 * 7.4
        ax_y = 1.0 + (gy + 3.0) / 5.5 * 5.5
        return ax_x, ax_y

    panel(ax, 0.4, 0.9, 7.6, 6.0)
    ax.text(0.6, 6.6, "interference graph", color=INK_DIM,
            fontsize=10, fontweight="bold")

    # progressively reveal nodes (0.6s) and edges (1.2s each)
    nodes_at = 0.4
    edges_start = 1.4
    edge_dur = 1.0

    # find which edge is "current" (recently added) and which endpoints to pulse
    pulse_endpoints = set()
    for i, (u, v) in enumerate(IFG_EDGES):
        ti = t - (edges_start + i * edge_dur)
        if 0 <= ti < 0.9:
            pulse_endpoints.add(u)
            pulse_endpoints.add(v)

    # edges (use orange highlight as each appears)
    for i, (u, v) in enumerate(IFG_EDGES):
        ti = t - (edges_start + i * edge_dur)
        a_full = smoothstep(ti / 0.5)
        if a_full <= 0:
            continue
        is_current = ti < 0.7
        col = ACCENT_ORG if is_current else INK_DIM
        lw = 2.4 if is_current else 1.6
        draw_edge(ax, to_ax(NODE_POS[u]), to_ax(NODE_POS[v]),
                  color=col, lw=lw, alpha=a_full)

    # nodes (drawn AFTER edges so they sit on top); pulse currently-added pair
    for i, v in enumerate(VREGS):
        a = smoothstep((t - nodes_at - i * 0.15) / 0.5)
        if a <= 0:
            continue
        if v in pulse_endpoints:
            # pulsing glow halo
            pulse = 0.5 + 0.5 * math.sin(t * 7)
            ax_p = to_ax(NODE_POS[v])
            ax.add_patch(Circle(ax_p, 0.5,
                                facecolor="none", edgecolor=ACCENT_ORG,
                                lw=1.8, alpha=0.35 + 0.4 * pulse, zorder=2.5))
            draw_node(ax, ax_p, v, fill=ACCENT_ORG, edge=INK, alpha=a, r=0.34,
                      text_color=BG)
        else:
            draw_node(ax, to_ax(NODE_POS[v]), v,
                      fill=PANEL, edge=INK, alpha=a, r=0.34)

    # explanation under each edge as it arrives
    explanations = [
        "v0 & v1 co-live at def(v1)",
        "v0 & v2 co-live at def(v2)",
        "v1 & v2 co-live at def(v2)",
        "v2 & v3 co-live at def(v3)",
        "v2 & v4 co-live at def(v4)",
    ]
    for i, txt in enumerate(explanations):
        ti = t - (edges_start + i * edge_dur)
        if 0 < ti < 0.9:
            ax.text(4.2, 0.55, txt, ha="center", va="center",
                    color=ACCENT_ORG, fontsize=11,
                    family="DejaVu Sans Mono",
                    alpha=smoothstep(ti / 0.3) * (1.0 - smoothstep((ti - 0.6) / 0.3)))


# ---------------------------------------------------------------------------
# scene 6 — simplify + color (K=3)
# ---------------------------------------------------------------------------

def scene_simplify_color(ax, t):
    title_bar(ax, "Simplify & Color   (K = 3)",
              "push low-degree nodes, pop and assign first free color")

    # Time budget: ~20s
    # phase 1 (0..9s): simplify — push nodes one by one
    # phase 2 (9..18s): color — pop and assign

    push_step_dur = 1.4
    n_steps_simp = len(SIMPLIFY_K3)
    color_step_dur = 1.4
    n_steps_color = len(COLOR_ASSIGN_K3)
    simp_end = 0.4 + n_steps_simp * push_step_dur
    color_end = simp_end + n_steps_color * color_step_dur

    pushed_count = int(min(n_steps_simp, max(0, (t - 0.4) / push_step_dur)))
    colored_count = int(min(n_steps_color, max(0, (t - simp_end - 0.4) / color_step_dur)))

    pushed_list = SIMPLIFY_K3[:pushed_count]
    pushed_names = [p[0] for p in pushed_list]
    colored_list = COLOR_ASSIGN_K3[:colored_count]
    colored_map = {v: c for v, c in colored_list}

    # Graph view: nodes that have been pushed go translucent
    def to_ax(p):
        gx, gy = p
        ax_x = 0.5 + (gx + 2.5) / 5.0 * 6.5
        ax_y = 1.0 + (gy + 3.0) / 5.5 * 5.2
        return ax_x, ax_y

    panel(ax, 0.4, 0.9, 6.7, 5.8)
    ax.text(0.6, 6.5, "interference graph", color=INK_DIM,
            fontsize=10, fontweight="bold")

    # edges first (faded if either endpoint pushed)
    for u, v in IFG_EDGES:
        gone = (u in pushed_names) or (v in pushed_names)
        a = 0.15 if gone else 0.7
        draw_edge(ax, to_ax(NODE_POS[u]), to_ax(NODE_POS[v]),
                  color=INK_DIM, lw=1.4, alpha=a)

    # compute working degree of every remaining vreg (= original neighbours
    # that have not yet been pushed)
    adj = adjacency()
    pushed_set = set(pushed_names)
    work_deg = {v: sum(1 for u in adj[v] if u not in pushed_set) for v in VREGS}

    # which is the next node we're about to push? pulse it
    next_push = None
    if t < simp_end:
        nxt_idx = pushed_count
        if nxt_idx < len(SIMPLIFY_K3):
            next_push = SIMPLIFY_K3[nxt_idx][0]

    # nodes (+ degree pip in lower-right corner)
    for v in VREGS:
        is_pushed = v in pushed_names
        if v in colored_map:
            fill = PHYS_PALETTE[colored_map[v]]
            alpha = 1.0
        elif is_pushed:
            fill = "#1F242C"
            alpha = 0.35
        else:
            fill = PANEL
            alpha = 1.0
        ax_p = to_ax(NODE_POS[v])
        if v == next_push and not is_pushed:
            pulse = 0.5 + 0.5 * math.sin(t * 6)
            ax.add_patch(Circle(ax_p, 0.5,
                                facecolor="none", edgecolor=ACCENT_ORG,
                                lw=1.6, alpha=0.3 + 0.4 * pulse, zorder=2.5))
        draw_node(ax, ax_p, v, fill=fill, alpha=alpha, r=0.34)
        # degree pip (only for nodes still in graph)
        if not is_pushed:
            d = work_deg[v]
            ax.add_patch(Circle((ax_p[0] + 0.34, ax_p[1] - 0.34), 0.16,
                                facecolor=BG, edgecolor=INK_DIM, lw=1.0,
                                alpha=alpha, zorder=4))
            ax.text(ax_p[0] + 0.34, ax_p[1] - 0.34, str(d),
                    ha="center", va="center", color=INK,
                    fontsize=8, fontweight="bold", alpha=alpha, zorder=5)

    # Select stack (right column)
    panel(ax, 7.3, 0.9, 4.0, 5.8)
    ax.text(7.5, 6.5, "select stack (LIFO)", color=INK_DIM,
            fontsize=10, fontweight="bold")
    # draw stack frames from bottom up
    base_y = 1.1
    slot_h = 0.6
    for i, (v, deg) in enumerate(pushed_list):
        y = base_y + i * slot_h
        a = smoothstep((t - 0.4 - i * push_step_dur) / 0.4)
        is_top = i == len(pushed_list) - 1
        # if we're in color phase, mark already-colored entries
        in_color_phase = t > simp_end
        already_colored = v in colored_map
        if already_colored:
            fc = PHYS_PALETTE[colored_map[v]]
            ec = INK
        elif is_top and not in_color_phase:
            fc = ACCENT_ORG
            ec = INK
        else:
            fc = "#1F242C"
            ec = GRID
        panel(ax, 7.5, y, 3.6, slot_h - 0.08, fc=fc, ec=ec, alpha=a)
        # text inside
        text_col = BG if already_colored or (is_top and not in_color_phase) else INK
        ax.text(7.7, y + (slot_h - 0.08) / 2, f"{v}",
                color=text_col, fontsize=11,
                fontweight="bold", alpha=a,
                family="DejaVu Sans Mono", va="center")
        ax.text(11.0, y + (slot_h - 0.08) / 2,
                f"deg = {deg}" if not already_colored else f"→ {colored_map[v]}",
                color=text_col, fontsize=10, alpha=a,
                family="DejaVu Sans Mono", va="center", ha="right")

    # Color legend (far right column)
    panel(ax, 11.6, 0.9, 4.0, 5.8)
    ax.text(11.8, 6.5, "physical registers", color=INK_DIM,
            fontsize=10, fontweight="bold")
    legend = [
        ("t0", "r4 — caller-saved"),
        ("t1", "r5 — caller-saved"),
        ("t2", "r6 — caller-saved"),
    ]
    for i, (reg, desc) in enumerate(legend):
        y = 5.7 - i * 0.7
        ax.add_patch(Circle((12.1, y), 0.22,
                            facecolor=PHYS_PALETTE[reg], edgecolor=INK, lw=1.4))
        ax.text(12.55, y, reg, color=INK, fontsize=12,
                fontweight="bold", family="DejaVu Sans Mono", va="center")
        ax.text(13.2, y, desc, color=INK_DIM, fontsize=10,
                family="DejaVu Sans Mono", va="center")
    # status lines below (two lines, both inside the legend panel)
    if t < simp_end:
        l1 = "simplifying"
        l2 = "push degree < 3"
        status_col = ACCENT_ORG
    elif t < color_end:
        l1 = "coloring"
        l2 = "pop, pick free color"
        status_col = ACCENT_GRN
    else:
        l1 = "done"
        l2 = "6 vregs → 3 regs"
        status_col = ACCENT_BLU
    ax.text(13.6, 2.05, l1, ha="center", va="center",
            color=status_col, fontsize=11, fontweight="bold")
    ax.text(13.6, 1.7, l2, ha="center", va="center",
            color=status_col, fontsize=9, family="DejaVu Sans Mono")
    # show recent "just colored" line
    if colored_count > 0 and t < color_end:
        v, c = colored_list[-1]
        ax.text(13.6, 1.15, f"{v}  ←  {c}",
                ha="center", va="center", color=PHYS_PALETTE[c],
                fontsize=14, family="DejaVu Sans Mono", fontweight="bold")


# ---------------------------------------------------------------------------
# scene 7 — spill (K=2)
# ---------------------------------------------------------------------------

def scene_spill(ax, t):
    title_bar(ax, "Spill   (what if K = 2?)",
              "no color for v2 — it's spilled to a frame slot, reloads/stores around uses")

    # Left: graph with v2 → SPILL
    def to_ax(p):
        gx, gy = p
        ax_x = 0.5 + (gx + 2.5) / 5.0 * 6.5
        ax_y = 1.0 + (gy + 3.0) / 5.5 * 5.2
        return ax_x, ax_y

    panel(ax, 0.4, 0.9, 6.7, 5.8)
    ax.text(0.6, 6.5, "interference graph (K = 2)", color=INK_DIM,
            fontsize=10, fontweight="bold")

    # color decisions roll in over the scene
    color_step = 1.4
    n_steps = len(COLOR_ASSIGN_K2)
    done_count = int(min(n_steps, max(0, (t - 0.4) / color_step)))
    colored_map = dict(COLOR_ASSIGN_K2[:done_count])

    for u, v in IFG_EDGES:
        draw_edge(ax, to_ax(NODE_POS[u]), to_ax(NODE_POS[v]),
                  color=INK_DIM, lw=1.4, alpha=0.6)

    for v in VREGS:
        if v in colored_map:
            c = colored_map[v]
            fill = PHYS_PALETTE[c]
            edge_col = ACCENT_RED if c == "SPILL" else INK
            lw = 2.4 if c == "SPILL" else 1.6
        else:
            fill = PANEL
            edge_col = INK
            lw = 1.6
        draw_node(ax, to_ax(NODE_POS[v]), v, fill=fill, edge=edge_col, lw=lw, r=0.34)

    # SPILL flash on v2 when it gets assigned
    if "v2" in colored_map:
        pulse = 0.5 + 0.5 * math.sin(t * 6)
        ax_p = to_ax(NODE_POS["v2"])
        ax.add_patch(Circle(ax_p, 0.55,
                            facecolor="none", edgecolor=ACCENT_RED,
                            lw=2.0, alpha=0.4 + 0.4 * pulse))

    # Right: the spill-code emission
    panel(ax, 7.5, 0.9, 8.0, 5.8)
    ax.text(7.7, 6.5, "spill code  (slot in frame, fp-relative)",
            color=INK_DIM, fontsize=10, fontweight="bold")

    spill_asm = [
        "; v2 was assigned SPILL → home in stack frame",
        "; allocate 1 word slot, fp-relative",
        "",
        "    ADDI sp, sp, #-1      ; reserve slot for v2",
        "",
        "    ADD  t0, t1           ; compute v2  (was t0)",
        "    SW   t0, fp, #-1      ; STORE v2  ←  spill",
        "",
        "    LW   t0, fp, #-1      ; RELOAD v2  before use",
        "    NEG(t1)               ; v3 = v0 - v1  (dst==b)",
        "    ADD  t1, t0",
        "",
        "    LW   t0, fp, #-1      ; RELOAD v2  before next use",
        "    ADD  t1, t0           ; v4 = v2 + v3",
    ]
    reveal = int(min(len(spill_asm), max(0, (t - 2.0) / 0.4)))
    visible = spill_asm[:reveal]
    code_block(ax, 7.6, 1.0, 7.8, 5.4, visible, mono_size=11)

    # caption
    if t > 6.0:
        a = smoothstep((t - 6.0) / 0.5)
        ax.text(8, 0.4,
                "→ codegen detects REGALLOC_SPILL and emits SW/LD around every use",
                ha="center", va="center", color=ACCENT_RED, fontsize=11, alpha=a)


# ---------------------------------------------------------------------------
# scene 8 — final assembly + hex
# ---------------------------------------------------------------------------

def scene_asm_hex(ax, t):
    title_bar(ax, "Emit assembly  →  BROM hex",
              "vregs replaced with their assigned physical registers; assembler packs 16-bit words")

    # Map asm-line index → hex-word index for the connector animation.
    # Only the "real" instruction lines map; comments/labels are skipped.
    asm_to_hex = {
        2: 0,   # MOV(t2, a0)
        3: 1,   # MOV(t1, a1)
        4: 2,   # MOV(t0, t2)
        5: 3,   # ADD  t0, t1
        6: 4,   # NEG(t1)
        7: 5,   # ADD  t1, t2
        8: 6,   # ADD  t1, t0
        9: 7,   # ADD  t0, t1
        10: 8,  # MOV(a0, t0)
        11: 9,  # RET
    }

    # Left: assembly
    reveal_asm = int(min(len(ASM_LINES), max(0, (t - 0.3) / 0.22)))
    visible = ASM_LINES[:reveal_asm]

    # Which line/word pair to highlight (rotates after both lists are revealed)
    mappable = sorted(asm_to_hex.keys())
    highlight_asm = None
    highlight_hex = None
    rotate_start = 4.0
    if t > rotate_start:
        idx = int((t - rotate_start) / 0.6) % len(mappable)
        candidate = mappable[idx]
        if candidate < reveal_asm:
            highlight_asm = candidate
            highlight_hex = asm_to_hex[candidate]

    code_block(ax, 0.4, 1.0, 7.4, 6.0, visible,
               title="dot.s   (after register allocation)", mono_size=11,
               highlight_idx={highlight_asm} if highlight_asm is not None else None)

    # Right: hex words flowing into the BROM
    panel(ax, 8.2, 1.0, 7.3, 6.0)
    ax.text(8.4, 6.6, "BROM image  (512 × 16-bit words)",
            color=INK_DIM, fontsize=10, fontweight="bold")

    # arrange hex words in a grid
    cols = 4
    cell_w = 1.5
    cell_h = 0.42
    grid_x0 = 8.5
    grid_y0 = 5.6
    n_show = int(min(len(HEX_WORDS), max(0, (t - 2.5) / 0.16)))
    hex_centers = {}
    for i, w in enumerate(HEX_WORDS):
        r = i // cols
        c = i % cols
        x = grid_x0 + c * (cell_w + 0.12)
        y = grid_y0 - r * (cell_h + 0.12)
        a = smoothstep((t - 2.5 - i * 0.16) / 0.3) if i < n_show + 2 else 0.0
        if a <= 0:
            continue
        is_hi = (i == highlight_hex)
        col = ACCENT_ORG if is_hi else ACCENT_VIO
        lw = 2.0 if is_hi else 1.2
        ax.add_patch(Rectangle((x, y - cell_h / 2), cell_w, cell_h,
                               facecolor=PANEL, edgecolor=col,
                               linewidth=lw * a, alpha=0.6 + 0.4 * a))
        ax.text(x + cell_w / 2, y, w,
                ha="center", va="center",
                color=col, family="DejaVu Sans Mono",
                fontsize=10, fontweight="bold", alpha=a)
        hex_centers[i] = (x, y)

    # connector line from highlighted asm to its hex word
    if highlight_asm is not None and highlight_hex in hex_centers:
        asm_y = 1.0 + 6.0 - 0.7 - highlight_asm * 0.32
        asm_x = 0.4 + 7.4 - 0.2
        hx, hy = hex_centers[highlight_hex]
        ax.add_patch(FancyArrowPatch(
            (asm_x, asm_y), (hx, hy),
            arrowstyle="-|>", color=ACCENT_ORG, lw=1.4,
            alpha=0.85, mutation_scale=12,
            connectionstyle="arc3,rad=0.08"))

    if t > 7.5:
        a = smoothstep((t - 7.5) / 0.4)
        ax.text(11.85, 0.55,
                "test_lo.hex   +   test_hi.hex   (byte-split for two 8-bit BROM halves)",
                ha="center", va="center",
                color=ACCENT_GRN, fontsize=11, fontweight="bold", alpha=a)


# ---------------------------------------------------------------------------
# scene 9 — flash to FPGA
# ---------------------------------------------------------------------------

def scene_flash(ax, t):
    title_bar(ax, "Flash  →  pipelined SoC",
              "BROM init drives the 4-stage CPU; `a0` holds the return value at halt")

    # Left: stylised hex stream with a moving PC cursor
    stream_x = 0.8
    stream_w = 5.0
    panel(ax, stream_x, 1.4, stream_w, 5.5)
    ax.text(stream_x + 0.2, 6.7, "BROM hex stream",
            color=INK_DIM, fontsize=10, fontweight="bold")
    n_words = 12

    # PC walks one slot every 0.4s, wraps for a continuous loop
    pc_cycle = 0.45
    pc_pos = ((t - 1.5) / pc_cycle) % n_words if t > 1.5 else -1

    for i in range(n_words):
        y = 6.2 - i * 0.4
        word = HEX_WORDS[i % len(HEX_WORDS)]
        # distance from PC determines glow
        dist = abs(i - pc_pos) if pc_pos >= 0 else 99
        if dist < 0.6:
            col = ACCENT_PNK
            a_text = 1.0
            # PC indicator chevron on the left
            ax.text(stream_x + 0.45, y, "►",
                    ha="center", va="center",
                    color=ACCENT_PNK, fontsize=11, fontweight="bold")
            ax.add_patch(Rectangle((stream_x + 0.7, y - 0.16),
                                   stream_w - 1.0, 0.32,
                                   facecolor=ACCENT_PNK, alpha=0.18,
                                   edgecolor="none"))
        elif dist < 2.0:
            col = ACCENT_VIO
            a_text = 0.95
        else:
            col = ACCENT_VIO
            a_text = 0.4 + 0.2 * math.sin(t * 1.5 + i * 0.4)
        a_text = min(1.0, a_text * smoothstep(t / 0.8))
        ax.text(stream_x + stream_w / 2 + 0.4, y, word,
                ha="center", va="center",
                color=col, fontsize=12,
                family="DejaVu Sans Mono", fontweight="bold",
                alpha=a_text)
    # PC legend on the right side of the header row
    a_pc = smoothstep((t - 1.0) / 0.5)
    ax.text(stream_x + stream_w - 0.2, 6.7, "PC →", color=ACCENT_PNK,
            fontsize=9, fontweight="bold", alpha=a_pc, ha="right",
            family="DejaVu Sans Mono")

    # Middle: arrows + FPGA chip
    chip_cx, chip_cy = 11.0, 4.2
    chip_w, chip_h = 4.0, 4.0
    chip_x = chip_cx - chip_w / 2
    chip_y = chip_cy - chip_h / 2
    # chip body
    panel(ax, chip_x, chip_y, chip_w, chip_h, fc="#101820",
          ec=ACCENT_PNK, lw=2.0, radius=0.15)
    # pins
    for i in range(6):
        py = chip_y + 0.6 + i * 0.6
        ax.add_patch(Rectangle((chip_x - 0.25, py - 0.06), 0.25, 0.12,
                               facecolor="#888", edgecolor="none"))
        ax.add_patch(Rectangle((chip_x + chip_w, py - 0.06), 0.25, 0.12,
                               facecolor="#888", edgecolor="none"))
    # label
    ax.text(chip_cx, chip_y + chip_h - 0.5, "ShivAT SoC",
            ha="center", va="center", color=ACCENT_PNK,
            fontsize=14, fontweight="bold")
    ax.text(chip_cx, chip_y + chip_h - 0.95, "Zybo Z7-10  ·  100 MHz",
            ha="center", va="center", color=INK_DIM, fontsize=9)

    # internal status: stages lighting up
    stages = ["IF", "ID", "EX", "MEM"]
    for i, st in enumerate(stages):
        cx = chip_cx - 1.4 + i * 0.95
        cy = chip_cy
        lit = 0.5 + 0.5 * math.sin(t * 6 - i * 1.3)
        col = ACCENT_GRN if lit > 0.5 else PANEL
        ax.add_patch(Circle((cx, cy), 0.32,
                            facecolor=col, edgecolor=ACCENT_GRN, lw=1.4))
        ax.text(cx, cy, st, ha="center", va="center",
                color=BG if lit > 0.5 else INK_DIM,
                fontsize=9, fontweight="bold")

    # arrow from stream to chip
    a_arrow = smoothstep((t - 0.4) / 0.6)
    ax.add_patch(FancyArrowPatch(
        (stream_x + stream_w + 0.05, 4.2),
        (chip_x - 0.05, 4.2),
        arrowstyle="-|>", color=ACCENT_PNK, lw=2.5,
        alpha=a_arrow, mutation_scale=22))
    ax.text((stream_x + stream_w + chip_x) / 2, 4.6,
            "$readmemh", ha="center", va="center",
            color=ACCENT_PNK, fontsize=10,
            family="DejaVu Sans Mono", alpha=a_arrow)

    # bottom result line — appears late
    a_result = smoothstep((t - 4.0) / 0.6)
    if a_result > 0:
        panel(ax, 0.8, 0.25, 14.4, 0.95, fc=PANEL, ec=ACCENT_GRN, lw=1.6,
              alpha=a_result)
        ax.text(8, 0.72,
                "test_tb done   pc = 0x0110   a0 = 0x0028   ← dot(3, 5) = 24",
                ha="center", va="center",
                color=ACCENT_GRN, fontsize=14,
                family="DejaVu Sans Mono", fontweight="bold", alpha=a_result)


# ---------------------------------------------------------------------------
# scene 10 — end card
# ---------------------------------------------------------------------------

def scene_end(ax, t):
    a = smoothstep(t / 0.8)
    ax.text(8, 5.0, "CodeGen + RegAlloc + Pipeline",
            ha="center", va="center", color=INK, alpha=a,
            fontsize=26, fontweight="bold")
    ax.text(8, 4.25, "Chaitin-Briggs  ·  liveness  ·  interference  ·  spill",
            ha="center", va="center", color=INK_DIM, alpha=a, fontsize=14)
    # mini palette swatch
    for i, c in enumerate(["t0", "t1", "t2", "s0", "SPILL"]):
        x = 5.5 + i * 1.25
        ax.add_patch(Circle((x, 3.0), 0.28,
                            facecolor=PHYS_PALETTE[c], edgecolor=INK,
                            lw=1.5, alpha=a))
        ax.text(x, 2.3, c, ha="center", va="center",
                color=INK_DIM, fontsize=10, alpha=a,
                family="DejaVu Sans Mono")
    ax.text(8, 1.4, "ShivAT  ·  16-bit pipelined RISC SoC",
            ha="center", va="center", color=INK_DIM, alpha=a * 0.7,
            fontsize=11)


# ---------------------------------------------------------------------------
# top-level scene list
# ---------------------------------------------------------------------------

SCENES = [
    Scene("title",        0.0,   4.0,  scene_title),
    Scene("pipeline",     4.0,  12.5,  scene_pipeline),
    Scene("c_to_ir",     12.5,  22.0,  scene_c_to_ir),
    Scene("liveness",    22.0,  39.0,  scene_liveness),
    Scene("interference",39.0,  55.0,  scene_interference),
    Scene("simplify",    55.0,  78.0,  scene_simplify_color),
    Scene("spill",       78.0,  89.0,  scene_spill),
    Scene("asm_hex",     89.0, 100.0,  scene_asm_hex),
    Scene("flash",      100.0, 110.0,  scene_flash),
    Scene("end",        110.0, 114.0,  scene_end),
]
TOTAL_DUR = SCENES[-1].end
N_FRAMES = int(TOTAL_DUR * FPS)


def render_frame(ax, t_global):
    ax.clear()
    setup_axes(ax)
    active = None
    for sc in SCENES:
        if sc.start <= t_global < sc.end:
            active = sc
            break
    if active is None:
        active = SCENES[-1]
    idx = SCENES.index(active)
    rel = t_global - active.start
    active.draw(ax, rel)

    # tiny progress bar at the bottom
    p = t_global / TOTAL_DUR
    ax.add_patch(Rectangle((0, 0), 16, 0.05, facecolor=GRID, edgecolor="none"))
    ax.add_patch(Rectangle((0, 0), 16 * p, 0.05, facecolor=ACCENT_ORG, edgecolor="none"))

    # scene counter (top-right)
    ax.text(15.85, 8.65, f"{idx + 1}/{len(SCENES)}",
            ha="right", va="center", color=INK_DIM, fontsize=9,
            family="DejaVu Sans Mono")


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

def main():
    out_dir = os.path.dirname(os.path.abspath(__file__))
    out_path = os.path.join(out_dir, "regalloc_pipeline.mp4")

    fig, ax = plt.subplots(figsize=(W_IN, H_IN), dpi=100)
    fig.patch.set_facecolor(BG)
    setup_axes(ax)

    def animate(i):
        t_global = i / FPS
        render_frame(ax, t_global)
        return []

    writer = FFMpegWriter(
        fps=FPS,
        codec="libx264",
        bitrate=4000,
        extra_args=["-pix_fmt", "yuv420p", "-preset", "medium", "-crf", "20"],
    )

    print(f"rendering {N_FRAMES} frames ({TOTAL_DUR:.1f}s @ {FPS}fps) → {out_path}")
    anim = FuncAnimation(fig, animate, frames=N_FRAMES, blit=False, interval=1000 / FPS)
    anim.save(out_path, writer=writer, dpi=100,
              progress_callback=lambda i, n: (i % 30 == 0) and print(f"  frame {i}/{n}"))
    print("done.")


if __name__ == "__main__":
    main()
