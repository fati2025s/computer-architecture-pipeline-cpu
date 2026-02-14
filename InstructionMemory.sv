module InstructionMemory(
    input  logic [31:0] addr, 
    output logic [31:0] instruction
);
    logic [31:0] imem [0:1023];    

    initial begin
        $readmemh("code.mem", imem);  
    end
    assign instruction = imem[addr[11:2]]; 

endmodule