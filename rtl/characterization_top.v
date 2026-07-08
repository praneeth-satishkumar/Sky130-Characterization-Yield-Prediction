`timescale 1ns / 1ps

module characterization_top(
    input clk,
    input rst,
    input start,
    input ro_clk_0,
    input ro_clk_1,
    input ro_clk_2,
    input clk_slow,
    input clk_fast,
    input clk_bad_duty,
    input clk_stuck_high,
    input clk_stuck_low,
    output reg [7:0]  ro_count_reg_0,
    output reg [7:0]  ro_count_reg_1,
    output reg [7:0]  ro_count_reg_2,
    output reg [15:0] delay_count_reg_0,
    output reg [15:0] delay_count_reg_1,
    output reg [15:0] delay_count_reg_2,
    output reg [7:0] status_reg,
    output reg [7:0] clock_status_reg,
    output reg [2:0] corner_class_reg,
    output reg busy,
    output reg done
);

    localparam IDLE        = 3'd0;
    localparam START_RO    = 3'd1;
    localparam WAIT_RO     = 3'd2;
    localparam START_DELAY = 3'd3;
    localparam WAIT_DELAY  = 3'd4;
    localparam STORE       = 3'd5;
    localparam DONE_STATE  = 3'd6;

    reg [2:0] state;
    reg start_prev;
    wire start_pulse;

    assign start_pulse = start && !start_prev;

    reg ro_start;

    wire [7:0] ro_count_0;
    wire [7:0] ro_count_1;
    wire [7:0] ro_count_2;
    wire ro_warning;
    wire ro_fault;
    wire ro_done;

    reg delay_start;

    wire [15:0] delay_count_0;
    wire [15:0] delay_count_1;
    wire [15:0] delay_count_2;
    wire [2:0] delay_status;
    wire delay_done;

    wire clock_fault;

    assign clock_fault = clk_slow | clk_fast | clk_bad_duty | clk_stuck_high | clk_stuck_low;

    localparam [7:0] SLOW_CLASS_THRESHOLD = 8'd100;
    localparam [7:0] FAST_CLASS_THRESHOLD = 8'd200;

    wire slow_process;
    wire fast_process;
    wire normal_process;

    assign slow_process =
        (ro_count_0 < SLOW_CLASS_THRESHOLD) ||
        (ro_count_1 < SLOW_CLASS_THRESHOLD) ||
        (ro_count_2 < SLOW_CLASS_THRESHOLD);

    assign fast_process =
        (ro_count_0 > FAST_CLASS_THRESHOLD) ||
        (ro_count_1 > FAST_CLASS_THRESHOLD) ||
        (ro_count_2 > FAST_CLASS_THRESHOLD);

    assign normal_process = !slow_process && !fast_process && !ro_fault;

    wire real_ro_clk_0;
    wire real_ro_clk_1;
    wire real_ro_clk_2;

    sky130_ring_oscillator ro0 (
        .enable(start),
        .ro_out(real_ro_clk_0)
    );

    sky130_ring_oscillator ro1 (
        .enable(start),
        .ro_out(real_ro_clk_1)
    );

    sky130_ring_oscillator ro2 (
        .enable(start),
        .ro_out(real_ro_clk_2)
    );

    // Existing RO counter module
    ro_counter ro_counter_inst (
        .clk(clk),
        .rst(rst),
        .start(ro_start),
        .ro_clk_0(real_ro_clk_0),
        .ro_clk_1(real_ro_clk_1),
        .ro_clk_2(real_ro_clk_2),
        .ro_count_0(ro_count_0),
        .ro_count_1(ro_count_1),
        .ro_count_2(ro_count_2),
        .warning(ro_warning),
        .fault(ro_fault),
        .done(ro_done)
    );

    // Delay-chain measurement block
    delay_chain_block delay_chain_inst (
        .clk(clk),
        .rst(rst),
        .start(delay_start),
        .delay_count_0(delay_count_0),
        .delay_count_1(delay_count_1),
        .delay_count_2(delay_count_2),
        .delay_status(delay_status),
        .done(delay_done)
    );

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;

            start_prev <= 1'b0;

            ro_start <= 1'b0;
            delay_start <= 1'b0;

            ro_count_reg_0 <= 8'd0;
            ro_count_reg_1 <= 8'd0;
            ro_count_reg_2 <= 8'd0;

            delay_count_reg_0 <= 16'd0;
            delay_count_reg_1 <= 16'd0;
            delay_count_reg_2 <= 16'd0;

            status_reg <= 8'd0;
            clock_status_reg <= 8'd0;
            corner_class_reg <= 3'd0;

            busy <= 1'b0;
            done <= 1'b0;
        end else begin
            start_prev <= start;

            // Default one-cycle start pulses
            ro_start <= 1'b0;
            delay_start <= 1'b0;

            case(state)

                IDLE: begin
                    busy <= 1'b0;
                    done <= 1'b0;

                    status_reg[0] <= 1'b0; // measurement_done
                    status_reg[1] <= 1'b0; // busy

                    if(start_pulse) begin
                        busy <= 1'b1;
                        status_reg <= 8'd0;
                        clock_status_reg <= 8'd0;
                        corner_class_reg <= 3'd0;
                        state <= START_RO;
                    end
                end

                START_RO: begin
                    busy <= 1'b1;
                    status_reg[1] <= 1'b1; // busy
                    ro_start <= 1'b1;
                    state <= WAIT_RO;
                end

                WAIT_RO: begin
                    busy <= 1'b1;

                    if(ro_done) begin
                        ro_count_reg_0 <= ro_count_0;
                        ro_count_reg_1 <= ro_count_1;
                        ro_count_reg_2 <= ro_count_2;

                        status_reg[2] <= ro_warning;
                        status_reg[3] <= ro_fault;

                        state <= START_DELAY;
                    end
                end

                START_DELAY: begin
                    delay_start <= 1'b1;
                    state <= WAIT_DELAY;
                end

                WAIT_DELAY: begin
                    if(delay_done) begin
                        delay_count_reg_0 <= delay_count_0;
                        delay_count_reg_1 <= delay_count_1;
                        delay_count_reg_2 <= delay_count_2;

                        state <= STORE;
                    end
                end

                STORE: begin
                    // Clock status register
                    clock_status_reg[0] <= clk_slow;
                    clock_status_reg[1] <= clk_fast;
                    clock_status_reg[2] <= clk_bad_duty;
                    clock_status_reg[3] <= clk_stuck_high;
                    clock_status_reg[4] <= clk_stuck_low;
                    clock_status_reg[5] <= clock_fault;
                    clock_status_reg[7:6] <= 2'b00;

                    // Main status register
                    status_reg[0] <= 1'b1;        // measurement done
                    status_reg[1] <= 1'b0;        // not busy
                    status_reg[2] <= ro_warning;  // RO warning
                    status_reg[3] <= ro_fault;    // RO fault
                    status_reg[4] <= clock_fault; // clock fault
                    status_reg[5] <= delay_done;  // delay measurement done
                    status_reg[6] <= delay_status[0]; // delay fast
                    status_reg[7] <= delay_status[2]; // delay slow

                    // Corner classification register
                    corner_class_reg[0] <= slow_process;
                    corner_class_reg[1] <= normal_process;
                    corner_class_reg[2] <= fast_process;

                    state <= DONE_STATE;
                end

                DONE_STATE: begin
                    busy <= 1'b0;
                    done <= 1'b1;

                    if(start_pulse) begin
                        done <= 1'b0;
                        busy <= 1'b1;
                        state <= START_RO;
                    end
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule
