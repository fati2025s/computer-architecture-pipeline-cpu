module Cache(
    input  logic        clk, reset,
    input  logic [31:0] addr, wdata,
    input  logic        rd_en, wr_en,
    output logic [31:0] rdata,
    output logic        miss,
    output logic [31:0] mem_addr, mem_wdata,
    output logic        mem_rd, mem_wr,
    input  logic [31:0] mem_rdata
);
    logic [31:0] cache_data [63:0];
    logic [23:0] tags [63:0];
    logic        valid [63:0];

    logic [5:0]  index;
    logic [23:0] tag;

    assign index = addr[7:2];
    assign tag   = addr[31:8];

    always_comb begin
        if ((rd_en || wr_en) && (!valid[index] || tags[index] != tag)) begin
            miss = 1;
            rdata = 32'b0;
        end else begin
            miss = 0; 
            rdata = cache_data[index];
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i=0; i<64; i++) valid[i] <= 0;
        end else if (miss) begin
            cache_data[index] <= mem_rdata;
            tags[index] <= tag;
            valid[index] <= 1;
        end else if (wr_en && !miss) begin
            cache_data[index] <= wdata;
        end
    end

    assign mem_addr  = addr;
    assign mem_wdata = wdata;
    assign mem_rd    = rd_en && miss;
    assign mem_wr    = wr_en;

endmodule