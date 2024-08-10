//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9.03 Education (64-bit)
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9
//Device Version: C
//Created Time: Sat Aug 10 20:30:36 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    pROMcoef your_instance_name(
        .dout(dout), //output [47:0] dout
        .clk(clk), //input clk
        .oce(oce), //input oce
        .ce(ce), //input ce
        .reset(reset), //input reset
        .ad(ad) //input [10:0] ad
    );

//--------Copy end-------------------
