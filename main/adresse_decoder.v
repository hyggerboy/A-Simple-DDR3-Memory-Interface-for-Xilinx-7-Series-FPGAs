module adresse_decoder(
    input  wire [127:0] data_to_store,
    input wire [31:0] adresse,
    output reg [127:0] ofsetread_data,
    
    output wire [127:0] data_to_write_to_mem_dc,
    input  wire [15:0] masking_byte,
    output wire [2:0] bank_adresse,
    output wire [2:0] bank_adresse_2,
    output wire [13:0] col_adresse,
    output wire [13:0] col_adresse_2,
    output wire [9:0] row_adresse,
    output wire [9:0] row_adresse_2,
    input  wire [127:0] data_read_from_mem_cd,
    output wire [15:0] mask_1_write,
    output wire [15:0] mask_2_write,
    input wire [127:0] first_read


);




wire [127:0] data_out_w;

reg [127:0] shifed_data;

wire [31:0] adresse_2;

assign adresse_2 = {adresse[31:0]} + 32'd8;

assign bank_adresse_2 = adresse_2[26:24];
assign col_adresse_2 = adresse_2[23:10];
assign row_adresse_2 = adresse_2[9:0];  
 
assign bank_adresse = adresse[26:24];
assign col_adresse = adresse[23:10];
assign row_adresse = adresse[9:0];

reg [15:0] masking_shifed;  

reg [15:0] mask_2;
reg [15:0] mask_1;

assign mask_1_write = mask_1 | masking_shifed;
assign mask_2_write = mask_2 | masking_shifed;

reg [31:0] full_mask = 32'h0000_1111;

always @* begin
    mask_1 = 16'h0000;
    mask_2 = 16'h0000;
    masking_shifed = 16'h0000;



    shifed_data = data_to_store;

    case(adresse[2:0])
        3'b000: begin
            shifed_data = data_to_store;
            masking_shifed = masking_byte;

            mask_1 = 16'h0000;
            mask_2 = 16'hffff;
        end

        3'b001: begin
            shifed_data = {data_to_store[15:0], data_to_store[127:16]};
            masking_shifed = {masking_byte[1:0],masking_byte[15:2]};
            mask_1 = 16'b1100_0000_0000_0000 ;
            mask_2 = 16'b0011_1111_1111_1111;

        end

        3'b010: begin
            shifed_data = {data_to_store[31:0], data_to_store[127:32]};
            masking_shifed = {masking_byte[3:0],masking_byte[15:4]};
            mask_1 = 16'b1111_0000_0000_0000 ;
            mask_2 = 16'b0000_1111_1111_1111 ;           
        end

        3'b011: begin
            shifed_data = {data_to_store[47:0], data_to_store[127:48]};
            masking_shifed = {masking_byte[5:0],masking_byte[15:6]};
            mask_1 = 16'b1111_1100_0000_0000;
            mask_2 = 16'b0000_0011_1111_1111;
        end

        3'b100: begin
            shifed_data = {data_to_store[63:0], data_to_store[127:64]};
            masking_shifed = {masking_byte[7:0],masking_byte[15:8]};
            mask_1 = 16'b1111_1111_0000_0000;
            mask_2 = 16'b0000_0000_1111_1111;
        end

        3'b101: begin
            shifed_data = {data_to_store[79:0], data_to_store[127:80]};
            masking_shifed = {masking_byte[9:0],masking_byte[15:10]};
            mask_1 = 16'b1111_1111_1100_0000;
            mask_2 = 16'b0000_0000_0011_1111;
        end

        3'b110: begin
            shifed_data = {{data_to_store[95:0], data_to_store[127:96]}};
            masking_shifed = {masking_byte[11:0],masking_byte[15:12]};
            mask_1 = 16'b1111_1111_1111_0000;
            mask_2 = 16'b0000_0000_0000_1111;
        end

        3'b111: begin
            shifed_data = {data_to_store[111:0], data_to_store[127:112]};
            masking_shifed = {masking_byte[13:0],masking_byte[15:14]};
            mask_1 = 16'b1111_1111_1111_1100;
            mask_2 = 16'b0000_0000_0000_0011;
        end
    endcase
    
    



case (adresse[2:0])
    3'b000: begin
        ofsetread_data = data_out_w;
    end

    // offset = 1 * 16 bits = 2 bytes
    3'b001: begin
        ofsetread_data = {first_read_fixed[111:0], data_out_w[127:112]};
    end

    // offset = 2 * 16 bits = 4 bytes
    3'b010: begin
        ofsetread_data = {first_read_fixed[95:0], data_out_w[127:96]};
    end

    // offset = 3 * 16 bits = 6 bytes
    3'b011: begin
        ofsetread_data = {first_read_fixed[79:0], data_out_w[127:80]};
    end

    // offset = 4 * 16 bits = 8 bytes
    3'b100: begin
        ofsetread_data = {first_read_fixed[63:0], data_out_w[127:64]};
    end

    // offset = 5 * 16 bits = 10 bytes
    3'b101: begin
        ofsetread_data = {first_read_fixed[47:0], data_out_w[127:48]};
    end

    // offset = 6 * 16 bits = 12 bytes
    3'b110: begin
        ofsetread_data = {first_read_fixed[31:0], data_out_w[127:32]};
    end

    // offset = 7 * 16 bits = 14 bytes
    3'b111: begin
        ofsetread_data = {first_read_fixed[15:0], data_out_w[127:16]};
    end
endcase
end

wire [127:0] first_read_fixed;

genvar beat_i;
genvar bit_i;

generate
    for (beat_i = 0; beat_i < 8; beat_i = beat_i + 1) begin : gen_beat
        for (bit_i = 0; bit_i < 8; bit_i = bit_i + 1) begin : gen_bit
            assign data_to_write_to_mem_dc[(bit_i*8) + beat_i] = shifed_data[(beat_i*16) + bit_i];
            assign data_to_write_to_mem_dc[((bit_i+8)*8) + beat_i] = shifed_data[(beat_i*16) + 8 + bit_i];
            assign data_out_w[(beat_i*16) + bit_i] =  data_read_from_mem_cd[(bit_i*8) + beat_i];
            assign data_out_w[(beat_i*16) + 8 + bit_i] = data_read_from_mem_cd[((bit_i+8)*8) + beat_i];
            assign first_read_fixed[(beat_i*16) + bit_i] = first_read[(bit_i*8) + beat_i];
            assign first_read_fixed[(beat_i*16) + 8 + bit_i] = first_read[((bit_i+8)*8) + beat_i];
            


        end
    end
endgenerate

endmodule