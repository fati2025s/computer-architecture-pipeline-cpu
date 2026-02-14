module HazardUnit(
    input  logic [4:0] rs1_id, rs2_id, rd_ex, rd_mem,
    input  logic       reg_wr_ex, reg_wr_mem,
    input  logic       is_branch_id, 
    input  logic       mem_read_ex, 
    input  logic       cache_miss,
    input  logic       br_taken,
    output logic       stall_if, stall_id, flush_id, flush_ex
);
    always_comb begin
        stall_if = 0; stall_id = 0; flush_id = 0; flush_ex = 0;

        if (cache_miss) begin
            stall_if = 1; stall_id = 1;
        end
        
        else if (is_branch_id && reg_wr_ex && (rd_ex != 0) && ((rd_ex == rs1_id) || (rd_ex == rs2_id))) begin
            stall_if = 1; 
            stall_id = 1; 
            flush_ex = 1; 
        end

        else if (mem_read_ex && (rd_ex != 0) && ((rd_ex == rs1_id) || (rd_ex == rs2_id))) begin
            stall_if = 1; 
            stall_id = 1; 
            flush_ex = 1;
        end

        if (br_taken && !cache_miss && !stall_id) begin
            flush_id = 1;
        end
    end
endmodule