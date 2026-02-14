module PC(
    input  logic        clk, reset,
    input  logic        en,      // سیگنال فعال‌ساز (اگر 0 باشد، PC فریز می‌شود)
    input  logic [31:0] d,       // ورودی آدرس بعدی
    output logic [31:0] q        // خروجی آدرس فعلی
);
    always_ff @(posedge clk) begin
        if (reset) 
            q <= 32'h0;
        else if (en)             // فقط در صورتی که استال نباشیم، PC آپدیت می‌شود
            q <= d;
    end
endmodule