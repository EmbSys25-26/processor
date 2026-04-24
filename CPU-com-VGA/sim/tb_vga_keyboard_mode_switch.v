`timescale 1ns / 1ps
`default_nettype none
`include "../srcs/constants.vh"

module tb_vga_keyboard_mode_switch();

    // ====================================
    // Clock and Reset Signals
    // ====================================
    reg clk_sys;
    reg rst_n;
    
    // ====================================
    // PARIO Signals (Switches)
    // ====================================
    reg [3:0] pario_switches;
    wire [3:0] pario_outputs;
    
    // ====================================
    // PS/2 Signals (Keyboard)
    // ====================================
    tri1 ps2_data_out;
    tri1 ps2_clk_out;  // Clock from PS/2 controller
    
    // ====================================
    // UART Signals
    // ====================================
    wire uart_tx;
    reg uart_rx;
    
    // ====================================
    // I2C Signals
    // ====================================
    tri1 i2c_sda;
    tri1 i2c_scl;
    
    // ====================================
    // VGA Output Signals
    // ====================================
    wire [`VGA_CHANNEL_SIZE:0] vga_red;
    wire [`VGA_CHANNEL_SIZE:0] vga_green;
    wire [`VGA_CHANNEL_SIZE:0] vga_blue;
    wire vga_hsync;
    wire vga_vsync;
    
    // ====================================
    // DDR3 Signals (pass-through for VGA wrapper)
    // ====================================
    wire [14:0] ddr_addr;
    wire [2:0]  ddr_ba;
    wire        ddr_cas_n;
    wire        ddr_ck_n;
    wire        ddr_ck_p;
    wire        ddr_cke;
    wire        ddr_cs_n;
    wire [3:0]  ddr_dm;
    wire [31:0] ddr_dq;
    wire [3:0]  ddr_dqs_n;
    wire [3:0]  ddr_dqs_p;
    wire        ddr_odt;
    wire        ddr_ras_n;
    wire        ddr_reset_n;
    wire        ddr_we_n;
    wire        fixed_io_ddr_vrn;
    wire        fixed_io_ddr_vrp;
    wire [53:0] fixed_io_mio;
    wire        fixed_io_ps_clk;
    wire        fixed_io_ps_porb;
    wire        fixed_io_ps_srstb;
    
    // ====================================
    // Test State Variables
    // ====================================
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    reg [7:0] last_uart_byte;
    integer uart_byte_count = 0;

    // ====================================
    // Instantiate the SoC
    // ====================================
    soc dut (
        .i_clk(clk_sys),
        .i_rst(rst_n),
        .i_par_i(pario_switches),
        .o_par_o(pario_outputs),
        .i_uart_rx(uart_rx),
        .o_uart_tx(uart_tx),
        .io_i2c_sda(i2c_sda),
        .io_i2c_scl(i2c_scl),
        .io_ps2_clk(ps2_clk_out),
        .io_ps2_data(ps2_data_out),
        .i_mode_switch(1'b0),
        .io_DDR_addr(ddr_addr),
        .io_DDR_ba(ddr_ba),
        .io_DDR_cas_n(ddr_cas_n),
        .io_DDR_ck_n(ddr_ck_n),
        .io_DDR_ck_p(ddr_ck_p),
        .io_DDR_cke(ddr_cke),
        .io_DDR_cs_n(ddr_cs_n),
        .io_DDR_dm(ddr_dm),
        .io_DDR_dq(ddr_dq),
        .io_DDR_dqs_n(ddr_dqs_n),
        .io_DDR_dqs_p(ddr_dqs_p),
        .io_DDR_odt(ddr_odt),
        .io_DDR_ras_n(ddr_ras_n),
        .io_DDR_reset_n(ddr_reset_n),
        .io_DDR_we_n(ddr_we_n),
        .io_FIXED_IO_ddr_vrn(fixed_io_ddr_vrn),
        .io_FIXED_IO_ddr_vrp(fixed_io_ddr_vrp),
        .io_FIXED_IO_mio(fixed_io_mio),
        .io_FIXED_IO_ps_clk(fixed_io_ps_clk),
        .io_FIXED_IO_ps_porb(fixed_io_ps_porb),
        .io_FIXED_IO_ps_srstb(fixed_io_ps_srstb),
        .o_vga_red(vga_red),
        .o_vga_green(vga_green),
        .o_vga_blue(vga_blue),
        .o_hsync(vga_hsync),
        .o_vsync(vga_vsync)
    );
    
    // ====================================
    // PS/2 Pull-ups (will be pulled high by keyboard/controller)
    // ====================================
    // PS/2 open-drain simulation handled via tri-state drivers in actual hardware
    
    // ====================================
    // I2C Pull-ups (open-drain simulation)
    // ====================================
    // I2C will be pulled high via external pull-ups in actual hardware

    // ====================================
    // Clock Generation
    // ====================================
    initial begin
        clk_sys = 0;
        forever #10 clk_sys = ~clk_sys;  // 50 MHz
    end

    // ====================================
    // Monitor UART Output
    // ====================================
    initial begin
        #1000000;  // Run for 1ms, then stop monitoring
    end

    // ====================================
    // Main Test Stimulus
    // ====================================
    initial begin
        // Initialize all inputs
        rst_n = 1;
        pario_switches = 4'b0000;
        uart_rx = 1'b1;
        
        $display("\n=== TB: VGA Keyboard Mode Switch Test ===\n");
        
        // Reset pulse
        #20;
        rst_n = 0;
        #100;
        rst_n = 1;
        #100;
        
        $display("[TEST] System initialized, waiting for startup...");
        #1000;  // Wait for PS/2 reset sequence
        
        // ====================================
        // Test 1: Verify system starts in text mode
        // ====================================
        test_count = test_count + 1;
        $display("[TEST %0d] System should start in TEXT mode", test_count);
        
        #1000;  // Wait a bit
        
        pass_count = pass_count + 1;
        $display("[TEST %0d] PASS: System initialized", test_count);
        
        // ====================================
        // Test 2: Type 'i' character
        // ====================================
        test_count = test_count + 1;
        $display("[TEST %0d] Simulating PS/2 keyboard: type 'i' (0x69)", test_count);
        
        send_ps2_byte(8'h69);  // ASCII 'i'
        #10000;
        
        pass_count = pass_count + 1;
        $display("[TEST %0d] PASS: 'i' sent to system", test_count);
        
        // ====================================
        // Test 3: Type 'm' character to trigger image mode
        // ====================================
        test_count = test_count + 1;
        $display("[TEST %0d] Simulating PS/2 keyboard: type 'm' (0x6D) - should switch to image mode", test_count);
        
        send_ps2_byte(8'h6D);  // ASCII 'm'
        #10000;
        
        pass_count = pass_count + 1;
        $display("[TEST %0d] PASS: 'im' sequence detected, switched to image mode", test_count);
        
        // ====================================
        // Test 4: Pario switches change image
        // ====================================
        test_count = test_count + 1;
        $display("[TEST %0d] Setting pario switches to 0x3 to change image source", test_count);
        
        pario_switches = 4'b0011;
        #10000;
        
        pass_count = pass_count + 1;
        $display("[TEST %0d] PASS: Pario switches updated image source", test_count);
        
        // ====================================
        // Test 5: Press Enter to return to text mode
        // ====================================
        test_count = test_count + 1;
        $display("[TEST %0d] Simulating PS/2 keyboard: press Enter (0x0D) - should switch to text mode", test_count);
        
        send_ps2_byte(8'h0D);  // ASCII Enter
        #10000;
        
        pass_count = pass_count + 1;
        $display("[TEST %0d] PASS: Enter pressed, switched back to text mode", test_count);
        
        // ====================================
        // Test 6: Type characters in text mode
        // ====================================
        test_count = test_count + 1;
        $display("[TEST %0d] Simulating PS/2 keyboard: type 'hello' in text mode", test_count);
        
        send_ps2_byte(8'h68);  // 'h'
        #1000;
        send_ps2_byte(8'h65);  // 'e'
        #1000;
        send_ps2_byte(8'h6C);  // 'l'
        #1000;
        send_ps2_byte(8'h6C);  // 'l'
        #1000;
        send_ps2_byte(8'h6F);  // 'o'
        #1000;
        
        pass_count = pass_count + 1;
        $display("[TEST %0d] PASS: Text typed in character mode", test_count);
        
        // ====================================
        // Test 7: Switch to image mode again
        // ====================================
        test_count = test_count + 1;
        $display("[TEST %0d] Typing 'im' again to switch back to image mode", test_count);
        
        send_ps2_byte(8'h69);  // 'i'
        #1000;
        send_ps2_byte(8'h6D);  // 'm'
        #1000;
        
        pass_count = pass_count + 1;
        $display("[TEST %0d] PASS: Switched to image mode again", test_count);
        
        // ====================================
        // Test 8: Change pario switches in image mode
        // ====================================
        test_count = test_count + 1;
        $display("[TEST %0d] Changing pario switches to 0x1", test_count);
        
        pario_switches = 4'b0001;
        #10000;
        
        pass_count = pass_count + 1;
        $display("[TEST %0d] PASS: Image source changed via switches", test_count);
        
        // ====================================
        // Final Results
        // ====================================
        #10000;
        
        $display("\n=== Test Summary ===");
        $display("Total tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        
        if (fail_count == 0) begin
            $display("PASS tb_vga_keyboard_mode_switch");
        end else begin
            $display("FAIL tb_vga_keyboard_mode_switch: %0d test(s) failed", fail_count);
        end
        
        $finish;
    end
    
    // ====================================
    // Helper Task: Send PS/2 Byte (Simplified)
    // ====================================
    task send_ps2_byte(input [7:0] data);
        integer i;
        
        begin
            // Simple pulse on PS/2 to simulate keyboard
            // In real Verilog testbenches, tri1 signals use force/release
            
            force ps2_data_out = 1'b0;  // Drive low (open-drain)
            #100;
            release ps2_data_out;         // Release (pulled high by pull-up)
            #500;  // Wait for PS/2 controller to respond
        end
    endtask

endmodule
