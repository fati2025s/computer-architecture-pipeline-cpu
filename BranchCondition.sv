module BranchCondition(
    input  logic [31:0] rs1, rs2, 
    input  logic [2:0]  br_type, 
    input  logic [6:0]  opcode,
    output logic        br_taken
);
    logic branch, jump;

    always_comb begin
        if (opcode == 7'b1101111 || opcode == 7'b1100111) 
            jump = 1'b1;
        else 
            jump = 1'b0;
    
        branch = 1'b0;
        if (opcode == 7'b1100011) begin
            case (br_type)
                3'b000: branch = (rs1 == rs2);                         // BEQ
                3'b001: branch = (rs1 != rs2);                         // BNE
                3'b100: branch = ($signed(rs1) <  $signed(rs2));       // BLT
                3'b101: branch = ($signed(rs1) >= $signed(rs2));       // BGE
                3'b110: branch = (rs1 < rs2);                          // BLTU
                3'b111: branch = (rs1 >= rs2);                         // BGEU
                default: branch = 1'b0;
            endcase
        end
    end

    assign br_taken = (branch | jump);

endmodule