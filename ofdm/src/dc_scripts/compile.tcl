
echo ${DESIGN}
echo ${SDC}
echo ${WORKDIR}
echo ${VFILES}
echo ${DONTTOUCH}
echo ${CLKPERIOD}
# ---------------------------------------------


# Setting up cell libs 
# ---------------------------------------- 
source libs.tcl


# adding verilog files to search path
# ----------------------------------------

#lappend search_path ${SEARCHPATH}


# info for formal verification
#set_svf ${DESIGN}.svf


# Setting DC ultra Optimization
# ----------------------------------------
set_ultra_optimization true

set synlib_prefer_ultra_license true
set synlib_enable_dpgen true
set synlib_dwgen_smart_generation true
set compile_new_boolean_structure true
set compile_new_optimization true

set_clock_gating_style -sequential_cell latch \
                       -minimum_bitwidth 4 \
                       -control_point before \
                       -control_signal scan_enable

#if {${DDCFILES} != ""} {
#    read_file -format ddc ${DDCFILES} 
#}


# Analyzing Design 
# ---------------------------------------

analyze -library ${WORKDIR} -format verilog ${VFILES}


# Elabourating Design
# --------------------------------------- 

elaborate ${DESIGN} -architecture verilog -library ${WORKDIR}

check_design > ${DESIGN}.check


# Setting Don't Touch  
# ---------------------------------------

if {${DONTTOUCH} != {}} {
    set_dont_touch ${DONTTOUCH}
}

# dont touch pads or power/ground nets
#set_dont_touch [get_cells PI*]
#set_dont_touch [get_nets VDD*]
#set_dont_touch [get_nets VSS]

uniquify

if {${DONTTOUCH} != ""} {
    set dont_touch_star_list {}
    foreach design ${DONTTOUCH} {lappend dont_touch_star_list "${design}*"} 
    set_dont_touch [find design -hierarchy ${dont_touch_star_list}]
}


read_sdc ${SDC}
source ${SDC}

# no scan for now
#set_scan_configuration -style none



create_clock CLK -name CLK -period ${CLKPERIOD}

# Setting buffering margins (for PAR)
# ---------------------------------------

set_clock_uncertainty -setup [expr 0.025 * ${CLKPERIOD}]  [get_clocks] 
set_critical_range [expr 0.02 * ${CLKPERIOD}] ${DESIGN} 

#insert_clock_gating -global
#propagate_constraints -gate_clock


# Creating Clock
# ---------------------------------------
# create_clock CLK -name CLK -period ${CLKPERIOD}create_clock CLK -name CLK -period ${CLKPERIOD}


# Combinational Design constraint
# -------------------------------------
 set_max_delay ${CLKPERIOD} -to [all_outputs] -from [all_inputs]
 set_flatten -phase true -effort high

# This constrainst sets the load capacitance in picofarads of the
# output pins of your design. 4fF is reasonable if your design is
# driving another block of on-chip logic.

set_load -pin_load 0.004 [all_outputs]


# Compiling Design
#------------------------------------   

set compile_auto_ungroup_delay_num_cells 100
set_max_area 0

compile -incremental_mapping \
        -map_effort high \
        -boundary_optimization \
        -area_effort high \
        -auto_ungroup area










#report_auto_ungroup

# Final Uniquify                                      
# ---------------------------------------   
#final uniquify of dont_touch designs
 if {${DONTTOUCH} != ""} {
    set_dont_touch ${DONTTOUCH} false
    uniquify
}


change_names -rules verilog -hierarchy -verbose

# use case-insesitives names to avoid confusing CAD tools (calibre)
define_name_rules insens -case_insensitive
change_names -rules insens -hierarchy -verbose

# outputting Gate-level Design
# ---------------------------------------

write -format verilog -hierarchy -output ${DESIGN}_syn.v 

# outputting DDC File
# ---------------------------------------      

write -format ddc -hierarchy -output ${DESIGN}.ddc


# outputting SDC File
# ---------------------------------------
write_sdc ${DESIGN}_out.sdc


# Timing/Area Reports
# ---------------------------------------
exec mkdir reports
cd reports

report_timing -capacitance \
              -transition_time \
              -nosplit \
              -nworst 10 \
              -max_paths 100 \
       > ${DESIGN}.timing

report_reference -nosplit > ${DESIGN}.area
report_resources -nosplit > ${DESIGN}.resources
report_power -nosplit -hier > ${DESIGN}.power

set cells [get_cells -hierarchical -filter "is_hierarchical == true"]
set zcells [sort_collection $cells { full_name }]
foreach_in_collection eachcell $zcells {
  current_instance $eachcell
  report_reference -nosplit >> ${DESIGN}.area
  report_resources -nosplit >> ${DESIGN}.resources
}


exit
