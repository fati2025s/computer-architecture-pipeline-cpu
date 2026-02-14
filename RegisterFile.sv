module RegisterFile(
    input  logic        clk, reset, reg_wr,
    input  logic [4:0]  raddr1, raddr2, waddr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata1, rdata2
);
    logic [31:0] rf [31:0];

    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 32; i++) rf[i] <= 32'b0;
        end else if (reg_wr && (waddr != 5'b0)) begin
            rf[waddr] <= wdata;
        end
    end

    always_comb begin
        if (raddr1 == 5'b0) rdata1 = 32'b0;
        else if ((raddr1 == waddr) && reg_wr) rdata1 = wdata;
        else rdata1 = rf[raddr1];

        if (raddr2 == 5'b0) rdata2 = 32'b0;
        else if ((raddr2 == waddr) && reg_wr) rdata2 = wdata; 
        else rdata2 = rf[raddr2];
    end
endmodule