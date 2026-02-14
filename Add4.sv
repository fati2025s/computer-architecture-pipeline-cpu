module Add4 (
    input  logic [31:0] a,
    output logic [31:0] b
);
    assign b = a + 32'd4;
endmodule