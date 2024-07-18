module button(
    input wire CLK,
    input wire RESETn,
    input wire iExtBtn,
    output wire oIntBtn
);
    reg[2:0] rdebounce; //loss deboune counter
    assign oIntBtn = (rdebounce[2] & ~rdebounce[1]) ? 1'd1 :1'd0;

    reg[23:0] rCnt;

    always @(posedge CLK or negedge RESETn) begin
        if (RESETn == 1'd0) begin
            rdebounce <= 3'b111;
        end else begin //create 3 D-flip flop
            rdebounce[0] <= iExtBtn;
            rdebounce[1] <= rdebounce[0];//delay check
            rdebounce[2] <= rdebounce[1];//create condition to build pulse 1 
        end
    end         
endmodule