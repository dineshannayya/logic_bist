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
////                                                              ////
////  Description                                                 ////
////   This is a standalone test bench to validate the            ////
////   Digital core MBIST logic through External WB i/F.          ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 18 Oct 2021, Dinesh A                               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`default_nettype wire

`timescale 1 ns / 1 ns

`include "uprj_netlists.v"

module user_mbist_test1_tb;
	reg clock;
	reg wb_rst_i;
	reg power1, power2;
	reg power3, power4;

        reg        wbd_ext_cyc_i;  // strobe/request
        reg        wbd_ext_stb_i;  // strobe/request
        reg [31:0] wbd_ext_adr_i;  // address
        reg        wbd_ext_we_i;  // write
        reg [31:0] wbd_ext_dat_i;  // data output
        reg [3:0]  wbd_ext_sel_i;  // byte enable

        wire [31:0] wbd_ext_dat_o;  // data input
        wire        wbd_ext_ack_o;  // acknowlegement
        wire        wbd_ext_err_o;  // error

	// User I/O
	wire [37:0] io_oeb;
	wire [37:0] io_out;
	wire [37:0] io_in;

	wire gpio;
	wire [37:0] mprj_io;
	wire [7:0] mprj_io_0;
	reg        test_fail;
	reg [31:0] read_data;
	event      error_insert;


	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.

	always #12.5 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
                wbd_ext_cyc_i ='h0;  // strobe/request
                wbd_ext_stb_i ='h0;  // strobe/request
                wbd_ext_adr_i ='h0;  // address
                wbd_ext_we_i  ='h0;  // write
                wbd_ext_dat_i ='h0;  // data output
                wbd_ext_sel_i ='h0;  // byte enable
	end

	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("simx.vcd");
	   	$dumpvars(4, user_mbist_test1_tb);
	   end
       `endif

	initial begin
		wb_rst_i <= 1'b1;
		#100;
		wb_rst_i <= 1'b0;	    	// Release reset

		#200; // Wait for reset removal
	        repeat (10) @(posedge clock);
		$display("Monitor: Standalone User Test Started");

		// Remove Wb Reset
		wb_user_core_write('h3080_0004,'h1);

	        repeat (2) @(posedge clock);
		#1;
		// Set the Bist Enable and Bist Run
                wb_user_core_write('h3080_0008,'h003);

		// Remove WB and BIST RESET
                wb_user_core_write('h3080_0004,'h003);

		test_fail = 0;

	       // BIST Test without any MEMORY ERROR //
               fork
		begin
		   // Check for MBIST Done
		   read_data = 'h0;
		   while (read_data[0] != 1'b1) begin
                      wb_user_core_read('h3080_000C,read_data);
	           end
		   // Check Is there is any BIST Error
		   if(read_data[1:0]  == 2'b11) test_fail = 1;
		end
		begin
		   // Loop for BIST TimeOut
	           repeat (200000) @(posedge clock);
	        		// $display("+1000 cycles");
		   test_fail = 1;
		end
	        join_any

		disable fork; //disable pending fork activity

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-1: BIST Test without any Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-1: BIST Test without any Memory Error insertion test Failed");
		 end
	    	$display("###################################################");

                wb_user_core_write('h3080_0008,'h000);
		// Apply WB and BIST RESET
                wb_user_core_write('h3080_0004,'h000);
		// Set the Bist Enable and Bist Run
                wb_user_core_write('h3080_0008,'h003);
		// Remove WB and BIST RESET
                wb_user_core_write('h3080_0004,'h003);
	       // BIST Test without One MEMORY ERROR //
               fork
		begin
		   // Check for MBIST Done
		   read_data = 'h0;
		   while (read_data[0] != 1'b1) begin
                      wb_user_core_read('h3080_000C,read_data);
	           end
		   // Check Is there is any BIST Error
		   // [0]   - Bist Done      - 1
		   // [1]   - Bist Error     - 0
		   // [2]   - Bist Correct   - 1
		   // [6:3] - Bist Error Cnt - 4'h1
		   if(read_data[6:0]  != 7'b0001101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x1
		end
	        // Single bit Error Insertion
	        begin
		   while(1) begin
	              repeat (1) @(posedge clock);
		      #1;
		      if(u_top.u_sram_2kb.web0 == 1'b0 && u_top.u_sram_2kb.addr0 == 'h10) begin
		          force u_top.u_sram_2kb.din0 = u_top.mem_din_b & 16'hFFFE;
			  -> error_insert;
		      end else begin
		          release u_top.u_sram_2kb.din0;
		      end
          	   end
		end
		begin
		   // Loop for BIST TimeOut
	           repeat (200000) @(posedge clock);
	        		// $display("+1000 cycles");
		   test_fail = 1;
		end
	        join_any
		disable fork; //disable pending fork activity

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-2: BIST Test with One Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-2: BIST Test with One Memory Error insertion test Failed");
		 end
	    	$display("###################################################");

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
    .user_clock2     (1'b1),  // Real-time clock
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

	force u_top.u_wb_host.u_buf_wb_rst.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_wb_rst.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_wb_rst.VGND =VSS;
	force u_top.u_wb_host.u_buf_wb_rst.VNB = VSS;

	force u_top.u_wb_host.u_buf_bist_rst.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_bist_rst.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_buf_bist_rst.VGND =VSS;
	force u_top.u_wb_host.u_buf_bist_rst.VNB = VSS;

	force u_top.u_wb_host.u_clkbuf_bist.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_clkbuf_bist.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_clkbuf_bist.VGND =VSS;
	force u_top.u_wb_host.u_clkbuf_bist.VNB = VSS;

	force u_top.u_wb_host.u_clkbuf_mem.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_clkbuf_mem.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_clkbuf_mem.VGND =VSS;
	force u_top.u_wb_host.u_clkbuf_mem.VNB = VSS;

    end
`endif    





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
  $display("STATUS: WB USER ACCESS WRITE Address : 0x%x, Data : 0x%x",address,data);
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
  $display("STATUS: WB USER ACCESS READ  Address : 0x%x, Data : 0x%x",address,data);
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
     user_mbist_test1_tb.test_fail = 1;
  end else begin
     $display("STATUS: WB USER ACCESS READ  Address : 0x%x, Data : 0x%x",address,data);
  end
  repeat (2) @(posedge clock);
end
endtask


endmodule
`default_nettype wire
