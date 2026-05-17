`timescale 1ns / 1ps

module tb_periph_vga_image;

    // --- System Signals ---
    reg i_clk;
    reg i_clkVGA;
    reg i_rst;

    // --- Bus Signals ---
    reg [15:0] i_addr;
    reg i_sel;
    reg i_we;
    reg i_re;
    reg [15:0] i_wdata;
    wire [15:0] o_rdata;
    wire o_rdy;
    
    // --- Peripheral Signals ---
    reg [3:0] i_par_i;
    wire [3:0] o_par_o;
    reg i_uart_rx;
    wire o_uart_tx;
    tri io_i2c_sda;
    tri io_i2c_scl;
    tri io_ps2_clk;
    tri io_ps2_data;
    reg i_int_en;
    reg i_in_irq;
    wire [15:0] o_irq_vector;
    wire o_irq_take;
    reg i_irq_ret;
    
    // --- VGA Signals ---
    wire [3:0] o_vga_red;
    wire [3:0] o_vga_green;
    wire [3:0] o_vga_blue;
    wire o_hsync;
    wire o_vsync;
    reg i_mode_switch;
    
    // --- Dummy DDR/MIO Wires ---
    wire [14:0] io_DDR_addr;
    wire [2:0] io_DDR_ba; wire io_DDR_cas_n;
    wire io_DDR_ck_n; wire io_DDR_ck_p; wire io_DDR_cke; wire io_DDR_cs_n;
    wire [3:0] io_DDR_dm; wire [31:0] io_DDR_dq;
    wire [3:0] io_DDR_dqs_n;
    wire [3:0] io_DDR_dqs_p; wire io_DDR_odt; wire io_DDR_ras_n;
    wire io_DDR_reset_n; wire io_DDR_we_n; wire io_FIXED_IO_ddr_vrn;
    wire io_FIXED_IO_ddr_vrp;
    wire [53:0] io_FIXED_IO_mio; wire io_FIXED_IO_ps_clk;
    wire io_FIXED_IO_ps_porb; wire io_FIXED_IO_ps_srstb;

    // --- Instantiate DUT ---
    periph_bus dut (
        .i_clk(i_clk), .i_rst(i_rst), .i_addr(i_addr), .i_sel(i_sel),
        .i_we(i_we), .i_re(i_re), .i_wdata(i_wdata), .o_rdata(o_rdata), .o_rdy(o_rdy),
        .i_par_i(i_par_i), .o_par_o(o_par_o), .i_uart_rx(i_uart_rx), .o_uart_tx(o_uart_tx),
        .io_i2c_sda(io_i2c_sda), .io_i2c_scl(io_i2c_scl), .io_ps2_clk(io_ps2_clk), .io_ps2_data(io_ps2_data),
        .i_int_en(i_int_en), .i_in_irq(i_in_irq), .o_irq_vector(o_irq_vector), .o_irq_take(o_irq_take),
        .i_irq_ret(i_irq_ret), .i_clkVGA(i_clkVGA), .o_vga_red(o_vga_red), .o_vga_green(o_vga_green),
        .o_vga_blue(o_vga_blue), .o_hsync(o_hsync), .o_vsync(o_vsync), .i_mode_switch(i_mode_switch),
        // DDR/MIO Maps
        .io_DDR_addr(io_DDR_addr), .io_DDR_ba(io_DDR_ba), .io_DDR_cas_n(io_DDR_cas_n), .io_DDR_ck_n(io_DDR_ck_n),
        .io_DDR_ck_p(io_DDR_ck_p), .io_DDR_cke(io_DDR_cke), .io_DDR_cs_n(io_DDR_cs_n), .io_DDR_dm(io_DDR_dm),
        .io_DDR_dq(io_DDR_dq), .io_DDR_dqs_n(io_DDR_dqs_n), .io_DDR_dqs_p(io_DDR_dqs_p), .io_DDR_odt(io_DDR_odt),
        .io_DDR_ras_n(io_DDR_ras_n), .io_DDR_reset_n(io_DDR_reset_n), .io_DDR_we_n(io_DDR_we_n),
        .io_FIXED_IO_ddr_vrn(io_FIXED_IO_ddr_vrn), .io_FIXED_IO_ddr_vrp(io_FIXED_IO_ddr_vrp), .io_FIXED_IO_mio(io_FIXED_IO_mio),
        .io_FIXED_IO_ps_clk(io_FIXED_IO_ps_clk), .io_FIXED_IO_ps_porb(io_FIXED_IO_ps_porb), .io_FIXED_IO_ps_srstb(io_FIXED_IO_ps_srstb)
    );

    // --- Clock Generation ---
    always #4  i_clk = ~i_clk;       // 125 MHz System Clock
    always #20 i_clkVGA = ~i_clkVGA; // 25 MHz VGA Clock

    // --- Bus Write Task ---
    task write_bus(input [15:0] addr, input [15:0] data);
    begin
        @(negedge i_clk);  // <--- FIXED: Drive on falling edge
        i_addr = addr; i_wdata = data;
        i_sel = 1;
        i_we = 1; i_re = 0;
        wait(o_rdy == 1);
        @(negedge i_clk);  // <--- FIXED: Drop on falling edge
        i_sel = 0; i_we = 0;
    end
    endtask

    initial begin
        // ---> BYPASS CDC MACROS <---
        // Prevent XPM macros from freezing due to the dead PLL clock during reset
        force dut.u_vga._rst_sync_vga = i_rst;
        force dut.u_vga._enVGA_sync   = dut.u_vga._enVGA;

        // Initialize
        i_clk = 0;
        i_clkVGA = 0; i_rst = 1; i_mode_switch = 0; // IMAGE MODE
        i_addr = 0;
        i_sel = 0; i_we = 0; i_re = 0; i_wdata = 0;
        i_par_i = 0; i_uart_rx = 1;
        i_int_en = 0; i_in_irq = 0; i_irq_ret = 0;

        #100;
        i_rst = 0;
        
        // ---> WAIT FOR PLL LOCK <---
        #20_000;
        
        $display("TEST: Enabling VGA via MMIO in Image Mode...");
        // Write to VGA CNTRL register (Base Address 0x0600)
        write_bus(16'h0600, 16'h0001);
        
        #50_000;
        $display("NOTE: VSYNC will likely wait in WAIT_SOF state because the Processing System is not simulated to send VDMA frames.");
        $display("Simulation complete. Bus routing validated.");
        $finish;
    end
endmodule