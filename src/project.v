`default_nettype none

module tt_um_connerdaehler_boop (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

    wire start;
    wire done;

    // Map Tiny Tapeout input
    assign start = ui_in[0];
    assign uo_out[0] = done;

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Instantiate your multiplier
    pm32 u_pm32 (
        .clk(clk),
        .rst(~rst_n),   // IMPORTANT: active-low reset fix
        .start(start),

        // TEMP FIX: you do NOT have real 32-bit IO yet
        .mc(32'b0),
        .mp(32'b0),

        .p(),
        .done(done)
    );

    // prevent warnings
    wire _unused = &{ena, ui_in[7:1], uio_in};

endmodule

