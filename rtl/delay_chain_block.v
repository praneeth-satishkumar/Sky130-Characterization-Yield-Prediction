`timescale 1ns / 1ps

module delay_chain_block(
    input clk,
    input rst,
    input start,
    output reg [15:0] delay_count_0,
    output reg [15:0] delay_count_1,
    output reg [15:0] delay_count_2,
    output reg [2:0] delay_status,
    output reg done
);

    reg start_prev;
    wire start_pulse;

    assign start_pulse = start && !start_prev;

    reg measuring;

    reg [15:0] cycle_count;

    reg [7:0]  chain_0;
    reg [15:0] chain_1;
    reg [31:0] chain_2;

    reg chain_0_done;
    reg chain_1_done;
    reg chain_2_done;

    localparam [15:0] FAST_DELAY_THRESHOLD = 16'd12;
    localparam [15:0] SLOW_DELAY_THRESHOLD = 16'd40;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            start_prev <= 1'b0;
            measuring <= 1'b0;

            cycle_count <= 16'd0;

            chain_0 <= 8'd0;
            chain_1 <= 16'd0;
            chain_2 <= 32'd0;

            chain_0_done <= 1'b0;
            chain_1_done <= 1'b0;
            chain_2_done <= 1'b0;

            delay_count_0 <= 16'd0;
            delay_count_1 <= 16'd0;
            delay_count_2 <= 16'd0;

            delay_status <= 3'd0;
            done <= 1'b0;
        end else begin
            start_prev <= start;

            if(start_pulse) begin
                measuring <= 1'b1;
                done <= 1'b0;

                cycle_count <= 16'd0;

                chain_0 <= 8'b00000001;
                chain_1 <= 16'b0000000000000001;
                chain_2 <= 32'h00000001;

                chain_0_done <= 1'b0;
                chain_1_done <= 1'b0;
                chain_2_done <= 1'b0;

                delay_count_0 <= 16'd0;
                delay_count_1 <= 16'd0;
                delay_count_2 <= 16'd0;

                delay_status <= 3'd0;
            end

            else if(measuring) begin
                cycle_count <= cycle_count + 1'b1;

                chain_0 <= {chain_0[6:0], 1'b0};
                chain_1 <= {chain_1[14:0], 1'b0};
                chain_2 <= {chain_2[30:0], 1'b0};

                if(chain_0[7] == 1'b1 && chain_0_done == 1'b0) begin
                    delay_count_0 <= cycle_count;
                    chain_0_done <= 1'b1;
                end

                if(chain_1[15] == 1'b1 && chain_1_done == 1'b0) begin
                    delay_count_1 <= cycle_count;
                    chain_1_done <= 1'b1;
                end

                if(chain_2[31] == 1'b1 && chain_2_done == 1'b0) begin
                    delay_count_2 <= cycle_count;
                    chain_2_done <= 1'b1;
                end

                if(chain_0_done && chain_1_done && chain_2_done) begin
                    measuring <= 1'b0;
                    done <= 1'b1;

                    if(delay_count_2 < FAST_DELAY_THRESHOLD) begin
                        delay_status <= 3'b001;
                    end else if(delay_count_2 > SLOW_DELAY_THRESHOLD) begin
                        delay_status <= 3'b100;
                    end else begin
                        delay_status <= 3'b010;
                    end
                end
            end
        end
    end

endmodule