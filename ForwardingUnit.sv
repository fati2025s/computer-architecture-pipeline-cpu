module ForwardingUnit(
    input  logic [4:0] rs1_ex, rs2_ex,
    input  logic [4:0] rd_mem, rd_wb, 
    input  logic       reg_wr_mem, reg_wr_wb,
    output logic [1:0] forwardA, forwardB
);
    always_comb begin
        if (reg_wr_mem && (rd_mem != 0) && (rd_mem == rs1_ex))
            forwardA = 2'b10;
        else if (reg_wr_wb && (rd_wb != 0) && (rd_wb == rs1_ex))
            forwardA = 2'b01; 
        else
            forwardA = 2'b00;
        
        if (reg_wr_mem && (rd_mem != 0) && (rd_mem == rs2_ex))
            forwardB = 2'b10;
        else if (reg_wr_wb && (rd_wb != 0) && (rd_wb == rs2_ex))
            forwardB = 2'b01;
        else
            forwardB = 2'b00;
    end
endmodule