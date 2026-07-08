`timescale 1ns / 1ps

module clock_integrity_system(
    input clk,
    input rst,
    input monitor_clk,

    output slow,
    output fast,
    output freq_ok,

    output bad_duty_cycle,
    output duty_ok,

    output missing_clock,
    output stuck_high,
    output stuck_low,

    output [15:0] edge_count,
    output [19:0] high_count,
    output [19:0] total_count,

    output reg clock_fault,
    output reg done
    );

    // Measurement window length
    localparam [15:0] MEASURE_LIMIT = 16'd1000;

    reg [15:0] measure_count;
    reg measure_enable;
    reg measure_tick;

    wire fm_done;

    // Create measurement window
    always @(posedge clk) begin
        if(rst) begin
            measure_count <= 16'd0;
            measure_enable <= 1'b0;
            measure_tick <= 1'b0;
            done <= 1'b0;
        end else begin
            measure_tick <= 1'b0;

            if(measure_count < MEASURE_LIMIT) begin
                measure_count <= measure_count + 1'b1;
                measure_enable <= 1'b1;
                done <= 1'b0;
            end else begin
                measure_enable <= 1'b0;
                measure_tick <= 1'b1;
                done <= 1'b1;
            end
        end
    end

    frequency_monitor fm(
        .clk(clk),
        .rst(rst),
        .monitor_clk(monitor_clk),
        .measure_tick(measure_tick),
        .slow(slow),
        .fast(fast),
        .freq_ok(freq_ok),
        .done(fm_done),
        .edge_count(edge_count)
    );

    duty_cycle_monitor dcm(
        .clk(clk),
        .rst(rst),
        .monitor_clk(monitor_clk),
        .measure_enable(measure_enable),
        .bad_duty_cycle(bad_duty_cycle),
        .duty_ok(duty_ok),
        .high_count(high_count),
        .total_count(total_count)
    );

    missing_clock_detector mcd(
        .clk(clk),
        .rst(rst),
        .monitor_clk(monitor_clk),
        .missing_clock(missing_clock),
        .stuck_high(stuck_high),
        .stuck_low(stuck_low)
    );

    always @(posedge clk) begin
        if(rst) begin
            clock_fault <= 1'b0;
        end else begin
            if(slow || fast || bad_duty_cycle || missing_clock || stuck_high || stuck_low) begin
                clock_fault <= 1'b1;
            end else begin
                clock_fault <= 1'b0;
            end
        end
    end

endmodule