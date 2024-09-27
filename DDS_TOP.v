module DDS_TOP (
    input  wire i_Ext_CLOCK,
    input  wire i_Ext_Resetn,
    input  wire i_button,
    input  wire i_Rot_A,
    input  wire i_Rot_B,
    input  wire i_Rot_C,
    output wire [11:0] o_InterpOut,
    output wire o_Dac_CLK,
    output wire [2:0] o_led_step   
);

//----------------------------------------//
// Signal Declaration
//----------------------------------------//

    wire w_FgReset;
    wire w_PLLReset;
    wire w_PLL_lock;
    wire w_PLL_CLK;

    wire w_Fg_CLK;
    wire w_B_sampcontrol;

    wire w_ready;
    wire w_enable;
    wire [2:0] w_Mode_Fq;

    wire [10:0]w_address;
    wire w_FreqChng;

    wire w_B_Re;
    wire [31:0] w_sinx;
    wire [31:0] w_cos2x;
    wire [31:0] w_Out1;
    wire [31:0] w_Out2;


    button button_Ex(
        .CLK       (w_Fg_CLK),
        .RESETn    (i_Ext_Resetn),
        .iExtBtn   (i_button),
        .oIntBtn   (w_B_sampcontrol)
    );
 

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
         .Fg_CLK    (w_Fg_CLK),
         .Dac_CLK   (o_Dac_CLK)
    );

    Sampctrl Sampling(
        .Fg_CLK     (w_Fg_CLK),
        .RESETn     (w_FgReset),
        .IntBTN     (w_B_sampcontrol),
        .Ready      (w_ready),
        .Enable     (w_enable),
        .Mode       (w_Mode_Fq)
    );
    /*osc top */

    button button_RE(
        .CLK       (w_Fg_CLK),
        .RESETn    (w_FgReset),
        .iExtBtn   (i_Rot_C),
        .oIntBtn   (w_B_Re)
    );
 
 
    Rotary rotaryencoder(
        .Fg_CLK    (w_Fg_CLK),
        .RESETn    (w_FgReset),
        .Rot_A     (i_Rot_A),
        .Rot_B     (i_Rot_B),
        .Rot_C     (w_B_Re),
        .Mode      (w_Mode_Fq),
        .Address   (w_address),
        .FreqChng  (w_FreqChng),
        .LedmodeRotary (o_led_step)
    );
 
 
    Lookuptb lookuptable(
        .Fg_CLK    (w_Fg_CLK),
        .RESETn    (w_FgReset),
        .Address   (w_address),
        .Out1      (w_Out1),
        .Out2      (w_Out2),
        .sinx      (w_sinx),
        .cos2x     (w_cos2x)
    );
 
    oscillator osc(
        .Fg_CLK    (w_Fg_CLK),
        .RESETn    (w_FgReset),
        .Enable    (w_enable),
        .Ready     (w_ready),
        .mode      (w_Mode_Fq),
        .sinx      (w_sinx),
        .cos2x     (w_cos2x),
        .FreqChng  (w_FreqChng),
        .Out1      (w_Out1),
        .Out2      (w_Out2)
    );
 
    interpolation interp(
        .Fg_CLK    (w_Fg_CLK),
        .RESETn    (w_FgReset),
        .Mode      (w_Mode_Fq),
        .Enable    (w_enable),
        .Out1      (w_Out1),
        .Out2      (w_Out2),
        .InterpOut (o_InterpOut)
    );


endmodule

