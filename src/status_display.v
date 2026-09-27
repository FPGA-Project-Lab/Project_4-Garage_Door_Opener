`timescale 1ns / 1ps

module status_display(
    input  wire       clk,

    input  wire       fully_open,
    input  wire       fully_closed,

    output reg  [6:0] seg,
    output reg  [3:0] an,
    output wire       dp
);

    //////////////////////////////////
    // Character Codes
    // Active-Low: gfedcba
    //////////////////////////////////
    localparam [6:0] BLANK = 7'b1111111;

    localparam [6:0] C = 7'b1000110;
    localparam [6:0] L = 7'b1000111;
    localparam [6:0] S = 7'b0010010;

    localparam [6:0] O = 7'b1000000;
    localparam [6:0] P = 7'b0001100;
    localparam [6:0] E = 7'b0000110;


    //////////////////////////////////
    // Display Refresh
    //////////////////////////////////
    reg [17:0] refresh_counter = 0;

    wire [1:0] digit;

    always @(posedge clk)
        refresh_counter <= refresh_counter + 1'b1;

    assign digit =
        refresh_counter[17:16];


    //////////////////////////////////
    // Decimal Point Off
    //////////////////////////////////
    assign dp = 1'b1;


    //////////////////////////////////
    // Display Logic
    //////////////////////////////////
    always @(*) begin

        // Default = completely blank
        an  = 4'b1111;
        seg = BLANK;


        // Only enable display at an endpoint
        if (fully_open || fully_closed) begin

            case (digit)

                //////////////////////////////////
                // Leftmost Digit = Blank
                //////////////////////////////////
                2'b00: begin
                    an  = 4'b0111;
                    seg = BLANK;
                end


                //////////////////////////////////
                // First Letter
                // O or C
                //////////////////////////////////
                2'b01: begin
                    an = 4'b1011;

                    if (fully_open)
                        seg = O;
                    else
                        seg = C;
                end


                //////////////////////////////////
                // Second Letter
                // P or L
                //////////////////////////////////
                2'b10: begin
                    an = 4'b1101;

                    if (fully_open)
                        seg = P;
                    else
                        seg = L;
                end


                //////////////////////////////////
                // Third Letter
                // E or S
                //////////////////////////////////
                2'b11: begin
                    an = 4'b1110;

                    if (fully_open)
                        seg = E;
                    else
                        seg = S;
                end

            endcase

        end

    end

endmodule