`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    06:16:55 04/12/2015 
// Design Name: 
// Module Name:    pcb 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module pcb(
    input              CLK_50M,
    input              CLK_AUX,

    input              BTN_SOUTH , 
    input [3:0]        SW,
    output wire [7:0]  LED, 
    output wire [12:0] SD_A,
    output wire  [1:0] SD_BA,
    output wire        SD_CAS,
    output wire        SD_CK_P,
    output wire        SD_CK_N,
    output wire        SD_CKE,
    output wire        SD_CS,
    inout  wire [15:0] SD_DQ,
    output wire        SD_LDM,
    output wire        SD_RAS,
    output wire        SD_UDM,
    output wire        SD_ODT,
    output wire        SD_UDQS_P,
    output wire        SD_UDQS_N,
    output wire        SD_LDQS_P,
    output wire        SD_LDQS_N,
    output wire        SD_WE,
    output wire        SD_LOOP_OUT,
    input  wire        SD_LOOP_IN
);
    
//`define  CLK_MUL_SRC 

   wire clk_50m_i, clk_50m_o, clk_100m, clk_75m, clk_25m,  dcm_locked, rst, global_rst ; 
   wire clk_120m, dcm_inter_locked ; 
   wire mem_clk_s, mem_rst_s_n ;  

   wire  sw_0_filter, fractal_rst_mask ;
   wire  btn_south_io, btn_south_io_filter ; 

   wire fractal_clk,  fractal_rst ; 

   wire  memory_init_done ; 

   //synthesis attribute keep of fractal_rst_mask is "true"
   `include "ddr2_512M16_mig_parameters_0.v"

   wire  clk_50m_in ; 
   //assign clk_50m_in  =  CLK_50M ; 
      
      IBUFG clk_50m_inst (
         .O ( clk_50m_in   ),
         .I ( CLK_50M      ) 
   ) ; 

   //  Instantiate the module
   clock_gen clock_gen_inst (
       .CLKIN_IN        (  clk_50m_in ), 
       .CLKDV_OUT       (  clk_25m    ), 
       .CLKFX_OUT       (  clk_75m    ), 
       //.CLKIN_IBUFG_OUT (  clk_50m_i  ), 
       .CLK0_OUT        (  clk_50m_o  ), 
       .CLK2X_OUT       (  clk_100m   ), 
       .LOCKED_OUT      (  dcm_locked )
   );

`ifdef CLK_MUL_SRC 
   clock_inter_gen clock_inter_gen_inst (
       .CLKIN_IN        (  clk_50m_in  ), 
       .CLKFX_OUT       (  clk_120M ), 
       .CLK0_OUT        (  ), 
       .LOCKED_OUT      (  dcm_inter_locked)
   );
`endif


`ifdef 0 
   wire     chipscope_clk_half, chipscope_clk ; 

   //synthesis attribute keep of chipscope_clk is "true"
   clock_chipscope_gen clock_chipscope_gen_inst (
       .CLKIN_IN        ( mem_clk_s           ), 
       .CLK0_OUT        ( chipscope_clk_half  ), 
       .CLK2X_OUT       ( chipscope_clk       ), 
       .LOCKED_OUT      (  )
   );

`endif

   synchro #(.INITIALIZE("LOGIC1"))
   synchro_reset (.async(!dcm_locked),.sync(rst),.clk(clk_75m));


   btn_filter  #(.PIN_NUM (2 ) ) top_btn_filter_inst (
     .clk     ( clk_75m   ),
     .pin_in  ( { btn_south_io,        SW[0]        } ),
     .pin_out ( { btn_south_io_filter, sw_0_filter  } ) 
   );

   ddr_mgr_main  ddr_mgr_main_inst (
      .clk               ( fractal_clk       ), //i
      .mem_clk_s         ( mem_clk_s         ), //i
      .rst               ( fractal_rst       ), //i
      .mem_rst_s_n       ( mem_rst_s_n       ), //i
      .memory_init_done  ( mem_init_done     ), //o 
      .led_0_io          ( LED[0]            ), //o 
      .ddr2_dq_fpga      ( SD_DQ             ), //o
      .ddr2_dqs_fpga     ( {SD_UDQS_P,SD_LDQS_P}), //o
      .ddr2_dqs_n_fpga   ( {SD_UDQS_N,SD_LDQS_N}), //o
      .ddr2_dm_fpga      ( {SD_UDM,SD_LDM}   ), //o
      .ddr2_clk_fpga     ( SD_CK_P           ), //o
      .ddr2_clk_n_fpga   ( SD_CK_N           ), //o
      .ddr2_address_fpga ( SD_A              ), //o
      .ddr2_ba_fpga      ( SD_BA             ), //o
      .ddr2_ras_n_fpga   ( SD_RAS            ), //o
      .ddr2_cas_n_fpga   ( SD_CAS            ), //o
      .ddr2_we_n_fpga    ( SD_WE             ), //o
      .ddr2_cs_n_fpga    ( SD_CS             ), //o
      .ddr2_cke_fpga     ( SD_CKE            ), //o
      .ddr2_odt_fpga     ( SD_ODT            ), //o
      .ddr2_rst_dqs_div_in  ( SD_LOOP_IN     ), //i
      .ddr2_rst_dqs_div_out ( SD_LOOP_OUT    )  //o
   );


   // main logic clock and reset signals
   assign   fractal_clk       = clk_75m ;  
   assign   fractal_rst       = rst | fractal_rst_mask | global_rst ;  
   assign   fractal_rst_mask  = sw_0_filter ;   
   assign   btn_south_io      = BTN_SOUTH ;  
   assign   global_rst        = btn_south_io_filter ; 

   // Memory clock and reset signals
   //assign   mem_clk_s         = CLK_AUX  ; 
   //assign   mem_clk_s         = clk_100m  ; 
   //BUFG    mem_clk_ibuf ( .I(clk_100m), .O(mem_clk_s ) ) ;  

   wire     clk_133m, clk_133m_pre ; 

   /*
   IBUFG  SYS_CLK_INST
   (
     .I  (  CLK_AUX),
     .O  (  clk_133m)
   );
   BUF   clk_133m_inst (
         .I (  clk_133m_pre ),
         .O (  clk_133m ) 
   ) ; 
*/
   
`ifdef CLK_MUL_SRC 
   // Remark:
   // *) Maximum clock frequency for MIG write is tested to be 110Mhz
   //    115Mhz dose NOT work on MIG write. 
   // *) After fix the issue of data write from clk180 to clk90, 120Mhz works fine. 
   //    130Mhz dose NIT work on MIG write.
   //    
   
   BUFGMUX  mem_clk_mux (
         .O    (  mem_clk_s ),
         //.I0   (  clk_100m  ),  
         .I0   (  clk_120M  ),
         .I1   (  CLK_AUX  ),
         .S    (  memory_init_done )
         //.S    (  1'b1 )
   ) ; 

`else    
   
   IBUFG  SYS_CLK_INST
   (
     .I  (  CLK_AUX),
     .O  (  mem_clk_s )
   );
  
`endif   

   assign   mem_rst_s_n       = dcm_locked & ( ~ global_rst ) ; 
   //assign   mem_rst_s_n       = dcm_inter_locked & ( ~ global_rst ) ; 
	
  assign    LED[7:1]          =  6'h00 ; 

endmodule
