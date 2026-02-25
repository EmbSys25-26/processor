`timescale 1ns / 1ps

/*************************************************************************************
 * INTERRUPT CONTROL MODULE (ARM style)
 *  Handles all SoC interrupt requests
 *  Features:
 *   - Interrupt Pending Validation
 *   - Interrupt Servicing
 *   - Interrupt Nesting
 *   - Read Currently Pending IRQ
 *   - Set interrupt mask
 *   - Set/Clear Pending Bits 
 ************************************************************************************/

module irq_ctrl(
    input wire i_clk,
    input wire i_rst,
    input wire i_sel,
    input wire i_we,                // Write Enable on IRQ
    input wire i_re,                // Read Enable on IRQ
    input wire [15:0] i_wdata,      // Data to Write
    output wire [15:0] o_rdata,     // Data to Read
    input wire [2:0] i_addr,        // Data Address to access
    output wire o_rdy,              // Feedback Signal
    input wire [7:0] i_src_irq,     // 
    input wire i_in_irq,
    input wire i_int_en,
    input wire i_irq_ret,
    output wire o_irq_take,
    output wire [15:0] o_irq_vector
);

/*************************************************************************************
 * SECTION 1. DECLARE/DEFINE Variables/Registers/Wires
 ************************************************************************************/

/****************************************************************************
 * 1.1 DEFINE SFRs - MMIO REGISTERS' ADDRESSES  (LS nibble)
 ***************************************************************************/
    localparam [3:0] IRQ_PEND = 3'b0;
    localparam [3:0] IRQ_MASK = 3'h2;
    localparam [4:0] IRQ_FORCE = 4'h4;
    localparam [4:0] IRQ_CLEAR = 4'h6;

/****************************************************************************
 * 1.2 DECLARE SFRs -  MMIO REGISTERS
 ***************************************************************************/

    reg [7:0] _pending_next;    // IRQ_PEND / IRQ_MASK

/****************************************************************************
 * 1.3 DEFINE INTERRUPT SOURCES
 *     - Priority is intrinsic to definition + case stmt
 ***************************************************************************/

    localparam IRQ_SRC_TIMER0   = 5'b00001;  // Lowest Priority
    localparam IRQ_SRC_TIMER1   = 5'b0001x;
    localparam IRQ_SRC_PARIO    = 5'b001xx;
    localparam IRQ_SRC_UART     = 5'b01xxx;
    localparam IRQ_SRC_I2C      = 5'b1xxxx;  // Highest priority


/****************************************************************************
 * 1.4 DEFINE INTERRUPT INDEXES
 ***************************************************************************/

    localparam IDX_IRQ_TIMER0   = 3'd0;
    localparam IDX_IRQ_TIMER1   = 3'd1;
    localparam IDX_IRQ_PARIO    = 3'd2;
    localparam IDX_IRQ_UART     = 3'd3;
    localparam IDX_IRQ_I2C      = 3'd4;

/****************************************************************************
 * 1.5 DEFINE INTERRUPT Lines
 ***************************************************************************/

    localparam LINE_IRQ_TIMER0   = 8'b0000_0001;
    localparam LINE_IRQ_TIMER1   = 8'b0000_0010;
    localparam LINE_IRQ_PARIO    = 8'b0000_0100; 
    localparam LINE_IRQ_UART     = 8'b0000_1000;
    localparam LINE_IRQ_I2C      = 8'b0001_0000;

/****************************************************************************
 * 1.5 DEFINE INTERRUPT VECTOR ADDRESSES
 ***************************************************************************/

    localparam ISR_TIMER0   = 16'h0020;
    localparam ISR_TIMER1   = 16'h0040;
    localparam ISR_PARIO    = 16'h0060;
    localparam ISR_UART     = 16'h0080;
    localparam ISR_I2C      = 16'h00A0;

/****************************************************************************
 * 1.6 DECLARE WIRES / REGS
 ***************************************************************************/
    reg [15:0] _rdata;
    reg [15:0] _irq_vector;

    reg [7:0] _pending;
    reg [7:0] _mask;
    reg [7:0] _servicing;

    wire [7:0] _masked;
    wire [7:0] _next_pend;
    wire _any_pend;

    reg [2:0] _sel_idx;
    reg [7:0] _sel_onehot;

    localparam _depth_max = 2;
    reg [_depth_max-1:0] _depth;
    reg [2:0] _pri_stack [_depth_max-1:0];

    wire [_depth_max-1:0] _depth_eff;
    wire [2:0] _cur_pri;
    wire _can_preempt;

    integer _k;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/****************************************************************************
 * 2.1 Base Signals
 ***************************************************************************/
    assign o_rdy = i_sel;
    assign _masked = (i_src_irq & _mask) & ~_servicing;
    assign _next_pend = _pending | _masked;
    assign _any_pend = |_next_pend;

    assign _depth_eff = (i_irq_ret && (_depth != 0)) ? (_depth - 1'b1) : _depth;
    assign _cur_pri = (_depth_eff == 0) ? 3'd0 : _pri_stack[_depth_eff - 1];
    assign _can_preempt = (_depth_eff == 0) ? 1'b1 : (_sel_idx > _cur_pri);

    assign o_irq_take = _any_pend & i_int_en & _can_preempt;

    // Explicitly consume i_in_irq for lint cleanliness; preemption is controlled by depth/priority.
    wire _unused_in_irq;
    assign _unused_in_irq = i_in_irq;

/****************************************************************************
 * 2.2 Priority Encoder and Vector
 ***************************************************************************/
    always @(*) begin
        _sel_idx = 3'd0;
        _sel_onehot = 8'h00;
        casex (_next_pend[4:0])
            IRQ_SRC_I2C:    begin _sel_idx = IDX_IRQ_I2C; _sel_onehot = LINE_IRQ_I2C; end    
            IRQ_SRC_UART:   begin _sel_idx = IDX_IRQ_UART; _sel_onehot = LINE_IRQ_UART; end
            IRQ_SRC_PARIO:  begin _sel_idx = IDX_IRQ_PARIO; _sel_onehot = LINE_IRQ_PARIO; end
            IRQ_SRC_TIMER1: begin _sel_idx = IDX_IRQ_TIMER1; _sel_onehot = LINE_IRQ_TIMER1; end
            IRQ_SRC_TIMER0: begin _sel_idx = IDX_IRQ_TIMER0; _sel_onehot = LINE_IRQ_TIMER0; end
            default: begin _sel_idx = 3'd0; _sel_onehot = 8'h00; end
        endcase
    end

    always @(*) begin
        if (o_irq_take) begin
            case (_sel_idx)
                IDX_IRQ_TIMER0: _irq_vector = ISR_TIMER0;
                IDX_IRQ_TIMER1: _irq_vector = ISR_TIMER1;
                IDX_IRQ_PARIO:  _irq_vector = ISR_PARIO;
                IDX_IRQ_UART:   _irq_vector = ISR_UART;
                IDX_IRQ_I2C:    _irq_vector = ISR_I2C;
                default: _irq_vector = 16'hFFFF;
            endcase
        end else begin
            _irq_vector = 16'hFFFF;
        end
    end

/****************************************************************************
 * 2.3 Pending and Servicing State
 ***************************************************************************/
    always @(*) begin
        _pending_next = _next_pend;

        if (o_irq_take) begin
            _pending_next = _pending_next & ~_sel_onehot;
        end

        // Write to IRQ SFRs
        if (i_sel && i_we) begin
            case (i_addr)
                IRQ_FORCE: _pending_next = _pending_next | i_wdata[7:0];     // Enable pending interrupt source(s)
                IRQ_CLEAR: _pending_next = _pending_next & ~i_wdata[7:0];    // Deactivate interrupt source(s)
                default: ;
            endcase
        end
    end

    always @(posedge i_clk) begin
        if (i_rst) begin
            _pending <= 8'h00;
        end else begin
            _pending <= _pending_next;
        end
    end

    always @(posedge i_clk) begin
        if (i_rst) begin
            _servicing <= 8'h00;
        end else begin
            _servicing <= (_servicing & i_src_irq);
            if (o_irq_take) begin
                _servicing <= (_servicing & i_src_irq) | _sel_onehot;
            end
        end
    end

/****************************************************************************
 * 2.4 Nesting and Mask Registers
 ***************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _depth <= {_depth_max{1'b0}};
            for (_k = 0; _k < _depth_max; _k = _k + 1) begin
                _pri_stack[_k] <= 3'd0;
            end
        end else begin
            case ({o_irq_take, i_irq_ret})
                2'b10: begin
                    if (_depth < _depth_max) begin
                        _pri_stack[_depth] <= _sel_idx;
                        _depth <= _depth + 1'b1;
                    end
                end
                2'b01: begin
                    if (_depth > 0) begin
                        _depth <= _depth - 1'b1;
                    end
                end
                2'b11: begin
                    if (_depth == 0) begin
                        _pri_stack[0] <= _sel_idx;
                        _depth <= 1'b1;
                    end else begin
                        _pri_stack[_depth - 1] <= _sel_idx;
                    end
                end
                default: ;
            endcase
        end
    end

    always @(posedge i_clk) begin
        if (i_rst) begin
            _mask <= 8'hFF;
        end else if (i_sel && i_we && (i_addr == IRQ_MASK)) begin
            _mask <= i_wdata[7:0];
        end
    end

/****************************************************************************
 * 2.5 MMIO Readback
 ***************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _rdata <= 16'h0000;
        end else if (i_sel && i_re) begin
            case (i_addr)
                IRQ_PEND: _rdata <= {8'h00, _pending};
                IRQ_MASK: _rdata <= {8'h00, _mask};
                default: _rdata <= 16'h0000;
            endcase
        end else begin
            _rdata <= 16'h0000;
        end
    end

    assign o_rdata = _rdata;
    assign o_irq_vector = _irq_vector;

endmodule
