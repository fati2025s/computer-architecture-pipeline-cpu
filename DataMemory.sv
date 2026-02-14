module DataMemory(
    input  logic [31:0] addr, wdata, 
    input  logic [2:0]  mask, 
    input  logic        wr_en, rd_en, clk,
    output logic [31:0] rdata
);
    logic [31:0] memory [0:1023]; // 4 KB Memory

    logic [31:0] raw_data;
    assign raw_data = (rd_en) ? memory[addr[11:2]] : 32'b0;

    always_comb begin
        case (mask)
            3'b000: rdata = {{24{raw_data[7]}},  raw_data[7:0]};   // LB
            3'b001: rdata = {{16{raw_data[15]}}, raw_data[15:0]};  // LH
            3'b010: rdata = raw_data;                              // LW
            3'b100: rdata = {24'b0, raw_data[7:0]};                // LBU
            3'b101: rdata = {16'b0, raw_data[15:0]};               // LHU
            default: rdata = 32'b0;
        endcase
    end

    always_ff @(posedge clk) begin
        if (wr_en) begin
            case (mask)
                3'b000: begin // SB (Store Byte)
                    case (addr[1:0])
                        2'b00: memory[addr[11:2]][7:0]   <= wdata[7:0];
                        2'b01: memory[addr[11:2]][15:8]  <= wdata[7:0];
                        2'b10: memory[addr[11:2]][23:16] <= wdata[7:0];
                        2'b11: memory[addr[11:2]][31:24] <= wdata[7:0];
                    endcase
                end
                3'b001: begin // SH (Store Halfword)
                    if (addr[1]) memory[addr[11:2]][31:16] <= wdata[15:0];
                    else         memory[addr[11:2]][15:0]  <= wdata[15:0];
                end
                3'b010: begin // SW (Store Word)
                    memory[addr[11:2]] <= wdata;
                end
            endcase
        end
    end
endmodule