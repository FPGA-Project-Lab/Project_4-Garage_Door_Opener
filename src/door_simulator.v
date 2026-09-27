`timescale 1ns / 1ps

module door_simulator(
    input  wire        clk,
    input  wire        move_tick,

    input  wire        motor_up,
    input  wire        motor_down,

    output wire [15:0] LED,

    output wire        fully_open,
    output wire        fully_closed
);

    //////////////////////////////////
    // 14-Bit Door Position
    //////////////////////////////////
    reg [13:0] door_position =
        14'b00000000000000;


    //////////////////////////////////
    // Limit Sensors
    //////////////////////////////////
    assign fully_open =
        (door_position == 14'h0000);

    assign fully_closed =
        (door_position == 14'h3FFF);


    //////////////////////////////////
    // Door Movement
    //////////////////////////////////
    always @(posedge clk) begin

        if (move_tick) begin

            // Close
            if (
                motor_down &&
                !motor_up &&
                !fully_closed
            )
                door_position <=
                    (door_position << 1) | 14'b1;


            // Open
            else if (
                motor_up &&
                !motor_down &&
                !fully_open
            )
                door_position <=
                    door_position >> 1;

        end

    end


    //////////////////////////////////
    // LEDs 1-14 = Door
    // LEDs 0 and 15 = Off
    //////////////////////////////////
    assign LED =
        {1'b0, door_position, 1'b0};

endmodule