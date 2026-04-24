`timescale 1ns / 1ps

module tb_periph_vga_char;

    // --- System Signals ---
    reg i_clk = 0;
    reg i_clkVGA = 0;
    reg i_rst = 1;
    
    // --- Bus Signals ---
    reg [15:0] i_addr = 0;
    reg i_sel = 0;
    reg i_we = 0;
    reg i_re = 0;
    reg [15:0] i_wdata = 0;
    wire [15:0] o_rdata;
    wire o_rdy;
    
    // --- Peripheral Signals ---
    reg [3:0] i_par_i = 0;
    wire [3:0] o_par_o;
    reg i_uart_rx = 1;
    wire o_uart_tx;
    tri io_i2c_sda;
    tri io_i2c_scl;
    tri io_ps2_clk;
    tri io_ps2_data;
    reg i_int_en = 0;
    reg i_in_irq = 0;
    wire [15:0] o_irq_vector;
    wire o_irq_take;
    reg i_irq_ret = 0;
    
    // --- VGA Signals ---
    wire [3:0] o_vga_red;
    wire [3:0] o_vga_green;
    wire [3:0] o_vga_blue;
    wire o_hsync;
    wire o_vsync;
    reg i_mode_switch = 1; // 1 = Text Mode
    
    // --- Dummy DDR/MIO Wires ---
    wire [14:0] io_DDR_addr; wire [2:0] io_DDR_ba; wire io_DDR_cas_n;
    wire io_DDR_ck_n; wire io_DDR_ck_p; wire io_DDR_cke; wire io_DDR_cs_n;
    wire [3:0] io_DDR_dm; wire [31:0] io_DDR_dq; wire [3:0] io_DDR_dqs_n;
    wire [3:0] io_DDR_dqs_p; wire io_DDR_odt; wire io_DDR_ras_n;
    wire io_DDR_reset_n; wire io_DDR_we_n; wire io_FIXED_IO_ddr_vrn;
    wire io_FIXED_IO_ddr_vrp; wire [53:0] io_FIXED_IO_mio; wire io_FIXED_IO_ps_clk;
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
        .io_DDR_addr(io_DDR_addr), .io_DDR_ba(io_DDR_ba), .io_DDR_cas_n(io_DDR_cas_n), .io_DDR_ck_n(io_DDR_ck_n),
        .io_DDR_ck_p(io_DDR_ck_p), .io_DDR_cke(io_DDR_cke), .io_DDR_cs_n(io_DDR_cs_n), .io_DDR_dm(io_DDR_dm),
        .io_DDR_dq(io_DDR_dq), .io_DDR_dqs_n(io_DDR_dqs_n), .io_DDR_dqs_p(io_DDR_dqs_p), .io_DDR_odt(io_DDR_odt),
        .io_DDR_ras_n(io_DDR_ras_n), .io_DDR_reset_n(io_DDR_reset_n), .io_DDR_we_n(io_DDR_we_n),
        .io_FIXED_IO_ddr_vrn(io_FIXED_IO_ddr_vrn), .io_FIXED_IO_ddr_vrp(io_FIXED_IO_ddr_vrp), .io_FIXED_IO_mio(io_FIXED_IO_mio),
        .io_FIXED_IO_ps_clk(io_FIXED_IO_ps_clk), .io_FIXED_IO_ps_porb(io_FIXED_IO_ps_porb), .io_FIXED_IO_ps_srstb(io_FIXED_IO_ps_srstb)
    );

    // --- Clock Generation ---
    always #4  i_clk    = ~i_clk;        // 125 MHz System Clock
    always #20 i_clkVGA = ~i_clkVGA;     // 25 MHz VGA Clock


    // --- Bus Write Task ---
        task write_bus(input [15:0] addr, input [15:0] data);
        begin
            @(negedge i_clk); // Drive on falling edge
            i_addr = addr; 
            i_wdata = data;
            i_sel = 1; 
            i_we = 1; 
            i_re = 0;
            
            wait(o_rdy == 1);
            
            @(negedge i_clk); // Drop signals on the next falling edge
            i_sel = 0; 
            i_we = 0;
        end
        endtask


    initial begin
            // 1. Reset the system
            #100;
            i_rst = 0;
            
            // 2. WAIT FOR THE PLL TO LOCK (CRITICAL!)
            // We must wait long enough for the wrapper to wake up and start generating _clk_pixel.
            // 20 microseconds is safely beyond the typical Xilinx lock time.
            #20_000;
    
            // 3. NOW it is safe to write to the bus. The clocks are alive and the CDC macros will work.
            $display("TEST: Enabling VGA and Auto-Increment...");
            write_bus(16'h0600, 16'h0003); // Write to CNTRL
            
            #100;
            
            $display("TEST: Sending 'O' and 'K' over the MMIO Bus...");
            write_bus(16'h0604, 16'h004F); // Write 'O'
            #100;
            write_bus(16'h0604, 16'h004B); // Write 'K'
    
            // 4. Run long enough to see the lines draw
            #200_000_0;
            $finish;
        end
        
endmodule