`timescale 1ns / 1ps

module Processor(input logic clk, reset);
    logic stall_if, stall_id, flush_id, flush_ex, cache_miss;
    logic [1:0] forwardA, forwardB;

    logic [31:0] pc_out, pc_next, pc_plus4, inst_if;
    
    PC pc_reg (.clk(clk), .reset(reset), .en(!stall_if), .d(pc_next), .q(pc_out));
    Add4 pc_add4 (.a(pc_out), .b(pc_plus4));
    
    assign pc_next = (br_taken) ? pc_target_id : pc_plus4;

    InstructionMemory imem (.addr(pc_out), .instruction(inst_if));

    logic [31:0] inst_id, pc_id, pc_plus4_id;
    
    always_ff @(posedge clk) begin
        if (reset || flush_id) begin
            inst_id <= 32'h00000013; 
            pc_id <= 0;
            pc_plus4_id <= 0;
        end else if (!stall_id) begin
            inst_id <= inst_if;
            pc_id <= pc_out;
            pc_plus4_id <= pc_plus4;
        end
    end

    logic [31:0] rdata1_id, rdata2_id, imm_id, pc_target_id;
    logic [3:0] alu_op_id;
    logic [2:0] mask_id, br_type_id;
    logic [1:0] wb_sel_id;
    logic reg_wr_id, sel_A_id, sel_B_id, rd_en_id, wr_en_id, br_taken;

    RegisterFile rf (.clk(clk), .reset(reset), .reg_wr(reg_wr_wb), 
                    .raddr1(inst_id[19:15]), .raddr2(inst_id[24:20]), 
                    .waddr(rd_wb), .wdata(wdata_wb), 
                    .rdata1(rdata1_id), .rdata2(rdata2_id));

    ImmediateGenerator ig (.instruction(inst_id), .imm_out(imm_id));

    Controller ctrl (.instruction(inst_id), .alu_op(alu_op_id), .mask(mask_id), 
                    .br_type(br_type_id), .reg_wr(reg_wr_id), .sel_A(sel_A_id), 
                    .sel_B(sel_B_id), .rd_en(rd_en_id), .wr_en(wr_en_id), .wb_sel(wb_sel_id));

    assign pc_target_id = (inst_id[6:0] == 7'b1100111) ? (rdata1_id + imm_id) : (pc_id + imm_id);
    
    logic [31:0] br_val1, br_val2;

    logic [31:0] final_br_val1, final_br_val2;

    always_comb begin
       if (reg_wr_mem && (rd_mem != 0) && (rd_mem == inst_id[19:15]))
            final_br_val1 = alu_out_mem; 
        else if (reg_wr_wb && (rd_wb != 0) && (rd_wb == inst_id[19:15]))
            final_br_val1 = wdata_wb;  
        else
            final_br_val1 = rdata1_id; 

        if (reg_wr_mem && (rd_mem != 0) && (rd_mem == inst_id[24:20]))
            final_br_val2 = alu_out_mem;
        else if (reg_wr_wb && (rd_wb != 0) && (rd_wb == inst_id[24:20]))
            final_br_val2 = wdata_wb;   
        else
            final_br_val2 = rdata2_id;  
    end

    BranchCondition bc (
        .rs1(final_br_val1), 
        .rs2(final_br_val2), 
        .br_type(br_type_id), 
        .opcode(inst_id[6:0]), 
        .br_taken(br_taken)
    );
    
    logic [31:0] rdata1_ex, rdata2_ex, imm_ex, pc_ex, pc_plus4_ex;
    logic [4:0] rs1_ex, rs2_ex, rd_ex;
    logic [3:0] alu_op_ex;
    logic [2:0] mask_ex;
    logic [1:0] wb_sel_ex;
    logic is_branch_id;
    logic reg_wr_ex, sel_A_ex, sel_B_ex, rd_en_ex, wr_en_ex;
    assign is_branch_id = (inst_id[6:0] == 7'b1100011);

    always_ff @(posedge clk) begin
        if (reset || flush_ex) begin
            reg_wr_ex <= 0; rd_en_ex <= 0; wr_en_ex <= 0;
            rd_ex <= 0;
        end else if (!cache_miss) begin
            rdata1_ex <= rdata1_id; rdata2_ex <= rdata2_id;
            imm_ex <= imm_id; pc_ex <= pc_id; pc_plus4_ex <= pc_plus4_id;
            rs1_ex <= inst_id[19:15]; rs2_ex <= inst_id[24:20]; rd_ex <= inst_id[11:7];
            alu_op_ex <= alu_op_id; mask_ex <= mask_id;
            wb_sel_ex <= wb_sel_id; reg_wr_ex <= reg_wr_id;
            sel_A_ex <= sel_A_id; sel_B_ex <= sel_B_id;
            rd_en_ex <= rd_en_id; wr_en_ex <= wr_en_id;
        end
    end

    logic [31:0] alu_A, alu_B, forward_B_mux, alu_out_ex;

    always_comb begin
        case (forwardA)
            2'b10: alu_A = alu_out_mem;
            2'b01: alu_A = wdata_wb;
            default: alu_A = (sel_A_ex) ? pc_ex : rdata1_ex;
        endcase

        case (forwardB)
            2'b10: forward_B_mux = alu_out_mem;
            2'b01: forward_B_mux = wdata_wb;
            default: forward_B_mux = rdata2_ex;
        endcase
    end
    
    assign alu_B = (sel_B_ex) ? imm_ex : forward_B_mux;

    ALU alu_unit (.A(alu_A), .B(alu_B), .alu_op(alu_op_ex), .C(alu_out_ex));

    logic [31:0] alu_out_mem, wdata_mem_in, pc_plus4_mem;
    logic [4:0] rd_mem;
    logic [2:0] mask_mem;
    logic [1:0] wb_sel_mem;
    logic reg_wr_mem, rd_en_mem, wr_en_mem;

    always_ff @(posedge clk) begin
        if (reset) begin
            reg_wr_mem <= 0; rd_en_mem <= 0; wr_en_mem <= 0;
        end else if (!cache_miss) begin
            alu_out_mem <= alu_out_ex;
            wdata_mem_in <= forward_B_mux; 
            rd_mem <= rd_ex; mask_mem <= mask_ex;
            wb_sel_mem <= wb_sel_ex; reg_wr_mem <= reg_wr_ex;
            rd_en_mem <= rd_en_ex; wr_en_mem <= wr_en_ex;
            pc_plus4_mem <= pc_plus4_ex;
        end
    end

    logic [31:0] rdata_mem;
    
    Cache d_cache (
        .clk(clk), .reset(reset), .addr(alu_out_mem), .wdata(wdata_mem_in),
        .rd_en(rd_en_mem), .wr_en(wr_en_mem), .rdata(rdata_mem), .miss(cache_miss),
        .mem_addr(main_mem_addr), .mem_wdata(main_mem_wdata), 
        .mem_rd(main_mem_rd), .mem_wr(main_mem_wr), .mem_rdata(main_mem_rdata)
    );

    DataMemory main_memory (
        .addr(main_mem_addr), .wdata(main_mem_wdata), .mask(mask_mem),
        .wr_en(main_mem_wr), .rd_en(main_mem_rd), .clk(clk), .rdata(main_mem_rdata)
    );

    logic [31:0] alu_out_wb, rdata_wb, pc_plus4_wb;
    logic [4:0] rd_wb;
    logic [1:0] wb_sel_wb;
    logic reg_wr_wb;

    always_ff @(posedge clk) begin
        if (reset) reg_wr_wb <= 0;
        else if (!cache_miss) begin
            alu_out_wb <= alu_out_mem;
            rdata_wb <= rdata_mem;
            pc_plus4_wb <= pc_plus4_mem;
            rd_wb <= rd_mem;
            wb_sel_wb <= wb_sel_mem;
            reg_wr_wb <= reg_wr_mem;
        end
    end

    logic [31:0] wdata_wb;
    WriteBack wb_unit (.A(alu_out_wb), .B(rdata_wb), .C(pc_plus4_wb), 
                      .wb_sel(wb_sel_wb), .wdata(wdata_wb));

    ForwardingUnit fu (.rs1_ex(rs1_ex), .rs2_ex(rs2_ex), .rd_mem(rd_mem), 
                      .rd_wb(rd_wb), .reg_wr_mem(reg_wr_mem), .reg_wr_wb(reg_wr_wb), 
                      .forwardA(forwardA), .forwardB(forwardB));

    HazardUnit hu (
        .rs1_id(inst_id[19:15]),
        .rs2_id(inst_id[24:20]),
        .rd_ex(rd_ex),
        .rd_mem(rd_mem),        
        .reg_wr_ex(reg_wr_ex),  
        .reg_wr_mem(reg_wr_mem), 
        .is_branch_id(is_branch_id), 
        .mem_read_ex(rd_en_ex),
        .cache_miss(cache_miss),
        .br_taken(br_taken),
        .stall_if(stall_if),
        .stall_id(stall_id),
        .flush_id(flush_id),
        .flush_ex(flush_ex)
    );
endmodule