module BRAM2 (
    input  wire         clk,
    input  wire         we,
    input  wire [7:0]   addr,
    input  wire [127:0] din,
    output reg  [127:0] dout
);

    (* ram_style = "block" *)
    reg [127:0] ram [0:255];

    

    always @(posedge clk) begin
        if (we) begin
            ram[addr] <= din;
        end

        dout <= ram[addr];
    end

endmodule