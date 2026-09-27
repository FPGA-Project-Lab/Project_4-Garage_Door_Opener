`timescale 1ns / 1ps

module debounce #(
    parameter integer STABLE_COUNT = 2_000_000
)(
    input wire clk,
    input wire noisy_btn,
    output reg clean_btn = 1'b0
);

    //////////////////////////////////
    // Counter Width
    //////////////////////////////////
    localparam integer COUNT_WIDTH =
        (STABLE_COUNT <= 1) ? 1 : $clog2(STABLE_COUNT);


    //////////////////////////////////
    // Button Synchronizer
    //////////////////////////////////
    reg sync0 = 1'b0;
    reg sync1 = 1'b0;

    always @(posedge clk) begin
        sync0 <= noisy_btn;
        sync1 <= sync0;
    end


    //////////////////////////////////
    // Debounce Counter
    //////////////////////////////////
    reg [COUNT_WIDTH-1:0] count = 0;

    always @(posedge clk) begin

        // Button agrees with current clean output:
        // nothing is changing, so restart the counter.
        if (sync1 == clean_btn) begin
            count <= 0;
        end

        // Button has remained different long enough:
        // accept the new button state.
        else if (count == STABLE_COUNT - 1) begin
            clean_btn <= sync1;
            count <= 0;
        end

        // Button is different, but has not been
        // stable long enough yet.
        else begin
            count <= count + 1'b1;
        end

    end

endmodule