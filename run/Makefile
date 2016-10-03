#-----------------------------------------------------------------------------
#
# Filename    : Makefile
#
# Created by  : $Merlionfire$
#               14/04/2015 # 
# Description : Compile the files at and below this level   
#
#-----------------------------------------------------------------------------

TB_BUILD_FLAG = on 
PROJ = fractal_fpga

COMPILER = vlog 
#COMPILER = vcs -full64
RTL_FILES = -f rtl.f  /opt/Xilinx/14.7/ISE_DS/ISE/verilog/src/glbl.v
LIB_DIR = ../../lib  
TB_FILES = ../tb/testbench.v 
MODEL_FILES =  
ALL_FILES =  $(RTL_FILES) $(MODEL_FILES) $(TB_FILES)

SIM_OPT = +define+SVA +define+SIM   +define+x512Mb +define+sg5E +define+x16 +define+MAX_MEM 

# -----------------------------   Code Coverage   ----------------------------
COVER_TYPE   = +cover=sbcef
COVER_REPORT_FILE  = $(PROJ)_cov.txt 
COVER_REPORT_HTML_DIR  = $(PROJ)_cov_report_html 
UCDB_FILE    = $(PROJ)_cov.ucdb 
COVER_OPT    = -coverage 
# ------------------------------------------------ ----------------------------
  
OPT =  -sv +v2k -novopt $(SIM_OPT)   $(COVER_TYPE) +libext+.v+.h+.vh -y $(LIB_DIR) +incdir+../src +incdir+../ISE/mig_ip/ddr2_512M16_mig/user_design/rtl +incdir+../ISE/mig_ip/ddr2_512M16_mig/user_design/sim  -l build.log     

INC = 

#RUN = vsim -pli libpli.so  -novopt -c testbench -L xilinx_XilinxCoreLib  -L xilinx_unisims -L xilinx_simprims  work.glbl  -do "nolog -all ; run -all ; quit" 
RUN = vsim -l cosim.log -wlftlim 1 -pli libpli.so  $(COVER_OPT) -c testbench -L xilinx_XilinxCoreLib  -L xilinx_unisims -L xilinx_simprims  work.glbl \
		-do "nolog -all ; coverage save -onexit $(UCDB_FILE)  ; run -all ; quit" 

default : help 

comp : 
	$(COMPILER) $(OPT) $(ALL_FILES)    
	vericom -sverilog -2001 -nolog  $(SIM_OPT) -lib work.verdi  +libext+.v+.h+.vh +incdir+../rtl +incdir+../rtl/mouse +incdir+../ISE/mig_ip/ddr2_512M16_mig/user_design/rtl  +incdir+../ISE/mig_ip/ddr2_512M16_mig/user_design/sim -y $(LIB_DIR)  $(ALL_FILES) 
run : 
	$(RUN)  
verdi : 
	verdi -2001 $(SIM_OPT)  -lib work.verdi  -ssf cosim_verdi.fsdb -top testbench -nologo &
nlint : 
	 nLint  -gui
cover_report_txt  : 
	vcover report -detail $(UCDB_FILE) -output $(COVER_REPORT_FILE)   
cover_report_html  : 
	vcover report -html -htmldir $(COVER_REPORT_HTML_DIR)  $(UCDB_FILE)    
help : 
	@echo "==================== HELP ====================="
	@echo "comp        : Compiles everything with debugger"
	@echo "==============================================="
	@echo "run         : Run simulation                   "
	@echo "==============================================="
	@echo "help        : Print help information           "
	@echo "            : This is default parameter        "
	@echo "=============================================================="
	@echo "cover_report_html: Create code coverage report in htlm format "
	@echo "=============================================================="
	@echo "nlint       : invoke nlint gui                 "
	@echo "==============================================="
	@echo ""
	@echo ""

