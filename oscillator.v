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
    input wire mode,
    input wire  [31:0]  init1, /*sinb set y1*/
    input wire  [31:0]  init2, /*a*/
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
    else if (Ready) r_a <= init2; /*set a = 2cos*/
end


always @(posedge Fg_CLK or negedge RESETn) begin
    if(~RESETn) r_out1 <= 0;
    else if (Ready)  r_out1 <= init1; /*set out1 = sinb */
    else if (Enable) r_out1 <= r_out; /*update */
end

always @(posedge Fg_CLK or negedge RESETn) begin
    if(~RESETn) r_out2 <= 0;
    else if (Ready)  r_out2 <= 0;
    else if (Enable) r_out2 <= r_out1;
end

    
endmodule
