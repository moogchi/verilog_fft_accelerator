module fft_top #(
    parameter N = 32, // Data Width
    parameter M = 4   // Address Width (Log2 N)
)(
    input wire clk,
    input wire rst,
    input wire start,
    output wire done,
    
    // Optional: Debug ports to see what's happening inside
    output wire [N-1:0] debug_data
);

    // ============================================================
    // 1. INTERNAL WIRES (The cables connecting the boxes)
    // ============================================================
    
    // Address Lines
    wire [M-1:0] addr_a_wire;
    wire [M-1:0] addr_b_wire;
    wire [M-1:0] rom_addr_wire;

    // Control Signals
    wire load_a_wire;
    wire load_b_wire;
    wire load_t_wire;
    wire ram_we_wire;

    // ============================================================
    // 2. INSTANTIATE THE BRAIN (Control Unit)
    // ============================================================
    control_unit #(
        .M(M), 
        .LOG2N(M) // If N=16, LOG2N is 4
    ) u_control (
        .clk(clk),
        .rst(rst),
        .start(start),
        
        // Outputs (The Commands)
        .addr_a(addr_a_wire),
        .addr_b(addr_b_wire),
        .rom_addr(rom_addr_wire),
        .load_a(load_a_wire),
        .load_b(load_b_wire),
        .load_t(load_t_wire),
        .ram_we(ram_we_wire),
        .done(done)
    );

    // ============================================================
    // 3. INSTANTIATE THE MUSCLES (Datapath)
    // ============================================================
    fft_datapath #(
        .N(N),
        .M(M)
    ) u_datapath (
        .clk(clk),
        
        // Inputs (Listening to the Brain)
        .addr_a(addr_a_wire),
        .addr_b(addr_b_wire),
        .rom_addr(rom_addr_wire),
        .load_a(load_a_wire),
        .load_b(load_b_wire),
        .load_t(load_t_wire),
        .ram_we(ram_we_wire),
        
        // Debug Output
        .debug_data_out(debug_data)
    );

endmodule