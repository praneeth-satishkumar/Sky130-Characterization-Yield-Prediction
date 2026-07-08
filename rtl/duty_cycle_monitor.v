`timescale 1ns / 1ps

module duty_cycle_monitor(
    input clk,
    input rst,
    input monitor_clk,
    input measure_enable,
    output reg bad_duty_cycle,
    output reg duty_ok,
    output reg [19:0] high_count,
    output reg [19:0] total_count,
    output reg done
    );
    
    localparam [19:0] LOW_DUTY_THRESHOLD  = 20'd400;
    localparam [19:0] HIGH_DUTY_THRESHOLD = 20'd600;

    reg [19:0] high_counter;
    reg [19:0] total_counter;

    reg measure_enable_prev;

    wire measure_end;

    assign measure_end = (measure_enable_prev == 1'b1 && measure_enable == 1'b0);

    always @(posedge clk) begin
        if(rst) begin
            bad_duty_cycle <= 1'b0;
            duty_ok <= 1'b0;

            high_count <= 20'd0;
            total_count <= 20'd0;

            high_counter <= 20'd0;
            total_counter <= 20'd0;

            measure_enable_prev <= 1'b0;
        end else begin
            measure_enable_prev <= measure_enable;

            if(measure_enable) begin
                total_counter <= total_counter + 1'b1;

                if(monitor_clk == 1'b1) begin
                    high_counter <= high_counter + 1'b1;
                end

                bad_duty_cycle <= 1'b0;
                duty_ok <= 1'b0;
            end

            else if(measure_end) begin
                high_count <= high_counter;
                total_count <= total_counter;

                if(high_counter < LOW_DUTY_THRESHOLD || high_counter > HIGH_DUTY_THRESHOLD) begin
                    bad_duty_cycle <= 1'b1;
                    duty_ok <= 1'b0;
                end else begin
                    bad_duty_cycle <= 1'b0;
                    duty_ok <= 1'b1;
                end

                high_counter <= 20'd0;
                total_counter <= 20'd0;
                done <= 1'b1;
            end
        end
    end
    
endmodule