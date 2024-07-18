module DDS_TOP (
    input  wire i_Ext_CLOCK,
    input  wire i_Ext_Resetn,
    output wire o_FG_CLK,
    output wire o_Dac_CLK    
);
    wire w_FgReset;
    wire w_PLLReset;
    wire w_PLL_lock;
    wire w_PLL_CLK;

    ResetGen_Module Resetgen(
        .CLK        (i_Ext_CLOCK),
        .ExtRESETn  (i_Ext_Resetn),
        .PllRESETn  (w_PLLReset),
        .FgRESETn   (w_FgReset),
        .PllLocked  (w_PLL_lock)
    );
    
    rpll PLL_module (
        .clkout     (w_PLL_CLK),
        .lock       (w_PLL_lock),
        .reset      (~w_PLLReset),
        .clkin      (i_Ext_CLOCK)
    );
    
    CLK_div clkdiv(
         .PLL_CLK   (w_PLL_CLK),
         .RESETn    (w_FgReset),
         .Fg_CLK    (o_FG_CLK),
         .Dac_CLK   (o_Dac_CLK)
    );

endmodule
