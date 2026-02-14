module ALU(
    input  logic [31:0] A, B,
    input  logic [3:0]  alu_op,
    output logic [31:0] C
);
    always_comb begin
        case (alu_op)
            4'd0:    C = A + B;                         // ADD
            4'd1:    C = A << B[4:0];                   // SLL
            4'd2:    C = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT
            4'd3:    C = (A < B) ? 32'd1 : 32'd0;       // SLTU
            4'd4:    C = A ^ B;                         // XOR
            4'd5:    C = A >> B[4:0];                   // SRL
            4'd6:    C = $signed(A) >>> B[4:0];         // SRA
            4'd7:    C = A | B;                         // OR
            4'd8:    C = A & B;                         // AND
            4'd9:    C = A - B;                         // SUB
            default: C = 32'd0;
        endcase
    end
endmodule