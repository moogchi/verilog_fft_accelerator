module dual_port_sram #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4
)(
    input wire clk,
    input wire we_a, we_b,
    input wire [ADDR_WIDTH-1:0] addr_a, addr_b,
    input wire [DATA_WIDTH-1:0] din_a, din_b,
    output wire [DATA_WIDTH-1:0] dout_a, dout_b // Changed 'reg' to 'wire'
);

    // The Memory Array
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    // 1. Asynchronous Read (Instant Data)
    assign dout_a = mem[addr_a];
    assign dout_b = mem[addr_b];

    // 2. Synchronous Write (Safe Saving)
    always @(posedge clk) begin
        if (we_a) 
            mem[addr_a] <= din_a;
        
        if (we_b) 
            mem[addr_b] <= din_b;
    end

endmodule