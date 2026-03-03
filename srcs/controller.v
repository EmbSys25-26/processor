`timescale 1ns / 1ps
`include "constants.vh"

module controller(
    input i_clk,
    input i_rst,
    input [2:0] i_imgSel,       
    output wire [`VGA_CHANNEL_SIZE:0] o_vga_red,
    output wire [`VGA_CHANNEL_SIZE:0] o_vga_green,
    output wire [`VGA_CHANNEL_SIZE:0] o_vga_blue,
    output wire o_hsync,
    output wire o_vsync  
);

 /*************************************************************************************
 * CLOCKING WIZARD
 ************************************************************************************/
 
  wire _clkSystem;
  wire _clkVGA;
  wire _locked;
  
  clk_wiz_0 u_clk_wiz (
    .clk_in1 (i_clk),
    .clk_out1(_clkSystem),
    .clk_out2 (_clkVGA),
    .reset   (i_rst),
    .locked  (_locked)
  );
  
  reg _rst_sync;
  always @(posedge _clkSystem or posedge i_rst) begin
    if (i_rst || ~_locked)
      _rst_sync <= 1'b1;
    else
      _rst_sync <= 1'b0;
  end
  
/****************************************************************************
 * DECLARE REGS to drive MMIO signals
 ***************************************************************************/
  
  reg         _sel;
  reg         _we;
  reg         _re;
  reg         _addr;
  reg  [15:0] _wdata;
  wire [15:0] _rdata;
  wire        _rdy;

/*************************************************************************************
 * INTERNAL MODULE INSTANTIATION
 ************************************************************************************/
    m_vga_mmio periph_vga (
        .i_clkSystem(_clkSystem),
        .i_clkVGA(_clkVGA),
        .i_rst(_rst_sync),
        .i_sel(_sel),
        .i_we(_we),
        .i_re(_re),
        .i_addr(_addr),
        .i_wdata(_wdata),
        .o_rdata(_rdata),
        .o_rdy(_rdy),
        .o_vga_red(o_vga_red),
        .o_vga_green(o_vga_green),
        .o_vga_blue(o_vga_blue),
        .o_hsync(o_hsync),
        .o_vsync(o_vsync)
    );
    
/****************************************************************************
 * STATE MACHINE
 * Sequence:
 *   1. Write i_imgSel to VGASEL (addr=1) - replaces previous fixed write
 *   2. Write 1 to CNTRL  (addr=0)
 *   3. Stay in DONE, continuously update VGASEL if i_imgSel changes
 ***************************************************************************/

  localparam S_IDLE         = 3'd0;
  localparam S_WRITE_VGASEL = 3'd1;
  localparam S_WAIT_VGASEL  = 3'd2;
  localparam S_WRITE_CNTRL  = 3'd3;
  localparam S_WAIT_CNTRL   = 3'd4;
  localparam S_DONE         = 3'd5;

  reg [2:0] _state;
  reg [2:0] _imgSel_prev;   // track changes to i_imgSel in DONE state

  always @(posedge _clkSystem) begin
    if (_rst_sync) begin
      _state       <= S_IDLE;
      _sel         <= 1'b0;
      _we          <= 1'b0;
      _re          <= 1'b0;
      _addr        <= 1'b0;
      _wdata       <= 16'h0000;
      _imgSel_prev <= 3'b000;
    end
    else begin
      case (_state)

        S_IDLE: begin
          _sel         <= 1'b0;
          _we          <= 1'b0;
          _imgSel_prev <= i_imgSel;
          _state       <= S_WRITE_VGASEL;
        end

        // Step 1: Write i_imgSel to VGASEL (addr=1)
        S_WRITE_VGASEL: begin
          _sel   <= 1'b1;
          _we    <= 1'b1;
          _re    <= 1'b0;
          _addr  <= 1'b1;                        // VGASEL
          _wdata <= {13'b0, i_imgSel};           // i_imgSel -> bits [2:0]
          _state <= S_WAIT_VGASEL;
        end

        S_WAIT_VGASEL: begin
          if (_rdy) begin
            _sel   <= 1'b0;
            _we    <= 1'b0;
            _state <= S_WRITE_CNTRL;
          end
        end

        // Step 2: Write 1 to CNTRL (addr=0)
        S_WRITE_CNTRL: begin
          _sel   <= 1'b1;
          _we    <= 1'b1;
          _re    <= 1'b0;
          _addr  <= 1'b0;                        // CNTRL
          _wdata <= 16'h0001;                    // enVGA = 1
          _state <= S_WAIT_CNTRL;
        end

        S_WAIT_CNTRL: begin
          if (_rdy) begin
            _sel         <= 1'b0;
            _we          <= 1'b0;
            _imgSel_prev <= i_imgSel;
            _state       <= S_DONE;
          end
        end

        // Step 3: Done - re-write VGASEL whenever i_imgSel changes
        S_DONE: begin
          if (i_imgSel != _imgSel_prev) begin
            _imgSel_prev <= i_imgSel;
            _sel         <= 1'b1;
            _we          <= 1'b1;
            _re          <= 1'b0;
            _addr        <= 1'b1;                // VGASEL
            _wdata       <= {13'b0, i_imgSel};
          end
          else begin
            _sel <= 1'b0;
            _we  <= 1'b0;
          end
        end

      endcase
    end
  end

endmodule