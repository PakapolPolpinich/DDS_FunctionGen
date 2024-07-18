//----------------------------------------//
// Filename     : ResetGen_Module.v
// Description  : Reset Generator for DDSFG
// Company      : KMITL
// Project      : Digital Direct Synthesis Function Generator
//----------------------------------------//
// Version      : 1.0
// Date         : 16 Jun 2023
// Author       : T. Sirus
// Remark       : New Creation
//----------------------------------------//
module ResetGen_Module(
    input   wire    CLK,

    input   wire    ExtRESETn,
    
    input   wire    PllLocked,
    output  wire    PllRESETn,

    output  wire    FgRESETn
);
//----------------------------------------//
// Constant Declaration
//----------------------------------------//
    localparam cExtIgnore = 23'd12000;
//----------------------------------------//
// Signal Declaration
//----------------------------------------//
    reg [3:0]   rStartupCnt = 4'd0;
    reg [3:0]   rHoldCnt = 4'd0;
    reg [22:0]  rExtIgnoreCnt = 23'd0;

    reg rPllRESETn;

    reg rFgRESETn;
//----------------------------------------//
// Output Declaration
//----------------------------------------//
    assign PllRESETn       = rPllRESETn;
    assign FgRESETn        = rFgRESETn;   

//----------------------------------------//
// Process Declaration
//----------------------------------------//
    always @(posedge CLK) begin : u_rStartupCnt
        rStartupCnt <= (rStartupCnt < 15) ? rStartupCnt + 4'd1 : rStartupCnt; 
    end

    always @(posedge CLK) begin : u_rExtIgnoreCnt
        if(rExtIgnoreCnt == 23'd0) begin
            rExtIgnoreCnt <= (ExtRESETn == 1'd0) ? 23'd1 : 23'd0;
        end
        else begin
            rExtIgnoreCnt <= (rExtIgnoreCnt == cExtIgnore) ? 23'd0 : rExtIgnoreCnt + 23'd1;
        end
    end

    always @(posedge CLK) begin : u_rHoldCnt
        rHoldCnt <= (ExtRESETn == 1'd0 && rExtIgnoreCnt == 23'd0) ? 4'd1 : 
                    (rHoldCnt == 4'd0) ? 4'd0 : rHoldCnt + 4'd1;
    end

    always @(posedge CLK) begin : u_rPllRESETn
        rPllRESETn <=   (rStartupCnt < 15) ? 1'd0 :
                        (rHoldCnt >= 15 | rHoldCnt == 4'd0) ? 1'd1 : 1'd0;
    end

    always @(posedge CLK) begin : u_rFgRESETn
        rFgRESETn <= (PllLocked == 1'd1) ? 1'd1 : 1'd0;
    end
endmodule