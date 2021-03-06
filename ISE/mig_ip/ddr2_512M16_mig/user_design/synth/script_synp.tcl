project -new 
add_file -verilog "../rtl/ddr2_512M16_mig_parameters_0.v"
add_file -verilog "../rtl/ddr2_512M16_mig.v"
add_file -verilog "../rtl/ddr2_512M16_mig_cal_ctl.v"
add_file -verilog "../rtl/ddr2_512M16_mig_cal_top.v"
add_file -verilog "../rtl/ddr2_512M16_mig_clk_dcm.v"
add_file -verilog "../rtl/ddr2_512M16_mig_controller_0.v"
add_file -verilog "../rtl/ddr2_512M16_mig_controller_iobs_0.v"
add_file -verilog "../rtl/ddr2_512M16_mig_data_path_0.v"
add_file -verilog "../rtl/ddr2_512M16_mig_data_path_iobs_0.v"
add_file -verilog "../rtl/ddr2_512M16_mig_data_read_0.v"
add_file -verilog "../rtl/ddr2_512M16_mig_data_read_controller_0.v"
add_file -verilog "../rtl/ddr2_512M16_mig_data_write_0.v"
add_file -verilog "../rtl/ddr2_512M16_mig_dqs_delay.v"
add_file -verilog "../rtl/ddr2_512M16_mig_fifo_0_wr_en_0.v"
add_file -verilog "../rtl/ddr2_512M16_mig_fifo_1_wr_en_0.v"
add_file -verilog "../rtl/ddr2_512M16_mig_infrastructure.v"
add_file -verilog "../rtl/ddr2_512M16_mig_infrastructure_iobs_0.v"
add_file -verilog "../rtl/ddr2_512M16_mig_infrastructure_top.v"
add_file -verilog "../rtl/ddr2_512M16_mig_iobs_0.v"
add_file -verilog "../rtl/ddr2_512M16_mig_ram8d_0.v"
add_file -verilog "../rtl/ddr2_512M16_mig_rd_gray_cntr.v"
add_file -verilog "../rtl/ddr2_512M16_mig_s3_dm_iob.v"
add_file -verilog "../rtl/ddr2_512M16_mig_s3_dq_iob.v"
add_file -verilog "../rtl/ddr2_512M16_mig_s3_dqs_iob.v"
add_file -verilog "../rtl/ddr2_512M16_mig_tap_dly.v"
add_file -verilog "../rtl/ddr2_512M16_mig_top_0.v"
add_file -verilog "../rtl/ddr2_512M16_mig_wr_gray_cntr.v"
add_file -constraint "../synth/mem_interface_top_synp.sdc"
impl -add rev_1
set_option -technology spartan3a
set_option -part xc3s700an
set_option -package fgg484
set_option -speed_grade -4
set_option -default_enum_encoding default
set_option -symbolic_fsm_compiler 1
set_option -resource_sharing 0
set_option -use_fsm_explorer 0
set_option -top_module "ddr2_512M16_mig"
set_option -frequency 132.996
set_option -fanout_limit 1000
set_option -disable_io_insertion 0
set_option -pipe 1
set_option -fixgatedclocks 0
set_option -retiming 0
set_option -modular 0
set_option -update_models_cp 0
set_option -verification_mode 0
set_option -write_verilog 0
set_option -write_vhdl 0
set_option -write_apr_constraint 0
project -result_file "../synth/rev_1/ddr2_512M16_mig.edf"
set_option -vlog_std v2001
set_option -auto_constrain_io 0
impl -active "../synth/rev_1"
project -run hdl_info_gen 
project -run
project -save

