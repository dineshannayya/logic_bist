//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021 , Dinesh Annayya                          
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
// SPDX-FileContributor: Created by Dinesh Annayya <dinesha@opencores.org>
//
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Digital core                                                ////
////                                                              ////
////  This file is part of the mbist_ctrl  project                ////
////  https://github.com/dineshannayya/mbist_ctrl.git             ////
////                                                              ////
////  Description                                                 ////
////      This is digital core and integrate all the main block   ////
////      here.                                                   ////
////      1. Wishbone Host                                        ////
////      2. MBIST Controller                                     ////
////      3. SRAM 2KB                                             ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 13th Oct 2021, Dinesh A                             ////
////          Initial Version                                     ////
//////////////////////////////////////////////////////////////////////
`default_nettype none

module user_project_wrapper #(
    parameter BITS = 32
) (
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

parameter BIST_ADDR_WD = 11;
parameter BIST_DATA_WD = 32;


wire                      bist_clk;
wire                      mem_clk_out;
wire                      bist_rst_n;

	// MBIST I/F
wire                      bist_en;
wire                      bist_run;
wire                      bist_shift;
wire                      bist_load;
wire                      bist_sdi;

wire  [3:0]               bist_error_cnt;
wire                      bist_correct;
wire                      bist_error;
wire                      bist_done;
wire                      bist_sdo;

// FUNCTIONAL A PORT 
wire                      func_clk_a;
wire                      func_cen_a;
wire  [BIST_ADDR_WD-1:2]  func_addr_a;
wire  [BIST_DATA_WD-1:0]  func_dout_a;

// Functional B Port
wire                      func_clk_b;
wire                      func_cen_b;
wire                      func_web_b;
wire [BIST_DATA_WD/8-1:0] func_mask_b;
wire  [BIST_ADDR_WD-1:2]  func_addr_b;
wire  [BIST_DATA_WD-1:0]  func_din_b;


// towards memory
// PORT-A
wire                      mem_clk_a;
wire   [BIST_ADDR_WD-1:2] mem_addr_a;
wire                      mem_cen_a;
wire   [BIST_DATA_WD-1:0] mem_din_b;

// PORT-B
wire                      mem_clk_b;
wire                      mem_cen_b;
wire                      mem_web_b;
wire [BIST_DATA_WD/8-1:0] mem_mask_b;
wire [BIST_ADDR_WD-1:2]   mem_addr_b;
wire [BIST_DATA_WD-1:0]   mem_dout_a;


wb_host u_wb_host(
        .user_clock1          (wb_clk_i         ),
        .user_clock2          (user_clock2      ),

    // Master Port
        .wbm_rst_i            (wb_rst_i         ),  
        .wbm_clk_i            (wb_clk_i         ),  
        .wbm_cyc_i            (wbs_cyc_i        ),  
        .wbm_stb_i            (wbs_stb_i        ),  
        .wbm_adr_i            (wbs_adr_i        ),  
        .wbm_we_i             (wbs_we_i         ),  
        .wbm_dat_i            (wbs_dat_i        ),  
        .wbm_sel_i            (wbs_sel_i        ),  
        .wbm_dat_o            (wbs_dat_o        ),  
        .wbm_ack_o            (wbs_ack_o        ),  
        .wbm_err_o            (                 ),  
        .bist_clk             (bist_clk         ),
        .bist_rst_n           (bist_rst_n       ),
	.mem_clk_out          (mem_clk_out      ),
	.mem_clk              (mem_clk_out      ),
	.wbd_int_rst_n        (                 ),

	.bist_en              (bist_en          ),
	.bist_run             (bist_run         ),
	.bist_shift           (bist_shift       ),
	.bist_load            (bist_load        ),
	.bist_sdi             (bist_sdi         ),

	.bist_error_cnt       (bist_error_cnt   ),
	.bist_correct         (bist_correct     ),
	.bist_error           (bist_error       ),
	.bist_done            (bist_done        ),
	.bist_sdo             (bist_sdo         ),

      // FUNCTIONAL A PORT    
        .func_clk_a           (func_clk_a       ),
        .func_cen_a           (func_cen_a       ),
        .func_addr_a          (func_addr_a      ),
        .func_dout_a          (func_dout_a      ),

       // Functional B Port   
        .func_clk_b           (func_clk_b       ),
        .func_cen_b           (func_cen_b       ),
	.func_web_b           (func_web_b       ),
	.func_mask_b          (func_mask_b      ),
        .func_addr_b          (func_addr_b      ),
        .func_din_b           (func_din_b       ),

        .io_out               (io_out           ),
        .io_oeb               (io_oeb           ),
        .la_data_out          (la_data_out      )

    );


mbist_top  #(
	`ifndef SYNTHESIS
	.BIST_ADDR_WD           (BIST_ADDR_WD-2         ),
	.BIST_DATA_WD           (BIST_DATA_WD           ),
	.BIST_ADDR_START        (9'h000                 ),
	.BIST_ADDR_END          (9'h1FB                 ),
	.BIST_REPAIR_ADDR_START (9'h1FC                 ),
	.BIST_RAD_WD_I          (BIST_ADDR_WD-2         ),
	.BIST_RAD_WD_O          (BIST_ADDR_WD-2         )
        `endif
     ) 
	     u_mbist (

	.bist_clk             (bist_clk         ),
	.rst_n                (bist_rst_n       ),

	
	.bist_en              (bist_en          ),
	.bist_run             (bist_run         ),
	.bist_shift           (bist_shift       ),
	.bist_load            (bist_load        ),
	.bist_sdi             (bist_sdi         ),

	.bist_error_cnt       (bist_error_cnt   ),
	.bist_correct         (bist_correct     ),
	.bist_error           (bist_error       ),
	.bist_done            (bist_done        ),
	.bist_sdo             (bist_sdo         ),

      // FUNCTIONAL A PORT    
        .func_clk_a           (func_clk_a       ),
        .func_cen_a           (func_cen_a       ),
        .func_addr_a          (func_addr_a      ),
        .func_dout_a          (func_dout_a      ),

       // Functional B Port   
        .func_clk_b           (func_clk_b       ),
        .func_cen_b           (func_cen_b       ),
	.func_web_b           (func_web_b       ),
	.func_mask_b          (func_mask_b      ),
        .func_addr_b          (func_addr_b      ),
        .func_din_b           (func_din_b       ),


     // towards memory
     // PORT-A
        .mem_clk_a            (mem_clk_a        ),
        .mem_addr_a           (mem_addr_a       ),
        .mem_cen_a            (mem_cen_a        ),
        .mem_dout_a           (mem_dout_a       ),
     // PORT-B
        .mem_clk_b            (mem_clk_b        ),
        .mem_cen_b            (mem_cen_b        ),
        .mem_web_b            (mem_web_b        ),
        .mem_mask_b           (mem_mask_b       ),
        .mem_addr_b           (mem_addr_b       ),
        .mem_din_b            (mem_din_b        )


);

sky130_sram_2kbyte_1rw1r_32x512_8 u_sram_2kb(
`ifdef USE_POWER_PINS
    .vccd1 (vccd1),// User area 1 1.8V supply
    .vssd1 (vssd1),// User area 1 digital ground
`endif
// Port 0: RW
    .clk0     (mem_clk_b),
    .csb0     (mem_cen_b),
    .web0     (mem_web_b),
    .wmask0   (mem_mask_b),
    .addr0    (mem_addr_b),
    .din0     (mem_din_b),
    .dout0    (),
// Port 1: R
    .clk1     (mem_clk_a),
    .csb1     (mem_cen_a),
    .addr1    (mem_addr_a),
    .dout1    (mem_dout_a)
  );


endmodule	// user_project_wrapper

`default_nettype wire
