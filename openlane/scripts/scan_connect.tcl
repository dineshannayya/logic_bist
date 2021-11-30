# delay calc example with parasitics
read_liberty $::env(LIB_SYNTH_COMPLETE)
read_verilog $::env(yosys_result_file_tag)_scancell.v
link_design $::env(DESIGN_NAME)

#To display all registers
set mylist [all_registers]

for { set si_index 0 }  { $si_index < $::env(SCAN_TOTAL_CHAINS) }  { incr si_index } {
   set scan_in($si_index) "scan_si[$si_index]"
}

set si_index 0

puts "Info: Connecting Scan Chain Si => FF => FF ..  FF .. => SO" 
foreach elem $mylist {

   set Inst [get_full_name $elem]

   #Disconnect the Net to scan enable Pin
   set net1 [get_full_name [get_nets -of_objects $Inst/SCE]]
   disconnect_pin $net1 $Inst/SCE

   # Connect Scan Enable
   connect_pin scan_en $Inst/SCE 

   #Disconnect Scan In
   set net1 [get_full_name [get_nets -of_objects $Inst/SCD]]
   disconnect_pin $net1 $Inst/SCD

   # Connect Scan Enable
   connect_pin $scan_in($si_index) $Inst/SCD 

   puts "Info: Connecting $scan_in($si_index) $Inst/SCD "

   # Current cell Q pin Became Scan in for next FF
   set scan_in($si_index) [get_full_name [get_nets -of_objects $Inst/Q]]

   incr si_index
   if {$si_index == $::env(SCAN_TOTAL_CHAINS) } {
      set si_index 0 
      incr si_depth
   }


}

## Calculate scan depth based on total scan cell & total scan chain
set si_depth  [expr [expr [llength $mylist] + $::env(SCAN_TOTAL_CHAINS)] / $::env(SCAN_TOTAL_CHAINS)]

puts "Info: Total Scan FF: [llength $mylist]" 
puts "Info: Total Scan Chain: $::env(SCAN_TOTAL_CHAINS)"
puts "Info: Scan Depth: $si_depth" 


# Delete the Tie Low cell connect to scan_so
for { set si_index 0 }  { $si_index < $::env(SCAN_TOTAL_CHAINS) }  { incr si_index } {
      set mylist [get_fanin -to scan_so[$si_index] -only_cells -trace_arcs all]
      foreach elem $mylist {
	 set Inst [get_full_name $elem]
	 if {$Inst ne ""} then {
	    puts "Info: Deleting $Inst Instance Connected to scan_so[$si_index] "
            delete_instance $Inst
         }
      }
}
puts "Info: Create a Buffer at Scan SO and connect Last FF SO to scan_so .."
for { set si_index 0 }  { $si_index < $::env(SCAN_TOTAL_CHAINS) }  { incr si_index } {
    make_instance u_scan_so_$si_index sky130_fd_sc_hd__tt_025C_1v80/sky130_fd_sc_hd__buf_8
    connect_pin $scan_in($si_index) u_scan_so_$si_index/A
    connect_pin scan_so[$si_index] u_scan_so_$si_index/X
}

write_verilog $::env(yosys_result_file_tag).v

exit
