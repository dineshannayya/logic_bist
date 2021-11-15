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
        reg [31:0] writemem [0:511];
        reg [8:0]  faultaddr [0:7];
        integer i;
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
	   	$dumpvars(5, user_mbist_test1_tb);
		$dumpoff;
	   end
       `endif

	initial begin
		wb_rst_i <= 1'b1;
		#100;
		wb_rst_i <= 1'b0;	    	// Release reset

		#200; // Wait for reset removal
	        repeat (10) @(posedge clock);
		$display("Monitor: Standalone User Test Started");

		test_fail = 0;
		// Remove Wb Reset
		wb_user_core_write('h3080_0004,'h1);

	    	$display("###################################################");
	    	$display(" MBIST Test with Without Address Failure");
	    	$display("###################################################");

		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 0
		// [6:3] - Bist Error Cnt - 4'h0
		insert_fault(0,0,7'h1);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-1: BIST Test without any Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-1: BIST Test without any Memory Error insertion test Failed");
		 end
	    	$display("###################################################");
	    	$display(" MBIST Test with Single Address Failure");
	    	$display("###################################################");
                $dumpon;
		   // Check Is there is any BIST Error
		   // [0]   - Bist Done      - 1
		   // [1]   - Bist Error     - 0
		   // [2]   - Bist Correct   - 1
		   // [6:3] - Bist Error Cnt - 4'h1
		   //if(read_data[6:0]  != 7'b0001101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x1
		faultaddr[0] = 9'h10;
		insert_fault(1,1,7'hD);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-2: BIST Test with One Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-2: BIST Test with One Memory Error insertion test Failed");
		 end
	    	$display("###################################################");

	    	$display("###################################################");
	    	$display(" MBIST Test with Two Address Failure");
	    	$display("###################################################");
		// Check Is there is any BIST Error
		// [0]   - Bist Done      - 1
		// [1]   - Bist Error     - 0
		// [2]   - Bist Correct   - 1
		// [6:3] - Bist Error Cnt - 4'h2
		//if(read_data[6:0]  != 7'b0010101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x2
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		insert_fault(2,0,7'h15);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-3: BIST Test with Two Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-3: BIST Test with Two Memory Error insertion test Failed");
		 end
	    	$display("###################################################");
	    	$display(" MBIST Test with Three Address Failure");
	    	$display("###################################################");

		   // Check Is there is any BIST Error
		   // [0]   - Bist Done      - 1
		   // [1]   - Bist Error     - 0
		   // [2]   - Bist Correct   - 1
		   // [6:3] - Bist Error Cnt - 4'h3
		   //if(read_data[6:0]  != 7'b0011101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x3
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		insert_fault(3,1,7'h1D);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-4: BIST Test with Three Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-4: BIST Test with Three Memory Error insertion test Failed");
		 end
                $dumpoff;
	    	$display("###################################################");
	    	$display(" MBIST Test with Fours Address Failure");
	    	$display("###################################################");
		   // Check Is there is any BIST Error
		   // [0]   - Bist Done      - 1
		   // [1]   - Bist Error     - 0
		   // [2]   - Bist Correct   - 1
		   // [6:3] - Bist Error Cnt - 4'h4
		   //if(read_data[6:0]  != 7'b0100101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x4
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		insert_fault(4,0,7'h25);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-5: BIST Test with Four Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-5: BIST Test with Four Memory Error insertion test Failed");
		end

	    	$display("###################################################");
	    	$display(" MBIST Test with Fours Address(Continous Starting Addrsess) Failure");
	    	$display("###################################################");
		   // Check Is there is any BIST Error
		   // [0]   - Bist Done      - 1
		   // [1]   - Bist Error     - 0
		   // [2]   - Bist Correct   - 1
		   // [6:3] - Bist Error Cnt - 4'h4
		   //if(read_data[6:0]  != 7'b0100101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x4
		faultaddr[0] = 9'h0;
		faultaddr[1] = 9'h1;
		faultaddr[2] = 9'h2;
		faultaddr[3] = 9'h3;
		insert_fault(4,0,7'h25);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-5.2: BIST Test with Four Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-5.2: BIST Test with Four Memory Error insertion test Failed");
		end

	    	$display("###################################################");
	    	$display(" MBIST Test with Fours Address(Last Addrsess) Failure");
	    	$display("###################################################");
		   // Check Is there is any BIST Error
		   // [0]   - Bist Done      - 1
		   // [1]   - Bist Error     - 0
		   // [2]   - Bist Correct   - 1
		   // [6:3] - Bist Error Cnt - 4'h4
		   //if(read_data[6:0]  != 7'b0100101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x4
		faultaddr[0] = 9'h1F8;
		faultaddr[1] = 9'h1F9;
		faultaddr[2] = 9'h1FA;
		faultaddr[3] = 9'h1FB;
		insert_fault(4,0,7'h25);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-5.3: BIST Test with Four Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-5.3: BIST Test with Four Memory Error insertion test Failed");
		end
	    	$display("###################################################");
	    	$display(" MBIST Test with Five Address Failure");
	    	$display("###################################################");
		   // Check Is there is any BIST Error
		   // [0]   - Bist Done      - 1
		   // [1]   - Bist Error     - 1
		   // [2]   - Bist Correct   - 1
		   // [6:3] - Bist Error Cnt - 4'h4
		   //if(read_data[6:0]  != 7'b0100101) test_fail = 1; // Bist correct = 1 and Bist Err Cnt - 0x4
		faultaddr[0] = 9'h10;
		faultaddr[1] = 9'h20;
		faultaddr[2] = 9'h30;
		faultaddr[3] = 9'h40;
		faultaddr[4] = 9'h50;
		insert_fault(5,1,7'h27);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-5: BIST Test with Five Memory Error insertion test Passed");
	        end else begin
	    	    $display("Monitor: Step-5: BIST Test with Five Memory Error insertion test Failed");
		 end

	    	$display("###################################################");
	    	$display(" MBIST Test with Functional Access, continuation of previous MBIST Signature");
	    	$display("###################################################");
		$dumpon;
		// Remove the Bist Enable and Bist Run
                wb_user_core_write('h3080_0008,'h000);
  
	        // Fill Random Data	
		for (i=0; i< 9'h1FC; i=i+1) begin
   	            writemem[i] = $random;
                    wb_user_core_write('h3000_0000+(i*4),writemem[i]);
		end
		for (i=0; i< 9'h1FC; i=i+1) begin
                    wb_user_core_read_check('h3000_0000+(i*4),read_data,writemem[i],32'hFFFFFFFF);
		end

		// Cross-check Reducency address hold the failure address data
		// Is last Error inserted address are 0x10,0x20,0x30,0x40
		// So Address 0x1FC = Data[0x10], 0x1FD = Data[0x20]
		//    Address 0x1FE = Data[0x30], 0x1FF = Data[0x40]
                wb_user_core_read_check('h3000_0000 + (9'h1FC *4),read_data,writemem[9'h10],32'hFFFFFFFF);
                wb_user_core_read_check('h3000_0000 + (9'h1FD *4),read_data,writemem[9'h20],32'hFFFFFFFF);
                wb_user_core_read_check('h3000_0000 + (9'h1FE *4),read_data,writemem[9'h30],32'hFFFFFFFF);
                wb_user_core_read_check('h3000_0000 + (9'h1FF *4),read_data,writemem[9'h40],32'hFFFFFFFF);

          	if(test_fail == 0) begin
	    	    $display("Monitor: Step-5: BIST Test with Functional access test Passed");
	        end else begin
	    	    $display("Monitor: Step-5: BIST Test with Functional access test failed");
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

	force u_top.u_wb_host.u_cpu_ref_sel.u_mux.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_cpu_ref_sel.u_mux.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_cpu_ref_sel.u_mux.VGND =VSS;
	force u_top.u_wb_host.u_cpu_ref_sel.u_mux.VNB = VSS;

	force u_top.u_wb_host.u_cpu_clk_sel.u_mux.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_cpu_clk_sel.u_mux.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_cpu_clk_sel.u_mux.VGND =VSS;
	force u_top.u_wb_host.u_cpu_clk_sel.u_mux.VNB = VSS;
	
	force u_top.u_wb_host.u_mem_ref_sel.u_mux.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_mem_ref_sel.u_mux.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_mem_ref_sel.u_mux.VGND =VSS;
	force u_top.u_wb_host.u_mem_ref_sel.u_mux.VNB = VSS;

	force u_top.u_wb_host.u_mem_clk_sel.u_mux.VPWR =USER_VDD1V8;
	force u_top.u_wb_host.u_mem_clk_sel.u_mux.VPB  =USER_VDD1V8;
	force u_top.u_wb_host.u_mem_clk_sel.u_mux.VGND =VSS;
	force u_top.u_wb_host.u_mem_clk_sel.u_mux.VNB = VSS;

	force u_top.u_mbist.u_mem_sel.u_mem_clk_a_sel.u_mux.VPWR =USER_VDD1V8;
	force u_top.u_mbist.u_mem_sel.u_mem_clk_a_sel.u_mux.VPB  =USER_VDD1V8;
	force u_top.u_mbist.u_mem_sel.u_mem_clk_a_sel.u_mux.VGND =VSS;
	force u_top.u_mbist.u_mem_sel.u_mem_clk_a_sel.u_mux.VNB = VSS;
	
	force u_top.u_mbist.u_mem_sel.u_mem_clk_b_sel.u_mux.VPWR =USER_VDD1V8;
	force u_top.u_mbist.u_mem_sel.u_mem_clk_b_sel.u_mux.VPB  =USER_VDD1V8;
	force u_top.u_mbist.u_mem_sel.u_mem_clk_b_sel.u_mux.VGND =VSS;
	force u_top.u_mbist.u_mem_sel.u_mem_clk_b_sel.u_mux.VNB = VSS;

	force u_top.u_mbist.u_mem_sel.u_cts_mem_clk_a.VPWR =USER_VDD1V8;
	force u_top.u_mbist.u_mem_sel.u_cts_mem_clk_a.VPB  =USER_VDD1V8;
	force u_top.u_mbist.u_mem_sel.u_cts_mem_clk_a.VGND =VSS;
	force u_top.u_mbist.u_mem_sel.u_cts_mem_clk_a.VNB = VSS;

	force u_top.u_mbist.u_mem_sel.u_cts_mem_clk_b.VPWR =USER_VDD1V8;
	force u_top.u_mbist.u_mem_sel.u_cts_mem_clk_b.VPB  =USER_VDD1V8;
	force u_top.u_mbist.u_mem_sel.u_cts_mem_clk_b.VGND =VSS;
	force u_top.u_mbist.u_mem_sel.u_cts_mem_clk_b.VNB = VSS;
    end
`endif    


//-------------------------------------
// Insert user defined number of fault 
// -----------------------------------

task insert_fault;
input [3:0]  num_fault;
input        fault_type; // 0 -> struck at 0 and 1 -> struck at 1
input [6:0]  mbist_signature;
reg [31:0] datain;
integer j;
begin
   repeat (2) @(posedge clock);
   // Remove the Bist Enable and Bist Run
   wb_user_core_write('h3080_0008,'h000);
   // Apply WB and BIST RESET
   wb_user_core_write('h3080_0004,'h000);
   // Set the Bist Enable and Bist Run
   wb_user_core_write('h3080_0008,'h003);
   // Remove WB and BIST RESET
   wb_user_core_write('h3080_0004,'h003);
   fork
   begin
      // Check for MBIST Done
      read_data = 'h0;
      while (read_data[0] != 1'b1) begin
         wb_user_core_read('h3080_000C,read_data);
      end
      // Check Is there is any BIST Error
      // [0]   - Bist Done      
      // [1]   - Bist Error     
      // [2]   - Bist Correct   
      // [6:3] - Bist Error Cnt 
      wb_user_core_read_check('h3080_000C,read_data,{25'h0,mbist_signature},32'h7F);
   end
   // Insert  Error Insertion
   begin
      while(1) begin
         repeat (1) @(posedge clock);
         #1;
         if(u_top.u_sram_2kb.web0 == 1'b0 && 
	   ((num_fault > 0 && u_top.u_sram_2kb.addr0 == faultaddr[0]) ||
	    (num_fault > 1 && u_top.u_sram_2kb.addr0 == faultaddr[1]) ||
	    (num_fault > 2 && u_top.u_sram_2kb.addr0 == faultaddr[2]) ||
	    (num_fault > 3 && u_top.u_sram_2kb.addr0 == faultaddr[3]) ||
	    (num_fault > 4 && u_top.u_sram_2kb.addr0 == faultaddr[4]) ||
	    (num_fault > 5 && u_top.u_sram_2kb.addr0 == faultaddr[5]) ||
	    (num_fault > 6 && u_top.u_sram_2kb.addr0 == faultaddr[6]) ||
	    (num_fault > 7 && u_top.u_sram_2kb.addr0 == faultaddr[7])))
             begin
	   if(fault_type == 0) // Struck at 0
	      force u_top.u_sram_2kb.din0 = u_top.mem_din_b  & 32'hFFFF_FFFE;
	   else
	      force u_top.u_sram_2kb.din0 = u_top.mem_din_b | 32'h1;
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

   if(num_fault == 1)
       wb_user_core_read_check('h3080_0014,read_data,{16'h0,7'h0,faultaddr[0]},32'h0000_FFFF);
   if(num_fault == 2)
       wb_user_core_read_check('h3080_0014,read_data,{7'h0,faultaddr[1],7'h0,faultaddr[0]},32'hFFFF_FFFF);
   if(num_fault == 3) begin
       wb_user_core_read_check('h3080_0014,read_data,{7'h0,faultaddr[1],7'h0,faultaddr[0]},32'hFFFF_FFFF);
       wb_user_core_read_check('h3080_0014,read_data,{16'h0,7'h0,faultaddr[2]},32'h0000_FFFF);
   end
   if(num_fault >= 4) begin
       wb_user_core_read_check('h3080_0014,read_data,{7'h0,faultaddr[1],7'h0,faultaddr[0]},32'hFFFF_FFFF);
       wb_user_core_read_check('h3080_0014,read_data,{7'h0,faultaddr[3],7'h0,faultaddr[2]},32'hFFFF_FFFF);
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
  //$display("STATUS: WB USER ACCESS WRITE Address : 0x%x, Data : 0x%x",address,data);
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
  #1;
  data  = wbd_ext_dat_o;  
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_cyc_i ='h0;  // strobe/request
  wbd_ext_stb_i ='h0;  // strobe/request
  wbd_ext_adr_i ='h0;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='h0;  // data output
  wbd_ext_sel_i ='h0;  // byte enable
  //$display("STATUS: WB USER ACCESS READ  Address : 0x%x, Data : 0x%x",address,data);
  repeat (2) @(posedge clock);
end
endtask

task  wb_user_core_read_check;
input [31:0] address;
output [31:0] data;
input [31:0] cmp_data;
input [31:0] cmp_mask;
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
  #1;
  data  = wbd_ext_dat_o;  
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_cyc_i ='h0;  // strobe/request
  wbd_ext_stb_i ='h0;  // strobe/request
  wbd_ext_adr_i ='h0;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='h0;  // data output
  wbd_ext_sel_i ='h0;  // byte enable
  if((data & cmp_mask) !== (cmp_data & cmp_mask) ) begin
     $display("ERROR : WB USER ACCESS READ  Address : 0x%x, Exd: 0x%x Rxd: 0x%x ",address,(cmp_data & cmp_mask),(data & cmp_mask));
     test_fail = 1;
  end else begin
     $display("STATUS: WB USER ACCESS READ  Address : 0x%x, Data : 0x%x",address,(data & cmp_mask));
  end
  repeat (2) @(posedge clock);
end
endtask


endmodule
`default_nettype wire
