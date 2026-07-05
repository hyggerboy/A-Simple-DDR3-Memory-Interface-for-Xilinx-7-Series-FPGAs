
module BRAMMASK(
    input wire clk,
    input wire [7:0] addr,
    output reg  [15:0] dout
);

    (* ram_style = "block" *)
    reg [15:0] rom [0:255];

    initial begin
        $readmemh("mask_for_test1.mem", rom);
    end

    always @(posedge clk) begin
        dout <= rom[addr];
    end

endmodule
