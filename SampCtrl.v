module Sampctrl (
    input Fg_CLK,
    input RESETn,
    input IntBTN,
    output wire Ready,
    output wire Enable,
    output wire  [2:0] Mode
);

//----------------------------------------//
// Signal Declaration
//----------------------------------------//

    reg [8:0] rCntReady;
    reg rCheckresetn;
    reg rReady;
    reg [2:0] rMode;
    reg [14:0] rEnableValue;

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
            rCntReady <= (rCheckresetn == 1'b1) ? rCntReady+7'd1 : rCntReady ;
        end else begin
            rReady <= 1'b1;
            rCheckresetn <= 1'b0;
        end
    end

    always @(posedge Fg_CLK or negedge RESETn) begin
       if(~RESETn) begin
            rEnableValue <= 0;
        end
        else begin
            case (rMode)
            0 : rEnableValue <= 0;
            1 : rEnableValue <= 9;
            2 : rEnableValue <= 99;
            3 : rEnableValue <= 999;
            4 : rEnableValue <= 9999;
            endcase
        end
    end

    always @(posedge Fg_CLK or negedge RESETn ) begin
        if(RESETn == 1'b0) begin
            rEnable <= 1'd1;
            rCntEnable <= 1'b0;
        end 
        else if(rMode == 3'd0) begin
                rEnable <= 1'd1;
                rCntEnable <= 1'b0;
        end
        else begin
                if(rCntEnable == rEnableValue) begin
                    rEnable <= 1'd1;
                    rCntEnable <= 1'b0;
                end else begin
                    rEnable <= 1'd0;
                    rCntEnable <= rCntEnable+ 1'd1;
                end
        end

    end
    always @(posedge Fg_CLK or negedge RESETn) begin
        if(RESETn == 1'b0) begin
            rCheckIntBTN <= 0;
            rMode <= 3'b0;
        end else begin
            if (IntBTN == 1'b1) begin
            rCheckIntBTN <= 1'b1;
            end
        
            if (rCntEnable == 11'b0 && rCheckIntBTN == 1'b1) begin
                if (rMode > 3'd3) rMode <= 3'b0;
                else rMode <= rMode+3'd1;
                rCheckIntBTN <= 1'b0;
                
            end
            else rMode <= rMode;
        end
    end


endmodule