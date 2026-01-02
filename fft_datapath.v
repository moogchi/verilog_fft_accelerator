module fft_datapath #(
    parameter N = 32, // Full Data Width (16 Real + 16 Imag)
    parameter M = 4   // Address Width (Log2 of Depth, e.g. 4 for 16 lines)
)(
    input wire clk,

    // --- Control Signals (From your Control Unit) ---
    input wire [M-1:0] addr_a,   // Address for Top Arm
    input wire [M-1:0] addr_b,   // Address for Bottom Arm
    input wire [M-1:0] rom_addr, // Address for Twiddle Factor
    input wire load_a,           // Load Register A
    input wire load_b,           // Load Register B
    input wire load_t,           // Load Register T
    input wire ram_we,           // Write Enable (Same for A and B ports)

    // --- Debug Output (Optional) ---
    output wire [N-1:0] debug_data_out
);

    // ============================================================
    // 1. WIRES & BUSES
    // ============================================================
    
    // Memory Outputs (Wires coming FROM RAM/ROM)
    wire [N-1:0] ram_out_a;
    wire [N-1:0] ram_out_b;
    wire [N-1:0] rom_out_t;

    // Register Outputs (The values held inside Reg A, B, T)
    reg signed [15:0] reg_ar, reg_ai; // Reg A
    reg signed [15:0] reg_br, reg_bi; // Reg B
    reg signed [15:0] reg_wr, reg_wi; // Reg T

    // Math Intermediate Results (T)
    wire signed [15:0] tr, ti;

    // Math Final Results (New A' and New B')
    wire signed [15:0] new_ar, new_ai;
    wire signed [15:0] new_br, new_bi;

    // The Feedback Loop (Bundling 16+16 back into 32)
    wire [N-1:0] write_data_a = {new_ar, new_ai}; 
    wire [N-1:0] write_data_b = {new_br, new_bi};

    assign debug_data_out = write_data_a; // Just for viewing in simulation

    // ============================================================
    // 2. MEMORY INSTANTIATION
    // ============================================================

    // The Dual Port RAM (Stores your Data)
    dual_port_sram #(.DATA_WIDTH(N), .ADDR_WIDTH(M)) data_mem (
        .clk(clk),
        .we_a(ram_we),   .we_b(ram_we),     // Write when Math is done
        .addr_a(addr_a), .addr_b(addr_b),   // Addresses from Control Unit
        .din_a(write_data_a),               // <--- FEEDBACK LOOP from Butterfly
        .din_b(write_data_b),               // <--- FEEDBACK LOOP from Butterfly
        .dout_a(ram_out_a),                 // Sends data to Reg A
        .dout_b(ram_out_b)                  // Sends data to Reg B
    );

    // The Twiddle ROM (Stores Constants)
    twiddle_rom #(.DATA_WIDTH(N), .ADDR_WIDTH(M)) twiddle_mem (
        .addr(rom_addr),                    // Address from Control Unit
        .dout(rom_out_t)                    // Sends data to Reg T
    );

    // ============================================================
    // 3. PIPELINE REGISTERS (The "Wall")
    // ============================================================
    
    // This matches your 3 Registers (A, B, T) with Load Enables
    always @(posedge clk) begin
        if (load_a) begin
            reg_ar <= ram_out_a[31:16]; // Top 16 bits = Real
            reg_ai <= ram_out_a[15:0];  // Bot 16 bits = Imag
        end
        if (load_b) begin
            reg_br <= ram_out_b[31:16];
            reg_bi <= ram_out_b[15:0];
        end
        if (load_t) begin
            reg_wr <= rom_out_t[31:16];
            reg_wi <= rom_out_t[15:0];
        end
    end

    // ============================================================
    // 4. THE BUTTERFLY UNIT (Combinational Math)
    // ============================================================

    // Step 1: Complex Multiplier (Calculates T = B * W)
    // This is the module we just wrote.
    complex_mult u_mult (
        .br(reg_br), .bi(reg_bi),
        .wr(reg_wr), .wi(reg_wi),
        .tr(tr),     .ti(ti)
    );

    // Step 2: The Wings (Adders and Subtractors)
    // Top = A + T, Bot = A - T
    // This is the module logic we discussed (or you can paste module here).
    butterfly_add u_add (
        .ar(reg_ar), .ai(reg_ai),
        .tr(tr),     .ti(ti),
        .top_r(new_ar), .top_i(new_ai),
        .bot_r(new_br), .bot_i(new_bi)
    );

endmodule