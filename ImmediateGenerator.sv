module ImmediateGenerator(
    input  logic [31:0] instruction,
    output logic [31:0] imm_out
);
    always_comb begin
        case (instruction[6:0])
            7'b0010011: begin   // I-type (ADDI, SLTI, etc.)
                imm_out = {{20{instruction[31]}}, instruction[31:20]};
            end
            7'b0000011: begin   // Load instructions (LW, LB, etc.)
                imm_out = {{20{instruction[31]}}, instruction[31:20]};
            end
            7'b1100111: begin   // JALR
                imm_out = {{20{instruction[31]}}, instruction[31:20]};
            end
            7'b0100011: begin   // S-type (SW, SB, etc.)
                imm_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            7'b1100011: begin   // B-type (BEQ, BNE, etc.)
                imm_out = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            7'b0110111, 7'b0010111: begin // U-type (LUI, AUIPC)
                imm_out = {instruction[31:12], 12'b0};
            end
            7'b1101111: begin   // J-type (JAL)
                imm_out = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            default: imm_out = 32'b0;
        endcase
    end
endmodule