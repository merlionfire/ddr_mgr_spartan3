////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 14.7
//  \   \         Application : xaw2verilog
//  /   /         Filename : clock_chipscope_gen.v
// /___/   /\     Timestamp : 11/25/2016 08:06:25
// \   \  /  \ 
//  \___\/\___\ 
//
//Command: xaw2verilog -st /home/cct/FPGA_Project/test_ddr_mgr/ISE/DCM_Chipscope_IP/./clock_chipscope_gen.xaw /home/cct/FPGA_Project/test_ddr_mgr/ISE/DCM_Chipscope_IP/./clock_chipscope_gen
//Design Name: clock_chipscope_gen
//Device: xc3s700an-4fgg484
//
// Module clock_chipscope_gen
// Generated by Xilinx Architecture Wizard
// Written for synthesis tool: XST
`timescale 1ns / 1ps

module clock_chipscope_gen(CLKIN_IN, 
                           CLK0_OUT, 
                           CLK2X_OUT, 
                           LOCKED_OUT);

    input CLKIN_IN;
   output CLK0_OUT;
   output CLK2X_OUT;
   output LOCKED_OUT;
   
   wire CLKFB_IN;
   wire CLK0_BUF;
   wire CLK2X_BUF;
   wire GND_BIT;
   
   assign GND_BIT = 0;
   assign CLK0_OUT = CLKFB_IN;
   BUFG  CLK0_BUFG_INST (.I(CLK0_BUF), 
                        .O(CLKFB_IN));
   BUFG  CLK2X_BUFG_INST (.I(CLK2X_BUF), 
                         .O(CLK2X_OUT));
   DCM_SP #( .CLK_FEEDBACK("1X"), .CLKDV_DIVIDE(2.0), .CLKFX_DIVIDE(1), 
         .CLKFX_MULTIPLY(4), .CLKIN_DIVIDE_BY_2("FALSE"), .CLKIN_PERIOD(7.519), 
         .CLKOUT_PHASE_SHIFT("FIXED"), .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), 
         .DFS_FREQUENCY_MODE("LOW"), .DLL_FREQUENCY_MODE("LOW"), 
         .DUTY_CYCLE_CORRECTION("TRUE"), .FACTORY_JF(16'hC080), 
         .PHASE_SHIFT(60), .STARTUP_WAIT("FALSE") ) DCM_SP_INST 
         (.CLKFB(CLKFB_IN), 
                       .CLKIN(CLKIN_IN), 
                       .DSSEN(GND_BIT), 
                       .PSCLK(GND_BIT), 
                       .PSEN(GND_BIT), 
                       .PSINCDEC(GND_BIT), 
                       .RST(GND_BIT), 
                       .CLKDV(), 
                       .CLKFX(), 
                       .CLKFX180(), 
                       .CLK0(CLK0_BUF), 
                       .CLK2X(CLK2X_BUF), 
                       .CLK2X180(), 
                       .CLK90(), 
                       .CLK180(), 
                       .CLK270(), 
                       .LOCKED(LOCKED_OUT), 
                       .PSDONE(), 
                       .STATUS());
endmodule
