// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

// Include caravel global defines for the number of the user project IO pads 
`include "defines.v"
`define USE_POWER_PINS

`ifdef GL
    // Assume default net type to be wire because GL netlists don't have the wire definitions
    `default_nettype wire
    `include "gl/user_project_wrapper.v"
    `include "gl/user_proj_example.v"
`else
    `include "user_project_wrapper.v"


    `include "mbist/src/mbist_addr_gen.sv"
    `include "mbist/src/mbist_fsm.sv" 
    `include "mbist/src/mbist_op_sel.sv" 
    `include "mbist/src/mbist_repair_addr.sv" 
    `include "mbist/src/mbist_top.sv" 
    `include "mbist/src/mbist_sti_sel.sv" 
    `include "mbist/src/mbist_pat_sel.sv"
    `include "mbist/src/mbist_mux.sv"
    `include "mbist/src/mbist_data_cmp.sv"

    `include "wb_host/src/wb_host.sv"
    `include "lib/async_fifo.sv"
    `include "lib/async_wb.sv"
    `include "lib/registers.v"
    `include "lib/clk_ctl.v"

    `include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"

`endif
