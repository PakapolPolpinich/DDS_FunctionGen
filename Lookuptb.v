module Lookuptb(
    input wire Fg_CLK,
    input wire RESETn,
    input wire [10:0]Address,
    input wire [31:0] Out1,
    input wire [31:0] Out2,
    output wire [31:0] sinx,
    output wire [31:0] cos2x
);

reg [47:0] coef;
wire [47:0] data;
assign sinx  = {4'b0000   ,coef[47:24],4'b0000};
assign cos2x = {6'b001111,coef[23:0] ,2'b00};

always @(*) begin
    coef = data;
end

pROMcoef Rom(
        .dout(data), //output [47:0] dout
        .clk(Fg_CLK), //input clk
        .oce(1'd0), //input oce
        .ce(1'd1), //input ce
        .reset(RESETn), //input reset
        .ad(Address) //input [10:0] ad
    );


endmodule