
############################  Search PATH ################################

set LIB_PATH     /home/IC/tsmc_fb_cl013g_sc/aci/sc-m

lappend search_path /home/IC/Projects/APB/std_cells
lappend search_path /home/IC/Projects/APB/rtl
lappend search_path $LIB_PATH/synopsys

########################### Define Top Module ############################
                                                   
set top_module APB

######################### Formality Setup File ###########################

set synopsys_auto_setup true

set_svf "/home/IC/Projects/APB/Syn/APB.svf"

####################### Read Reference tech libs ########################
 

set SSLIB "/home/IC/tsmc_fb_cl013g_sc/aci/sc-m/synopsys/scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "/home/IC/tsmc_fb_cl013g_sc/aci/sc-m/synopsys/scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set FFLIB "/home/IC/tsmc_fb_cl013g_sc/aci/sc-m/synopsys/scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"

read_db -container Ref [list $SSLIB $TTLIB $FFLIB]

###################  Read Reference Design Files ######################## 
read_verilog -container Ref "APB.v"
read_verilog -container Ref "masterAPB.v"
read_verilog -container Ref "slave1.v"
read_verilog -container Ref "slave2.v"
#read_verilog -container Ref "scan_mux.v"


######################## set the top Reference Design ######################## 

set_reference_design APB
set_top APB

####################### Read Implementation tech libs ######################## 

read_db -container Imp [list $SSLIB $TTLIB $FFLIB]

#################### Read Implementation Design Files ######################## 

read_verilog -container Imp -netlist "/home/IC/Projects/APB/Syn/netlists/APB.v"

####################  set the top Implementation Design ######################

set_implementation_design APB
set_top APB

########################## Don't verify ###########################

# do not verify scan in & scan out ports as a compare point as it is existed only after synthesis (post dft) and not existed in the RTL

#scan in
#set_dont_verify_points -type port Ref:/WORK/*/SI
#set_dont_verify_points -type port Imp:/WORK/*/SI

#scan_out
#set_dont_verify_points -type port Ref:/WORK/*/SO
#set_dont_verify_points -type port Imp:/WORK/*/SO

############################### contants #####################################

# all atpg enable (test_mode, scan_enable) are zero during formal compare in post synthesis

#test_mode
#set_constant Ref:/WORK/*/test_mode 0
#set_constant Imp:/WORK/*/test_mode 0

#scan_enable
#set_constant Ref:/WORK/*/SE 0
#set_constant Imp:/WORK/*/SE 0

## matching Compare points
match

#verify
## verify
set successful [verify]
if {!$successful} {
diagnose
analyze_points -failing
}

report_passing_points > "reports/passing_points.rpt"
report_failing_points > "reports/failing_points.rpt"
report_aborted_points > "reports/aborted_points.rpt"
report_unverified_points > "reports/unverified_points.rpt"


start_gui
