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
// Copyright 2007, 2008 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor             : Xilinx
// \   \   \/    Version        : 3.6.1
//  \   \        Application        : MIG
//  /   /        Filename           : sim_tb_top.v
// /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:41 $
// \   \  /  \   Date Created       : Mon May 2 2005
//  \___\/\___\
//
// Device      : Spartan-3/3A/3A-DSP
// Design Name : DDR2 SDRAM
// Purpose     : This is the simulation testbench which is used to verify the
//               design. The basic clocks and resets to the interface are
//               generated here. This also connects the memory interface to the
//               memory model.
//*****************************************************************************

`timescale 1ns / 100ps

`include "../rtl/ddr2_512M16_mig_parameters_0.v"

module sim_tb_top;

   localparam DEVICE_WIDTH = 16; // Memory device data width
   localparam REG_ENABLE   = `REGISTERED; // registered addr/ctrl

   localparam real CLK_PERIOD_NS      = 7519.0 / 1000.0;
   localparam real TPROP_DQS          = 0.00;  // Delay for DQS signal during Write Operation
   localparam real TPROP_DQS_RD       = 0.05;  // Delay for DQS signal during Read Operation
   localparam real TPROP_PCB_CTRL     = 0.00;  // Delay for Address and Ctrl signals
   localparam real TPROP_PCB_DATA     = 0.00;  // Delay for data signal during Write operation
   localparam real TPROP_PCB_DATA_RD  = 0.00;  // Delay for data signal during Read operation

   reg                     sys_clk;
   reg                     sys_rst_n;
   wire                    sys_rst_out;
   reg [`ROW_ADDRESS-1:0]  ddr2_address_reg;
   reg [`BANK_ADDRESS-1:0] ddr2_ba_reg;
   reg                     ddr2_cke_reg;
   reg                     ddr2_ras_n_reg;
   reg                     ddr2_cas_n_reg;
   reg                     ddr2_we_n_reg;
   reg                     ddr2_cs_n_reg;
   reg                     ddr2_odt_reg;

   wire                    sys_clk_n;
   wire                    sys_clk_p;

   wire [`DATA_WIDTH-1:0]         ddr2_dq_sdram;
   wire [`DATA_STROBE_WIDTH-1:0]  ddr2_dqs_sdram;

   // ddr2_dqs_n signal will be driven only in case of differential dqs is enabled.
   wire [`DATA_STROBE_WIDTH-1:0]  ddr2_dqs_n_sdram;
   wire [`DATA_MASK_WIDTH-1:0]    ddr2_dm_sdram;
   reg  [`DATA_MASK_WIDTH-1:0]    ddr2_dm_sdram_tmp;
   reg  [`CLK_WIDTH-1:0]          ddr2_clk_sdram;
   reg  [`CLK_WIDTH-1:0]          ddr2_clk_n_sdram;
   reg  [`ROW_ADDRESS-1:0]        ddr2_address_sdram;
   reg  [`BANK_ADDRESS-1:0]       ddr2_ba_sdram;
   reg                            ddr2_ras_n_sdram;
   reg                            ddr2_cas_n_sdram;
   reg                            ddr2_we_n_sdram;
   reg                            ddr2_cs_n_sdram;
   reg                            ddr2_cke_sdram;
   reg                            ddr2_odt_sdram;


   wire [`DATA_WIDTH-1:0]         ddr2_dq_fpga;
   wire [`DATA_STROBE_WIDTH-1:0]  ddr2_dqs_fpga;

   // ddr2_dqs_n signal will be driven only in case of differential dqs is enabled.
   wire [`DATA_STROBE_WIDTH-1:0]  ddr2_dqs_n_fpga;
   wire [`DATA_MASK_WIDTH-1:0]    ddr2_dm_fpga;
   wire [`CLK_WIDTH-1:0]          ddr2_clk_fpga;
   wire [`CLK_WIDTH-1:0]          ddr2_clk_n_fpga;
   wire [`ROW_ADDRESS-1:0]        ddr2_address_fpga;
   wire [`BANK_ADDRESS-1:0]       ddr2_ba_fpga;
   wire                           ddr2_ras_n_fpga;
   wire                           ddr2_cas_n_fpga;
   wire                           ddr2_we_n_fpga;
   wire                           ddr2_cs_n_fpga;
   wire                           ddr2_cke_fpga;
   wire                           ddr2_odt_fpga;

   // Only RDIMM memory parts support the reset signal,
   // hence the ddr2_reset_n signal can be ignored for other memory parts
   wire              #(TPROP_PCB_CTRL) ddr2_reset_n;

   //ddr2_dm_8_16 signal will be driven only for x16 components are selected
   wire [1:0]                  ddr2_dm_8_16_sdram;

   wire                        error;
   wire                        init_done;
   wire                        cntrl0_data_valid_out;
   wire                        rst_dqs_div_loop;
   wire                                            cntrl0_burst_done;
   wire                                            cntrl0_ar_done;
   wire                                            cntrl0_user_data_valid;
   wire                                            cntrl0_auto_ref_req;
   wire                                            cntrl0_user_cmd_ack;
   wire                                            [2:0]cntrl0_user_command_register;
   wire                                            cntrl0_clk_tb;
   wire                                            cntrl0_clk90_tb;
   wire                                            cntrl0_sys_rst_tb;
   wire                                            cntrl0_sys_rst90_tb;
   wire                                            cntrl0_sys_rst180_tb;
   wire                                            [((`DATA_MASK_WIDTH*2)-1):
                                                    0]cntrl0_user_data_mask;
   wire                                            [(2*`DATA_WIDTH)-1:
                                                    0]cntrl0_user_output_data;
   wire                                            [(2*`DATA_WIDTH)-1:
                                                    0]cntrl0_user_input_data;
   wire                                            [((`ROW_ADDRESS + 
                                                      `COLUMN_ADDRESS +
                                                      `BANK_ADDRESS)-1):
                                                    0] cntrl0_user_input_address;

/////////////////////////////////////////////////////////////////////////////
// Clock generation and reset
/////////////////////////////////////////////////////////////////////////////

   initial
     sys_clk = 1'b0;
   always
     sys_clk = #(CLK_PERIOD_NS/2) ~sys_clk;

   assign sys_clk_p = sys_clk;
   assign sys_clk_n = ~sys_clk;

  // Generate Reset
   initial begin
      sys_rst_n = 1'b0;
      #200;
      sys_rst_n = 1'b1;
   end

   assign sys_rst_out = `RESET_ACTIVE_LOW ? sys_rst_n : ~sys_rst_n;





// =============================================================================
//                             BOARD Parameters
// =============================================================================
// These parameter values can be changed to model varying board delays
// between the Spartan device and the memory model

  always @( * ) begin
    ddr2_clk_sdram         <=  #(TPROP_PCB_CTRL) ddr2_clk_fpga;
    ddr2_clk_n_sdram       <=  #(TPROP_PCB_CTRL) ddr2_clk_n_fpga;
    ddr2_address_sdram     <=  #(TPROP_PCB_CTRL) ddr2_address_fpga;
    ddr2_ba_sdram          <=  #(TPROP_PCB_CTRL) ddr2_ba_fpga;
    ddr2_ras_n_sdram       <=  #(TPROP_PCB_CTRL) ddr2_ras_n_fpga;
    ddr2_cas_n_sdram       <=  #(TPROP_PCB_CTRL) ddr2_cas_n_fpga;
    ddr2_we_n_sdram        <=  #(TPROP_PCB_CTRL) ddr2_we_n_fpga;
    ddr2_cs_n_sdram        <=  #(TPROP_PCB_CTRL) ddr2_cs_n_fpga;
    ddr2_cke_sdram         <=  #(TPROP_PCB_CTRL) ddr2_cke_fpga;
    ddr2_odt_sdram         <=  #(TPROP_PCB_CTRL) ddr2_odt_fpga;
    ddr2_dm_sdram_tmp      <=  #(TPROP_PCB_DATA) ddr2_dm_fpga;//DM signal generation
  end

  assign ddr2_dm_sdram = ddr2_dm_sdram_tmp;

// Controlling the bi-directional BUS
  genvar dqwd;
  generate
    for (dqwd = 0;dqwd < `DATA_WIDTH;dqwd = dqwd+1) begin : dq_delay
      WireDelay #
       (
        .Delay_g     (TPROP_PCB_DATA),
        .Delay_rd    (TPROP_PCB_DATA_RD)
       )
      u_delay_dq
       (
        .A       (ddr2_dq_fpga[dqwd]),
        .B       (ddr2_dq_sdram[dqwd]),
    .reset       (sys_rst_n)
       );
    end
  endgenerate

  genvar dqswd;
  generate
    for (dqswd = 0;dqswd < `DATA_STROBE_WIDTH;dqswd = dqswd+1) begin : dqs_delay
      WireDelay #
       (
        .Delay_g     (TPROP_DQS),
        .Delay_rd    (TPROP_DQS_RD)
       )
      u_delay_dqs
       (
        .A       (ddr2_dqs_fpga[dqswd]),
        .B       (ddr2_dqs_sdram[dqswd]),
    .reset       (sys_rst_n)
       );

      WireDelay #
       (
        .Delay_g     (TPROP_DQS),
        .Delay_rd    (TPROP_DQS_RD)
       )
      u_delay_dqs_n
       (
        .A       (ddr2_dqs_n_fpga[dqswd]),
        .B       (ddr2_dqs_n_sdram[dqswd]),
    .reset       (sys_rst_n)
       );
    end
  endgenerate

   //***************************************************************************
   // FPGA memory controller
   //***************************************************************************

   ddr2_512M16_mig u_mem_controller
     (
      .sys_clk_in                   (sys_clk_p),
      .reset_in_n                   (sys_rst_out),
      .cntrl0_ddr2_ras_n            (ddr2_ras_n_fpga),
      .cntrl0_ddr2_cas_n            (ddr2_cas_n_fpga),
      .cntrl0_ddr2_we_n             (ddr2_we_n_fpga),
      .cntrl0_ddr2_cs_n             (ddr2_cs_n_fpga),
      .cntrl0_ddr2_cke              (ddr2_cke_fpga),
      .cntrl0_ddr2_odt              (ddr2_odt_fpga),
      .cntrl0_ddr2_dm               (ddr2_dm_fpga),
      .cntrl0_ddr2_dq               (ddr2_dq_fpga),
      .cntrl0_ddr2_dqs              (ddr2_dqs_fpga),
      .cntrl0_ddr2_dqs_n            (ddr2_dqs_n_fpga),
      .cntrl0_ddr2_ck               (ddr2_clk_fpga),
      .cntrl0_ddr2_ck_n             (ddr2_clk_n_fpga),
      .cntrl0_ddr2_ba               (ddr2_ba_fpga),
      .cntrl0_ddr2_a                (ddr2_address_fpga),
      .cntrl0_burst_done            (cntrl0_burst_done),
      .cntrl0_init_done             (init_done),
      .cntrl0_ar_done               (cntrl0_ar_done),
      .cntrl0_user_data_valid       (cntrl0_user_data_valid),
      .cntrl0_auto_ref_req          (cntrl0_auto_ref_req),
      .cntrl0_user_cmd_ack          (cntrl0_user_cmd_ack),
      .cntrl0_user_command_register (cntrl0_user_command_register),
      .cntrl0_clk_tb                (cntrl0_clk_tb),
      .cntrl0_clk90_tb              (cntrl0_clk90_tb),
      .cntrl0_sys_rst_tb            (cntrl0_sys_rst_tb),
      .cntrl0_sys_rst90_tb          (cntrl0_sys_rst90_tb),
      .cntrl0_sys_rst180_tb         (cntrl0_sys_rst180_tb),
      .cntrl0_user_output_data      (cntrl0_user_output_data),
      .cntrl0_user_input_data       (cntrl0_user_input_data),
      .cntrl0_user_input_address    (cntrl0_user_input_address),
      .cntrl0_user_data_mask        (cntrl0_user_data_mask), 
      .cntrl0_rst_dqs_div_in        (rst_dqs_div_loop),
      .cntrl0_rst_dqs_div_out       (rst_dqs_div_loop)
      );

   /////////////////////////////////////////////////////////////////////////////
   // Extra one clock pipelining for RDIMM address and
   // control signals is implemented here (Implemented external to memory model)
   /////////////////////////////////////////////////////////////////////////////

   always @( posedge ddr2_clk_sdram[0] ) begin
      if ( ddr2_reset_n == 1'b0 ) begin
         ddr2_ras_n_reg <= 1'b1;
         ddr2_cas_n_reg <= 1'b1;
         ddr2_we_n_reg  <= 1'b1;
         ddr2_cs_n_reg  <= 1'b1;
         ddr2_odt_reg   <= 1'b0;
      end
      else begin
         ddr2_address_reg <= #(CLK_PERIOD_NS/2) ddr2_address_sdram;
         ddr2_ba_reg      <= #(CLK_PERIOD_NS/2) ddr2_ba_sdram;
         ddr2_ras_n_reg   <= #(CLK_PERIOD_NS/2) ddr2_ras_n_sdram;
         ddr2_cas_n_reg   <= #(CLK_PERIOD_NS/2) ddr2_cas_n_sdram;
         ddr2_we_n_reg    <= #(CLK_PERIOD_NS/2) ddr2_we_n_sdram;
         ddr2_cs_n_reg    <= #(CLK_PERIOD_NS/2) ddr2_cs_n_sdram;
         ddr2_odt_reg     <= #(CLK_PERIOD_NS/2) ddr2_odt_sdram;
      end
   end

/////////////////////////////////////////////////////////////////////////////
// To avoid tIS violations on CKE when reset is deasserted
/////////////////////////////////////////////////////////////////////////////

   always @( posedge ddr2_clk_n_sdram[0] )
      if ( ddr2_reset_n == 1'b0 )
        ddr2_cke_reg <= 1'b0;
      else
        ddr2_cke_reg <= #(CLK_PERIOD_NS) ddr2_cke_sdram;

   /////////////////////////////////////////////////////////////////////////////
   // Memory model instances
   /////////////////////////////////////////////////////////////////////////////

   genvar i;
   generate
      if (DEVICE_WIDTH == 16) begin
/////////////////////////////////////////////////////////////////////////////
// if memory part is x16
/////////////////////////////////////////////////////////////////////////////
         if ( REG_ENABLE ) begin
/////////////////////////////////////////////////////////////////////////////
// if the memory part is Registered DIMM
/////////////////////////////////////////////////////////////////////////////
            for(i = 0; i < `DATA_STROBE_WIDTH/2; i = i+1) begin : gen_bytes
               
               ddr2_model u_mem0
                 (
                  .ck      (ddr2_clk_sdram[`CLK_WIDTH*i/`DATA_STROBE_WIDTH]),
                  .ck_n    (ddr2_clk_n_sdram[`CLK_WIDTH*i/`DATA_STROBE_WIDTH]),
                  .cke     (ddr2_cke_reg),
                  .cs_n    (ddr2_cs_n_reg),
                  .ras_n   (ddr2_ras_n_reg),
                  .cas_n   (ddr2_cas_n_reg),
                  .we_n    (ddr2_we_n_reg),
                  .dm_rdqs (ddr2_dm_sdram[(2*(i+1))-1 : i*2]),
                  .ba      (ddr2_ba_reg),
                  .addr    (ddr2_address_reg),
                  .dq      (ddr2_dq_sdram[(16*(i+1))-1 : i*16]),
                  .dqs     (ddr2_dqs_sdram[(2*(i+1))-1 : i*2]),
                  .dqs_n   (ddr2_dqs_n_sdram[(2*(i+1))-1 : i*2]),
                  .rdqs_n  (),
                  .odt     (ddr2_odt_reg)
                  );
            end
         end
         else begin
/////////////////////////////////////////////////////////////////////////////
// if the memory part is component or unbuffered DIMM
/////////////////////////////////////////////////////////////////////////////
            if ( `DATA_WIDTH%16 ) begin
/////////////////////////////////////////////////////////////////////////////
// for the memory part x16, if the data width is not multiple
// of 16, memory models are instantiated for all data with x16
// memory model and except for MSB data. For the MSB data
// of 8 bits, all memory data, strobe and mask data signals are
// replicated to make it as x16 part. For example if the design
// is generated for data width of 72, memory model x16 parts
// instantiated for 4 times with data ranging from 0 to 63.
// For MSB data ranging from 64 to 71, one x16 memory model
// by replicating the 8-bit data twice and similarly
// the case with data mask and strobe.
/////////////////////////////////////////////////////////////////////////////
               for(i = 0; i < `DATA_WIDTH/16 ; i = i+1) begin : gen_bytes
                 
                  ddr2_model u_mem0
                    (
                     .ck       (ddr2_clk_sdram[i]),
                     .ck_n     (ddr2_clk_n_sdram[i]),
                     .cke     (ddr2_cke_sdram),
                     .cs_n    (ddr2_cs_n_sdram),
                     .ras_n   (ddr2_ras_n_sdram),
                     .cas_n   (ddr2_cas_n_sdram),
                     .we_n    (ddr2_we_n_sdram),
                     .dm_rdqs (ddr2_dm_sdram[(2*(i+1))-1 : i*2]),
                     .ba      (ddr2_ba_sdram),
                     .addr    (ddr2_address_sdram),
                     .dq      (ddr2_dq_sdram[(16*(i+1))-1 : i*16]),
                     .dqs     (ddr2_dqs_sdram[(2*(i+1))-1 : i*2]),
                     .dqs_n   (ddr2_dqs_n_sdram[(2*(i+1))-1 : i*2]),
                     .rdqs_n  (),
                     .odt     (ddr2_odt_sdram)
                     );
               end

               assign ddr2_dm_8_16_sdram = {ddr2_dm_sdram[`DATA_MASK_WIDTH - 1],ddr2_dm_sdram[`DATA_MASK_WIDTH - 1]};
               
               ddr2_model u_mem1
                 (
                  .ck      (ddr2_clk_sdram[`CLK_WIDTH-1]),
                  .ck_n    (ddr2_clk_n_sdram[`CLK_WIDTH-1]),
                  .cke     (ddr2_cke_sdram),
                  .cs_n    (ddr2_cs_n_sdram),
                  .ras_n   (ddr2_ras_n_sdram),
                  .cas_n   (ddr2_cas_n_sdram),
                  .we_n    (ddr2_we_n_sdram),
                  .dm_rdqs (ddr2_dm_8_16_sdram),
                  .ba      (ddr2_ba_sdram),
                  .addr    (ddr2_address_sdram),
                  .dq      ({ddr2_dq_sdram[`DATA_WIDTH - 1 : `DATA_WIDTH - 8],
                             ddr2_dq_sdram[`DATA_WIDTH - 1 : `DATA_WIDTH - 8]}),
                  .dqs     ({ddr2_dqs_sdram[`DATA_STROBE_WIDTH - 1],
                             ddr2_dqs_sdram[`DATA_STROBE_WIDTH - 1]}),
                  .dqs_n   ({ddr2_dqs_n_sdram[`DATA_STROBE_WIDTH - 1],
                             ddr2_dqs_n_sdram[`DATA_STROBE_WIDTH - 1]}),
                  .rdqs_n  (),
                  .odt     (ddr2_odt_sdram)
                  );
            end
            else begin
/////////////////////////////////////////////////////////////////////////////
// if the data width is multiple of 16
/////////////////////////////////////////////////////////////////////////////
               for(i = 0; i < `DATA_STROBE_WIDTH/2; i = i+1) begin : gen_bytes
                  
                  ddr2_model u_mem0
                    (
                     .ck       (ddr2_clk_sdram[i]),
                     .ck_n     (ddr2_clk_n_sdram[i]),
                     .cke     (ddr2_cke_sdram),
                     .cs_n    (ddr2_cs_n_sdram),
                     .ras_n   (ddr2_ras_n_sdram),
                     .cas_n   (ddr2_cas_n_sdram),
                     .we_n    (ddr2_we_n_sdram),
                     .dm_rdqs (ddr2_dm_sdram[(2*(i+1))-1 : i*2]),
                     .ba      (ddr2_ba_sdram),
                     .addr    (ddr2_address_sdram),
                     .dq      (ddr2_dq_sdram[(16*(i+1))-1 : i*16]),
                     .dqs     (ddr2_dqs_sdram[(2*(i+1))-1 : i*2]),
                     .dqs_n   (ddr2_dqs_n_sdram[(2*(i+1))-1 : i*2]),
                     .rdqs_n  (),
                     .odt     (ddr2_odt_sdram)
                     );
               end
            end
         end
      end else
        if (DEVICE_WIDTH == 8) begin
/////////////////////////////////////////////////////////////////////////////
// if the memory part is x8
/////////////////////////////////////////////////////////////////////////////
           if ( REG_ENABLE ) begin
/////////////////////////////////////////////////////////////////////////////
// if the memory part is Registered DIMM
/////////////////////////////////////////////////////////////////////////////
              for(i = 0; i < `DATA_WIDTH/`DATABITSPERSTROBE; i = i+1) begin : gen_bytes
                 
                 ddr2_model u_mem0
                   (
                    .ck      (ddr2_clk_sdram[`CLK_WIDTH*i/`DATA_STROBE_WIDTH]),
                    .ck_n    (ddr2_clk_n_sdram[`CLK_WIDTH*i/`DATA_STROBE_WIDTH]),
                    .cke     (ddr2_cke_reg),
                    .cs_n    (ddr2_cs_n_reg),
                    .ras_n   (ddr2_ras_n_reg),
                    .cas_n   (ddr2_cas_n_reg),
                    .we_n    (ddr2_we_n_reg),
                    .dm_rdqs (ddr2_dm_sdram[i]),
                    .ba      (ddr2_ba_reg),
                    .addr    (ddr2_address_reg),
                    .dq      (ddr2_dq_sdram[(8*(i+1))-1 : i*8]),
                    .dqs     (ddr2_dqs_sdram[i]),
                    .dqs_n   (ddr2_dqs_n_sdram[i]),
                    .rdqs_n  (),
                    .odt     (ddr2_odt_reg)
                    );
              end
           end
           else begin
/////////////////////////////////////////////////////////////////////////////
// if the memory part is component or unbuffered DIMM
/////////////////////////////////////////////////////////////////////////////
              for(i = 0; i < `DATA_STROBE_WIDTH; i = i+1) begin : gen_bytes
                 
                 ddr2_model u_mem0
                   (
                    .ck        (ddr2_clk_sdram[i]),
                    .ck_n      (ddr2_clk_n_sdram[i]),
                    .cke     (ddr2_cke_sdram),
                    .cs_n    (ddr2_cs_n_sdram),
                    .ras_n   (ddr2_ras_n_sdram),
                    .cas_n   (ddr2_cas_n_sdram),
                    .we_n    (ddr2_we_n_sdram),
                    .dm_rdqs (ddr2_dm_sdram[i]),
                    .ba      (ddr2_ba_sdram),
                    .addr    (ddr2_address_sdram),
                    .dq      (ddr2_dq_sdram[(8*(i+1))-1 : i*8]),
                    .dqs     (ddr2_dqs_sdram[i]),
                    .dqs_n   (ddr2_dqs_n_sdram[i]),
                    .rdqs_n  (),
                    .odt     (ddr2_odt_sdram)
                    );
              end
           end
        end else
          if (DEVICE_WIDTH == 4) begin
/////////////////////////////////////////////////////////////////////////////
// if the memory part is x4
/////////////////////////////////////////////////////////////////////////////
             if ( REG_ENABLE ) begin
/////////////////////////////////////////////////////////////////////////////
// if the memory part is Registered DIMM
/////////////////////////////////////////////////////////////////////////////
                for(i = 0; i < `DATA_STROBE_WIDTH; i = i+1) begin : gen_bytes
                   
                   ddr2_model u_mem0
                     (
                      .ck      (ddr2_clk_sdram[`CLK_WIDTH*i/`DATA_STROBE_WIDTH]),
                      .ck_n    (ddr2_clk_n_sdram[`CLK_WIDTH*i/`DATA_STROBE_WIDTH]),
                      .cke     (ddr2_cke_reg),
                      .cs_n    (ddr2_cs_n_reg),
                      .ras_n   (ddr2_ras_n_reg),
                      .cas_n   (ddr2_cas_n_reg),
                      .we_n    (ddr2_we_n_reg),
                      .dm_rdqs (ddr2_dm_sdram[i/2]),
                      .ba      (ddr2_ba_reg),
                      .addr    (ddr2_address_reg),
                      .dq      (ddr2_dq_sdram[(4*(i+1))-1 : i*4]),
                      .dqs     (ddr2_dqs_sdram[i]),
                      .dqs_n   (ddr2_dqs_n_sdram[i]),
                      .rdqs_n  (),
                      .odt     (ddr2_odt_reg)
                      );
                end
             end
             else begin
/////////////////////////////////////////////////////////////////////////////
// if the memory part is component or unbuffered DIMM
/////////////////////////////////////////////////////////////////////////////
                for(i = 0; i < `DATA_STROBE_WIDTH; i = i+1) begin : gen_bytes
                   
                   ddr2_model u_mem0
                     (
                      .ck      (ddr2_clk_sdram[i]),
                      .ck_n    (ddr2_clk_n_sdram[i]),
                      .cke     (ddr2_cke_sdram),
                      .cs_n    (ddr2_cs_n_sdram),
                      .ras_n   (ddr2_ras_n_sdram),
                      .cas_n   (ddr2_cas_n_sdram),
                      .we_n    (ddr2_we_n_sdram),
                      .dm_rdqs (ddr2_dm_sdram[i/2]),
                      .ba      (ddr2_ba_sdram),
                      .addr    (ddr2_address_sdram),
                      .dq      (ddr2_dq_sdram[(4*(i+1))-1 : i*4]),
                      .dqs     (ddr2_dqs_sdram[i]),
                      .dqs_n   (ddr2_dqs_n_sdram[i]),
                      .rdqs_n  (),
                      .odt     (ddr2_odt_sdram)
                      );
                end
             end
          end
   endgenerate

// synthesizable test bench provided for wotb designs
   ddr2_512M16_mig_test_bench_0 test_bench0
      (
       .auto_ref_req      (cntrl0_auto_ref_req),
       .fpga_clk          (cntrl0_clk_tb),
       .fpga_rst90        (cntrl0_sys_rst90_tb),
       .fpga_rst180       (cntrl0_sys_rst180_tb),
       .clk90             (cntrl0_clk90_tb),
       .burst_done        (cntrl0_burst_done),
       .init_done         (init_done),
       .ar_done           (cntrl0_ar_done),
       .u_ack             (cntrl0_user_cmd_ack),
       .u_data_val        (cntrl0_user_data_valid),
       .u_data_o          (cntrl0_user_output_data),
       .u_addr            (cntrl0_user_input_address),
       .u_cmd             (cntrl0_user_command_register),
       .u_data_i          (cntrl0_user_input_data),
       .u_data_m          (cntrl0_user_data_mask),
       .led_error_output  (error),
       .data_valid_out    (data_valid_out)
       );


endmodule // sim_tb_top
