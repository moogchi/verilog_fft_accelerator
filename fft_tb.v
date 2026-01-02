`timescale 1ns / 1ps

module fft_tb;

    // --- CONFIGURATION ---
    parameter N_WIDTH = 32;
    parameter M_ADDR  = 6;  // <--- CHANGED TO 6 (64 Points)
    
    reg clk, rst, start;
    wire done;
    wire [31:0] debug_data;

    fft_top #(.N(N_WIDTH), .M(M_ADDR)) uut (
        .clk(clk), .rst(rst), .start(start), .done(done), .debug_data(debug_data)
    );

    always #5 clk = ~clk;

    integer i;
    reg [M_ADDR-1:0] bit_rev;   // Variable to hold reversed address
    reg signed [15:0] wave_real; // Temp variable for math
    
    // Constants for Sine Generation
    real PI = 3.14159265;
    real freq = 4.0; // We want to see 4 cycles in the window

    initial begin
        // WAVEFORM DUMPING
        $dumpfile("fft.vcd");
        $dumpvars(0, fft_tb);

        clk = 0; rst = 1; start = 0;

        // --- BACKDOOR LOADING: 64-Point Sine Wave ---
        $display("Loading 64-Point Input Data...");
        
        for (i = 0; i < 64; i = i + 1) begin
            // 1. Generate High-Res Sine Wave using System Math
            // Amplitude 1000, Freq 4
            wave_real = $rtoi(1000.0 * $cos(2.0 * PI * freq * i / 64.0));
            
            // 2. Calculate Bit Reverse Address Automatically
            // For M=6: {0,1,2,3,4,5} -> {5,4,3,2,1,0}
            bit_rev[5] = i[0];
            bit_rev[4] = i[1];
            bit_rev[3] = i[2];
            bit_rev[2] = i[3];
            bit_rev[1] = i[4];
            bit_rev[0] = i[5];

            // 3. Load to RAM
            uut.u_datapath.data_mem.mem[bit_rev] = {wave_real, 16'd0};
        end

        // --- RUN FFT ---
        #100; rst = 0;
        #20;  start = 1;
        #10;  start = 0;

        wait(done);
        $display("FFT Done!");
        
        // --- PRINT RESULTS ---
        // Only print the first 10 and the spikes to keep terminal clean
        $display("Checking Index 4 and 60 (Mirrors)...");
        $display("Idx 4:  %d", $signed(uut.u_datapath.data_mem.mem[4][31:16]));
        $display("Idx 60: %d", $signed(uut.u_datapath.data_mem.mem[60][31:16]));

        #100;
        $stop;
    end
endmodule