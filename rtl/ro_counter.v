`timescale 1ns / 1ps

module ro_counter(
    input clk,
    input rst,
    input start,
    input ro_clk_0,
    input ro_clk_1,
    input ro_clk_2,
    output reg [7:0] ro_count_0,
    output reg [7:0] ro_count_1,
    output reg [7:0] ro_count_2,
    output reg warning,
    output reg fault,
    output reg done
    );
    
    localparam [9:0] MEASUREMENT_LIMIT = 10'd1000;

    localparam [7:0] SLOW_THRESHOLD = 8'd90;
    localparam [7:0] FAST_THRESHOLD = 8'd210;

    localparam [7:0] SLOW_WARNING = 8'd100;
    localparam [7:0] FAST_WARNING = 8'd200;

    reg [9:0] measurement_window;

    reg [7:0] count_0;
    reg [7:0] count_1;
    reg [7:0] count_2;

    reg prev_rclk_0;
    reg prev_rclk_1;
    reg prev_rclk_2;

    reg measuring;
    reg start_prev;

    wire start_pulse;

    assign start_pulse = start && !start_prev;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            ro_count_0 <= 8'd0;
            ro_count_1 <= 8'd0;
            ro_count_2 <= 8'd0;

            count_0 <= 8'd0;
            count_1 <= 8'd0;
            count_2 <= 8'd0;

            warning <= 1'b0;
            fault <= 1'b0;
            done <= 1'b0;

            prev_rclk_0 <= 1'b0;
            prev_rclk_1 <= 1'b0;
            prev_rclk_2 <= 1'b0;

            measurement_window <= 10'd0;
            measuring <= 1'b0;
            start_prev <= 1'b0;
        end else begin
            start_prev <= start;

            if(start_pulse) begin
                measurement_window <= 10'd0;

                count_0 <= 8'd0;
                count_1 <= 8'd0;
                count_2 <= 8'd0;

                ro_count_0 <= 8'd0;
                ro_count_1 <= 8'd0;
                ro_count_2 <= 8'd0;

                warning <= 1'b0;
                fault <= 1'b0;
                done <= 1'b0;

                measuring <= 1'b1;

                prev_rclk_0 <= ro_clk_0;
                prev_rclk_1 <= ro_clk_1;
                prev_rclk_2 <= ro_clk_2;
            end

            else if(measuring) begin
                if(measurement_window < MEASUREMENT_LIMIT) begin
                    measurement_window <= measurement_window + 1'b1;

                    if(prev_rclk_0 == 1'b0 && ro_clk_0 == 1'b1) begin
                        count_0 <= count_0 + 1'b1;
                    end

                    if(prev_rclk_1 == 1'b0 && ro_clk_1 == 1'b1) begin
                        count_1 <= count_1 + 1'b1;
                    end

                    if(prev_rclk_2 == 1'b0 && ro_clk_2 == 1'b1) begin
                        count_2 <= count_2 + 1'b1;
                    end

                    prev_rclk_0 <= ro_clk_0;
                    prev_rclk_1 <= ro_clk_1;
                    prev_rclk_2 <= ro_clk_2;
                end

                else begin
                    measuring <= 1'b0;
                    done <= 1'b1;

                    ro_count_0 <= count_0;
                    ro_count_1 <= count_1;
                    ro_count_2 <= count_2;

                    if((count_0 < SLOW_THRESHOLD) || (count_0 > FAST_THRESHOLD) ||
                       (count_1 < SLOW_THRESHOLD) || (count_1 > FAST_THRESHOLD) ||
                       (count_2 < SLOW_THRESHOLD) || (count_2 > FAST_THRESHOLD)) begin
                        fault <= 1'b1;
                        warning <= 1'b0;
                    end

                    else if((count_0 < SLOW_WARNING) || (count_0 > FAST_WARNING) ||
                            (count_1 < SLOW_WARNING) || (count_1 > FAST_WARNING) ||
                            (count_2 < SLOW_WARNING) || (count_2 > FAST_WARNING)) begin
                        warning <= 1'b1;
                        fault <= 1'b0;
                    end

                    else begin
                        warning <= 1'b0;
                        fault <= 1'b0;
                    end
                end
            end
        end
    end

endmodule