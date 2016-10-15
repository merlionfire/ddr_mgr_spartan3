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
// Copyright 2005, 2006, 2007 Xilinx, Inc.
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
//  /   /        Filename	    : ddr2_512M16_mig_main_0.v
// /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
// \   \  /  \   Date Created	    : Mon May 2 2005
//  \___\/\___\
// Device	: Spartan-3/3A/3A-DSP
// Design Name	: DDR2 SDRAM
// Purpose	: This modules has the instantiation for top and test_bench 
//		  modules.
//*****************************************************************************

`timescale 1ns/100ps
`include "../rtl/ddr2_512M16_mig_parameters_0.v"

module    ddr2_512M16_mig_main_0
  (
   input                            clk_int,
   input                            clk90_int,
   input [4:0]                      delay_sel_val,
   input                            sys_rst,
   input                            sys_rst90,
   input                            sys_rst180,
   input                            rst_dqs_div_in,
   output                           rst_dqs_div_out,
   output [(`CLK_WIDTH-1):0]        ddr2_ck,
   output [(`CLK_WIDTH-1):0]        ddr2_ck_n,
   output                           ddr2_cas_n,
   output                           ddr2_cke,
   output                           ddr2_cs_n,
   output                           ddr2_ras_n,
   output                           ddr2_we_n,
   output                           ddr2_odt,
   output [`ROW_ADDRESS-1:0]        ddr2_a,
   output [`BANK_ADDRESS-1:0]       ddr2_ba,
   inout [(`DATA_WIDTH-1):0]        ddr2_dq,
   input                            wait_200us,
   inout [(`DATA_STROBE_WIDTH-1):0] ddr2_dqs,
   output[((`DATA_MASK_WIDTH)-1):0]  ddr2_dm,
    inout  [(`DATA_STROBE_WIDTH-1):0] ddr2_dqs_n, 

   output                           init_done,
   output                           led_error_output1,
   output                           data_valid_out,
   //debug_signals
   output [4:0]                       dbg_delay_sel, 
   output                             dbg_rst_calib,
   input [4:0]                        vio_out_dqs,
   input                              vio_out_dqs_en,
   input [4:0]                        vio_out_rst_dqs_div,
   input                              vio_out_rst_dqs_div_en
   );



   wire [((`DATA_WIDTH*2)-1):0]                  user_output_data;
   wire [((`ROW_ADDRESS +
           `COLUMN_ADDRESS  + `BANK_ADDRESS)-1):0] u1_address;
   wire                                          user_data_val1;
   wire [2:0]                                    user_cmd1;
   wire                                          auto_ref_req;
   wire                                          user_ack1;
   wire [((`DATA_WIDTH*2)-1):0]                  u1_data_i;
   wire [((`DATA_MASK_WIDTH*2)-1):0]             u1_data_m;
   wire                                          burst_done_val1;
   wire                                          ar_done_val1;

   ddr2_512M16_mig_top_0        top0
      (
       .auto_ref_req		(auto_ref_req),
       .wait_200us		(wait_200us),
       .rst_dqs_div_in		(rst_dqs_div_in),
       .rst_dqs_div_out		(rst_dqs_div_out),
       .user_input_data		(u1_data_i),
       .user_data_mask          (u1_data_m),
       .user_output_data	(user_output_data),
       .user_data_valid		(user_data_val1),
       .user_input_address	(u1_address[((`ROW_ADDRESS + `COLUMN_ADDRESS 
                                            + `BANK_ADDRESS)-1):0]),
       .user_command_register   (user_cmd1),
       .user_cmd_ack		(user_ack1),
       .burst_done		(burst_done_val1),
       .init_done		(init_done),
       .ar_done			(ar_done_val1),
       .ddr2_dqs		(ddr2_dqs),
      .ddr2_dqs_n (ddr2_dqs_n),
       .ddr2_dq			(ddr2_dq),
       .ddr2_cke		(ddr2_cke),
       .ddr2_cs_n		(ddr2_cs_n),
       .ddr2_ras_n		(ddr2_ras_n),
       .ddr2_cas_n		(ddr2_cas_n),
       .ddr2_we_n		(ddr2_we_n),
       .ddr2_dm                 (ddr2_dm),

       .ddr2_odt		(ddr2_odt),
       .ddr2_ba			(ddr2_ba),
       .ddr2_a			(ddr2_a),
       .ddr2_ck			(ddr2_ck),
       .ddr2_ck_n		(ddr2_ck_n),
       .clk_int			(clk_int),
       .clk90_int		(clk90_int),
       .delay_sel_val		(delay_sel_val),
       .sys_rst			(sys_rst),
       .sys_rst90		(sys_rst90),
       .sys_rst180		(sys_rst180),
      //debug signals
      .dbg_delay_sel            (dbg_delay_sel),
      .dbg_rst_calib            (dbg_rst_calib),
      .vio_out_dqs              (vio_out_dqs),   
      .vio_out_dqs_en           (vio_out_dqs_en),   
      .vio_out_rst_dqs_div      (vio_out_rst_dqs_div),
      .vio_out_rst_dqs_div_en   (vio_out_rst_dqs_div_en)
       );

   ddr2_512M16_mig_test_bench_0    test_bench0
      (
       .auto_ref_req      (auto_ref_req),
       .fpga_clk          (clk_int),
       .fpga_rst90        (sys_rst90),
       .fpga_rst180       (sys_rst180),
       .clk90             (clk90_int),
       .burst_done        (burst_done_val1),
       .init_done         (init_done),
       .ar_done           (ar_done_val1),
       .u_ack             (user_ack1),
       .u_data_val        (user_data_val1),
       .u_data_o          (user_output_data),
       .u_addr            (u1_address),
       .u_cmd             (user_cmd1),
       .u_data_i          (u1_data_i),
       .u_data_m          (u1_data_m),
       .led_error_output  (led_error_output1),
       .data_valid_out    (data_valid_out)
       );

endmodule
