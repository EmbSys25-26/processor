`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
//  wdt.v  –  MMIO wrapper for the watchdog timer
//
//  Register map (i_addr):
//    ADDR_CTRL   (2'b00)  R/W  [0]=WEN [1]=RSTEN [2]=IEN [3]=WDTIF(w1c) [4]=RSTF(w1c)
//    ADDR_PS     (2'b01)  R/W  Prescaler limit
//    ADDR_RELOAD (2'b10)  R/W  Reload value
//    ADDR_CMD    (2'b11)  W    KEY: 0xA5A5=KICK, 0xDEAD=STOP  /  R: current counter
// -----------------------------------------------------------------------------

module wdt (
    input  wire        i_clk,
    input  wire        i_rst,
    input  wire        i_rst_ext,
    input  wire        i_sel,
    input  wire        i_we,
    input  wire        i_re,
    input  wire [1:0]  i_addr,
    input  wire [15:0] i_wdata,
    output wire [15:0] o_rdata,
    output wire        o_rdy,
    output wire        o_int_req,
    output wire        o_rst_req
);

/*************************************************************************************
 * SECTION 1. LOCAL PARAMETERS – register address map
 ************************************************************************************/
    localparam ADDR_CTRL   = 2'b00;
    localparam ADDR_PS     = 2'b01;
    localparam ADDR_RELOAD = 2'b10;
    localparam ADDR_CMD    = 2'b11;

    // Magic KEY values
    localparam KEY_KICK = 16'hA5A5;
    localparam KEY_STOP = 16'hDEAD;

/*************************************************************************************
 * SECTION 2. MMIO DECODE – wires derived from the bus interface
 ************************************************************************************/
    wire _bus_write = i_sel && i_we;

    // Key commands on the CMD register
    wire _kick = _bus_write && (i_addr == ADDR_CMD) && (i_wdata == KEY_KICK);
    wire _stop = _bus_write && (i_addr == ADDR_CMD) && (i_wdata == KEY_STOP);

    // CTRL register write strobe
    wire _ctrl_write = _bus_write && (i_addr == ADDR_CTRL);

    // Write-1-to-clear strobes for status flags
    wire _clr_wdtif = _ctrl_write && i_wdata[3];
    wire _clr_rstf  = _ctrl_write && i_wdata[4];

    // Staged register values (written to core on config-reg write)
    reg [15:0] _prescaler_limit_reg;
    reg [15:0] _reload_reg;

    always @(posedge i_clk) begin
        if (i_rst_ext) begin
            _prescaler_limit_reg <= 16'h0000;
            _reload_reg          <= 16'h0000;
        end else if (i_rst) begin
            _prescaler_limit_reg <= 16'h0000;
            _reload_reg          <= 16'h0000;
        end else if (_bus_write) begin
            if (i_addr == ADDR_PS)     _prescaler_limit_reg <= i_wdata;
            if (i_addr == ADDR_RELOAD) _reload_reg          <= i_wdata;
        end
    end

/*************************************************************************************
 * SECTION 3. CORE INSTANTIATION
 ************************************************************************************/
    wire        _core_wen;
    wire        _core_rsten;
    wire        _core_ien;
    wire [15:0] _core_reload;
    wire [15:0] _core_prescaler_limit;
    wire [15:0] _core_cnt;
    wire        _core_wdtif;
    wire        _core_rstf;
    wire        _core_rst_pulse;

    wdt_core u_wdt_core (
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_rst_ext          (i_rst_ext),

        // Control inputs
        .i_wen              (i_wdata[0]),
        .i_rsten            (i_wdata[1]),
        .i_ien              (i_wdata[2]),
        .i_reload           (_reload_reg),
        .i_prescaler_limit  (_prescaler_limit_reg),

        // Commands
        .i_kick             (_kick),
        .i_stop             (_stop),
        .i_ctrl_write       (_ctrl_write),

        // Write-1-to-clear
        .i_clr_wdtif        (_clr_wdtif),
        .i_clr_rstf         (_clr_rstf),

        // Outputs
        .o_wen              (_core_wen),
        .o_rsten            (_core_rsten),
        .o_ien              (_core_ien),
        .o_reload           (_core_reload),
        .o_prescaler_limit  (_core_prescaler_limit),
        .o_cnt              (_core_cnt),
        .o_wdtif            (_core_wdtif),
        .o_rstf             (_core_rstf),
        .o_rst_pulse        (_core_rst_pulse)
    );

/*************************************************************************************
 * SECTION 4. READ-BACK MUX
 ************************************************************************************/
    reg [15:0] _rdata;

    always @(*) begin
        if (!i_sel || !i_re) begin
            _rdata = 16'h0000;
        end else begin
            case (i_addr)
                ADDR_CTRL:   _rdata = {11'b0, _core_rstf, _core_wdtif,
                                       _core_ien, _core_rsten, _core_wen};
                ADDR_PS:     _rdata = _core_prescaler_limit;
                ADDR_RELOAD: _rdata = _core_reload;
                ADDR_CMD:    _rdata = _core_cnt;
                default:     _rdata = 16'h0000;
            endcase
        end
    end

/*************************************************************************************
 * SECTION 5. OUTPUT ASSIGNMENTS
 ************************************************************************************/
    assign o_rdata   = _rdata;
    assign o_rdy     = i_sel;
    assign o_int_req = _core_wdtif;
    assign o_rst_req = _core_rst_pulse;

endmodule
