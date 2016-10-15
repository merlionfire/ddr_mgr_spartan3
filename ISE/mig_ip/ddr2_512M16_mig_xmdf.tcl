# The package naming convention is <core_name>_xmdf
package provide ddr2_512M16_mig_xmdf 1.0

# This includes some utilities that support common XMDF operations 
package require utilities_xmdf

# Define a namespace for this package. The name of the name space
# is <core_name>_xmdf
namespace eval ::ddr2_512M16_mig_xmdf {
# Use this to define any statics
}

# Function called by client to rebuild the params and port arrays
# Optional when the use context does not require the param or ports
# arrays to be available.
proc ::ddr2_512M16_mig_xmdf::xmdfInit { instance } {
	# Variable containing name of library into which module is compiled
	# Recommendation: <module_name>
	# Required
	utilities_xmdf::xmdfSetData $instance Module Attributes Name ddr2_512M16_mig
}
# ::ddr2_512M16_mig_xmdf::xmdfInit

# Function called by client to fill in all the xmdf* data variables
# based on the current settings of the parameters
proc ::ddr2_512M16_mig_xmdf::xmdfApplyParams { instance } {

set fcount 0
	# Array containing libraries that are assumed to exist
	# Examples include unisim and xilinxcorelib
	# Optional
	# In this example, we assume that the unisim library will
	# be magically
	# available to the simulation and synthesis tool
	utilities_xmdf::xmdfSetData $instance FileSet $fcount type logical_library
	utilities_xmdf::xmdfSetData $instance FileSet $fcount logical_library unisim
	incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_cal_ctl.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_cal_top.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_clk_dcm.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_controller_0.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_controller_iobs_0.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_data_path_0.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_data_path_iobs_0.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_data_read_0.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_data_read_controller_0.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_data_write_0.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_dqs_delay.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_fifo_0_wr_en_0.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_fifo_1_wr_en_0.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_infrastructure.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_infrastructure_iobs_0.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_infrastructure_top.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_iobs_0.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_parameters_0.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_ram8d_0.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_rd_gray_cntr.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_s3_dm_iob.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_s3_dq_iob.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_s3_dqs_iob.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_tap_dly.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_top_0.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/rtl/ddr2_512M16_mig_wr_gray_cntr.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path ddr2_512M16_mig/user_design/par/ddr2_512M16_mig.ucf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type ucf 
utilities_xmdf::xmdfSetData $instance FileSet $fcount associated_module ddr2_512M16_mig
incr fcount

}

# ::gen_comp_name_xmdf::xmdfApplyParams
