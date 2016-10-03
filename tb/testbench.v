//////////////////////////////////////////////////////////////////////////////////
// Author: merlionfire 
// 
// Create Date:    10/01/2016 
// Design Name: 
// Module Name:    testbench.v 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:    Testbench  
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps
`default_nettype none 
`define  SIM 
`define  DUT   ddr_mgr_main_inst 
module testbench () ; 

`include "ddr2_512M16_mig_parameters_0.v"

  logic clk, rst ; 
  logic mem_clk_s, mem_rst_s_n ; 
  logic mem_clk0 ;  

   // Sinals between DDR2 model and MIG .
   wire [`DATA_WIDTH-1:0]         ddr2_dq_fpga;
   wire [`DATA_STROBE_WIDTH-1:0]  ddr2_dqs_fpga;
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

   wire ddr2_rst_dqs_div_in ;
   wire ddr2_rst_dqs_div_out; 



  //*******************************************************************//
  //     Instatiation                                                  // 
  //*******************************************************************//

   ddr_mgr_main  ddr_mgr_main_inst (
      .clk                  ( clk               ), //i
      .mem_clk_s            ( mem_clk_s         ), //i
      .rst                  ( rst               ), //i
      .mem_rst_s_n          ( mem_rst_s_n       ), //i
      .ddr2_dq_fpga         ( ddr2_dq_fpga      ), //o
      .ddr2_dqs_fpga        ( ddr2_dqs_fpga     ), //o
      .ddr2_dqs_n_fpga      ( ddr2_dqs_n_fpga   ), //o
      .ddr2_dm_fpga         ( ddr2_dm_fpga      ), //o
      .ddr2_clk_fpga        ( ddr2_clk_fpga     ), //o
      .ddr2_clk_n_fpga      ( ddr2_clk_n_fpga   ), //o
      .ddr2_address_fpga    ( ddr2_address_fpga ), //o
      .ddr2_ba_fpga         ( ddr2_ba_fpga      ), //o
      .ddr2_ras_n_fpga      ( ddr2_ras_n_fpga   ), //o
      .ddr2_cas_n_fpga      ( ddr2_cas_n_fpga   ), //o
      .ddr2_we_n_fpga       ( ddr2_we_n_fpga    ), //o
      .ddr2_cs_n_fpga       ( ddr2_cs_n_fpga    ), //o
      .ddr2_cke_fpga        ( ddr2_cke_fpga     ), //o
      .ddr2_odt_fpga        ( ddr2_odt_fpga     ), //o
      .ddr2_rst_dqs_div_in  ( ddr2_rst_dqs_div_in ), //i
      .ddr2_rst_dqs_div_out ( ddr2_rst_dqs_div_out)  //o
  );

   /////////////////////////////////////////////////////////////////////////////
   // Memory model instances
   /////////////////////////////////////////////////////////////////////////////
   
   ddr2_model u_mem0 (
      .ck      (ddr2_clk_fpga),
      .ck_n    (ddr2_clk_n_fpga),
      .cke     (ddr2_cke_fpga),
      .cs_n    (ddr2_cs_n_fpga),
      .ras_n   (ddr2_ras_n_fpga),
      .cas_n   (ddr2_cas_n_fpga),
      .we_n    (ddr2_we_n_fpga),
      .dm_rdqs (ddr2_dm_fpga),
      .ba      (ddr2_ba_fpga),
      .addr    (ddr2_address_fpga),
      .dq      (ddr2_dq_fpga),
      .dqs     (ddr2_dqs_fpga),
      .dqs_n   (ddr2_dqs_n_fpga),
      .rdqs_n  (),
      .odt     (ddr2_odt_fpga)
  );

  //*******************************************************************//
  //     clock                                                         // 
  //*******************************************************************//

  always #10ns clk = ~ clk ; 
  always #4ns mem_clk_s = ~ mem_clk_s ; 


  //*******************************************************************//
  //     Main test                                                     // 
  //*******************************************************************//

  assign  ddr2_rst_dqs_div_in = ddr2_rst_dqs_div_out ;

  assign   mem_clk0 = `DUT.mem_clk0 ; 

  initial begin 
     rst   =  1'b1; clk   =  1'b0;  
     mem_clk_s = 1'b0 ;  mem_rst_s_n = 1'b0 ; 
     
     //reset dut 
     repeat (8) @(posedge clk ) ; 
     #10 mem_rst_s_n =  1'b1 ; 
     
     $display("[SIM_INFO] DDR2_mgr and MIG have been unfrozen by testbench, be waiting for memory init done......" ) ;   

     wait ( ddr_mgr_main_inst.mig_init_done ) ; 
     $display("[SIM_INFO] Memory initialization has been done !!" ) ;   

     repeat (8) @(posedge clk ) ; 
     $display("[SIM_INFO] Picoblaze start to preload ddr2 ............") ;  

     wait ( ddr_mgr_main_inst.buffer_init_done ) ; 
     $display("[SIM_INFO] Picoblaze preloading ddr2 has been done !!") ;  


     wait ( `DUT.rd_xfr_en ) ; 
     $display("[SIM_INFO] First read request occurs. Requested row address is 0x%2h", `DUT.rd_mem_addr) ;  
     
     repeat (20) @(negedge mem_clk0 ) ; 

     forever begin 
        $display("[SIM_INFO] frame = %1d", `DUT.screen_cnt );  
        @( `DUT.screen_cnt )  ; 
        if ( `DUT.screen_cnt == 100 )  begin 
           $sdisplay("[SIM_INFO] The number of frame has reach the upper-limition.Sim will finish as expected" );  
           $finish ; 
        end

      end

  end 



  //*******************************************************************//
  //     FSDB dumper                                                   // 
  //*******************************************************************//

  initial begin
      $fsdbDumpfile("cosim_verdi.fsdb");
      $fsdbDumpvars();
      #1ms $finish ; 
  end

`ifdef SVA 
/*
   property DDR2_VALUE_CHECKER ; 
      @( posedge clk ) 
         `DISP.linebuf_rd_en |-> ##2 ( `DISP.linebuf_rd_data == { 5'b00000, `DISP.pixel_y }  ) ; 
   endproperty 

   assert property ( DDR2_VALUE_CHECKER ) 
      else begin 
         $display( "[ASSERT ERR] %t: ddr2 data is not as expected !!!", $time ) ; 
         repeat (20 ) @( posedge clk ) ; 
         $finish ; 
      end   

   cover property ( DDR2_VALUE_CHECKER ) ;     

   property DDR2_VALUE_CHECKER ; 
      @( posedge clk ) disable iff ( rst == 1'b1 )  
         `DISP.diag_err == 1'b0  ; 
   endproperty 

   assert property ( DDR2_VALUE_CHECKER ) 
      else begin 
         $display( "[ASSERT ERR] %t: ddr2 data is not as expected !!!", $time ) ; 
         repeat (20 ) @( posedge clk ) ; 
         $finish ; 
      end   

   cover property ( DDR2_VALUE_CHECKER ) ;     
*/
`endif

endmodule 
