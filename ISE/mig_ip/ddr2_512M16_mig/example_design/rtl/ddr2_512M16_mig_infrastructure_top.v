//*****************************************************************************
// DISCLAIMER OF LIABILITY
//
// This file contains proprietary and confidential information of
// Xilinx, Inc. ("Xilinx"), that is distributed under a license
// from Xilinx, and may be used, copied and/or disclosed only
// pursuant to the terms of a valid license agreement with Xilinx.
//
// XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
// ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
// LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
// MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
// does not warrant that functions included in the Materials will
// meet the requirements of Licensee, or that the operation of the
// Materials will be uninterrupted or error-free, or that defects
// in the Materials will be corrected. Furthermore, Xilinx does
// not warrant or make any representations regarding use, or the
// results of the use, of the Materials in terms of correctness,
// accuracy, reliability or otherwise.
//
// Xilinx products are not designed or intended to be fail-safe,
// or for use in any application requiring fail-safe performance,
// such as life-support or safety devices or systems, Class III
// medical devices, nuclear facilities, applications related to
// the deployment of airbags, or any other applications that could
// lead to death, personal injury or severe property or
// environmental damage (individually and collectively, "critical
// applications"). Customer assumes the sole risk and liability
// of any use of Xilinx products in critical applications,
// subject only to applicable laws and regulations governing
// limitations on product liability.
//
// Copyright 2005, 2006, 2007, 2008 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor		    : Xilinx
// \   \   \/    Version            : 3.6.1
//  \   \        Application	    : MIG
//  /   /        Filename	    : ddr2_512M16_mig_infrastructure_top.v
// /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:41 $
// \   \  /  \   Date Created	    : Mon May 2 2005
//  \___\/\___\
// Device	: Spartan-3/3A/3A-DSP
// Design Name	: DDR2 SDRAM
// Purpose	: This module has instantiations clk_dcm and cal_top.
//		  This generate reset signals.
//*****************************************************************************

`timescale 1ns/100ps
`include "../rtl/ddr2_512M16_mig_parameters_0.v"
module ddr2_512M16_mig_infrastructure_top
  (
   input        sys_clk,
   input        sys_clkb,
   input        sys_clk_in,
   input        reset_in_n,
   output [4:0] delay_sel_val1_val,
   output       sys_rst_val,
   output       sys_rst90_val,
   output       sys_rst180_val,
   output reg   wait_200us_rout,
   output       clk_int_val,
   output       clk90_int_val,
   // debug signals
   output [4:0] dbg_phase_cnt,
   output [5:0] dbg_cnt,
   output       dbg_trans_onedtct,
   output       dbg_trans_twodtct,
   output       dbg_enb_trans_two_dtct

   );

   wire       user_rst;
   wire       clk_int;
   wire       clk90_int;
   wire       dcm_lock;
   wire       sys_clk_ibuf;
   wire       clk_int_val1;
   wire       clk_int_val2;
   wire       clk90_int_val1;
   wire       clk90_int_val2;
   wire [4:0] delay_sel_val;
   wire       user_cal_rst;
   reg        sys_rst_o;
   reg        sys_rst_1;
   reg        sys_rst;
   reg        sys_rst90_o;
   reg        sys_rst90_1;
   reg        sys_rst90;
   reg        sys_rst180_o;
   reg        sys_rst180_1;
   reg        sys_rst180;
   reg [15:0] counter200;
   reg        wait_200us;
   reg        wait_clk90;
   reg        wait_clk270;
   reg        wait_200us_r;

   generate
   if(`CLK_TYPE == "DIFFERENTIAL") begin : DIFF_ENDED_CLKS_INST

     IBUFGDS_LVDS_25  SYS_CLK_INST
       (
        .I  (sys_clk),
        .IB (sys_clkb),
        .O  (sys_clk_ibuf)
        );
   end else if(`CLK_TYPE == "SINGLE_ENDED") begin : SINGLE_ENDED_CLKS_INST

     IBUFG  SYS_CLK_INST
       (
        .I  (sys_clk_in),
        .O  (sys_clk_ibuf)
        );
   end
   endgenerate

   assign clk_int_val        = clk_int;
   assign clk90_int_val      = clk90_int;
   assign sys_rst_val        = sys_rst;
   assign sys_rst90_val      = sys_rst90;
   assign sys_rst180_val     = sys_rst180;
   assign delay_sel_val1_val = delay_sel_val;
   assign clk_int_val1       = clk_int;
   assign clk90_int_val1     = clk90_int;
   assign clk_int_val2       = clk_int_val1;
   assign clk90_int_val2     = clk90_int_val1;
   assign user_rst           = `RESET_ACTIVE_LOW  == 1'b1 ?
				~reset_in_n :  reset_in_n;
   assign user_cal_rst       = `RESET_ACTIVE_LOW  == 1'b1 ?
				reset_in_n : ~reset_in_n;

   always @(posedge clk_int_val2) begin
      if(user_rst == 1'b1 || dcm_lock == 1'b0) begin
         wait_200us <= 1'b1;
         counter200     <= 16'd0;
      end
      else
`ifdef simulation
        wait_200us <= 1'b0;
`else
      if ( counter200 < 16'd33400 ) begin
         counter200 <= counter200 + 1'b1;
         wait_200us <= 1'b1;
      end
      else begin
         counter200 <= counter200;
         wait_200us <= 1'b0;
      end
`endif
   end

   always @( posedge clk_int_val2 )
     wait_200us_r <= wait_200us;

   always @( posedge clk_int_val2 )
     wait_200us_rout <= wait_200us;

   always @(negedge clk90_int_val2) begin
      if(user_rst == 1'b1 || dcm_lock == 1'b0)
        wait_clk270 <= 1'b1;
      else
        wait_clk270 <= wait_200us_r;
   end

   always @(posedge clk90_int_val2) begin
      wait_clk90 <= wait_clk270;
   end

   always@(posedge clk_int_val2) begin
      if(user_rst == 1'b1 || dcm_lock == 1'b0 || wait_200us_r == 1'b1 ) begin
         sys_rst_o <= 1'b1;
         sys_rst_1 <= 1'b1;
         sys_rst   <= 1'b1;
      end
      else begin
         sys_rst_o <= 1'b0;
         sys_rst_1 <= sys_rst_o;
         sys_rst   <= sys_rst_1;
      end
   end

   always@(posedge clk90_int_val2) begin
      if (user_rst == 1'b1 || dcm_lock == 1'b0 || wait_clk90 == 1'b1) begin
         sys_rst90_o <= 1'b1;
         sys_rst90_1 <= 1'b1;
         sys_rst90   <= 1'b1;
      end
      else begin
         sys_rst90_o <= 1'b0;
         sys_rst90_1 <= sys_rst90_o;
         sys_rst90   <= sys_rst90_1;
      end
   end

   always@(negedge clk_int_val2) begin
      if (user_rst == 1'b1 || dcm_lock == 1'b0 || wait_clk270 == 1'b1) begin
         sys_rst180_o <= 1'b1;
         sys_rst180_1 <= 1'b1;
         sys_rst180   <= 1'b1;
      end
      else begin
         sys_rst180_o <= 1'b0;
         sys_rst180_1 <= sys_rst180_o;
         sys_rst180   <= sys_rst180_1;
      end
   end

   ddr2_512M16_mig_clk_dcm clk_dcm0
     (
      .input_clk   (sys_clk_ibuf),
      .rst         (user_rst),
      .clk         (clk_int),
      .clk90       (clk90_int),
      .dcm_lock    (dcm_lock)
      );

   ddr2_512M16_mig_cal_top cal_top0
     (
      .clk0                   (clk_int_val2),
      .clk0dcmlock            (dcm_lock),
      .reset                  (user_cal_rst),
      .tapfordqs              (delay_sel_val),
      .dbg_phase_cnt          (dbg_phase_cnt),
      .dbg_cnt                (dbg_cnt),
      .dbg_trans_onedtct      (dbg_trans_onedtct),
      .dbg_trans_twodtct      (dbg_trans_twodtct),
      .dbg_enb_trans_two_dtct (dbg_enb_trans_two_dtct)
      );

endmodule
