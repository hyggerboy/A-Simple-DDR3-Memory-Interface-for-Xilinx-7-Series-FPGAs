module BRAM3(
    input wire clk,
    input wire [7:0] addr,
    output reg  [31:0] dout
);

    (* ram_style = "block" *)
    reg [31:0] rom[0:255];
    
    initial begin
        $readmemh("adresse_for_write_test1.mem", rom);
    end


    always @(posedge clk) begin
        dout <= rom[addr];
    end

endmodule