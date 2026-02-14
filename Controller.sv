module Controller(
    input  logic [31:0] instruction,
    output logic [3:0]  alu_op, 
    output logic [2:0]  mask, br_type, 
    output logic        reg_wr, sel_A, sel_B, rd_en, wr_en, 
    output logic [1:0]  wb_sel
);
    logic [2:0] func3;
    logic [6:0] func7;
    logic [6:0] opcode;
    
    assign func3  = instruction[14:12];
    assign func7  = instruction[31:25];
    assign opcode = instruction[6:0];

    always_comb begin
        alu_op  = 4'd0;
        mask    = 3'd0;
        br_type = 3'd0;
        reg_wr  = 1'b0;
        sel_A   = 1'b0; 
        sel_B   = 1'b0; 
        rd_en   = 1'b0;
        wr_en   = 1'b0;
        wb_sel  = 2'd0; 

        case (opcode)
            7'b0110011: begin   // R-type (ADD, SUB, AND, ...)
                reg_wr = 1; sel_A = 0; sel_B = 0; wb_sel = 0;
                case (func3)
                    3'b000: alu_op = (func7[5]) ? 4'd9 : 4'd0; // SUB : ADD
                    3'b001: alu_op = 4'd1; // SLL
                    3'b010: alu_op = 4'd2; // SLT
                    3'b011: alu_op = 4'd3; // SLTU
                    3'b100: alu_op = 4'd4; // XOR
                    3'b101: alu_op = (func7[5]) ? 4'd6 : 4'd5; // SRA : SRL
                    3'b110: alu_op = 4'd7; // OR
                    3'b111: alu_op = 4'd8; // AND
                endcase
            end

            7'b0010011: begin   // I-type (ADDI, ORI, ...)
                reg_wr = 1; sel_A = 0; sel_B = 1; wb_sel = 0;
                case (func3)
                    3'b000: alu_op = 4'd0; // ADDI
                    3'b010: alu_op = 4'd2; // SLTI
                    3'b011: alu_op = 4'd3; // SLTUI
                    3'b100: alu_op = 4'd4; // XORI
                    3'b110: alu_op = 4'd7; // ORI
                    3'b111: alu_op = 4'd8; // ANDI
                    3'b001: alu_op = 4'd1; // SLLI
                    3'b101: alu_op = (func7[5]) ? 4'd6 : 4'd5; // SRAI : SRLI
                endcase
            end

            7'b0000011: begin   // Load (LW, LB, ...)
                reg_wr = 1; sel_A = 0; sel_B = 1; rd_en = 1; wb_sel = 1;
                alu_op = 4'd0; mask = func3;
            end

            7'b0100011: begin   // Store (SW, SB, ...)
                reg_wr = 0; sel_A = 0; sel_B = 1; wr_en = 1;
                alu_op = 4'd0; mask = func3;
            end         

            7'b1100011: begin   // Branch (BEQ, BNE, ...)
                reg_wr = 0; sel_A = 1; sel_B = 1; // PC + Imm for branch target
                br_type = func3;
            end         

            7'b0110111: begin   // LUI
                reg_wr = 1; sel_B = 1; alu_op = 4'd0; wb_sel = 0; // LUI معمولاً با جمع با صفر یا لود مستقیم هندل می‌شود
            end

            7'b0010111: begin   // AUIPC
                reg_wr = 1; sel_A = 1; sel_B = 1; alu_op = 4'd0; wb_sel = 0;
            end

            7'b1101111: begin   // JAL
                reg_wr = 1; wb_sel = 2; // Write PC+4
            end

            7'b1100111: begin   // JALR
                reg_wr = 1; sel_A = 0; sel_B = 1; alu_op = 4'd0; wb_sel = 2;
            end

            default: ;
        endcase
    end
endmodule