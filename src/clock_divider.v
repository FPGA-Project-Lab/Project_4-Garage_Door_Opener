`timescale 1ns / 1ps

module clock_divider #(
    parameter integer TICK_COUNT = 20_000_000
)(
    input  wire clk,
    output reg  move_tick = 1'b0
);

    localparam integer COUNT_WIDTH =
        (TICK_COUNT <= 1) ? 1 : $clog2(TICK_COUNT);

    reg [COUNT_WIDTH-1:0] counter = 0;


    always @(posedge clk) begin

        if (counter == TICK_COUNT - 1) begin
            counter   <= 0;
            move_tick <= 1'b1;
        end

        else begin
            counter   <= counter + 1'b1;
            move_tick <= 1'b0;
        end

    end

endmodule