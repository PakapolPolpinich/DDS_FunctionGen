//----------------------------------------//
// Filename     : button.v
// Description  : Sampling control
// Company      : KMITL
// Project      : Digital Direct Synthesis Function Generator
//----------------------------------------//
// Version      : 0.0
// Date         : 23 Jun 2024
// Author       : Pakapol polpinich
// Remark       : New Creation
//----------------------------------------//

module button(
    input wire CLK,
    input wire RESETn,
    input wire iExtBtn,
    output wire oIntBtn
);

//----------------------------------------//
// Signal Declaration
//----------------------------------------//

    reg[2:0] rdebounce; //loss deboune counter
    
    reg[24:0] rCnt;

//----------------------------------------//
// Output Declaration
//----------------------------------------//

    assign oIntBtn = (rdebounce[2] & ~rdebounce[1] & (rCnt == 24'd0)) ? 1'd1 :1'd0;


//----------------------------------------//
// Process Declaration
//----------------------------------------//

    always @(posedge CLK or negedge RESETn) begin 
        if (RESETn == 1'd0) begin
            rdebounce <= 3'b111;
        end else begin //create 3 D-flip flop
            rdebounce[0] <= iExtBtn;
            rdebounce[1] <= rdebounce[0];//delay check
            rdebounce[2] <= rdebounce[1];//create condition to build pulse 1 
        end
    end

    always @(posedge CLK or negedge RESETn) begin //wrong this
        if(~RESETn) rCnt <= 25'd0;
        else begin 
            if(rCnt == 25'd0) 
                rCnt <= (oIntBtn == 1'd1) ? 25'd1 : 25'd0;
            else   
                rCnt <= (rCnt != 25'd24_000_000) ? rCnt+25'd1 : 25'd0;
        end
    end         
endmodule