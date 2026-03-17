`timescale 1ns / 1ps
`include "constants.vh"

module tb_vga();

    reg clk_pixel;
    reg rst;
    
   
    initial clk_pixel = 0;
    always #20 clk_pixel = ~clk_pixel;   // 25 MHz clock (period = 40 ns)
    
    // AXI4-Stream signals
    reg  [15:0] axis_tdata;
    reg         axis_tvalid;
    wire        axis_tready;
    reg         axis_tlast;
    
    // VGA outputs
    wire [`VGA_CHANNEL_SIZE:0] vga_red;
    wire [`VGA_CHANNEL_SIZE:0] vga_green;
    wire [`VGA_CHANNEL_SIZE:0] vga_blue;
    wire hsync;
    wire vsync;
    wire endLine;
    
        m_hsync_vga u_hsync (
        .i_clk          (clk_pixel),
        .i_rst          (rst),
        .i_enVGA        (1'b1),
        .i_axis_tdata   (axis_tdata),
        .i_axis_tvalid  (axis_tvalid),
        .o_axis_tready  (axis_tready),
        .o_endLine      (endLine),
        .o_vga_red      (vga_red),
        .o_vga_green    (vga_green),
        .o_vga_blue     (vga_blue),
        .o_hsync        (hsync)
    );
    
       m_vsync_vga u_vsync (
        .i_clk    (clk_pixel),
        .i_rst    (rst),
        .i_enVGA  (1'b1),
        .i_endLine(endLine),
        .o_vsync  (vsync)
    );
       
    integer pixel_count;
    
    initial begin
        rst         = 1;
        axis_tvalid = 0;
        axis_tdata  = 16'h0000;
        axis_tlast  = 0;
        pixel_count = 0;
    
        repeat(10) @(posedge clk_pixel);
        rst = 0;
    
        // Começa a enviar pixels - simula o VDMA
        // Envia pixels de teste: vermelho puro = 0xF000
        forever begin
            @(posedge clk_pixel);
            
            // VDMA has valid pixel
            axis_tvalid = 1'b1;
            
            // first 320 pixels = red, then always bue
            if (pixel_count < 320)
                axis_tdata = 16'hF000;  // red
            else
                axis_tdata = 16'h00F0;  // blue
    
              if (axis_tready && axis_tvalid) begin
                pixel_count = pixel_count + 1;
                
                if (pixel_count % 640 == 639)
                    axis_tlast = 1'b1;
                else
                    axis_tlast = 1'b0;
                    
                if (pixel_count >= 640*480)
                    pixel_count = 0;
            end
        end
    end
      
endmodule

