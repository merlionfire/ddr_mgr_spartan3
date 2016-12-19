
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name test_ddr_mgr -dir "/home/cct/FPGA_Project/test_ddr_mgr/ISE/proj/test_ddr_mgr/planAhead_run_1" -part xc3s700anfgg484-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/cct/FPGA_Project/test_ddr_mgr/ISE/proj/test_ddr_mgr/pcb.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/cct/FPGA_Project/test_ddr_mgr/ISE/proj/test_ddr_mgr} {../../fifo_ip} }
add_files [list {../../fifo_ip/dumo_fifo.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "/home/cct/FPGA_Project/test_ddr_mgr/ISE/test_ddr_mgr.ucf" [current_fileset -constrset]
add_files [list {/home/cct/FPGA_Project/test_ddr_mgr/ISE/test_ddr_mgr.ucf}] -fileset [get_property constrset [current_run]]
link_design
