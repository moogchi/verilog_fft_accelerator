module control_unit #(
    parameter M = 4,      // Address Width (e.g., 4 bits for 16-point FFT)
    parameter LOG2N = 4   // Number of Stages (log2(16) = 4)
)(
    input wire clk,
    input wire rst,
    input wire start,

    // --- Address Outputs (To Datapath) ---
    output wire [M-1:0] addr_a,
    output wire [M-1:0] addr_b,
    output wire [M-1:0] rom_addr,

    // --- Control Signals (To Datapath) ---
    output reg load_a,   // Latch Register A
    output reg load_b,   // Latch Register B
    output reg load_t,   // Latch Twiddle Register
    output reg ram_we,   // Write Enable for RAM
    output reg done      // Done Flag
);

    // ============================================================
    // 1. STATE MACHINE DEFINITIONS
    // ============================================================
    localparam S_IDLE   = 2'b00;
    localparam S_LOAD   = 2'b01; // Fetch A, B, W from RAM/ROM
    localparam S_WRITE  = 2'b10; // Compute & Write Result Back
    localparam S_UPDATE = 2'b11; // Increment Counters / Check Loops

    reg [1:0] state, next_state;

    // ============================================================
    // 2. INTERNAL COUNTERS (The "Registers" in your drawing)
    // ============================================================
    reg [3:0]   stage_cnt;  // Outer Loop (1 to 4)
    reg [M-1:0] group_cnt;  // Middle Loop (Group Index)
    reg [M-1:0] pair_cnt;   // Inner Loop (Pair Index)
    
    // The Shift Registers
    reg [M-1:0] span;       // Left Shift Register (<< 1)
    reg [M-1:0] num_groups; // Right Shift Register (>> 1)

    // ============================================================
    // 3. ADDRESS GENERATION LOGIC (The "Cloud")
    // ============================================================
    // Logic: AddrA = (Group * 2 * Span) + Pair
    // Logic: AddrB = AddrA + Span
    
    // Note: (Group * 2 * Span) is the same as (Group * (Span << 1))
    wire [M-1:0] group_offset = group_cnt * (span << 1);
    
    assign addr_a = group_offset + pair_cnt;
    assign addr_b = addr_a + span;

    // Twiddle Address Logic:
    // Matches the rotation speed needed for each stage.
    // Equivalent to: pair * (N / (2 * span))
    assign rom_addr = pair_cnt << (LOG2N - stage_cnt);

    // ============================================================
    // 4. SEQUENTIAL LOGIC (Counters & Shifts)
    // ============================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= S_IDLE;
            pair_cnt   <= 0;
            group_cnt  <= 0;
            stage_cnt  <= 1;
            
            // Initial Values
            span       <= 1;                    // Start Span = 1
            num_groups <= 1 << (LOG2N - 1);     // Start Groups = N/2 (e.g., 8)
            done       <= 0;
        end 
        else begin
            state <= next_state;

            // --- Counter Updates (Only in S_UPDATE state) ---
            if (state == S_UPDATE) begin
                
                // Priority 1: Inner Loop (Pairs)
                // "if pair_cnt < span - 1"
                if (pair_cnt < span - 1) begin
                    pair_cnt <= pair_cnt + 1;
                end 
                
                // Priority 2: Middle Loop (Groups)
                // "if group_cnt < num_groups - 1"
                else if (group_cnt < num_groups - 1) begin
                    pair_cnt  <= 0;              // Reset Pair
                    group_cnt <= group_cnt + 1;  // Next Group
                end 
                
                // Priority 3: Outer Loop (Stages)
                // "if stage_cnt < LOG2N"
                else if (stage_cnt < LOG2N) begin
                    pair_cnt   <= 0;
                    group_cnt  <= 0;
                    stage_cnt  <= stage_cnt + 1; // Next Stage
                    
                    // THE SHIFT REGISTERS UPDATE HERE
                    span       <= span << 1;     // Span Doubles (1->2->4)
                    num_groups <= num_groups >> 1; // Groups Halve (8->4->2)
                end 
                
                // Priority 4: Finish
                else begin
                    done <= 1;
                end
            end

            // Reset logic when starting a new run
            if (state == S_IDLE && start) begin
                done       <= 0;
                stage_cnt  <= 1;
                pair_cnt   <= 0;
                group_cnt  <= 0;
                span       <= 1;
                num_groups <= 1 << (LOG2N - 1);
            end
        end
    end

    // ============================================================
    // 5. NEXT STATE & OUTPUT LOGIC (The "Brain" Cloud)
    // ============================================================
    always @(*) begin
        // Default Assignments (Latch avoidance)
        next_state = state;
        load_a = 0; 
        load_b = 0; 
        load_t = 0; 
        ram_we = 0;

        case (state)
            // --- S_IDLE (MISSING IN YOUR CODE) ---
            S_IDLE: begin
                if (start) next_state = S_LOAD;
            end

            // --- S_LOAD ---
            S_LOAD: begin
                // Action: Fetch Data from RAM to Registers
                load_a = 1;
                load_b = 1;
                load_t = 1;
                
                // Unconditional Jump to Execute
                next_state = S_WRITE;
            end

            // --- S_WRITE ---
            S_WRITE: begin
                // Action: Write Math Result back to RAM
                ram_we = 1;
                
                // Unconditional Jump to Update Counters
                next_state = S_UPDATE;
            end

            // --- S_UPDATE (THE FIXED VERSION) ---
            S_UPDATE: begin
                // FIX: Check the actual counters directly.
                // If we are at the Last Stage + Last Group + Last Pair, we are finished.
                if (stage_cnt == LOG2N && group_cnt == num_groups - 1 && pair_cnt == span - 1) 
                    next_state = S_IDLE;
                else 
                    next_state = S_LOAD; // Not done, go fetch next pair
            end
        endcase
    end

endmodule
