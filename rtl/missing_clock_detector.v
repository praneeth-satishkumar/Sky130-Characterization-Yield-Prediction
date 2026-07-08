`timescale 1ns / 1ps

module missing_clock_detector(
    input clk,
    input rst,
    input monitor_clk,
    output reg missing_clock,
    output reg stuck_high,
    output reg stuck_low,
    output reg done
    );

    localparam [15:0] TIMEOUT_LIMIT = 16'd1000;

    reg [15:0] timeout_count;

    // Synchronize monitor_clk into clk domain
    reg monitor_clk_sync_0;
    reg monitor_clk_sync_1;
    reg prev_monitor_clk;

    wire edge_detected;

    assign edge_detected = monitor_clk_sync_1 ^ prev_monitor_clk;

    always @(posedge clk) begin
        if(rst) begin
            missing_clock <= 1'b0;
            stuck_high <= 1'b0;
            stuck_low <= 1'b0;

            timeout_count <= 16'd0;

            monitor_clk_sync_0 <= 1'b0;
            monitor_clk_sync_1 <= 1'b0;
            prev_monitor_clk <= 1'b0;
        end else begin

            // 2-stage synchronizer
            monitor_clk_sync_0 <= monitor_clk;
            monitor_clk_sync_1 <= monitor_clk_sync_0;
            prev_monitor_clk <= monitor_clk_sync_1;

            if(edge_detected) begin
                timeout_count <= 16'd0;

                missing_clock <= 1'b0;
                stuck_high <= 1'b0;
                stuck_low <= 1'b0;
                done <= 1'b1;
            end else begin
                if(timeout_count < TIMEOUT_LIMIT) begin
                    timeout_count <= timeout_count + 1'b1;
                end else begin
                    timeout_count <= TIMEOUT_LIMIT;

                    missing_clock <= 1'b1;

                    if(monitor_clk_sync_1 == 1'b1) begin
                        stuck_high <= 1'b1;
                        stuck_low <= 1'b0;
                        done <= 1'b1;
                    end else begin
                        stuck_high <= 1'b0;
                        stuck_low <= 1'b1;
                        done <= 1'b1;
                    end
                end
            end
        end
    end

endmodule