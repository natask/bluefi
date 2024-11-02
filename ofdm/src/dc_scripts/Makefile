design_name := mkTransceiver
sdc         := mkTransmitter.sdc
clk_period  := 50
dont_touch  := 

########################################
# Directories
########################################

build_dir := build
#lib_dir   := $(STDCELLLIB)
work_dir  := Work

# standard place for rtl (relative to heirarchy one up)
r_dir   := ../src
rtl_dir := `cd $(r_dir); pwd`

# standard place for Bluespec verilog rtl
brtl_dir  := $(BLUESPECDIR)/Verilog

########################################
# List of Files
########################################

VFILES   = $(shell find $(rtl_dir) $(brtl_dir) -name "*.v")
BSVFILES = $(shell find $(rtl_dir) $(brtl_dir) -name "*.bsv")

########################################
# General functions
########################################

TIME_STAMP := $(shell date +%Y-%m-%d_%H-%M) 
build_suffix := $(shell date +%Y-%m-%d_%H-%M)


all: do_mapping

gen_build_dir:
	@echo Generating new build dir
	mkdir $(build_dir)-$(build_suffix)                                       
	mkdir $(build_dir)-$(build_suffix)/$(work_dir)                            
	rm -f $(build_dir)                              
	ln -s $(build_dir)-$(build_suffix) $(build_dir)
	ln -s ../compile.tcl $(build_dir)/
	ln -s ../libs.tcl    $(build_dir)/

do_mapping: gen_build_dir
	@echo Entering build directory
	cd $(build_dir) && dc_shell-xg-t \
                  -x '  set SCRIPTDIR ../$(build2syn_dir)/$(scripts_dir); \
                        set DESIGN $(design_name);              \
                        set SDC $(sdc);                 \
                        set WORKDIR $(work_dir);             \
                        set LINK_DBS $(TSMC_LINK_DBS); \
			set TARGET_DBS $(TSMC_TARGET_DBS); \
			set SYMBOL_SDBS $(TSMC_SYMBOL_SDBS); \
                        set VFILES {$(VFILES)};           \
                        set CLKPERIOD $(clk_period); \
                        set SEARCHPATH $(rtl_dir); \
                        set DONTTOUCH {$(dont_touch)}; '\
        -f compile.tcl | tee mapping.log;

.PHONY: gen_build_dir


