# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

# Base Configurations. Don't Touch
# section begin

# YOU ARE NOT ALLOWED TO CHANGE ANY VARIABLES DEFINED IN THE FIXED WRAPPER CFGS 
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper_empty/fixed_wrapper_cfgs.tcl

# YOU CAN CHANGE ANY VARIABLES DEFINED IN THE DEFAULT WRAPPER CFGS BY OVERRIDING THEM IN THIS CONFIG.TCL
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper_empty/default_wrapper_cfgs.tcl

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_project_wrapper
#section end

# User Configurations

## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/user_project_wrapper.v"

set ::env(SYNTH_DEFINES) [list SYNTHESIS ]

## Clock configurations
set ::env(CLOCK_PORT) "wb_clk_i user_clock2"
set ::env(CLOCK_NET) "wb_clk_i user_clock2"

set ::env(CLOCK_PERIOD) "10"

## Internal Macros
### Macro PDN Connections
set ::env(FP_PDN_ENABLE_MACROS_GRID) "0"
set ::env(FP_PDN_ENABLE_GLOBAL_CONNECTIONS) "1"

set ::env(FP_PDN_MACRO_HOOKS) "\
     u_wb_host	vccd1 vssd1 \
     u_mbist    vccd1 vssd1 \
     u_sram_2kb vccd1 vssd1 "

set ::env(VDD_NETS) "vccd1"
set ::env(GND_NETS) "vssd1"

### Macro Placement
set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro.cfg

set ::env(PDN_CFG) $script_dir/pdn.tcl

### Black-box verilog and views
set ::env(VERILOG_FILES_BLACKBOX) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v \
	$script_dir/../../verilog/gl/wb_host.v \
	$script_dir/../../verilog/gl/mbist.v"

set ::env(EXTRA_LEFS) "\
	$script_dir/../../lef/sky130_sram_2kbyte_1rw1r_32x512_8.lef \
	$script_dir/../../lef/mbist.lef \
	$script_dir/../../lef/wb_host.lef"

set ::env(EXTRA_GDS_FILES) "\
	$script_dir/../../gds/sky130_sram_2kbyte_1rw1r_32x512_8.gds \
	$script_dir/../../gds/mbist.gds \
	$script_dir/../../gds/wb_host.gds"

set ::env(SDC_FILE) "$script_dir/base.sdc"
set ::env(BASE_SDC_FILE) "$script_dir/base.sdc"

set ::env(GLB_RT_MAXLAYER) 5

# disable pdn check nodes becuase it hangs with multiple power domains.
# any issue with pdn connections will be flagged with LVS so it is not a critical check.
set ::env(FP_PDN_CHECK_NODES) 0

### Macro PDN Connections
set ::env(FP_PDN_ENABLE_MACROS_GRID) "0"
set ::env(FP_PDN_ENABLE_GLOBAL_CONNECTIONS) "1"

set ::env(VDD_NETS) "vccd1 vccd2 vdda1 vdda2"
set ::env(GND_NETS) "vssd1 vssd2 vssa1 vssa2"

# The following is because there are no std cells in the example wrapper project.
set ::env(SYNTH_TOP_LEVEL) 1
set ::env(PL_RANDOM_GLB_PLACEMENT) 1

set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 0
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0

set ::env(FP_PDN_ENABLE_RAILS) 0

set ::env(DIODE_INSERTION_STRATEGY) 0
set ::env(FILL_INSERTION) 0
set ::env(TAP_DECAP_INSERTION) 0
set ::env(CLOCK_TREE_SYNTH) 0

set ::env(QUIT_ON_LVS_ERROR) "0"
set ::env(QUIT_ON_MAGIC_DRC) "0"
set ::env(QUIT_ON_NEGATIVE_WNS) "0"
set ::env(QUIT_ON_SLEW_VIOLATIONS) "0"
set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
set ::env(QUIT_ON_TR_DRC) "0"


