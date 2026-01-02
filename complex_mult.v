module complex_mult (
    input  signed [15:0] br, bi, // Inputs from Reg B (Real/Imag)
    input  signed [15:0] wr, wi, // Inputs from Reg T (Real/Imag)
    output signed [15:0] tr, ti  // Outputs to the Butterfly Adder
);

    // 1. The Four Multiplications (Your 4 "X" Boxes)
    // Result is 32 bits because 16 * 16 grows.
    wire signed [31:0] k1, k2, k3, k4;

    assign k1 = br * wr; // Real * Real
    assign k2 = bi * wi; // Imag * Imag
    assign k3 = br * wi; // Real * Imag
    assign k4 = bi * wr; // Imag * Real

    // 2. The Add/Sub Logic (Your "+" and "-" Boxes)
    // Real Part = (Real*Real) - (Imag*Imag)
    wire signed [31:0] tr_full = k1 - k2; 
    
    // Imag Part = (Real*Imag) + (Imag*Real)
    wire signed [31:0] ti_full = k3 + k4;

    // 3. The Slicing (Fitting 32 bits back into 16 bits)
    // Assuming Q2.14 Fixed Point (common for student FFTs).
    // We drop the top 2 bits (sign extension copies) and the bottom 14 bits.
    // Adjust [29:14] if you use a different decimal point standard.
    assign tr = tr_full[29:14];
    assign ti = ti_full[29:14];

endmodule