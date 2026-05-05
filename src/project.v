`default_nettype none

module tt_um_connerdaehler_boop (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // ----------------------------
    // reset (active high internally)
    // ----------------------------
    wire rst = ~rst_n;

    // ----------------------------
    // start pulse generation
    // ----------------------------
    reg ena_d;
    always @(posedge clk or posedge rst) begin
        if (rst)
            ena_d <= 1'b0;
        else
            ena_d <= ena;
    end

    wire start = ena & ~ena_d;

    // ----------------------------
    // inputs (8-bit packed -> 32-bit)
    // ----------------------------
    wire [31:0] mc = {24'b0, ui_in};
    wire [31:0] mp = {24'b0, uio_in};

    // ----------------------------
    // PM32 core
    // ----------------------------
    wire [63:0] product;
    wire done;

    pm32 u_pm32 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .mc(mc),
        .mp(mp),
        .p(product),
        .done(done)
    );

    // ----------------------------
    // OUTPUT (byte-select view)
    // ----------------------------
    wire [2:0] sel = uio_in[2:0];
    wire [63:0] shifted = product >> (sel * 8);

    assign uo_out = done ? shifted[7:0] : 8'b0;

    // ----------------------------
    // optional debug output
    // ----------------------------
    assign uio_out = {7'b0, done};
    assign uio_oe  = 8'b00000001;

    // ----------------------------
    // unused inputs
    // ----------------------------
    wire _unused = &{ena, 1'b0};

endmodule
