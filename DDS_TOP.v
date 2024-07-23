module DDS_TOP (
    input  wire i_Ext_CLOCK,
    input  wire i_Ext_Resetn,
    input  wire i_button,
    output wire o_FG_CLK,
    output wire o_Enable,
    output wire r_button
);
    wire w_FgReset;
    wire w_PLLReset;
    wire w_PLL_lock;
    wire w_PLL_CLK;
    wire w_ready;
    wire o_Dac_CLK;

    assign r_button = i_button ;
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

    Sampctrl Sampling(
        .Fg_CLK     (o_FG_CLK),
        .RESETn     (i_Ext_Resetn),
        .IntBTN     (i_button),
        .Ready      (w_ready),
        .Enable     (o_Enable)
    );


endmodule
