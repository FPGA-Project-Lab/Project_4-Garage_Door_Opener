`timescale 1ns / 1ps

module door_leds #(
    parameter integer DEBOUNCE_COUNT = 2_000_000
)(
    input  wire        clk,
    input  wire        move_tick,
    input  wire        door_btn,
    input  wire        abort_btn,

    input  wire [15:0] open_next,
    input  wire [15:0] close_next,

    output wire [15:0] LED,
    output wire [15:0] current_position
);

    //////////////////////////////////
    // Motion States
    //////////////////////////////////
    localparam [1:0] STOPPED = 2'b00;
    localparam [1:0] OPENING = 2'b01;
    localparam [1:0] CLOSING = 2'b10;

    reg [1:0] motion = STOPPED;


    //////////////////////////////////
    // Door Position
    //////////////////////////////////
    reg [15:0] door_position = 16'h0000;


    //////////////////////////////////
    // Main Door Button Debounce
    //////////////////////////////////
    wire clean_door_btn;

    debounce #(
        .STABLE_COUNT(DEBOUNCE_COUNT)
    ) debounce_door (
        .clk(clk),
        .noisy_btn(door_btn),
        .clean_btn(clean_door_btn)
    );


    //////////////////////////////////
    // Abort Button Debounce
    //////////////////////////////////
    wire clean_abort_btn;

    debounce #(
        .STABLE_COUNT(DEBOUNCE_COUNT)
    ) debounce_abort (
        .clk(clk),
        .noisy_btn(abort_btn),
        .clean_btn(clean_abort_btn)
    );


    //////////////////////////////////
    // Main Button Edge Detection
    //////////////////////////////////
    reg door_btn_prev = 1'b0;

    wire door_pulse;

    assign door_pulse =
        clean_door_btn & ~door_btn_prev;


    always @(posedge clk) begin
        door_btn_prev <= clean_door_btn;
    end


    //////////////////////////////////
    // Door Controller
    //////////////////////////////////
    always @(posedge clk) begin

        //////////////////////////////////
        // Safety Abort
        //////////////////////////////////
        if (
            clean_abort_btn &&
            motion == CLOSING
        ) begin

            motion <= OPENING;

        end


        //////////////////////////////////
        // Main Door Button
        //////////////////////////////////
        else if (door_pulse) begin

            case (motion)

                ////////////////////////////
                // Reverse While Opening
                ////////////////////////////
                OPENING: begin
                    motion <= CLOSING;
                end


                ////////////////////////////
                // Reverse While Closing
                ////////////////////////////
                CLOSING: begin
                    motion <= OPENING;
                end


                ////////////////////////////
                // Door Currently Stopped
                ////////////////////////////
                default: begin

                    if (door_position == 16'h0000)
                        motion <= CLOSING;

                    else if (door_position == 16'hFFFF)
                        motion <= OPENING;

                end

            endcase

        end


        //////////////////////////////////
        // Movement Tick
        //////////////////////////////////
        else if (move_tick) begin

            case (motion)

                ////////////////////////////
                // Opening
                ////////////////////////////
                OPENING: begin

                    door_position <= open_next;

                    if (open_next == 16'h0000)
                        motion <= STOPPED;

                end


                ////////////////////////////
                // Closing
                ////////////////////////////
                CLOSING: begin

                    door_position <= close_next;

                    if (close_next == 16'hFFFF)
                        motion <= STOPPED;

                end


                ////////////////////////////
                // Stopped
                ////////////////////////////
                default: begin
                    motion <= STOPPED;
                end

            endcase

        end

    end


    //////////////////////////////////
    // Outputs
    //////////////////////////////////
    assign LED = door_position;

    assign current_position =
        door_position;

endmodule