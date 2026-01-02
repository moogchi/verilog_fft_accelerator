// This takes 'A' and the calculated 'T' to make the final outputs
module butterfly_add (
    input  signed [15:0] ar, ai, // Register A (Real/Imag)
    input  signed [15:0] tr, ti, // T (Result from Multiplier)
    output signed [15:0] top_r, top_i, // New A'
    output signed [15:0] bot_r, bot_i  // New B'
);

    // Top Output = A + T
    // Note: We might need one extra bit for overflow, but usually we just wrap
    assign top_r = ar + tr;
    assign top_i = ai + ti;

    // Bottom Output = A - T
    assign bot_r = ar - tr;
    assign bot_i = ai - ti;

endmodule