`timescale 1ns / 1ps

module main #(
    parameter integer DEBOUNCE_COUNT = 2_000_000,
    parameter integer TICK_COUNT = 20_000_000
)(
    input  wire        CLK100MHZ,

    input  wire        door_btn,
    input  wire        abort_btn,

    output wire [15:0] LED,

    output wire [6:0]  seg,
    output wire [3:0]  an,
    output wire        dp
);

    //////////////////////////////////
    // Internal Signals
    //////////////////////////////////
    wire move_tick;

    wire motor_up;
    wire motor_down;

    wire fully_open;
    wire fully_closed;


    //////////////////////////////////
    // Garage Door Controller
    //////////////////////////////////
    garage_controller #(
        .DEBOUNCE_COUNT(DEBOUNCE_COUNT)
    ) garage_controller_inst (
        .clk(CLK100MHZ),

        .door_btn(door_btn),
        .abort_btn(abort_btn),

        .fully_open(fully_open),
        .fully_closed(fully_closed),

        .motor_up(motor_up),
        .motor_down(motor_down)
    );


    //////////////////////////////////
    // Clock Divider
    //////////////////////////////////
    clock_divider #(
        .TICK_COUNT(TICK_COUNT)
    ) clock_divider_inst (
        .clk(CLK100MHZ),
        .move_tick(move_tick)
    );


    //////////////////////////////////
    // Simulated Physical Door
    //////////////////////////////////
    door_simulator door_simulator_inst (
        .clk(CLK100MHZ),
        .move_tick(move_tick),

        .motor_up(motor_up),
        .motor_down(motor_down),

        .LED(LED),

        .fully_open(fully_open),
        .fully_closed(fully_closed)
    );


    //////////////////////////////////
    // Garage Door Status Display
    //////////////////////////////////
    status_display status_display_inst (
        .clk(CLK100MHZ),

        .fully_open(fully_open),
        .fully_closed(fully_closed),

        .seg(seg),
        .an(an),
        .dp(dp)
    );

endmodule