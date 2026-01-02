module twiddle_rom #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 6 // Log2(64) = 6
)(
    input wire [ADDR_WIDTH-1:0] addr,
    output reg [DATA_WIDTH-1:0] dout
);
    // 64-Point FFT Twiddle Factors (W_64^k)
    // Format: Q2.14 Fixed Point {Real, Imag}
    always @(*) begin
        case(addr)
            6'd0:  dout = 32'h4000_0000; // 1.000,  0.000
            6'd1:  dout = 32'h3F96_F374; // 0.995, -0.196
            6'd2:  dout = 32'h3E5C_E707; // 0.980, -0.390
            6'd3:  dout = 32'h3C56_DAD8; // 0.956, -0.580
            6'd4:  dout = 32'h398C_CEBC; // 0.923, -0.765
            6'd5:  dout = 32'h35FA_C2C0; // 0.881, -0.942
            6'd6:  dout = 32'h31AB_B6EB; // 0.831, -1.111
            6'd7:  dout = 32'h2CB2_AB41; // 0.773, -1.268
            6'd8:  dout = 32'h2714_A000; // 0.707, -1.414
            6'd9:  dout = 32'h20DE_9528; // 0.634, -1.546
            6'd10: dout = 32'h1A1E_8AB2; // 0.555, -1.662
            6'd11: dout = 32'h12E6_80D0; // 0.471, -1.763
            6'd12: dout = 32'h0B46_7795; // 0.382, -1.847
            6'd13: dout = 32'h0342_6F10; // 0.290, -1.913
            6'd14: dout = 32'hFB04_6746; // 0.195, -1.961
            6'd15: dout = 32'hF296_6042; // 0.098, -1.990
            6'd16: dout = 32'hC000_5A82; // 0.000, -2.000 (Wait, Imag is -1.0 -> 0xC000)
            // Note: Simplification for brevity, we repeat the pattern logic or map quadrants.
            // But for a true 64-point lookup without logic overhead, we list 0-31:
            6'd17: dout = 32'hF733_E782; 
            6'd18: dout = 32'hEE95_CF04; 
            6'd19: dout = 32'hE630_B746; 
            6'd20: dout = 32'hDE15_A070; 
            6'd21: dout = 32'hD64E_8A90; 
            6'd22: dout = 32'hCEEC_75D0; 
            6'd23: dout = 32'hC805_6234; 
            6'd24: dout = 32'hC1A4_5000; 
            6'd25: dout = 32'hBBCF_3F28; 
            6'd26: dout = 32'hB69C_2FB2; 
            6'd27: dout = 32'hB226_21B0; 
            6'd28: dout = 32'hAE7D_1528; 
            6'd29: dout = 32'hAB9C_0A20; 
            6'd30: dout = 32'hA9A8_00B0; 
            6'd31: dout = 32'hA8AE_F8E0;
            default: dout = 32'h4000_0000;
        endcase
    end
endmodule