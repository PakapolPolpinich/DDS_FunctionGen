module Rotary(
    input wire Fg_CLK,
    input wire RESETn,
    input wire Rot_A,
    input wire Rot_B,
    input wire Rot_C,
    input  wire [2:0] Mode,
    output wire [10:0] Address,
    output wire FreqChng
);

//----------------------------------------//
// Signal Declaration
//----------------------------------------//

    reg[2:0] r_sys_a;
    reg[2:0] r_sys_b;

    reg r_A_fall;
    reg r_B_fall;

    reg [1:0] r_C;
    reg [2:0] Modestep;
    reg [3:0] rCurrentState;

    reg [10:0] count;
    reg [6:0] step;
    reg [10:0] rAddress;

    reg rFreqChng;
    reg [22:0] rCntdelay;
    reg Delaysignal;
    
//----------------------------------------//
// Constant Declaration
//----------------------------------------//
    parameter   idle = 4'd0,
                StCountUp = 4'd1,
                StCountDown = 4'd2 ;

//----------------------------------------//
// Output Declaration
//----------------------------------------//

    assign Address = rAddress;
    assign FreqChng = rFreqChng;

//----------------------------------------//
// Process Declaration
//----------------------------------------//
    always @(*) begin
        r_A_fall = (r_sys_a[1] & ~ r_sys_a[0]) ? 1'd1:1'd0;
        r_B_fall = (r_sys_b[1] & ~r_sys_b[0]) ? 1'd1:1'd0;
    end

    always @(posedge Fg_CLK or negedge RESETn) begin
        if(~RESETn) r_sys_a <= 3'b111;
        else begin
            r_sys_a[0] <= Rot_A;
            r_sys_a[1] <= r_sys_a[0];
        end
    end

    always @(posedge Fg_CLK or negedge RESETn) begin
        if(~RESETn) r_sys_b <= 3'b111;
        else begin
            r_sys_b[0] <= Rot_B;
            r_sys_b[1] <= r_sys_b[0];
        end
    end

    always @(posedge Fg_CLK or negedge RESETn) begin // signal form button interface
        if(~RESETn) begin
            r_C <= 0;
            Modestep <= 3'd0;
        end
        else begin
            r_C <= Rot_C;
            if (r_C == 1'd1) begin //confuse why
                if(Modestep > 3'd1)
                    Modestep <= 3'd0;
                else Modestep <= Modestep+3'd1;
            end 
        end
    end

    always  @(posedge Fg_CLK or negedge RESETn) begin
        if(~RESETn) step <= 7'd1;
        else case(Modestep)
            3'd0: step <= 7'd1;
            3'd1: step <= 7'd10;
            3'd2: step <= 7'D100;
            endcase
    end


    always@(posedge Fg_CLK or negedge RESETn) begin
        if(~RESETn)begin
             rCurrentState <= idle;
             count <= 0;
        end
          else begin
            if(Mode == 3'd4 && count < 11'd800) count <= 11'd800;
            else begin
                case (rCurrentState) //fsm
                idle : begin
                    if(r_B_fall == 1'd1) begin
                        count <= (count + step > 11'd1800) ? 11'd1800 : count + step;     
                        rCurrentState <= StCountUp;
                    end
                    else if (r_A_fall == 1'd1) begin
                        if(Mode == 3'd4) count <= (count - step < 11'd800 ) ? 11'd800 : count - step;
                        else count <= (count < step ) ? 11'd0 : count - step; // ทำไม count - step < 0 ไม่เข้าเงื่อนไข
                        rCurrentState <= StCountDown;
                    end
                    else rCurrentState <= rCurrentState;
                end
                StCountUp : begin
                    rCurrentState <= (r_A_fall == 1'd1) ? idle : StCountUp;
                end
                StCountDown :begin
                rCurrentState  <= (r_B_fall == 1'd1) ? idle : StCountDown; 
                end
                endcase
            end

        end 
    end
    
    always@(posedge Fg_CLK or negedge RESETn) begin /* delay 100 ms*/
        if(~RESETn) begin
            rCntdelay <= 22'd0;
            Delaysignal <= 1'd0;
        end
        else begin
            if(rCntdelay == 22'd2400) begin
                Delaysignal <= 1'd1;
                rCntdelay <= 22'd0;
            end
            else begin
                Delaysignal <= 1'd0;
                rCntdelay <= rCntdelay + 22'd1;
            end 
        end
    end 

    always@(posedge Fg_CLK or negedge RESETn) begin
        if(~RESETn) rAddress <= 11'd0;
        else 
            if(Delaysignal == 1'd1) rAddress <= count;
            else rAddress <= rAddress; 
    end

    always@(posedge Fg_CLK or negedge RESETn) begin
        if(~RESETn) rFreqChng <= 1'd0;
        else begin
            if((rAddress != count) && (Delaysignal == 1'd1))
                rFreqChng <= 1'd1;
            else rFreqChng <= 1'd0; 
        end
    end
endmodule
