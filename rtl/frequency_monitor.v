`timescale 1ns / 1ps

module frequency_monitor(
    input clk,
    input rst,
    input monitor_clk,
    input measure_tick,
    output reg slow,
    output reg fast,
    output reg freq_ok,
    output reg done,
    output reg [15:0] edge_count
    );
    
    localparam [15:0] SLOW_THRESHOLD = 16'd90;
    localparam [15:0] FAST_THRESHOLD = 16'd210;
    
    reg prev_clk;
    reg [15:0] tick_count;

    wire rising_edge;
    wire [15:0] next_count;

    assign rising_edge = (monitor_clk == 1'b1 && prev_clk == 1'b0);
    assign next_count = tick_count + (rising_edge ? 16'd1 : 16'd0);
    
    always @(posedge clk) begin
        if(rst) begin
            slow <= 1'b0;
            fast <= 1'b0;
            freq_ok <= 1'b0;
            done <= 1'b0;
            edge_count <= 16'd0;
            tick_count <= 16'd0;
            prev_clk <= 1'b0;
        end else begin
            done <= 1'b0;
            prev_clk <= monitor_clk;

            if(measure_tick) begin
                edge_count <= next_count;
                tick_count <= 16'd0;
                done <= 1'b1;

                slow <= 1'b0;
                fast <= 1'b0;
                freq_ok <= 1'b0;

                if(next_count < SLOW_THRESHOLD) begin
                    slow <= 1'b1;
                end else if(next_count > FAST_THRESHOLD) begin
                    fast <= 1'b1;
                end else begin
                    freq_ok <= 1'b1;
                end
            end else begin
                tick_count <= next_count;
            end
        end
    end

endmodule