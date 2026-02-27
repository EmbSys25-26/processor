`timescale 1ns / 1ps

/*************************************************************************************
 * PS2 MMIO MODULE
 *  Implements PS2 MMIO, instantiates PS2 Transmit (Device -> Host)  and PS2 Receive (Device -> Host)  Modules 
 *  Features:
 *  - 2 flip-flop synchronizers on CLK and DATA
 *  - Falling edge ps2 clock detection shared between RX and TX modules
 *  - Peripheral Interrupt on Rx Pending
 ************************************************************************************/

module ps2_mmio (
	input wire i_clk,
    input wire i_rst,
    input wire i_sel,           // IO selection
    input wire i_we,            // IO write enable
    input wire i_re,            // IO read enable
    input wire [1:0] i_addr,    // Address used to identify the peripheral register
    input wire [15:0] i_wdata,  // Data to Write
    output wire [15:0] o_rdata, // Data Read
    output wire o_rdy,          // Feadback peripheral ready
    inout io_ps2_clk,       // PS2 - Clock device
	inout io_ps2_data,      // PS2 - Data device
    output wire o_irq_req       // PS2 - Interrupt Request
	
);
	
	
/*************************************************************************************
 * SECTION 1. DECLARE/DEFINE Variables/Registers/Wires
 ************************************************************************************/

/****************************************************************************
 * 1.1 DEFINE SFRs - MMIO REGISTERS' ADDRESSES  (LS nibble)
 ***************************************************************************/
	
	localparam [1:0] PS2DR = 2'b00;
	localparam [1:0] PS2SR = 2'b01;
	localparam [1:0] PS2CR = 2'b10; 
	
/****************************************************************************
 * 1.2 DECLARE SFRs -  MMIO REGISTERS
 ***************************************************************************/	
	/*    PS2DR    */
	reg [7:0] _rxd;
	reg [7:0] _txd;
	
	/*    PS2SR     */
	reg _rxne;
	reg _txe;
	reg _pe;
	reg _err;
	
	
	/*	  PS2CR	    */
	reg _rxie; 
	reg _txie; 
	reg _en; 
	

/****************************************************************************
 * 1.3 DECLARE WIRES / REGS
 ***************************************************************************/
	
	// handshake/ control Wires
	reg _tx_start; // pulled high for 1 cycle when CPU writes to PS2
	wire _tx_done; // flag - transmition has finished
	wire _rx_valid;// pulses high when RX module finishes a frame 
	wire [7:0] _rx_data_wire; 
	wire _rx_pe; // from rx the parity error
	wire _rx_err; // from rx the frame erro
	
	reg [15:0] _rdata;
	
	
	// --- 2 flip-flop synchronizers ---
    reg [1:0] _clk_sync;
    reg [1:0] _data_sync;

    wire _ps2_clk_s;   // synchronized CLK
    wire _ps2_data_s;  // synchronized DATA
    
    // --- Falling edge detection ---
    reg  _clk_prev;
    wire _fall_edge;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/****************************************************************************
 * 2.1 2 flip-flop synchronizers
 ***************************************************************************/
 always @(posedge i_clk) begin
        if (i_rst) begin
            _clk_sync  <= 2'b11;
            _data_sync <= 2'b11;
        end else begin
            _clk_sync  <= {_clk_sync[0],  io_ps2_clk};
            _data_sync <= {_data_sync[0], io_ps2_data};
        end
    end

    assign _ps2_clk_s  = _clk_sync[1];
    assign _ps2_data_s = _data_sync[1];

/****************************************************************************
 * 2.2 Falling edge detection
 ***************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _clk_prev <= 1'b1;
        end else begin
            _clk_prev <= _ps2_clk_s;
        end
    end

    assign _fall_edge = _clk_prev & ~_ps2_clk_s;

/****************************************************************************
 * 2.3 PS/2 RX/TX Instances
 ***************************************************************************/
    assign o_rdy = i_sel;
	assign o_irq_req = _rxie  & _rxne; 
	
	
	// declare the modulE HOST->DEVICE (receive)
	
	// declare the module DEVICE->HOST (transmit) 
	
	ps2_h2d u_ps2_h2d(
	
        .i_clk        (i_clk),
        .i_rst        (i_rst),
        .i_start      (_tx_start),
        .i_data       (_txd),
        .i_fall_edge  (_fall_edge),
        .i_ps2_data_s (_ps2_data_s),
        .io_ps2_clk   (io_ps2_clk),
        .io_ps2_data  (io_ps2_data),
        .o_tx_done    (_tx_done),
        .o_tx_busy    (),
        .o_tx_aerr    (_tx_aerr)
    );
	
	
/****************************************************************************
 * 2.2 MMIO Side Effects
 ***************************************************************************/
	
	always @(posedge i_clk) begin 
		if (i_rst) begin
			_tx_start <= 1'b0; 
			_txd <= 8'h00; 
			_rxd <= 8'h00;
			_rxne <= 1'b0;
			_txe <= 1'b1;
			_pe <= 1'b0; 
			_err <= 1'b0; 
			_rxie <= 1'b1; 
			_txie <= 1'b1; 
			_en <= 1'b0; 
		end 
		  else begin 
			_tx_start <= 1'b0;
			  if(_rx_valid) begin
			  _rxne <= 1'b1; 
			  _rxd <= _rx_data_wire; // here it has to be the result from the module of RX ps2
			  _pe   <= _rx_pe;
   		      _err  <= _rx_err;
   		      
			  end 
			  
			  if(_tx_done) _txe <= 1'b1;
			  
			  // write to PS2 SFRs
			  if(i_sel && i_we) begin
				case(i_addr)
					PS2DR:begin
						_txd <= i_wdata[7:0];
						_tx_start <= 1'b1;
						_txe <= 0; 
					end
					
					PS2CR: begin 
						_rxie <= i_wdata[0];
						_txie <= i_wdata[1];
						_en <= i_wdata[2]; 
					end
				endcase
			   end
				
						
			  if(i_sel && i_re && (i_addr == PS2DR)) begin 
				 _rxne <= 1'b0; 
				  
			  end 
			  
		  end
			
			end 
			
	
/****************************************************************************
 * 2.3 MMIO Readback
 ***************************************************************************/
    always @(*) begin
        if (!i_sel || !i_re) begin
            _rdata = 16'h0000;
        end else begin
            case (i_addr)
				PS2DR: _rdata = {8'h00, _rxd};
				PS2SR: _rdata = {12'b0,_err, _pe, _txe, _rxne};
				PS2CR: _rdata = {13'b0, _en, _txie, _rxie}; 
                default: _rdata = 16'h0000;
            endcase
        end
    end

    assign o_rdata = _rdata;

endmodule