//----------------------------------------//
// Filename     : interpolation.v
// Description  : interpolation
// Company      : KMITL
// Project      : Digital Direct Synthesis Function Generator
//----------------------------------------//
// Version      : 0.1
// Date         : 31 Jun 2024
// Author       : Pakapol polpinich
// Remark       : fix delta
//----------------------------------------//

module interpolation(
    input  wire Fg_CLK,
    input  wire RESETn,
    input  wire [2:0]  Mode,
    input  wire Enable,
    input  reg  [31:0] Out1,
    input  reg  [31:0] Out2,
    output reg  [11:0] InterpOut
);

reg Enable_delay;
reg [63:0] delta;
reg [31:0] r_N;
reg [31:0] rOutput;

always @(*) begin
    if(~RESETn) r_N <= 32'd1;
    else begin
        case (Mode)
        3'd0 : r_N <= 32'd1;
        3'd1 : r_N <= 32'd53687091;
        3'd2 : r_N <= 32'd5368709; 
        3'd3 : r_N <= 32'd536871;
        3'd4 : r_N <= 32'd53687;
        endcase
    end
end

always @(*)begin //combination
        delta = $signed(Out2-Out1) * $signed(r_N);
    end

always @(posedge Fg_CLK or negedge RESETn)begin /*delay enable*/
    if(~RESETn) Enable_delay <= 0;
    else Enable_delay <= Enable;     
end


always @(posedge Fg_CLK or negedge RESETn) begin /*not finish calculater*/
    if(~RESETn) rOutput <= 0;
    else begin
        if(Enable_delay) begin
            rOutput <= Out2;
        end
        else begin
            rOutput <= $signed(rOutput) - delta[60:29];
        end
    end
end


always @(posedge Fg_CLK or negedge RESETn) begin /*output 12 bit*/
    if(~RESETn) InterpOut <= 12'd0;
    else  begin
        InterpOut <= rOutput[29:18];
    end
end


endmodule
