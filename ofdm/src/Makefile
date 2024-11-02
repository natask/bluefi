#########################################
# OFDM Makefile
#########################################

#########################################
# build an OFDM transceiver which outputs
# verilog (e.g. to build WiFi transceiver
# type "make build_WiFi") 
#########################################
build_%:
	cd $(subst build_,,$@) && make

##########################################
# clean a build
##########################################
clean_%:
	cd $(subst clean_,,$@) && make clean

##########################################
# synthesize the build using design compiler
##########################################
syn_%:
	cd $(subst syn_,,$@) && make syn

##########################################
# run simulation using bluesim
##########################################
runbsim_%:
	cd $(subst runbsim_,,$@) && make run_bsim

##########################################
# run simulation using iverilog
##########################################
runivsim_%:
	cd $(subst runivsim_,,$@) && make run_ivsim


