module CLK_div (
    input wire PLL_CLK,
    input wire RESETn,
    output reg Fg_CLK,
    output reg Dac_CLK
);

    always @(posedge PLL_CLK or negedge RESETn) begin
        if(~RESETn) begin
            Fg_CLK <= 0;
    end
        else Fg_CLK <= ~Fg_CLK;
    end

    always @(negedge PLL_CLK or negedge RESETn) begin
        if(~RESETn) begin    
            Dac_CLK <= 0;
        end
        else Dac_CLK <= ~Dac_CLK;
    end
    
endmodule
