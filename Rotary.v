module Rotary(
    input wire Fg_CLK,
    input wire RESETn,
    input wire Rot_A,
    input wire Rot_B,
    input wire Rot_C,
    input  wire [2:0] Mode,
    output wire [10:0] Address,
    output wire FreqChng,
    output reg [2:0] LedmodeRotary
);

//----------------------------------------//
// Signal Declaration
//----------------------------------------//

    reg[2:0] FF_sys_A;
    reg[2:0] FF_sys_B;

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
    
    reg [10:0] cool_cnt;

//----------------------------------------//
// Constant Declaration
//----------------------------------------//
    parameter   idle = 4'd0,
                StCountUp = 4'd1,
                StCountDown = 4'd2,
                StCooldown = 4'd3;

//----------------------------------------//
// Output Declaration
//----------------------------------------//

    assign Address = rAddress;
    assign FreqChng = rFreqChng;

//----------------------------------------//
// Process Declaration
//----------------------------------------//

    always @(posedge Fg_CLK or negedge RESETn) begin
        if(~RESETn) begin
            FF_sys_A <= 3'b000;
            FF_sys_B <= 3'b000;
        end
        else begin
            FF_sys_A <= {FF_sys_A[1:0],Rot_A};
            FF_sys_B <= {FF_sys_B[1:0],Rot_B};
        end
    end

    always @(*) begin
        r_A_fall = (FF_sys_A[2] & ~FF_sys_A[1]) ? 1'd1:1'd0;
        r_B_fall = (FF_sys_B[2] & ~FF_sys_B[1]) ? 1'd1:1'd0;
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
        if(~RESETn) begin 
          step <= 7'd1;
          LedmodeRotary <= 3'b111;
        end
        else 
          case(Modestep)
            3'd0: begin 
              step <= 7'd1;
              LedmodeRotary <= 3'b110;  
              end
            3'd1: begin 
              step <= 7'd10;
              LedmodeRotary <= 3'b101; 
              end
            3'd2: begin 
              step <= 7'd100;
              LedmodeRotary <= 3'b011;
              end
            endcase
    end

always @(posedge Fg_CLK or negedge RESETn) begin
    if (~RESETn) begin
      rCurrentState  <= idle;
      count    <= 0;
      cool_cnt <= 0;
    end 
    else begin
      if ((Mode == 3'd4) & (count < 11'd800)) count <= 11'd800; 
        else  begin
            case (rCurrentState)
              idle: begin
                      if      (r_B_fall) rCurrentState <= 1; 
                      else if (r_A_fall) rCurrentState <= 2;
                    end
              StCountUp: begin  
                      if (r_A_fall) begin
                        rCurrentState <= StCooldown; 
                        count <= ($unsigned(count+step)>1799) ? 11'd1799 : count+step;
                      end
                      end  
              StCountDown: begin  
                      if (r_B_fall) begin
                        rCurrentState <= StCooldown; 
                        count <=  ((Mode  == 3'd4 ) & (count <= 800)) ? 11'd800 :              // No less than 800 in mode4
                                  ($unsigned(count) <= $unsigned(step)) ? 11'd0 : count-step; // if count<=step, set to 0 to avoid overflow
                      end
                 end 
              StCooldown: begin // cool down stage to avoid glitch
                      if ((cool_cnt >= 256) & (FF_sys_A[2]==1) & (FF_sys_B[2]==1)) begin // cool down for 256 clock (can be adjusted if not smooth)
                          cool_cnt <= 0;                                               // Also wait until A and B are 1 (idle stage)
                          rCurrentState <= idle;
                      end else begin 
                          cool_cnt <= (cool_cnt<256) ? cool_cnt+11'd1 : cool_cnt;
                      end
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
            if(rCntdelay == 22'd2400000) begin
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