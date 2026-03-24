`timescale 1ns / 1ps

module tb_periph_bus_i2s;

    // Clock and Reset Signals
    reg clk;          // 100 MHz (simulates the system i_clk)
    reg rst;
    reg i2s_mclk;     // 12.288 MHz (simulates the MMCM output)

    // Bus Signals (Simulating the CPU)
    reg [15:0] bus_addr;
    reg        bus_sel;
    reg        bus_we;
    reg        bus_re;
    reg [15:0] bus_wdata;
    wire [15:0] bus_rdata;
    wire        bus_rdy;

    // Interrupt Controller Signals
    wire        irq_take;
    wire [15:0] irq_vector;
    reg         in_irq;
    reg         int_en;
    reg         irq_ret;

    // Top-level Signals (I2S and I2C)
    wire i2s_mclk_out;
    wire i2s_bclk;
    wire i2s_lrclk;
    wire i2s_pbdat;
    wire i2s_sda;
    wire i2s_scl;

    // I2C Pull-ups (Crucial for open-drain simulation)
    assign (weak1, weak0) i2s_sda = 1'b1;
    assign (weak1, weak0) i2s_scl = 1'b1;

    // ---------------------------------------------------------
    // PERIPH_BUS Instance
    // ---------------------------------------------------------
    periph_bus dut (
        .i_clk(clk),
        .i_rst(rst),
        .i_addr(bus_addr),
        .i_sel(bus_sel),
        .i_we(bus_we),
        .i_re(bus_re),
        .i_wdata(bus_wdata),
        .o_rdata(bus_rdata),
        .o_rdy(bus_rdy),
        .i_par_i(4'b0000),
        .o_par_o(),
        .i_uart_rx(1'b1),
        .o_uart_tx(),
        .io_i2c_sda(),
        .io_i2c_scl(),
        .i_i2s_mclk(i2s_mclk),
        .o_i2s_mclk(i2s_mclk_out),
        .o_i2s_bclk(i2s_bclk),
        .o_i2s_lrclk(i2s_lrclk),
        .o_i2s_pbdat(i2s_pbdat),
        .io_i2s_sda(i2s_sda),
        .io_i2s_scl(i2s_scl),
        .i_int_en(int_en),
        .i_in_irq(in_irq),
        .o_irq_vector(irq_vector),
        .o_irq_take(irq_take),
        .i_irq_ret(irq_ret)
    );

    // ---------------------------------------------------------
    // Clock Generation
    // ---------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz (T=10ns)

    initial i2s_mclk = 0;
    always #40.69 i2s_mclk = ~i2s_mclk; // 12.288 MHz (T~=81.38ns)

    // ---------------------------------------------------------
    // Tasks to simulate CPU MMIO accesses
    // ---------------------------------------------------------
    task write_mmio(input [15:0] addr, input [15:0] data);
        begin
            @(posedge clk);
            bus_addr  <= addr;
            bus_wdata <= data;
            bus_sel   <= 1'b1;
            bus_we    <= 1'b1;
            bus_re    <= 1'b0;
            @(posedge clk);
            bus_sel   <= 1'b0;
            bus_we    <= 1'b0;
        end
    endtask

    task read_mmio(input [15:0] addr, output [15:0] data);
        begin
            @(posedge clk);
            bus_addr <= addr;
            bus_sel  <= 1'b1;
            bus_we   <= 1'b0;
            bus_re   <= 1'b1;
            @(posedge clk);
            data = bus_rdata;
            bus_sel  <= 1'b0;
            bus_re   <= 1'b0;
        end
    endtask

    // ---------------------------------------------------------
    // Test Sequence (Stimulus)
    // ---------------------------------------------------------
    reg [15:0] read_val;
    integer i;

    initial begin
        // Initial conditions
        rst = 1;
        bus_sel = 0; bus_we = 0; bus_re = 0;
        bus_addr = 0; bus_wdata = 0;
        int_en = 1; in_irq = 0; irq_ret = 0;

        #100;
        @(posedge clk);
        rst = 0;
        #100;

        $display("--- STARTING I2S FIFO MMIO TEST ---");

        // 1. Trigger I2C Initialization (I2C_INIT = 0x8708)
        $display("1. Sending I2C initialization command...");
        write_mmio(16'h8708, 16'h0001); 

        // Poll STATUS register until init is done (Bit 1)
        read_val = 16'h0000;
        while ((read_val & 16'h0002) == 0) begin
            #50_000; // Wait 50us between reads
            read_mmio(16'h8704, read_val); 
        end
        $display("-> I2C Initialization Complete! (STATUS bit 1 = 1)");

        // 2. Pre-fill the FIFO completely before starting (16 samples)
        $display("2. Pre-filling the FIFO with 16 audio samples...");
        for (i = 0; i < 16; i = i + 1) begin
            // Writing sequential values (A000, A001...) to track them in waveform
            write_mmio(16'h8700, 16'hA000 + i); // TX_LEFT
            write_mmio(16'h8702, 16'hB000 + i); // TX_RIGHT (Pushes to FIFO)
        end

        // 3. Enable I2S TX and Interrupts
        $display("3. Enabling I2S_TX and Interrupts...");
        write_mmio(16'h8706, 16'h0003); 

        // 4. Wait for the FIFO to become half-empty (Triggering IRQ)
        $display("4. Waiting for I2S to consume 8 samples (Hardware IRQ expected)...");
        wait(irq_take == 1'b1 && irq_vector == 16'h00C0);
        $display("-> I2S Interrupt received! (FIFO is half-empty)");

        // 5. Write a burst of 8 new samples in the Interrupt Service Routine
        $display("5. Simulating CPU bursting 8 new samples to refill FIFO...");
        for (i = 0; i < 8; i = i + 1) begin
            write_mmio(16'h8700, 16'hC000 + i);
            write_mmio(16'h8702, 16'hD000 + i); 
        end

        // Wait a bit to observe the new data shifting out
        #100_000;
        $display("--- TEST COMPLETED SUCCESSFULLY ---");
        $finish;
    end

endmodule