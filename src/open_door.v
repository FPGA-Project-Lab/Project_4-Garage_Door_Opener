`timescale 1ns / 1ps

module open_door(
    input  wire [15:0] current_position,
    output wire [15:0] next_position
);

    assign next_position = current_position >> 1;

endmodule