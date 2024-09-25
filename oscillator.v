//----------------------------------------//
// Filename     : oscillator.v
// Description  : oscillator
// Company      : KMITL
// Project      : Digital Direct Synthesis Function Generator
//----------------------------------------//
// Version      : 0.0
// Date         : 23 Jun 2024
// Author       : Pakapol polpinich
// Remark       : New Creation
//----------------------------------------//

module oscillator(
    input wire Fg_CLK,
    input wire RESETn,
    input wire Enable,
    input wire Ready,
    input wire [2:0] mode,
    input wire  [31:0]  sinx, /*sinb set y1*/
    input wire  [31:0]  cos2x, /*a*/
    input wire  FreqChng,
    output wire [31:0]  Out1,
    output wire [31:0]  Out2
);

//----------------------------------------//
// Signal Declaration
//----------------------------------------//


reg [31:0]  r_out1;
reg [31:0]  r_out2;

reg [31:0]  r_a; /*gain a */
reg [63:0]  r_c;
reg [31:0]  r_out1_a;


reg [31:0]  r_out;

reg update_wait;
reg update;
reg zero_cross;
reg [31:0]sine;
reg dir;

//----------------------------------------//
// Output Declaration
//----------------------------------------//

assign Out1 = r_out1;
assign Out2 = r_out2;

//----------------------------------------//
// Process Declaration
//----------------------------------------//

always @(*)begin
    r_out <= r_out1_a - r_out2;
end

always @(*)begin
    r_c <= $signed(r_a) * $signed(r_out1);
    r_out1_a <= r_c[60:29];
end

always @(posedge Fg_CLK or negedge RESETn) begin
    if(~RESETn) r_a <= 0;
    else if (Ready || update) r_a <= cos2x; /*set a = 2cos*/
end


always @(posedge Fg_CLK or negedge RESETn) begin
    if(~RESETn) r_out1 <= 0;
    else if (Ready || update)  r_out1 <= sine; /*set out1 = sinb */
    else if (Enable) r_out1 <= r_out; /*update */
end

always @(posedge Fg_CLK or negedge RESETn) begin
    if(~RESETn) r_out2 <= 0;
    else if (Ready || update)  r_out2 <= 0;
    else if (Enable) r_out2 <= r_out1;
end

/*add frequency change*/

always @(posedge Fg_CLK or negedge RESETn) begin
    if(~RESETn) update_wait <= 0;
    else begin
        if(FreqChng == 1) update_wait <= 1; /*wait change*/
        else if (update == 1) update_wait <= 0;
    end
end

always@(*) begin
    if (((mode != 4) && (r_out1[31:22] == 10'h000 | r_out1[31:22] == 10'h3FF)) || ((mode == 4)&&((r_out1[31:23] == 9'h000)|(r_out1[31:23] == 9'h1FF)))) 
            zero_cross = 1;
    else zero_cross = 0;
end

always@(*) begin
    if(r_out2[31] == 1) dir = 1;
    else dir = 0;
end


always @(*) begin
    if(zero_cross && update_wait && Enable) update = 1;
    else update = 0;
end


always @(*) begin
    sine = (dir == 1) ? sinx : ~sinx + 1;
end
endmodule


