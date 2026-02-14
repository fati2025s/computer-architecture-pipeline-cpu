module WriteBack(
    input  logic [31:0] A, B, C, 
    input  logic [1:0]  wb_sel,
    output logic [31:0] wdata
);
    always_comb begin
        case (wb_sel)
            2'b00:   wdata = A; // ALU
            2'b01:   wdata = B; // Load
            2'b10:   wdata = C; // JAL
            default: wdata = A;
        endcase
    end
endmodule