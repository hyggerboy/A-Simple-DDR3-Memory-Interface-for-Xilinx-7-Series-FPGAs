module fasttest(
    input wire clk,
    input wire rx,
    output wire tx,
    input wire ddr_bussy,
    input wire [127:0] data_from_mem,
    output reg write_to_mem = 1'b0,
    output reg read_from_mem = 1'b0,
    output reg [31:0]  adresse = 32'd0,
    output reg [127:0] data_to_write_to_mem = 128'd0,
    input wire bnt,
    output wire [15:0] mask
);

reg [31:0] time_of_opration = 0;
 
    ila_69 your_instance_name (
        .clk(clk),
        .probe0(state),
        .probe1(ddr_bussy),
        .probe2(time_of_opration)

    );
 
    reg write_flag = 1'b0;
    wire bussy;
    reg [7:0] data__in_w = 8'd0;
    wire [7:0] data_out;
 
    uart uboy (
        .clk(clk),
        .tx(tx),
        .rx(rx),
        .write_flag(write_flag),
        .bussy(bussy),
        .data__in_w(data_out),
        .data_out(data__in_w)
    );
 
    wire [127:0] data;
 
    BRAM1 ROM_data(
        .clk(clk),
        .addr(cnt),
        .dout(data)
    );
    
     BRAMMASK ROM_mask(
        .clk(clk),
        .addr(cnt),
        .dout(mask)
    );
    wire [31:0] adresse_from_rom;
 
    BRAM3 ROM_adresse_write(
        .clk(clk),
        .addr(cnt),
        .dout(adresse_from_rom)
    );
    
    wire [31:0] adresse_from_rom_r;
    
    BRAM4 ROM_adresse_read(
        .clk(clk),
        .addr(cnt),
        .dout(adresse_from_rom_r)
    );

    reg we = 1'b0;
    reg [7:0] addr = 8'd0;
    reg [127:0] din = 128'd0;
    wire [127:0] dout;
 
    BRAM2 RWM(
        .clk(clk),
        .we(we),
        .addr(addr),
        .din(din),
        .dout(dout)
    );
 
    localparam [3:0]
        ideal              = 4'd0,
        send_data          = 4'd3,
        wait_for_send_data = 4'd4,
        read_data          = 4'd5,
        read_data_wait     = 4'd6,
        uart_wait_bram     = 4'd8,
        uart               = 4'd9,
        uart_wait_busy     = 4'd10,
        uart_wait_done     = 4'd11,
        done               = 4'd12,
        wait_a_bit         = 4'd13;

    reg [3:0] state = ideal;
    reg [3:0] nextstate = ideal;
    reg [8:0] cnt = 8'd0;
    reg [8:0] dincnt = 4'd0;
    reg [8:0] adresse_cnt = 8'd0;
    reg [6:0] uart_bit_num = 0;
    reg [8:0] bramcnt = 0;
    reg [8:0] data_to_uart;

    reg [7:0] bram_write_addr = 8'd0;

    // seen_busy flags to ensure DDR actually started before we check done
    reg ddr_seen_busy_write = 1'b0;
    reg ddr_seen_busy_read  = 1'b0;

    // seen_busy for UART TX
    reg uart_seen_busy = 1'b0;
 
    always @* begin
 
        nextstate = state;
 
        write_to_mem  = 1'b0;
        read_from_mem = 1'b0;
        write_flag    = 1'b0;
        we            = 1'b0;
 
        case(state)
 
            ideal: begin
                if(!ddr_bussy && bnt) begin
                    nextstate = wait_a_bit;
                end else begin
                    nextstate = ideal;
                end
            end
            
            wait_a_bit: begin
                nextstate            = send_data;
                write_to_mem         = 1'b1;
                data_to_write_to_mem = data;
                adresse              = adresse_from_rom;
            end    
 
            send_data: begin
                if(cnt < 9'd256) begin
                    if(!ddr_bussy) begin
                        data_to_write_to_mem = data;
                        adresse              = adresse_from_rom;
                        write_to_mem         = 1'b1;
                        nextstate            = send_data;
                    end else begin
                        nextstate = wait_for_send_data;
                    end
                end else begin
                    nextstate = read_data;
                end
            end
 
            // wait for DDR to go busy then finish before moving on
            wait_for_send_data: begin
                if (!ddr_bussy) begin
                    nextstate = send_data;
                end else begin
                    nextstate = wait_for_send_data;
                end
            end
 
            read_data: begin
                if(cnt < 9'd256) begin
                    if(!ddr_bussy) begin
                        adresse       = adresse_from_rom_r;
                        read_from_mem = 1'b1;
                        nextstate     = read_data;
                    end else begin
                        nextstate = read_data_wait;
                    end
                end else begin
                    nextstate = uart_wait_bram;
                end
            end
 
            // wait for DDR to go busy then finish before capturing data
            read_data_wait: begin
                if (!ddr_bussy) begin
                    din       = data_from_mem;
                    addr      = bram_write_addr;
                    we        = 1'b1;
                    nextstate = read_data;
                end else begin
                    nextstate = read_data_wait;
                end
            end
 
            uart_wait_bram: begin
                addr      = bramcnt;
                we        = 1'b0;
                nextstate = uart;
            end
 
            uart: begin
                addr = bramcnt;
                if (bramcnt < 256) begin
                    we = 1'b0;
                    if(!bussy) begin
                        write_flag = 1'b1;
                        case(uart_bit_num)
                            4'd0:  data_to_uart = dout[127:120];
                            4'd1:  data_to_uart = dout[119:112];
                            4'd2:  data_to_uart = dout[111:104];
                            4'd3:  data_to_uart = dout[103:96];
                            4'd4:  data_to_uart = dout[95:88];
                            4'd5:  data_to_uart = dout[87:80];
                            4'd6:  data_to_uart = dout[79:72];
                            4'd7:  data_to_uart = dout[71:64];
                            4'd8:  data_to_uart = dout[63:56];
                            4'd9:  data_to_uart = dout[55:48];
                            4'd10: data_to_uart = dout[47:40];
                            4'd11: data_to_uart = dout[39:32];
                            4'd12: data_to_uart = dout[31:24];
                            4'd13: data_to_uart = dout[23:16];
                            4'd14: data_to_uart = dout[15:8];
                            4'd15: data_to_uart = dout[7:0];
                        endcase
                        nextstate = uart_wait_busy;
                    end else begin
                        nextstate = uart;
                    end
                end else begin
                    nextstate = done;
                end
            end
 
            // wait for UART to go busy then finish
            uart_wait_busy: begin
                addr = bramcnt;
                if (uart_seen_busy && !bussy) begin
                    if(uart_bit_num == 0) begin
                        nextstate = uart_wait_bram;
                    end else begin
                        nextstate = uart;
                    end
                end else begin
                    nextstate = uart_wait_busy;
                end
            end
 
            done: begin
                nextstate = done;
            end
 
            default: begin
                nextstate = ideal;
            end
 
        endcase
    end
 
    always @(posedge clk) begin
        state <= nextstate;
 
        if(!bussy && state == uart) begin
            data__in_w <= data_to_uart;
        end

        // ddr seen_busy for writes
        if (state == wait_for_send_data) begin
            if (ddr_bussy) ddr_seen_busy_write <= 1'b1;
        end else begin
            ddr_seen_busy_write <= 1'b0;
        end

        // ddr seen_busy for reads
        if (state == read_data_wait) begin
            if (ddr_bussy) ddr_seen_busy_read <= 1'b1;
        end else begin
            ddr_seen_busy_read <= 1'b0;
        end

        // uart seen_busy
        if (state == uart_wait_busy) begin
            if (bussy) uart_seen_busy <= 1'b1;
        end else begin
            uart_seen_busy <= 1'b0;
        end
 
        if(state == ideal) begin
            cnt            <= 0;
            adresse_cnt    <= 0;
            dincnt         <= 0;
            bram_write_addr <= 0;
        end
 
        if(state == send_data && nextstate == wait_for_send_data) begin
            cnt <= cnt + 1;
        end
 
        if(state == send_data && nextstate == read_data) begin
            cnt <= 0;
        end
 
        if(state == read_data && nextstate == read_data_wait) begin
            bram_write_addr <= cnt;
            cnt             <= cnt + 1;
        end
 
        if(state == read_data && nextstate == uart_wait_bram) begin
            bramcnt <= 0;
        end
 
        if(state == uart && nextstate == uart_wait_busy) begin
            if(uart_bit_num < 15) begin
                uart_bit_num <= uart_bit_num + 1;
            end else begin
                uart_bit_num <= 0;
                bramcnt      <= bramcnt + 1;
            end
        end
    end
    
always@(posedge clk) begin     
    if (state == 4'd3 || state == 4'd4 || state == 4'd5 || state == 4'd6) begin 
        time_of_opration <= time_of_opration +1;
     end else begin
            time_of_opration <= time_of_opration;
     end
end
                  
 
endmodule