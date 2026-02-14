`timescale 1ns / 1ps

module Processor_TB;
    logic clk, reset;

    Processor UUT (.clk(clk), .reset(reset));

    initial begin
        clk = 1;
        forever #5 clk = ~clk; 
    end

    initial begin
        $display("--- شروع شبیه‌سازی پردازنده RISC-V ---");
        reset = 1;
        #15; 
        reset = 0;

        $monitor("Time=%0t | PC=%h | Instr=%h | ALU_Out=%h | WB_Data=%h", 
                 $time, UUT.pc_out, UUT.inst_id, UUT.alu_out_ex, UUT.wdata_wb);

        #1000;
        $display("--- پایان شبیه‌سازی ---");
        $stop;
    end

    initial begin
        $dumpfile("processor_waves.vcd");
        $dumpvars(0, Processor_TB);
    end
endmodule