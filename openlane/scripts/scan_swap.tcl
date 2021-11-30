# delay calc example with parasitics
read_liberty $::env(LIB_SYNTH_COMPLETE)
read_verilog $::env(yosys_result_file_tag).v
link_design $::env(DESIGN_NAME)

write_verilog $::env(yosys_result_file_tag)_prescan.v
#To display all registers
set mylist [all_registers]
foreach elem $mylist {
   set Inst [get_full_name $elem]

   #Replace the FF to Scan FF
   replace_to_scan_cell $Inst

}

write_verilog $::env(yosys_result_file_tag)_scancell.v

exit
