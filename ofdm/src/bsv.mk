ifndef BLUESPECDIR
  $(error Please set environment variable BLUESPECDIR before running make)
endif

# setup dir for build output and simulation output
BSVBLD = ../../build
RESDIR = ../../result
MAINV  = $(BLUESPECDIR)/Verilog/main.v

# bluespec compiler flags
BSC = bsc -u -aggressive-conditions -steps 1000000 +RTS -K4000M -RTS \
	-keep-fires -cross-info -no-show-method-conf -show-compiles
BSC_V = $(BSC) -verilog
BSC_BA = $(BSC) -sim
BSC_LIB = $(BSC) -elab -verilog

# Decides root directory (null for common files)
mkSimTop = $(sim_top:%.bsv=mk%)
BLD= $(BSVBLD)/$(mkSimTop)
RES= $(RESDIR)/$(mkSimTop)

# Separate directory for each build output
v_dir= $(BLD)/src
o_dir= $(BLD)/bo
s_dir= $(BLD)/sim
b_dir= $(BLD)/bin
syn_dir= $(BLD)/syn
lib_dir = $(BSVBLD)/../src/lib
src_dirs = $(o_dir):$(lib_dir):$(lib_dir)/CPInsert:$(lib_dir)/ChannelEstimator:$(lib_dir)/ConvEncoder:$(lib_dir)/FFT:$(lib_dir)/FIFOs:$(lib_dir)/Interleaver:$(lib_dir)/Mapper:$(lib_dir)/PilotInsert:$(lib_dir)/Pipeline:$(lib_dir)/Puncturer:$(lib_dir)/ReedSolomon:$(lib_dir)/Scrambler:$(lib_dir)/ShiftRegs:$(lib_dir)/Synchronizer:$(lib_dir)/Unserializer:$(lib_dir)/Viterbi:+

# add for bil testing
#rtl_dir=$(rtl)
#RIO_DIR	    = ${RIO}
#TB_INC +=  +incdir+${RIO}/source/rio_defs_virtex4_10b/sim
#TB_INC += +incdir+${rtl_dir}/rio_defs_virtex4_10b/sim
#SYNTB_INC += +incdir+${rtl_dir}/rio_defs_virtex4_10b/syn
#COMP_OPTS = ${TB_INC}
#SYNCOMP_OPTS = ${SYNTB_INC}


mkSimTop = $(sim_top:%.bsv=mk%)
#bsv_files= $(dut_files) $(syn_files) $(dut_top) $(lib_files) $(sim_top) 
bsv_files= $(dut_top) $(sim_top)

bi_files= $(bsv_files:%.bsv=$(o_dir)/%.bo)
ba_files= $(bsv_files:%.bsv=$(o_dir)/mk%.ba)
ba_rules= $(bsv_files:%.bsv=mk%BA)
v_files = $(bsv_files:%.bsv=$(v_dir)/mk%.v)
v_rules = $(bsv_files:%.bsv=mk%V)
lib_rules = $(bsv_files:%.bsv=mk%LIB)
cxx_obj = $(cxx_files:%.cxx=$(s_dir)/%.o)


# Transformation Rules
mk%V: %.bsv
	@mkdir -p $(v_dir) $(o_dir)
	$(BSC_V) -bdir $(o_dir) -vdir $(v_dir) -p $(src_dirs) $<
	touch $@

mk%BA: %.bsv
	@mkdir -p $(s_dir) $(o_dir)
	$(BSC_BA) -bdir $(o_dir) -simdir $(s_dir) -p $(src_dirs) $<
	touch $@

mk%LIB: %.bsv
	@mkdir -p $(v_dir) $(s_dir) $(o_dir)
	$(BSC_LIB) -bdir $(o_dir) -vdir $(v_dir) -simdir $(s_dir) -p $(src_dirs) $<
	touch $(subst LIB,V,$@)
	touch $(subst LIB,BA,$@)


$(s_dir)/%.o: %.cxx
	@mkdir -p $(s_dir)
	@# compile C++ code
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<

# iverilog simulator
$(b_dir)/ivsim_$(mkSimTop): $(v_rules) 
	mkdir -p $(b_dir)
	iverilog -y . -y $(BLUESPECDIR)/Verilog -y $(v_dir) \
	${MAINV} -o $@ -DTOP=$(mkSimTop)

.PHONY: $(RES)/run_ivsim
$(RES)/run_ivsim: $(b_dir)/ivsim_$(mkSimTop)
	mkdir -p $(RES)
	$< | tee $@

# bluesim simulator
$(b_dir)/bsim_$(mkSimTop): $(ba_rules) $(cxx_obj) 
	mkdir -p $(b_dir)
	bsc -v -e $(mkSimTop) -sim -bdir $(o_dir) -simdir $(o_dir) \
	-p $(o_dir):$(BSVBLD)/bo:+ -o $@ $(o_dir)/*.ba $(cxx_obj)

.PHONY: $(RES)/run_bsim
$(RES)/run_bsim: $(b_dir)/bsim_$(mkSimTop)
	mkdir -p $(RES)
	$< | tee $@

# VCS simulator
$(b_dir)/simv_$(mkSimTop): $(v_rules) 
	mkdir -p $(b_dir)
	cd $(b_dir) && vcs  +v2k +libext+.v ${MAINV} -y . -y $(libv_dir) \
		-y $(v_dir) -y $(BLUESPECDIR)/Verilog -o $@ +define+TOP=$(mkSimTop)

.PHONY: run_vcs
$(RES)/run_vcs: $(b_dir)/simv_$(mkSimTop)
	mkdir -p $(RES) 
	$< +bscvcd +bsccycle | tee $@

# MTI simulator
# $(b_dir)/simu.work:
# 	mkdir -p $(b_dir)
# 	cd $(b_dir) && vlib simu.work
# 	cd $(b_dir) && vmap RLL_LIB ${RIO}/libs/rll_lib 
# 	cd $(b_dir) && vmap RDB_LIB ${RIO}/libs/rdb_lib 

# $(b_dir)/mti: $(v_files) $(b_dir)/simu.work
# 	cd $(b_dir) && 	vlog -work simu.work +define+TOP=$(mkSimTop) +v2k ${MAINV} \
# 		-y $(BLUESPECDIR)/Verilog -y $(rtl_dir) -y $(v_dir) -y $(libv_dir) +libext+.v ${COMP_OPTS}
# 	cd $(b_dir) && touch mti

# .PHONY: run_mti
# run_mti: $(b_dir)/mti
# 	cd $(b_dir) && vsim -c -do "run -all; exit" simu.work.main +bscvcd +bsccycle \
# 	+nowarnTSCALE -L RLL_LIB -L RDB_LIB | tee mti.txt

# view_mti:
# 	cd $(b_dir) && /pkg/qct/software/novas/2007.01/bin/verdi &


# Generates verilog files for synthesis
.PHONY: syn
syn: $(v_rules)
	mkdir -p $(syn_dir)
	cp -p ../dc_scripts/* $(syn_dir)/
	cd $(syn_dir) && make

.PHONY: icarus
icarus: $(b_dir)/$(mkSimTop)

# Generates verilog files for synthesis
.PHONY: lib
lib: $(lib_rules)

# Simulation with Bluespec
.PHONY: bsim
bsim: $(b_dir)/bsim_$(mkSimTop)

.PHONY: run_bsim
run_bsim: $(RES)/run_bsim

# Simulation with iverilog
.PHONY: ivsim
ivsim: $(b_dir)/ivsim_$(mkSimTop)

.PHONY: run_ivsim
run_ivsim: $(RES)/run_ivsim

# Simulation with Vcs
.PHONY: simv
simv: $(b_dir)/simv_$(mkSimTop)

.PHONY: run_simv
run_simv: $(RES)/run_simv

# Simulation with Modelsim
.PHONY: mti
mti: $(b_dir)/mti

# Build memory
.PHONY: memory
memory: $(BLD)/memory_done
$(BLD)/memory_done: sram.tcl
	mkdir -p $(v_dir)
	cd $(v_dir) && zMem $(PWD)/sram.tcl
	mkdir -p $(v_dir)_bb
	cd $(v_dir) && mv *_bbx.v $(v_dir)_bb
	cd $(v_dir) && mv *.edf.gz $(BLD)
	cd $(v_dir) && rm *.vhd *.log *_gates*.v
	touch $@

# Fire up Blueview
.PHONY: blueview
blueview: $(v_dir)/$(mkSimTop).info
	cd $(b_dir) && blueview $< $(b_dir)/dump.vcd /main/top

# Clean deletes object files
.PHONY: clean
clean:
	rm -rf $(BLD)
	rm mk*V
	rm mk*BA

# generate only html documentation. "doxygen -g" shows all defaults
doc_bsv=$(BLD)/doc/bsv
.PHONY: bsv_doc
bsv_doc: $(doc_bsv)/html/index.html
$(doc_bsv)/html/index.html: $(bsv_files)
	mkdir -p $(doc_bsv)
	@rm -rf $(doc_bsv)/Doxyfile
	@echo "PROJECT_NAME           = $(sim_top)"      >> $(doc_bsv)/Doxyfile
	@echo "OUTPUT_DIRECTORY       = $(doc_bsv)"      >> $(doc_bsv)/Doxyfile
	@echo "TAB_SIZE               = 4"               >> $(doc_bsv)/Doxyfile
	@echo "INPUT                  = $(pwd)"          >> $(doc_bsv)/Doxyfile
	@echo "FILE_PATTERNS          = *.h *.bsv"       >> $(doc_bsv)/Doxyfile
	@echo "SOURCE_BROWSER         = YES"             >> $(doc_bsv)/Doxyfile
	@echo "GENERATE_LATEX         = NO"              >> $(doc_bsv)/Doxyfile
	doxygen $(doc_bsv)/Doxyfile

doc_verilog=$(BLD)/doc/verilog
.PHONY: verilog_doc
verilog_doc: $(doc_verilog)/html/index.html
$(doc_verilog)/html/index.html:
	mkdir -p $(doc_verilog)
	@rm -rf $(doc_verilog)/Doxyfile
	@echo "PROJECT_NAME           = $(mkSimTop)"              >> $(doc_verilog)/Doxyfile
	@echo "OUTPUT_DIRECTORY       = $(doc_verilog)"           >> $(doc_verilog)/Doxyfile
	@echo "TAB_SIZE               = 4"                        >> $(doc_verilog)/Doxyfile
	@echo "INPUT                  = $(v_dir) $(PWD)/down/rtl" >> $(doc_verilog)/Doxyfile
	@echo "FILE_PATTERNS          = *.h *.v"                  >> $(doc_verilog)/Doxyfile
	@echo "SOURCE_BROWSER         = YES"                      >> $(doc_verilog)/Doxyfile
	@echo "GENERATE_LATEX         = NO"                       >> $(doc_verilog)/Doxyfile
	doxygen $(doc_verilog)/Doxyfile

.PHONY: doc
doc: bsv_doc verilog_doc

help:
	@echo
	@echo "   TARGETS:"
	@echo
	@echo "     synth - generates $(v_dir)/*.v and iverilog executable- $(b_dir)/$(mkSimTop)"
	@echo "       lib - generates $(v_dir)/*.v and $(o_dir)/*.ba/bo files"
	@echo "      bsim - generates $(o_dir)/*.bi/bo and Bluespec executable- $(b_dir)/bsim_$(mkSimTop)"
	@echo "       mti - generates $(o_dir)/*.bi/bo and Modelsim simulation env- $(b_dir)/mti"
	@echo "      simv - generates $(o_dir)/*.bi/bo and VCS executable- $(b_dir)/simv"
	@echo
	@echo "     clean - deletes $(BLD)"
	@echo

env:
	@echo
	@echo "---------------------------------------------------------"
	@echo "               Makefile Environment"
	@echo "---------------------------------------------------------"	
	@echo "       BSV Source files: $(bsv_files)"
	@echo "---------------------------------------------------------"
	@echo "           .v directory: $(v_dir)"	
	@echo "     .ba file directory: $(s_dir)"
	@echo ".bi, .bo file directory: $(o_dir)"
	@echo "---------------------------------------------------------"
	@echo "              BSV files: $(bsv_files)"
	@echo "              CXX files: $(cxx_files)"
	@echo "              DUT files: $(dut_files)"
	@echo "              SYN files: $(syn_files)"
	@echo "              SIM files: $(sim_files)"
	@echo "                V files: $(v_files)"
	@echo "---------------------------------------------------------"
	@echo " For make actions, type: make -n target_name"
	@echo "---------------------------------------------------------"
	@echo
