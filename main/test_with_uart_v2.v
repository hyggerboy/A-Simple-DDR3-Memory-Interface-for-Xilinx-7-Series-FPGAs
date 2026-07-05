module uart_test_v2 (
    input clk,
    output tx,
    input rx,
    input bnt,
    input bnt1,

    input  [127:0] mem_data,
    output reg [127:0] data_to_mem,

    output reg write_to_mem,
    output reg read_from_mem,
    input ddr_bussy,

    output [2:0] state_w,
    output reg [31:0] adresse_r
);

assign state_w = state;

wire [7:0] data__in_w;
reg  [7:0] data_out;
reg        write_flag;
wire       bussy;

uart uboy (
    .clk(clk),
    .tx(tx),
    .rx(rx),
    .write_flag(write_flag),
    .bussy(bussy),
    .data__in_w(data__in_w),
    .data_out(data_out)
);

localparam ideal                  = 3'b000,
           read_or_write          = 3'b001,
           adresse                = 3'b010,
           data_write             = 3'b011,
           data_read              = 3'b100,
           preform_write_opration = 3'b101,
           preform_read_opration  = 3'b110;

reg [2:0] state = ideal;
reg [2:0] nextstate = ideal;

reg [4:0] byte_num = 5'd0;

reg pre_bussy = 1'b0;
reg ddr_seen_busy = 1'b0;

reg [127:0] tx_word = 128'd0;


reg [1:0] tx_phase = 2'd0;
reg tx_seen_busy = 1'b0;




always @* begin
    nextstate = state;

    write_to_mem = 1'b0;
    read_from_mem = 1'b0;

    case (state)

        ideal: begin
            if (rx != 1'b1) begin
                nextstate = adresse;
            end else begin
                nextstate = ideal;
            end
        end

        adresse: begin
            if (byte_num == 5'd4) begin
                if (adresse_r[31] == 1'b1) begin
                    nextstate = data_write;
                end else begin
                    nextstate = preform_read_opration;
                    read_from_mem = 1'b1;
                end
            end else begin
                nextstate = adresse;
            end
        end

        data_write: begin
            if (byte_num == 5'd16) begin
                nextstate = preform_write_opration;
                write_to_mem = 1'b1;
            end else begin
                nextstate = data_write;
            end
        end

        preform_write_opration: begin
            if (ddr_seen_busy && !ddr_bussy) begin
                nextstate = ideal;
            end else begin
                nextstate = preform_write_opration;
            end
        end

        preform_read_opration: begin
            if (ddr_seen_busy && !ddr_bussy) begin
                nextstate = data_read;
            end else begin
                nextstate = preform_read_opration;
            end
        end

        data_read: begin
            if (byte_num == 5'd16) begin
                nextstate = ideal;
            end else begin
                nextstate = data_read;
            end
        end

        default: begin
            nextstate = ideal;
        end

    endcase
end




always @(posedge clk) begin
    state <= nextstate;

    pre_bussy <= bussy;

    write_flag <= 1'b0;

    if (state != nextstate) begin
        byte_num <= 5'd0;

        tx_phase <= 2'd0;
        tx_seen_busy <= 1'b0;

        if ((nextstate == preform_read_opration) ||
            (nextstate == preform_write_opration)) begin
            ddr_seen_busy <= 1'b0;
        end

        if (nextstate == data_read) begin
            tx_word <= mem_data;
            tx_phase <= 2'd0;
            tx_seen_busy <= 1'b0;
            byte_num <= 5'd0;
        end

    end else begin

        case (state)

            adresse: begin
                if ((pre_bussy == 1'b1) && (bussy == 1'b0)) begin
                    adresse_r <= {adresse_r[23:0], data__in_w};
                    byte_num <= byte_num + 1'b1;
                end
            end

            data_write: begin
                if ((pre_bussy == 1'b1) && (bussy == 1'b0)) begin
                    data_to_mem <= {data_to_mem[119:0], data__in_w};
                    byte_num <= byte_num + 1'b1;
                end
            end

            preform_write_opration: begin
                if (ddr_bussy) begin
                    ddr_seen_busy <= 1'b1;
                end
            end

            preform_read_opration: begin
                if (ddr_bussy) begin
                    ddr_seen_busy <= 1'b1;
                end
            end

            data_read: begin
                case (tx_phase)

                    2'd0: begin
                        case (byte_num)
                            5'd0:  data_out <= tx_word[127:120];
                            5'd1:  data_out <= tx_word[119:112];
                            5'd2:  data_out <= tx_word[111:104];
                            5'd3:  data_out <= tx_word[103:96];
                            5'd4:  data_out <= tx_word[95:88];
                            5'd5:  data_out <= tx_word[87:80];
                            5'd6:  data_out <= tx_word[79:72];
                            5'd7:  data_out <= tx_word[71:64];
                            5'd8:  data_out <= tx_word[63:56];
                            5'd9:  data_out <= tx_word[55:48];
                            5'd10: data_out <= tx_word[47:40];
                            5'd11: data_out <= tx_word[39:32];
                            5'd12: data_out <= tx_word[31:24];
                            5'd13: data_out <= tx_word[23:16];
                            5'd14: data_out <= tx_word[15:8];
                            5'd15: data_out <= tx_word[7:0];
                            default: data_out <= 8'h00;
                        endcase

                        tx_seen_busy <= 1'b0;
                        tx_phase <= 2'd1;
                    end

                    2'd1: begin
                        if (!bussy) begin
                            write_flag <= 1'b1;
                            tx_phase <= 2'd2;
                        end
                    end

                    2'd2: begin
                        if (bussy) begin
                            tx_seen_busy <= 1'b1;
                        end

                        if (tx_seen_busy && !bussy) begin
                            byte_num <= byte_num + 1'b1;
                            tx_phase <= 2'd0;
                        end
                    end

                    default: begin
                        tx_phase <= 2'd0;
                    end

                endcase
            end

            default: begin
            end

        endcase
    end
end

endmodule