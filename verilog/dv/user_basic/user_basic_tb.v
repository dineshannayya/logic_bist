////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText:  2021 , Dinesh Annayya
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
// SPDX-FileContributor: Modified by Dinesh Annayya <dinesha@opencores.org>
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Standalone User validation Test bench                       ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////   This is a standalone test bench to validate the            ////
////   Digital core.                                              ////
////   1. User Risc core is booted using  compiled code of        ////
////      user_risc_boot.c                                        ////
////   2. User Risc core uses Serial Flash and SDRAM to boot      ////
////   3. After successful boot, Risc core will check the UART    ////
////      RX Data, If it's available then it loop back the same   ////
////      data in uart tx                                         ////
////   4. Test bench send random 40 character towards User uart   ////
////      and expect same data to return back                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 16th Feb 2021, Dinesh A                             ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`default_nettype wire

`timescale 1 ns/10 ps

`include "uprj_netlists.v"

`define WB_MAP           `30080_0000
`define GLBL_FUNC_MAP    'h3000_0000

`define GLBL_BIST_CTRL1  'h3000_0008    
`define GLBL_BIST_CTRL2  'h3000_000C
`define GLBL_BIST_STAT1  'h3000_0010
`define GLBL_BIST_STAT2  'h3000_0014
`define GLBL_BIST_SWDATA 'h3000_0018
`define GLBL_BIST_SRDATA 'h3000_001C
`define GLBL_BIST_SPDATA 'h3000_0020
`define GLBL_BIST_SOFT1  'h3000_0024
`define GLBL_BIST_SOFT2  'h3000_0028
`define GLBL_BIST_SOFT3  'h3000_002C

`define WB_GLBL_CTRL     'h3080_0000
`define WB_BANK_SEL      'h3080_0004
`define WB_CLK_CTRL1     'h3080_0008
`define WB_CLK_CTRL2     'h3080_000C


module user_basic_tb;
parameter CLK1_PERIOD = 10;
parameter CLK2_PERIOD = 2;

reg            clock         ;
reg            clock2        ;
reg            wb_rst_i      ;
reg            power1, power2;
reg            power3, power4;

reg            wbd_ext_cyc_i;  // strobe/request
reg            wbd_ext_stb_i;  // strobe/request
reg [31:0]     wbd_ext_adr_i;  // address
reg            wbd_ext_we_i;  // write
reg [31:0]     wbd_ext_dat_i;  // data output
reg [3:0]      wbd_ext_sel_i;  // byte enable

wire [31:0]    wbd_ext_dat_o;  // data input
wire           wbd_ext_ack_o;  // acknowlegement
wire           wbd_ext_err_o;  // error

// User I/O
wire [37:0]    io_oeb        ;
wire [37:0]    io_out        ;
wire [37:0]    io_in         ;

wire [37:0]    mprj_io       ;
wire [7:0]     mprj_io_0     ;
reg            test_fail     ;
reg [31:0]     read_data     ;
//----------------------------------
// Uart Configuration
// ---------------------------------
reg [1:0]      uart_data_bit        ;
reg	       uart_stop_bits       ; // 0: 1 stop bit; 1: 2 stop bit;
reg	       uart_stick_parity    ; // 1: force even parity
reg	       uart_parity_en       ; // parity enable
reg	       uart_even_odd_parity ; // 0: odd parity; 1: even parity

reg [7:0]      uart_data            ;
reg [15:0]     uart_divisor         ;	// divided by n * 16
reg [15:0]     uart_timeout         ;// wait time limit

reg [15:0]     uart_rx_nu           ;
reg [15:0]     uart_tx_nu           ;
reg [7:0]      uart_write_data [0:39];
reg 	       uart_fifo_enable     ;	// fifo mode disable

wire           clock_mon;
integer        test_step;

integer i,j;

	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.

	always #(CLK1_PERIOD/2) clock  <= (clock === 1'b0);
	always #(CLK2_PERIOD/2) clock2 <= (clock2 === 1'b0);

	initial begin
		test_step = 0;
		clock = 0;
		clock2 = 0;
                wbd_ext_cyc_i ='h0;  // strobe/request
                wbd_ext_stb_i ='h0;  // strobe/request
                wbd_ext_adr_i ='h0;  // address
                wbd_ext_we_i  ='h0;  // write
                wbd_ext_dat_i ='h0;  // data output
                wbd_ext_sel_i ='h0;  // byte enable
	end

	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("risc_boot.vcd");
	   	$dumpvars(0, user_basic_tb.u_top.u_wb_host);
	   end
       `endif

	initial begin
		wb_rst_i <= 1'b1;
		#100;
		wb_rst_i <= 1'b0;	    	// Release reset
	end
initial
begin

   #200; // Wait for reset removal
   repeat (10) @(posedge clock);
   $display("Monitor: Standalone User Basic Test Started");
   
   repeat (2) @(posedge clock);

   test_fail=0;
   fork
      begin
	  // Default Value Check
	  // assign cfg_glb_ctrl         = reg_0[7:0];
          // assign cfg_wb_clk_ctrl      = reg_0[11:8];
	  // assign cfg_lbist_clk_ctrl   = reg_0[15:12];

	  $display("Step-1, WBS CLK: CLOCK1  LBIST CLK: CLOCK1");
	  test_step = 1;
          wb_user_core_write('h3080_0000,{16'h0,4'h0,4'h0,8'h00});
	  clock_monitor(CLK1_PERIOD,CLK1_PERIOD);

	  $display("Step-2, WBS CLK: CLOCK1/2,LBIST CLK: CLOCK1/2 ");
	  test_step = 2;
          wb_user_core_write('h3080_0000,{16'h0,4'h8,4'h8,8'h00});
	  clock_monitor(2*CLK1_PERIOD,2*CLK1_PERIOD);

	  $display("Step-3, WBS CLK: CLOCK1/(2+1), LBIST CLK: CLOCK1/(2+1)");
	  test_step = 3;
          wb_user_core_write('h3080_0000,{16'h0,4'h9,4'h9,8'h00});
	  clock_monitor(3*CLK1_PERIOD,3*CLK1_PERIOD);

	  $display("Step-4, WBS CLK: CLOCK1/(2+2), LBIST CLK: CLOCK1/(2+2) ");
	  test_step = 4;
          wb_user_core_write('h3080_0000,{16'h0,4'hA,4'hA,8'h00});
	  clock_monitor(4*CLK1_PERIOD,4*CLK1_PERIOD);

	  $display("Step-5, WBS CLK: CLOCK1/(2+3), LBIST CLK: CLOCK1/(2+3)");
	  test_step = 5;
          wb_user_core_write('h3080_0000,{16'h0,4'hB,4'hB,8'h00});
	  clock_monitor(5*CLK1_PERIOD,5*CLK1_PERIOD);

	  $display("Step-6, WBS CLK: CLOCK1/(2+4),LBIST CLK: CLOCK1/(2+4)");
	  test_step = 6;
          wb_user_core_write('h3080_0000,{16'h0,4'hC,4'hC,8'h00});
	  clock_monitor(6*CLK1_PERIOD,6*CLK1_PERIOD);

	  $display("Step-7, WBS CLK: CLOCK2/(2+5),LBIST CLK: CLOCK2/(2+5)");
	  test_step = 6;
          wb_user_core_write('h3080_0000,{16'h0,4'hD,4'hD,8'h00});
	  clock_monitor(7*CLK1_PERIOD,7*CLK1_PERIOD);

	  $display("Step-8, WBS CLK: CLOCK2/(2+6),LBIST CLK: CLOCK2/(2+6)");
	  test_step = 8;
          wb_user_core_write('h3080_0000,{16'h0,4'hE,4'hE,8'h00});
	  clock_monitor(8*CLK1_PERIOD,8*CLK1_PERIOD);

	  $display("Step-9, WBS CLK: CLOCK2/(2+7),LBIST CLK: CLOCK2/(2+7)");
	  test_step = 9;
          wb_user_core_write('h3080_0000,{16'h0,4'hF,4'hF,8'h00});
	  clock_monitor(9*CLK1_PERIOD,9*CLK1_PERIOD);
         
	 $display("###################################################");
         $display("Monitor: Checking the chip signature :");
	//  WBS CLK: CLOCK1
         wb_user_core_write('h3080_0000,{20'h0,4'h0,8'h00});
         // Remove Wb/PinMux Reset
         wb_user_core_write(`WB_GLBL_CTRL,'h1);

	 wb_user_core_read_check(`GLBL_BIST_SOFT1,read_data,32'h4C66_8354);
	 wb_user_core_read_check(`GLBL_BIST_SOFT2,read_data,32'h0312_2021);
	 wb_user_core_read_check(`GLBL_BIST_SOFT3,read_data,32'h0001_1000);
      end
   
      begin
      repeat (20000) @(posedge clock);
   		// $display("+1000 cycles");
      test_fail = 1;
      end
      join_any
      disable fork; //disable pending fork activity

   
      $display("###################################################");
      if(test_fail == 0) begin
         `ifdef GL
             $display("Monitor: Standalone User UART Test (GL) Passed");
         `else
             $display("Monitor: Standalone User UART Test (RTL) Passed");
         `endif
      end else begin
          `ifdef GL
              $display("Monitor: Standalone User UART Test (GL) Failed");
          `else
              $display("Monitor: Standalone User UART Test (RTL) Failed");
          `endif
       end
      $display("###################################################");
      #100
      $finish;
end


wire USER_VDD1V8 = 1'b1;
wire VSS = 1'b0;


user_project_wrapper u_top(
`ifdef USE_POWER_PINS
    .vccd1(USER_VDD1V8),	// User area 1 1.8V supply
    .vssd1(VSS),	// User area 1 digital ground
`endif
    .wb_clk_i        (clock),  // System clock
    .user_clock2     (clock2),  // Real-time clock
    .wb_rst_i        (wb_rst_i),  // Regular Reset signal

    .wbs_cyc_i   (wbd_ext_cyc_i),  // strobe/request
    .wbs_stb_i   (wbd_ext_stb_i),  // strobe/request
    .wbs_adr_i   (wbd_ext_adr_i),  // address
    .wbs_we_i    (wbd_ext_we_i),  // write
    .wbs_dat_i   (wbd_ext_dat_i),  // data output
    .wbs_sel_i   (wbd_ext_sel_i),  // byte enable

    .wbs_dat_o   (wbd_ext_dat_o),  // data input
    .wbs_ack_o   (wbd_ext_ack_o),  // acknowlegement

 
    // Logic Analyzer Signals
    .la_data_in      ('0) ,
    .la_data_out     (),
    .la_oenb         ('0),
 

    // IOs
    .io_in          (io_in)  ,
    .io_out         (io_out) ,
    .io_oeb         (io_oeb) ,

    .user_irq       () 

);

`ifndef GL // Drive Power for Hold Fix Buf
    // All standard cell need power hook-up for functionality work
    initial begin


    end
`endif    


task clock_monitor;
input [15:0] exp_wbs_period;
input [15:0] exp_lbist_period;
begin
   force clock_mon = u_top.u_wb_host.wbs_clk_out;
   check_clock_period("WBS Clock",exp_wbs_period);
   release clock_mon;
   force clock_mon = u_top.u_wb_host.lbist_clk_int;
   check_clock_period("LBIST Clock",exp_lbist_period);
   release clock_mon;

end
endtask

//----------------------------------
// Check the clock period
//----------------------------------
task check_clock_period;
input [127:0] clk_name;
input [15:0] clk_period; // in NS
time prev_t, next_t, periodd;
begin
	$timeformat(-12,3,"ns",10);
   repeat(1) @(posedge clock_mon);
   repeat(1) @(posedge clock_mon);
   prev_t  = $realtime;
   repeat(100) @(posedge clock_mon);
   next_t  = $realtime;
   periodd = (next_t-prev_t)/100;
   //periodd = (periodd)/1e9;
   if(clk_period != periodd) begin
       $display("STATUS: FAIL => %s Exp Period: %d Rxd: %d",clk_name,clk_period,periodd);
       test_fail = 1;
   end else begin
       $display("STATUS: PASS => %s  Period: %d ",clk_name,clk_period);
   end
end
endtask






task wb_user_core_write;
input [31:0] address;
input [31:0] data;
begin
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_adr_i =address;  // address
  wbd_ext_we_i  ='h1;  // write
  wbd_ext_dat_i =data;  // data output
  wbd_ext_sel_i ='hF;  // byte enable
  wbd_ext_cyc_i ='h1;  // strobe/request
  wbd_ext_stb_i ='h1;  // strobe/request
  wait(wbd_ext_ack_o == 1);
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_cyc_i ='h0;  // strobe/request
  wbd_ext_stb_i ='h0;  // strobe/request
  wbd_ext_adr_i ='h0;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='h0;  // data output
  wbd_ext_sel_i ='h0;  // byte enable
  $display("DEBUG WB USER ACCESS WRITE Address : %x, Data : %x",address,data);
  repeat (2) @(posedge clock);
end
endtask

task  wb_user_core_read;
input [31:0] address;
output [31:0] data;
reg    [31:0] data;
begin
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_adr_i =address;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='0;  // data output
  wbd_ext_sel_i ='hF;  // byte enable
  wbd_ext_cyc_i ='h1;  // strobe/request
  wbd_ext_stb_i ='h1;  // strobe/request
  wait(wbd_ext_ack_o == 1);
  data  = wbd_ext_dat_o;  
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_cyc_i ='h0;  // strobe/request
  wbd_ext_stb_i ='h0;  // strobe/request
  wbd_ext_adr_i ='h0;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='h0;  // data output
  wbd_ext_sel_i ='h0;  // byte enable
  $display("DEBUG WB USER ACCESS READ Address : %x, Data : %x",address,data);
  repeat (2) @(posedge clock);
end
endtask


task  wb_user_core_read_check;
input [31:0] address;
output [31:0] data;
input [31:0] cmp_data;
reg    [31:0] data;
begin
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_adr_i =address;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='0;  // data output
  wbd_ext_sel_i ='hF;  // byte enable
  wbd_ext_cyc_i ='h1;  // strobe/request
  wbd_ext_stb_i ='h1;  // strobe/request
  wait(wbd_ext_ack_o == 1);
  data  = wbd_ext_dat_o;  
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_cyc_i ='h0;  // strobe/request
  wbd_ext_stb_i ='h0;  // strobe/request
  wbd_ext_adr_i ='h0;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='h0;  // data output
  wbd_ext_sel_i ='h0;  // byte enable
  if(data !== cmp_data) begin
     $display("ERROR : WB USER ACCESS READ  Address : 0x%x, Exd: 0x%x Rxd: 0x%x ",address,cmp_data,data);
     test_fail = 1;
  end else begin
     $display("STATUS: WB USER ACCESS READ  Address : 0x%x, Data : 0x%x",address,data);
  end
  repeat (2) @(posedge clock);
end
endtask

endmodule
`default_nettype wire
