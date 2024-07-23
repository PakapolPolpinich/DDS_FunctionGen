//----------------------------------------//
// Filename     : SampCtrl.v
// Description  : Sampling control
// Company      : KMITL
// Project      : Digital Direct Synthesis Function Generator
//----------------------------------------//
// Version      : 0.0
// Date         : 23 Jun 2024
// Author       : Pakapol polpinich
// Remark       : New Creation
//----------------------------------------//
module SampCtrl (
    input Fg_CLK,
    input RESETn,
    input IntBTN,
    output wire Ready,
    output wire Enable
);

//----------------------------------------//
// Signal Declaration
//----------------------------------------//

    reg [8:0] rCntReady; //when reset
    reg rCheckresetn;// when signal button come it 1
    reg rReady;
    reg [2:0] rMode;

    reg rCheckIntBTN;
    reg [14:0] rCntEnable;
    reg rEnable;

//----------------------------------------//
// Output Declaration
//----------------------------------------//

    assign Ready = rReady;
    assign Enable = rEnable;
    assign Mode = rMode;

//----------------------------------------//
// Process Declaration
//----------------------------------------//

    always @(posedge Fg_CLK or negedge RESETn) begin
        if(RESETn == 1'b0) begin
            rReady <= 1'b0;
            rCntReady <= 1'b0;
            rCheckresetn = 1'b1;
        end else if (rCntReady != 7'd79 || rCheckresetn <= 1'b0) begin
            rReady <= 1'b0;
            rCntReady <= (rCheckresetn == 1'b1) ? rCntReady+1 : rCntReady ;
        end else begin
            rReady <= 1'b1;
            rCheckresetn <= 1'b0;
        end
    end

    always @(posedge Fg_CLK or negedge RESETn ) begin
        if(RESETn == 1'b0) begin
            rEnable <= 1'd1;
            rCntEnable <= 1'b0;
        end 
        else if (rMode == 3'd0) begin
            rEnable <= 1'd1;
            rCntEnable <= 1'b0;
        end
        else if (rMode == 3'd1) begin
                if(rCntEnable == 4'd9) begin
                    rEnable <= 1'd1;
                    rCntEnable <= 1'b0;
                end else begin
                    rEnable <= 1'd0;
                    rCntEnable <= rCntEnable+ 1'd1;
                end
        end
        else if (rMode == 3'd2) begin
                if(rCntEnable == 7'd99) begin
                    rEnable <= 1'd1;
                    rCntEnable <= 1'b0;
                end else begin
                    rEnable <= 1'd0;
                    rCntEnable <= rCntEnable+1;
                end
        end
        else if (rMode == 3'd3) begin
                if(rCntEnable == 10'd999) begin
                    rEnable <= 1'd1;
                    rCntEnable <= 1'b0;
                end else begin
                    rEnable <= 1'd0;
                    rCntEnable <= rCntEnable+1;
                end
        end
        else if (rMode == 3'd4) begin
                if(rCntEnable == 14'd9999) begin
                    rEnable <= 1'd1;
                    rCntEnable <= 1'b0;
                end else begin
                    rEnable <= 1'd0;
                    rCntEnable <= rCntEnable+1;
                end
        end
    end

    always @(posedge Fg_CLK or negedge RESETn) begin
        if(RESETn == 1'b0) begin
            rCheckIntBTN <= 0;
            rMode <= 3'b0;
        end 
        else begin
            if (IntBTN == 1'b1) begin
            rCheckIntBTN <= 1'b1;
            end
        
            if (rCntEnable == 11'b0 && rCheckIntBTN == 1'b1) begin
                if (rMode > 3'd3) rMode <= 3'b0;
                else rMode <= rMode+1;
                rCheckIntBTN <= 1'b0;        
            end
            else rMode <= rMode;
        end
    end


endmodule
