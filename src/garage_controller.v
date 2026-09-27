`timescale 1ns / 1ps

module garage_controller #(
    parameter integer DEBOUNCE_COUNT = 2_000_000
)(
    input  wire clk,

    input  wire door_btn,
    input  wire abort_btn,

    input  wire fully_open,
    input  wire fully_closed,

    output wire motor_up,
    output wire motor_down
);

    //////////////////////////////////
    // States
    //////////////////////////////////
    localparam [1:0] STOPPED = 2'b00;
    localparam [1:0] OPENING = 2'b01;
    localparam [1:0] CLOSING = 2'b10;

    reg [1:0] motion = STOPPED;


    //////////////////////////////////
    // Debounce Buttons
    //////////////////////////////////
    wire clean_door_btn;
    wire clean_abort_btn;

    debounce #(
        .STABLE_COUNT(DEBOUNCE_COUNT)
    ) debounce_door (
        .clk(clk),
        .noisy_btn(door_btn),
        .clean_btn(clean_door_btn)
    );

    debounce #(
        .STABLE_COUNT(DEBOUNCE_COUNT)
    ) debounce_abort (
        .clk(clk),
        .noisy_btn(abort_btn),
        .clean_btn(clean_abort_btn)
    );


    //////////////////////////////////
    // Door Button Edge Detection
    //////////////////////////////////
    reg door_btn_prev = 1'b0;

    wire door_pulse;

    assign door_pulse =
        clean_door_btn & ~door_btn_prev;


    //////////////////////////////////
    // State Machine
    //////////////////////////////////
    always @(posedge clk) begin

        door_btn_prev <= clean_door_btn;

        case (motion)

            //////////////////////////////////
            // Door Stopped
            //////////////////////////////////
            STOPPED: begin

                if (door_pulse) begin

                    if (fully_open)
                        motion <= CLOSING;

                    else if (fully_closed)
                        motion <= OPENING;

                end

            end


            //////////////////////////////////
            // Door Opening
            //////////////////////////////////
            OPENING: begin

                if (fully_open)
                    motion <= STOPPED;

                else if (door_pulse)
                    motion <= CLOSING;

            end


            //////////////////////////////////
            // Door Closing
            //////////////////////////////////
            CLOSING: begin

                if (fully_closed)
                    motion <= STOPPED;

                else if (clean_abort_btn)
                    motion <= OPENING;

                else if (door_pulse)
                    motion <= OPENING;

            end


            //////////////////////////////////
            // Safety Default
            //////////////////////////////////
            default:
                motion <= STOPPED;

        endcase

    end


    //////////////////////////////////
    // Moore Outputs
    //////////////////////////////////
    assign motor_up =
        (motion == OPENING);

    assign motor_down =
        (motion == CLOSING);

endmodule