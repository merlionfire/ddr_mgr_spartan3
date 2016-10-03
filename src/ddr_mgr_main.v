
// Copy fractal_top and remove siganls inrelevent of ddr_mgr testing
`include "ddr2_512M16_mig_parameters_0.v"
//`default_nettype none
module ddr_mgr_main  
#( 
   parameter FONT_WIDTH_N_BITS = 3,  
   parameter FONT_HEIGH_N_BITS = 4  
)
(
   // --- clock and reset 
   input  wire        clk,
   input  wire        mem_clk_s,
   input  wire        rst,
   input  wire        mem_rst_s_n,

   // --- MIG and ddr2 device interface
   inout  wire [`DATA_WIDTH-1:0]         ddr2_dq_fpga,
   inout  wire [`DATA_STROBE_WIDTH-1:0]  ddr2_dqs_fpga,
   inout  wire [`DATA_STROBE_WIDTH-1:0]  ddr2_dqs_n_fpga,
   output wire [`DATA_MASK_WIDTH-1:0]    ddr2_dm_fpga,
   output wire [`CLK_WIDTH-1:0]          ddr2_clk_fpga,
   output wire [`CLK_WIDTH-1:0]          ddr2_clk_n_fpga,
   output wire [`ROW_ADDRESS-1:0]        ddr2_address_fpga,
   output wire [`BANK_ADDRESS-1:0]       ddr2_ba_fpga,
   output wire                           ddr2_ras_n_fpga,
   output wire                           ddr2_cas_n_fpga,
   output wire                           ddr2_we_n_fpga,
   output wire                           ddr2_cs_n_fpga,
   output wire                           ddr2_cke_fpga,
   output wire                           ddr2_odt_fpga,
   input  wire                           ddr2_rst_dqs_div_in,
   output wire                           ddr2_rst_dqs_div_out
) ; 

   parameter  REG_DISP_BLK_ADDR  =  4'h0 ; 
   parameter  REG_DDR2_MGR_ADDR  =  4'h1 ;  
   parameter  REG_FRAC_UNIT_ADDR =  4'h2 ;  
   parameter  REG_MOUSE_ADDR     =  4'h3 ;

   parameter  DISP_BLK_SEL_BIT   =  4'h0 ;  
   parameter  DDR2_MGR_SEL_BIT   =  4'h1 ;    
   parameter  FRAC_UNIT_SEL_BIT  =  4'h2 ; 
   parameter  MOUSE_SEL_BIT      =  4'h3 ;

   wire [7:0 ] port_id, out_port,  in_port;
   wire        write_strobe,  read_strobe,  interrupt,  interrupt_ack ; 
   reg  [15:0] pi_blk_sel ; 
   wire [3:0]  pi_addr;
   wire        pi_wr_en, pi_rd_en ; 
   wire [7:0]  pi_wr_data, pi_disp_rd_data, pi_ddr2_mgr_rd_data, pi_unit_rd_data, pi_mouse_rd_data  ; 

   //Signals between ddr2_mgr and MIG  

   wire                                  mig_burst_done;
   wire                                  mig_init_done;
   wire                                  mig_ar_done;
   wire                                  mig_user_data_valid;
   wire                                  mig_auto_ref_req;
   wire                                  mig_user_cmd_ack;
   wire [2:0]                            mig_user_input_cmds;
   wire                                  mig_clk0;
   wire                                  mig_clk90;
   wire                                  mig_rst0;
   wire                                  mig_rst90;
   wire                                  mig_rst180;
   wire [((`DATA_MASK_WIDTH*2)-1): 0]    mig_user_input_mask;
   wire [(2*`DATA_WIDTH)-1: 0]           mig_user_input_data;
   wire [(2*`DATA_WIDTH)-1: 0]           mig_user_output_data;
   wire [((`ROW_ADDRESS + `COLUMN_ADDRESS + `BANK_ADDRESS)-1): 0] mig_user_input_addr;
   wire                                  rst_dqs_div_loop;

   wire  mem_clk0, mem_clk90, mem_rst, mem_rst0, mem_rst90, mem_rst180 ; 


   wire rd_mem_req, rd_mem_grant, rd_data_valid;
   wire [24:0] rd_mem_addr; 
   reg  [9:0]  rd_xfr_len; 
   wire [31:0] rd_data;

   picoblaze  picoblaze_inst (
      .clk           ( clk           ), //i
      .reset         ( rst           ), //i
      .port_id       ( port_id       ), //o
      .write_strobe  ( write_strobe  ), //o
      .read_strobe   ( read_strobe   ), //o
      .out_port      ( out_port      ), //o
      .in_port       ( in_port       ), //i
      .interrupt     ( interrupt     ), //i
      .interrupt_ack ( interrupt_ack )  //o
   );

   ddr2_mgr  ddr2_mgr_inst (
      .clk0                 ( mem_clk0             ), //i
      .rst0                 ( mem_rst0             ), //i
      .clk90                ( mem_clk90            ), //i
      .rst90                ( mem_rst90            ), //i
      .rst180               ( mem_rst180           ), //i
      .pi_clk               ( clk                  ), //i
      .pi_rst               ( rst                  ), //i
      .mig_user_input_cmds  ( mig_user_input_cmds  ), //o
      .mig_burst_done       ( mig_burst_done       ), //o
      .mig_user_input_addr  ( mig_user_input_addr  ), //o
      .mig_init_done        ( mig_init_done        ), //i
      .mig_user_cmd_ack     ( mig_user_cmd_ack     ), //i
      .mig_user_input_data  ( mig_user_input_data  ), //o
      .mig_user_input_mask  ( mig_user_input_mask  ), //o
      .mig_user_output_data ( mig_user_output_data ), //i
      .mig_user_data_valid  ( mig_user_data_valid  ), //i
      .mig_auto_ref_req     ( mig_auto_ref_req     ), //i
      .mig_ar_done          ( mig_ar_done          ), //i
      .pi_blk_sel           ( pi_blk_sel[DDR2_MGR_SEL_BIT] ), //i
      .pi_addr              ( pi_addr              ), //i
      .pi_wr_en             ( pi_wr_en             ), //i
      .pi_rd_en             ( pi_rd_en             ), //i
      .pi_wr_data           ( pi_wr_data           ), //i
      .pi_rd_data           ( pi_ddr2_mgr_rd_data  ), //o
      .rd_mem_req           ( rd_mem_req           ), //i
      .rd_mem_addr          ( rd_mem_addr          ), //i
      .rd_xfr_len           ( rd_xfr_len           ), //i
      .rd_mem_grant         ( rd_mem_grant         ), //o
      .rd_data              ( rd_data              ), //o
      .rd_data_valid        ( rd_data_valid        )  //o
   );

   ddr2_512M16_mig u_mem_controller
   (
      // Clock and reset for MIG 
      .sys_clk_in                   ( mem_clk_s     ),//i      
      .reset_in_n                   ( mem_rst_s_n   ),//i
      // DDR2 interface  
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

      // Mig interface 

      .cntrl0_burst_done            (mig_burst_done),
      .cntrl0_init_done             (mig_init_done),
      .cntrl0_ar_done               (mig_ar_done),
      .cntrl0_user_data_valid       (mig_user_data_valid),
      .cntrl0_auto_ref_req          (mig_auto_ref_req),
      .cntrl0_user_cmd_ack          (mig_user_cmd_ack),
      .cntrl0_user_command_register (mig_user_input_cmds),
      .cntrl0_clk_tb                (mig_clk0),
      .cntrl0_clk90_tb              (mig_clk90),
      .cntrl0_sys_rst_tb            (mig_rst0),
      .cntrl0_sys_rst90_tb          (mig_rst90),
      .cntrl0_sys_rst180_tb         (mig_rst180),
      .cntrl0_user_output_data      (mig_user_output_data),
      .cntrl0_user_input_data       (mig_user_input_data),
      .cntrl0_user_input_address    (mig_user_input_addr),
      .cntrl0_user_data_mask        (mig_user_input_mask), 
      .cntrl0_rst_dqs_div_in        (ddr2_rst_dqs_div_in),
      .cntrl0_rst_dqs_div_out       (ddr2_rst_dqs_div_out)
   );




   //*************************************************************//
   // Register address decoder   
   //*************************************************************//
  
   always @(*) begin  
      pi_blk_sel   =  4'h0;    
      case  ( port_id[7:4] ) 
         REG_DISP_BLK_ADDR    :  pi_blk_sel[DISP_BLK_SEL_BIT]   =  1'b1 ; 
         REG_DDR2_MGR_ADDR    :  pi_blk_sel[DDR2_MGR_SEL_BIT]   =  1'b1 ; 
         REG_FRAC_UNIT_ADDR   :  pi_blk_sel[FRAC_UNIT_SEL_BIT]  =  1'b1 ; 
         REG_MOUSE_ADDR       :  pi_blk_sel[MOUSE_SEL_BIT]      =  1'b1 ; 
      endcase 
   end


   // Register configuraton for disp_pi
   reg   [7:0] cw_cs ; 
   parameter   REG_CW_CS_ADDR    =  4'h0;             
   always @( posedge clk ) begin    
      if ( rst ) begin 
         cw_cs          <= 8'h00; 
      end else begin
         if ( pi_wr_en && pi_blk_sel[DISP_BLK_SEL_BIT] ) begin 
            case ( pi_addr ) 
               REG_CW_CS_ADDR             :  cw_cs          <= pi_wr_data ;   
            endcase 
         end
      end
   end



   // verification logic 

   reg   rd_go, buffer_init_done_1d ; 
   reg   rd_xfr_done, rd_xfr_done_nxt ; 
   wire  buffer_init_done, buffer_init_done_pulse ;  
   reg [12:0] req_addr_row ; 
   reg [15:0]  screen_cnt   ;  
   reg   screen_cnt_overrun ; 

   // Create rd_go signal, which initiates state machine to issue read request to ddr2_mgr ;  
   // rd_go is asserted :
   //    *) once register CW_CS[1] indicating memory init is done 
   //    *) after every data read finishes 
   assign buffer_init_done =  cw_cs[1] ;   

   assign buffer_init_done_pulse  =  buffer_init_done & ~buffer_init_done_1d ;    
   always @( negedge mem_clk0 ) begin    
      if ( mem_rst ) begin 
         rd_go                <= 1'b0 ;
         buffer_init_done_1d  <= 1'b0 ; 
      end else begin 
         buffer_init_done_1d  <= buffer_init_done; 
         if ( buffer_init_done_pulse | rd_xfr_done ) begin  
            rd_go          <= 1'b1 ;
         end else begin 
            rd_go          <= 1'b0 ;
         end
      end
   end


   /// ----- Below is from frame_buf.v
   reg   [ `COLUMN_ADDRESS-1:0 ]  addr_col ,addr_col_nxt  ; 
   reg   [ `ROW_ADDRESS-1:0 ]     addr_row , addr_row_nxt ;  
   reg   [ `BANK_ADDRESS-1:0 ]    addr_bank   = 'h0 ; 


   parameter   MAX_ROW_NUM    =  13'h02FF ; 

   always @( negedge mem_clk0 ) begin    
      if ( mem_rst ) begin 
         req_addr_row   <= 'h0 ;  
         rd_go          <= 1'b0 ;
         screen_cnt     <= 'h0 ; 
         screen_cnt_overrun   <= 1'b0 ; 
      end else begin 
         if ( rd_xfr_done == 1'b1 ) begin  
            if ( req_addr_row == MAX_ROW_NUM ) begin 
               req_addr_row   <= 'h0 ; 
               screen_cnt     <= screen_cnt + 1'b1 ; 
               if ( screen_cnt == 16'hFFFF ) begin 
                  screen_cnt_overrun   <= 1'b1 ; 
               end
            end else begin 
               req_addr_row   <= req_addr_row + 1'b1 ;   
            end
         end


      end 

   end

   // It measn how many transfer between ddr_mgr
   // Since 32bit data_width rd_data of  ddr_mg output, which read from outside ddr2.
   //
   
   reg   [1:0] req_st_nxt, req_st_r ; 
   reg   rd_req_nxt, rd_req_r ; 
   reg   [9:0] rd_xfr_len_nxt ;
   wire  rd_xfr_en, rd_xfr_en_sync, rd_data_valid_sync, rd_go_sync  ;


   parameter  XFR_LEN_PER_LINE  = 10'h200 ; 

   parameter ST_IDLE       =  2'b00,
             ST_WAIT_GRANT =  2'b01, 
             ST_PRE_XFR    =  2'b10, 
             ST_DATA_XFR   =  2'b11; 

   assign rd_xfr_en  =  req_st_r[1] ; 

   assign   rd_mem_addr =  { addr_row, addr_col, addr_bank }  ; 

   synchro synchro_rd_data_valid (.async(rd_data_valid ),.sync( rd_data_valid_sync ),.clk( ~mem_clk0 ) ) ;

   always @( negedge mem_clk0 ) begin    
      if ( mem_rst ) begin 
         req_st_r    <= ST_IDLE ; 
         rd_req_r    <= 1'b0 ;  
         addr_row    <= 'h0  ; 
         addr_col    <= 'h0  ; 
         rd_xfr_len  <= 10'h0 ; 
      end else begin 
         req_st_r    <= req_st_nxt ;
         rd_req_r    <= rd_req_nxt ;  
         addr_row    <= addr_row_nxt  ; 
         addr_col    <= addr_col_nxt  ; 
         rd_xfr_len  <= rd_xfr_len_nxt ; 
         rd_xfr_done <= rd_xfr_done_nxt ; 
      end
   end 


   always @( * ) begin    
      req_st_nxt     =  req_st_r ; 
      rd_req_nxt     =  1'b0 ; 
      addr_row_nxt   =  addr_row; 
      addr_col_nxt   =  addr_col; 
      rd_xfr_len_nxt =  rd_xfr_len ; 
      rd_xfr_done_nxt    =  1'b0 ; 
      case ( req_st_r  )  
         ST_IDLE  : begin 
            if ( rd_go ) begin 
               req_st_nxt     =  ST_WAIT_GRANT ; 
               rd_req_nxt     =  1'b1 ; 
               addr_row_nxt   =  req_addr_row ;   
               addr_col_nxt   =  'h0;          //address need to be updated  
               rd_xfr_len_nxt =  XFR_LEN_PER_LINE ; 
            end 
         end
         ST_WAIT_GRANT : begin 
            rd_req_nxt  =  1'b1 ; 
            if ( rd_mem_grant ) begin 
               req_st_nxt  =  ST_PRE_XFR ; 
               rd_req_nxt  =  1'b0 ; 
            end
         end
         ST_PRE_XFR  : begin 
            if ( rd_data_valid_sync ) begin 
               req_st_nxt  =  ST_DATA_XFR ; 
            end
         end
         ST_DATA_XFR : begin 
            if ( ~ rd_data_valid_sync ) begin 
               req_st_nxt         =  ST_IDLE ; 
               rd_xfr_done_nxt    =  1'b1 ; 
            end
         end
      endcase 
   end 

   synchro synchro_rd_xfr_en (.async(rd_xfr_en),.sync( rd_xfr_en_sync ),.clk( mem_clk90 ) ) ;


   // Verify the data read from memory through ddr2_mgr with preloaded data
   //           16'b1001_0110_1100_0011
   reg   data_fault ; 
   parameter   BYTE_0   =  8'h10 ; 
   parameter   BYTE_1   =  8'h86 ; 
   parameter   BYTE_2   =  8'hCB ; 
   parameter   BYTE_3   =  8'hFD ; 

   always @( posedge mem_clk90 ) begin
      if ( rd_data_valid & rd_xfr_en_sync  ) begin 
         if ( rd_data != { BYTE_3, BYTE_2, BYTE_1, BYTE_0 } ) begin 
            data_fault  <= 1'b1 ; 
         end 
      end 
      
   end 


   //*************************************************************//
   // Control singals related to char window 
   //*************************************************************//

   assign   pi_wr_en    =  write_strobe ;
   assign   pi_rd_en    =  read_strobe ; 
   assign   pi_wr_data  =  out_port ; 
   //assign   in_port     =  pi_ddr2_mgr_rd_data | pi_disp_rd_data | pi_unit_rd_data | pi_mouse_rd_data ;  
   assign   in_port     =  pi_ddr2_mgr_rd_data | pi_disp_rd_data ;  
   assign   pi_addr     =  port_id[3:0] ; 

   assign   mem_clk0   =  mig_clk0 ; 
   assign   mem_clk90  =  mig_clk90;
   assign   mem_rst0   =  mig_rst0 ; 
   assign   mem_rst90  =  mig_rst90;
   assign   mem_rst180 =  mig_rst180 ; 
   assign   mem_rst    =  mem_rst180 ; 

endmodule
