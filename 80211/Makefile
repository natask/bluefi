# The MIT License
#
# Copyright (c) 2006 Nirav Dave (ndave@csail.mit.edu)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.




LOGDIR = logs
CURTIME = `date +%F_%H%M`
TITLE = 80211

all: design


#################################
#        Program Macros         #
#################################
BSC = bsc -v -u -keep-fires -dschedule -relax-method-earliness 
BSC_PROF = prof_bsc -v -u -keep-fires -relax-method-earliness 
BSC_C = bsc -v -u
BIGRUN = +RTS -K1000M -RTS -steps 800000
OPTS = ${OPT_} ${OPTB}
OPT_ = -opt-undetermined-vals
OPTB = -opt-bool
NOOPT= -no-opt-bool -no-opt-mux -no-opt-mux-const -no-opt-ATS
COND = -aggressive-conditions
PROF = +RTS -prof-all -RTS
VRULES = -show-rule-rel \* \*
DE_RWIRE = -inline-rwire


SCHED = -dschedule

BSC_DEBUG  = ${BSC} ${DIRS} ${COND} ${SCHED}  ${BIGRUN} 
BSC_DEBUG_PROF  = ${BSC_PROF} ${DIRS} ${PROF} ${COND} ${SCHED}  ${BIGRUN} -scheduler-effort 0
#${OPT}

BSC_DEBUG_TRACE = ${BSC} ${DIRS} ${COND} ${SCHED} ${VRULES} ${BIGRUN} -trace-heap
BSC_NORMAL = ${BSC} ${DIRS} ${BIGRUN}
BSC_SCHOPT = ${BSC} ${DIRS} ${BIGRUN} ${COND} ${OPTS}
BSC_OPT    = ${BSC} ${DIRS} ${COND} ${OPTS} ${BIGRUN}

BSC_SYNTH  = ${BSC} ${DIRS} ${COND} ${OPTS} ${DE_RWIRE} ${BIGRUN}

RM = rm
RMDIR = rmdir

PWD = `pwd`

#################################
# Default Dir is probably wrong #
################################# 
DIRS = -p +:..:../../framework:../../framework/PPC
BINS = 
VFILES = mk*.v module_*.v
CFILES = *.c *.o *.h
SYMFILES = csrc simv simv.daidir vcdplus.vpd vcs.key
TMPFILES = .tmp_*

SUBD = $(filter %/, $(shell ls -F))
SUBDIRS ?= $(SUBD)

###################################################################
# Generic Compile functions                                       #
###################################################################

define bsc_compile_normal
@echo \*\*\* Compiling $(strip $(1))
@echo
@echo
@[ -d logs ] || mkdir logs
@${BSC_NORMAL} ${1} 2>&1 | tee -a ${LOGDIR}/$(strip ${1})-${CURTIME}.bsc-out
endef

define bsc_compile_debug_prof
@echo \*\*\* Compiling $(strip $(1))
@echo
@echo
@[ -d logs ] || mkdir logs
@${BSC_DEBUG_PROF} ${1} 2>&1 | tee -a ${LOGDIR}/$(strip ${1})-${CURTIME}.bsc-out
endef

###################################################################
# Verilog Compile functions                                       #
###################################################################

define verilog_compile_normal
@echo \*\*\* Compiling \(NORMAL\) $(strip $(1)) from file $(strip $(2)) into Verilog
@echo
@echo
@[ -d logs ] || mkdir logs
@${BSC_NORMAL} -verilog -g ${1} ${2} 2>&1 | tee -a ${LOGDIR}/$(strip ${1})-${CURTIME}.bsc-out
endef

define verilog_compile_schopt
@echo \*\*\* Compiling \(SCHOPT\) $(strip $(1)) from file $(strip $(2)) into Verilog
@echo
@echo
@[ -d logs ] || mkdir logs
@${BSC_SCHOPT} -verilog -g ${1} ${2} 2>&1 | tee -a ${LOGDIR}/$(strip ${1})-${CURTIME}.bsc-out
endef

define verilog_compile_opt
@echo \*\*\* Compiling \(OPT\) $(strip $(1)) from file $(strip $(2)) into Verilog
@echo
@echo
@[ -d logs ] || mkdir logs
@${BSC_OPT}    -verilog -g ${1} ${2} 2>&1 | tee -a ${LOGDIR}/$(strip ${1})-${CURTIME}.bsc-out
endef

define verilog_compile_debug
@echo \*\*\* Compiling \(DEBUG\) $(strip $(1)) from file $(strip $(2)) into Verilog
@echo
@echo
@[ -d logs ] || mkdir logs
@${BSC_DEBUG}  -verilog -g ${1} ${2} 2>&1 | tee -a ${LOGDIR}/$(strip ${1})-${CURTIME}.bsc-out
endef

define verilog_compile_debug_prof
@echo \*\*\* Compiling \(DEBUG\) $(strip $(1)) from file $(strip $(2)) into Verilog
@echo
@echo
@[ -d logs ] || mkdir logs
@${BSC_DEBUG_PROF}  -verilog -g ${1} ${2} 2>&1 | tee -a ${LOGDIR}/$(strip ${1})-${CURTIME}.bsc-out
endef

define verilog_compile_debug_trace
@echo \*\*\* Compiling \(DEBUG_TRACE\) $(strip $(1)) from file $(strip $(2)) into Verilog
@echo
@echo
@[ -d logs ] || mkdir logs
@${BSC_DEBUG_TRACE} -verilog -g ${1} ${2} 2>&1 | tee -a ${LOGDIR}/$(strip ${1})-${CURTIME}.bsc-out
endef

define verilog_compile_synth
@echo \*\*\* Compiling \(Synth\) $(strip $(1)) from file $(strip $(2)) into Verilog
@echo
@echo
@[ -d logs ] || mkdir logs
@${BSC_SYNTH}  -verilog -g ${1} ${2} 2>&1 | tee -a ${LOGDIR}/$(strip ${1})-${CURTIME}.bsc-out
endef


###################################################################
# General Definitions                                             #
###################################################################
all:
	@echo Making all in ${PWD}
ifneq ($(SUBDIRS),)
	@for dir in ${SUBDIRS} ; do \
	cd $$dir;  [ -f Makefile ] && ${MAKE} all ; cd .. ; done
endif



###################################################################
# Make sure there's a log dir                                     #
###################################################################

logs:
	mkdir logs

###################################################################
# Cleanup                                                         #
###################################################################

spotless: cleaner purgelogs cleanvcs
cleaner:  clean tidy cleanvcs

cleanvcs:
	${RM} -rf ${SYMFILES}
ifneq ($(SUBDIRS),)
	@for dir in ${SUBDIRS} ; do \
	cd $$dir;  [ -f Makefile ] && echo "cleaning vcs from $$dir" && \
        ${MAKE} cleanvcs ; cd ..; done
endif


tidy:
	${RM} -f *~ \#*
ifneq ($(SUBDIRS),)
	@for dir in ${SUBDIRS} ; do \
	cd $$dir;  [ -f Makefile ] && echo "tidying $$dir" && \
        ${MAKE} tidy ; cd .. ;  done
endif


clean:
	${RM} -f *.b[io] ${CFILES} ${BINS} ${VFILES}
ifneq ($(SUBDIRS),)
	@for dir in ${SUBDIRS} ; do \
	cd $$dir; [ -f Makefile ] && echo "cleaning $$dir" && \
        ${MAKE} clean ; cd .. ; done
endif


cleanish:
	${RM} -f ${CFILES} ${BINS} ${VFILES}
ifneq ($(SUBDIRS),)
	@for dir in ${SUBDIRS} ; do \
	cd $$dir; [-f Makefile ] && echo "almost cleaning $$dir" && \
        ${MAKE} cleanish ; cd .. ; done
endif

purgelogs:
	${RM} -f ${LOGDIR}/*
ifneq ($(SUBDIRS),)
	@for dir in ${SUBDIRS} ; do \
	cd $$dir; [ -f Makefile ] && echo "purging logs for $$dir" && \
        ${MAKE} purgelogs ; cd .. ; done
endif


###################################################################
# Make Commands                                                   #
###################################################################

design: mkConvEncoder.v mkScrambler.v mkInterleaver.v mkMapper.v mkIFFT.v \
	mkCyclicExtender.v mkController.v mkTransmitter.v

mkController.v:
	$(call verilog_compile_schopt, mkController, Controller.bsv)

mkConvEncoder.v:
	$(call verilog_compile_schopt, mkConvEncoder_24_48, ConvEncoder.bsv)	

mkScrambler.v:
	$(call verilog_compile_schopt, mkScrambler_48, Scrambler.bsv)

mkInterleaver.v:
	$(call verilog_compile_schopt, mkInterleaver, Interleaver.bsv)

mkMapper.v:
	$(call verilog_compile_schopt, mkMapper_48_64, Mapper.bsv)

mkIFFT.v:
	$(call verilog_compile_schopt, mkIFFT_Comb, IFFT.bsv)

mkCyclicExtender.v:
	$(call verilog_compile_schopt, mkCyclicExtender, CyclicExtender.bsv)

mkTransmitter.v:
	$(call verilog_compile_schopt, mkTransmitter_Comb, Transmitter.bsv)

