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
////  Wishbone Interconnect                                       ////
////                                                              ////
////  This file is part of the mbist_ctrl cores project           ////
////  https://github.com/dineshannayya/mbist_ctrl.git             ////
////                                                              ////
////  Description                                                 ////
////	1. 1 masters and 5 slaves share bus Wishbone connection   ////
////     M0 - WB_PORT                                             ////
////     S0 - Glbl_Reg                                            ////
////     S1 - MBIST1                                              ////
////     S2 - MBIST2                                              ////
////     S3 - MBIST3                                              ////
////     S4 - MBIST4                                              ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
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



module wb_interconnect #(
	parameter SCW = 8,   // SCAN CHAIN WIDTH
	parameter CH_CLK_WD = 9,
	parameter CH_DATA_WD = 95
        ) (
`ifdef USE_POWER_PINS
         input logic            vccd1,    // User area 1 1.8V supply
         input logic            vssd1,    // User area 1 digital ground
`endif
         input logic             scan_en,
         input logic             scan_mode,
         input logic [SCW-1:0]   scan_si,
         output logic [SCW-1:0]  scan_so,
         output logic            scan_en_o,
         output logic            scan_mode_o,

         // Clock Skew Adjust
         input logic [3:0]      cfg_cska_wi,
         input logic            wbd_clk_int,
	 output logic           wbd_clk_wi,

	 // Bus repeaters
	 input [CH_CLK_WD-1:0]  ch_clk_in,
	 output [CH_CLK_WD-1:0] ch_clk_out,
	 input [CH_DATA_WD-1:0] ch_data_in,
	 output [CH_DATA_WD-1:0]ch_data_out,

         input logic		clk_i, 
         input logic            rst_n,
         
         // Master 0 Interface
         input   logic	[31:0]	m0_wbd_dat_i,
         input   logic  [31:0]	m0_wbd_adr_i,
         input   logic  [3:0]	m0_wbd_sel_i,
         input   logic  	m0_wbd_we_i,
         input   logic  	m0_wbd_cyc_i,
         input   logic  	m0_wbd_stb_i,
         output  logic	[31:0]	m0_wbd_dat_o,
         output  logic		m0_wbd_ack_o,
         output  logic		m0_wbd_err_o,
         
         
         // Slave 0 Interface
         input	logic [31:0]	s0_wbd_dat_i,
         input	logic 	        s0_wbd_ack_i,
         //input	logic 	s0_wbd_err_i, - unused
         output	logic [31:0]	s0_wbd_dat_o,
         output	logic [7:0]	s0_wbd_adr_o,
         output	logic [3:0]	s0_wbd_sel_o,
         output	logic 	        s0_wbd_we_o,
         output	logic 	        s0_wbd_cyc_o,
         output	logic 	        s0_wbd_stb_o,
         
         // Slave 1 Interface
         input	logic [31:0]	s1_wbd_dat_i,
         input	logic 	        s1_wbd_ack_i,
         // input	logic 	s1_wbd_err_i, - unused
         output	logic [31:0]	s1_wbd_dat_o,
         output	logic [10:0]	s1_wbd_adr_o,
         output	logic [3:0]	s1_wbd_sel_o,
         output	logic 	        s1_wbd_we_o,
         output	logic 	        s1_wbd_cyc_o,
         output	logic 	        s1_wbd_stb_o,
         
         // Slave 2 Interface
         input	logic [31:0]	s2_wbd_dat_i,
         input	logic 	        s2_wbd_ack_i,
         // input	logic 	s2_wbd_err_i, - unused
         output	logic [31:0]	s2_wbd_dat_o,
         output	logic [10:0]	s2_wbd_adr_o, // glbl reg need only 8 bits
         output	logic [3:0]	s2_wbd_sel_o,
         output	logic 	        s2_wbd_we_o,
         output	logic 	        s2_wbd_cyc_o,
         output	logic 	        s2_wbd_stb_o,

         // Slave 3 Interface
	 // Uart is 8bit interface 
         input	logic [31:0]	s3_wbd_dat_i,
         input	logic 	        s3_wbd_ack_i,
         // input	logic 	s3_wbd_err_i,
         output	logic [31:0]	s3_wbd_dat_o,
         output	logic [10:0]	s3_wbd_adr_o, 
         output	logic [3:0]   	s3_wbd_sel_o,
         output	logic 	        s3_wbd_we_o,
         output	logic 	        s3_wbd_cyc_o,
         output	logic 	        s3_wbd_stb_o,

         // Slave 4 Interface
         input	logic [31:0]	s4_wbd_dat_i,
         input	logic 	        s4_wbd_ack_i,
         // input	logic 	s4_wbd_err_i,
         output	logic [31:0]	s4_wbd_dat_o,
         output	logic [10:0]	s4_wbd_adr_o, 
         output	logic [3:0]   	s4_wbd_sel_o,
         output	logic 	        s4_wbd_we_o,
         output	logic 	        s4_wbd_cyc_o,
         output	logic 	        s4_wbd_stb_o,

         // Slave 5 Interface
         input	logic [31:0]	s5_wbd_dat_i,
         input	logic 	        s5_wbd_ack_i,
         // input	logic 	s5_wbd_err_i, - unused
         output	logic [31:0]	s5_wbd_dat_o,
         output	logic [9:0]	s5_wbd_adr_o,
         output	logic [3:0]	s5_wbd_sel_o,
         output	logic 	        s5_wbd_we_o,
         output	logic 	        s5_wbd_cyc_o,
         output	logic 	        s5_wbd_stb_o,
         
         // Slave 6 Interface
         input	logic [31:0]	s6_wbd_dat_i,
         input	logic 	        s6_wbd_ack_i,
         // input	logic 	s6_wbd_err_i, - unused
         output	logic [31:0]	s6_wbd_dat_o,
         output	logic [9:0]	s6_wbd_adr_o, // glbl reg need only 8 bits
         output	logic [3:0]	s6_wbd_sel_o,
         output	logic 	        s6_wbd_we_o,
         output	logic 	        s6_wbd_cyc_o,
         output	logic 	        s6_wbd_stb_o,

         // Slave 7 Interface
	 // Uart is 8bit interface 
         input	logic [31:0]	s7_wbd_dat_i,
         input	logic 	        s7_wbd_ack_i,
         // input	logic 	s7_wbd_err_i,
         output	logic [31:0]	s7_wbd_dat_o,
         output	logic [9:0]	s7_wbd_adr_o, 
         output	logic [3:0]   	s7_wbd_sel_o,
         output	logic 	        s7_wbd_we_o,
         output	logic 	        s7_wbd_cyc_o,
         output	logic 	        s7_wbd_stb_o,

         // Slave 8 Interface
         input	logic [31:0]	s8_wbd_dat_i,
         input	logic 	        s8_wbd_ack_i,
         // input	logic 	s8_wbd_err_i,
         output	logic [31:0]	s8_wbd_dat_o,
         output	logic [9:0]	s8_wbd_adr_o, 
         output	logic [3:0]   	s8_wbd_sel_o,
         output	logic 	        s8_wbd_we_o,
         output	logic 	        s8_wbd_cyc_o,
         output	logic 	        s8_wbd_stb_o
	);

////////////////////////////////////////////////////////////////////
//
// Type define
//


// WishBone Wr Interface
typedef struct packed { 
  logic	[31:0]	wbd_dat;
  logic  [31:0]	wbd_adr;
  logic  [3:0]	wbd_sel;
  logic  	wbd_we;
  logic  	wbd_cyc;
  logic  	wbd_stb;
  logic [3:0] 	wbd_tid; // target id
} type_wb_wr_intf;

// WishBone Rd Interface
typedef struct packed { 
  logic	[31:0]	wbd_dat;
  logic  	wbd_ack;
  logic  	wbd_err;
} type_wb_rd_intf;


// Master Write Interface
type_wb_wr_intf  m0_wb_wr;

// Master Read Interface
type_wb_rd_intf  m0_wb_rd;

// Slave Write Interface
type_wb_wr_intf  s0_wb_wr;
type_wb_wr_intf  s1_wb_wr;
type_wb_wr_intf  s2_wb_wr;
type_wb_wr_intf  s3_wb_wr;
type_wb_wr_intf  s4_wb_wr;
type_wb_wr_intf  s5_wb_wr;
type_wb_wr_intf  s6_wb_wr;
type_wb_wr_intf  s7_wb_wr;
type_wb_wr_intf  s8_wb_wr;

// Slave Read Interface
type_wb_rd_intf  s0_wb_rd;
type_wb_rd_intf  s1_wb_rd;
type_wb_rd_intf  s2_wb_rd;
type_wb_rd_intf  s3_wb_rd;
type_wb_rd_intf  s4_wb_rd;
type_wb_rd_intf  s5_wb_rd;
type_wb_rd_intf  s6_wb_rd;
type_wb_rd_intf  s7_wb_rd;
type_wb_rd_intf  s8_wb_rd;


type_wb_wr_intf  m_bus_wr;  // Multiplexed Master I/F
type_wb_rd_intf  m_bus_rd;  // Multiplexed Slave I/F

type_wb_wr_intf  s_bus_wr;  // Multiplexed Master I/F
type_wb_rd_intf  s_bus_rd;  // Multiplexed Slave I/F

// channel repeater
assign ch_clk_out  = ch_clk_in;
assign ch_data_out = ch_data_in;

assign scan_en_o = scan_en;
assign scan_mode_o = scan_mode;

// Wishbone interconnect clock skew control
clk_skew_adjust u_skew_wi
       (
`ifdef USE_POWER_PINS
               .vccd1      (vccd1                      ),// User area 1 1.8V supply
               .vssd1      (vssd1                      ),// User area 1 digital ground
`endif
	       .clk_in     (wbd_clk_int                 ), 
	       .sel        (cfg_cska_wi                 ), 
	       .clk_out    (wbd_clk_wi                  ) 
       );

//-------------------------------------------------------------------
// EXTERNAL MEMORY MAP
// 0x0000_0000 to 0x0000_0FFF  - GLBL
// 0x0000_1000 to 0x0000_1FFF  - MBIST1
// 0x0000_2000 to 0x0000_2FFF  - MBIST2
// 0x0000_3000 to 0x0000_3FFF  - MBIST3
// 0x0000_4000 to 0x0000_4FFF  - MBIST4
// 0x0000_5000 to 0x0000_5FFF  - MBIST5
// 0x0000_6000 to 0x0000_6FFF  - MBIST6
// 0x0000_7000 to 0x0000_7FFF  - MBIST7
// 0x0000_8000 to 0x0000_8FFF  - MBIST8
// ---------------------------------------------------------------------------
//
wire [3:0] m0_wbd_tid_i       = (m0_wbd_adr_i[15:12] == 4'b0000  ) ? 4'b0000 :   // GLBL
                                (m0_wbd_adr_i[15:12] == 4'b0001  ) ? 4'b0001 :   // MBIST1
                                (m0_wbd_adr_i[15:12] == 4'b0010  ) ? 4'b0010 :   // MBIST2
                                (m0_wbd_adr_i[15:12] == 4'b0011  ) ? 4'b0011 :   // MBIST3
                                (m0_wbd_adr_i[15:12] == 4'b0100  ) ? 4'b0100 :   // MBIST4
                                (m0_wbd_adr_i[15:12] == 4'b0101  ) ? 4'b0101 :   // MBIST5
                                (m0_wbd_adr_i[15:12] == 4'b0110  ) ? 4'b0110 :   // MBIST6
                                (m0_wbd_adr_i[15:12] == 4'b0111  ) ? 4'b0111 :   // MBIST7
                                (m0_wbd_adr_i[15:12] == 4'b1000  ) ? 4'b1000 :   // MBIST8
				4'b0000; 

//----------------------------------------
// Master Mapping
// -------------------------------------
assign m0_wb_wr.wbd_dat = m0_wbd_dat_i;
assign m0_wb_wr.wbd_adr = {m0_wbd_adr_i[31:2],2'b00};
assign m0_wb_wr.wbd_sel = m0_wbd_sel_i;
assign m0_wb_wr.wbd_we  = m0_wbd_we_i;
assign m0_wb_wr.wbd_cyc = m0_wbd_cyc_i;
assign m0_wb_wr.wbd_stb = m0_wbd_stb_i;
assign m0_wb_wr.wbd_tid = m0_wbd_tid_i;

assign m0_wbd_dat_o  =  m0_wb_rd.wbd_dat;
assign m0_wbd_ack_o  =  m0_wb_rd.wbd_ack;
assign m0_wbd_err_o  =  m0_wb_rd.wbd_err;


//----------------------------------------
// Slave Mapping
// -------------------------------------
// Masked Now and added stagging FF now
 assign  s0_wbd_dat_o =  s0_wb_wr.wbd_dat ;
 assign  s0_wbd_adr_o =  s0_wb_wr.wbd_adr[7:0] ;
 assign  s0_wbd_sel_o =  s0_wb_wr.wbd_sel ;
 assign  s0_wbd_we_o  =  s0_wb_wr.wbd_we  ;
 assign  s0_wbd_cyc_o =  s0_wb_wr.wbd_cyc ;
 assign  s0_wbd_stb_o =  s0_wb_wr.wbd_stb ;
         
// 2KB SRAM 
 assign  s1_wbd_dat_o =  s1_wb_wr.wbd_dat ;
 assign  s1_wbd_adr_o =  s1_wb_wr.wbd_adr[10:0] ;
 assign  s1_wbd_sel_o =  s1_wb_wr.wbd_sel ;
 assign  s1_wbd_we_o  =  s1_wb_wr.wbd_we  ;
 assign  s1_wbd_cyc_o =  s1_wb_wr.wbd_cyc ;
 assign  s1_wbd_stb_o =  s1_wb_wr.wbd_stb ;
                      
 assign  s2_wbd_dat_o =  s2_wb_wr.wbd_dat ;
 assign  s2_wbd_adr_o =  s2_wb_wr.wbd_adr[10:0] ; // Global Reg Need 8 bit
 assign  s2_wbd_sel_o =  s2_wb_wr.wbd_sel ;
 assign  s2_wbd_we_o  =  s2_wb_wr.wbd_we  ;
 assign  s2_wbd_cyc_o =  s2_wb_wr.wbd_cyc ;
 assign  s2_wbd_stb_o =  s2_wb_wr.wbd_stb ;

 assign  s3_wbd_dat_o =  s3_wb_wr.wbd_dat;
 assign  s3_wbd_adr_o =  s3_wb_wr.wbd_adr[10:0] ; // Global Reg Need 8 bit
 assign  s3_wbd_sel_o =  s3_wb_wr.wbd_sel;
 assign  s3_wbd_we_o  =  s3_wb_wr.wbd_we  ;
 assign  s3_wbd_cyc_o =  s3_wb_wr.wbd_cyc ;
 assign  s3_wbd_stb_o =  s3_wb_wr.wbd_stb ;
 
 assign  s4_wbd_dat_o =  s4_wb_wr.wbd_dat ;
 assign  s4_wbd_adr_o =  s4_wb_wr.wbd_adr[10:0] ; // Global Reg Need 8 bit
 assign  s4_wbd_sel_o =  s4_wb_wr.wbd_sel ;
 assign  s4_wbd_we_o  =  s4_wb_wr.wbd_we  ;
 assign  s4_wbd_cyc_o =  s4_wb_wr.wbd_cyc ;
 assign  s4_wbd_stb_o =  s4_wb_wr.wbd_stb ;

// 1KB SRAM 
 assign  s5_wbd_dat_o =  s5_wb_wr.wbd_dat ;
 assign  s5_wbd_adr_o =  s5_wb_wr.wbd_adr[9:0] ;
 assign  s5_wbd_sel_o =  s5_wb_wr.wbd_sel ;
 assign  s5_wbd_we_o  =  s5_wb_wr.wbd_we  ;
 assign  s5_wbd_cyc_o =  s5_wb_wr.wbd_cyc ;
 assign  s5_wbd_stb_o =  s5_wb_wr.wbd_stb ;
                      
 assign  s6_wbd_dat_o =  s6_wb_wr.wbd_dat ;
 assign  s6_wbd_adr_o =  s6_wb_wr.wbd_adr[9:0] ; // Global Reg Need 8 bit
 assign  s6_wbd_sel_o =  s6_wb_wr.wbd_sel ;
 assign  s6_wbd_we_o  =  s6_wb_wr.wbd_we  ;
 assign  s6_wbd_cyc_o =  s6_wb_wr.wbd_cyc ;
 assign  s6_wbd_stb_o =  s6_wb_wr.wbd_stb ;

 assign  s7_wbd_dat_o =  s7_wb_wr.wbd_dat;
 assign  s7_wbd_adr_o =  s7_wb_wr.wbd_adr[9:0] ; // Global Reg Need 8 bit
 assign  s7_wbd_sel_o =  s7_wb_wr.wbd_sel;
 assign  s7_wbd_we_o  =  s7_wb_wr.wbd_we  ;
 assign  s7_wbd_cyc_o =  s7_wb_wr.wbd_cyc ;
 assign  s7_wbd_stb_o =  s7_wb_wr.wbd_stb ;
 
 assign  s8_wbd_dat_o =  s8_wb_wr.wbd_dat ;
 assign  s8_wbd_adr_o =  s8_wb_wr.wbd_adr[9:0] ; // Global Reg Need 8 bit
 assign  s8_wbd_sel_o =  s8_wb_wr.wbd_sel ;
 assign  s8_wbd_we_o  =  s8_wb_wr.wbd_we  ;
 assign  s8_wbd_cyc_o =  s8_wb_wr.wbd_cyc ;
 assign  s8_wbd_stb_o =  s8_wb_wr.wbd_stb ;
 
 assign s0_wb_rd.wbd_dat  = s0_wbd_dat_i ;
 assign s0_wb_rd.wbd_ack  = s0_wbd_ack_i ;
 assign s0_wb_rd.wbd_err  = 1'b0; // s0_wbd_err_i ; - unused
 
 assign s1_wb_rd.wbd_dat  = s1_wbd_dat_i ;
 assign s1_wb_rd.wbd_ack  = s1_wbd_ack_i ;
 assign s1_wb_rd.wbd_err  = 1'b0; // s1_wbd_err_i ; - unused
 
 assign s2_wb_rd.wbd_dat  = s2_wbd_dat_i ;
 assign s2_wb_rd.wbd_ack  = s2_wbd_ack_i ;
 assign s2_wb_rd.wbd_err  = 1'b0; // s2_wbd_err_i ; - unused

 assign s3_wb_rd.wbd_dat  = s3_wbd_dat_i ;
 assign s3_wb_rd.wbd_ack  = s3_wbd_ack_i ;
 assign s3_wb_rd.wbd_err  = 1'b0; // s3_wbd_err_i ; - unused

 assign s4_wb_rd.wbd_dat  = s4_wbd_dat_i ;
 assign s4_wb_rd.wbd_ack  = s4_wbd_ack_i ;
 assign s4_wb_rd.wbd_err  = 1'b0; // s4_wbd_err_i ; - unused
 
 assign s5_wb_rd.wbd_dat  = s5_wbd_dat_i ;
 assign s5_wb_rd.wbd_ack  = s5_wbd_ack_i ;
 assign s5_wb_rd.wbd_err  = 1'b0; // s5_wbd_err_i ; - unused
 
 assign s6_wb_rd.wbd_dat  = s6_wbd_dat_i ;
 assign s6_wb_rd.wbd_ack  = s6_wbd_ack_i ;
 assign s6_wb_rd.wbd_err  = 1'b0; // s6_wbd_err_i ; - unused

 assign s7_wb_rd.wbd_dat  = s7_wbd_dat_i ;
 assign s7_wb_rd.wbd_ack  = s7_wbd_ack_i ;
 assign s7_wb_rd.wbd_err  = 1'b0; // s7_wbd_err_i ; - unused

 assign s8_wb_rd.wbd_dat  = s8_wbd_dat_i ;
 assign s8_wb_rd.wbd_ack  = s8_wbd_ack_i ;
 assign s8_wb_rd.wbd_err  = 1'b0; // s8_wbd_err_i ; - unused
//
// arbitor removed as only one master
//
wire [1:0]  gnt = 2'b0;;


// Generate Multiplexed Master Interface based on grant
always_comb begin
     case(gnt)
        2'h0:	   m_bus_wr = m0_wb_wr;
        default:   m_bus_wr = m0_wb_wr;
     endcase			
end


// Generate Multiplexed Slave Interface based on target Id
wire [3:0] s_wbd_tid =  s_bus_wr.wbd_tid; // to fix iverilog warning
always_comb begin
     case(s_wbd_tid)
        4'h0:	   s_bus_rd = s0_wb_rd;
        4'h1:	   s_bus_rd = s1_wb_rd;
        4'h2:	   s_bus_rd = s2_wb_rd;
        4'h3:	   s_bus_rd = s3_wb_rd;
        4'h4:	   s_bus_rd = s4_wb_rd;
        4'h5:	   s_bus_rd = s5_wb_rd;
        4'h6:	   s_bus_rd = s6_wb_rd;
        4'h7:	   s_bus_rd = s7_wb_rd;
        4'h8:	   s_bus_rd = s8_wb_rd;
        default:   s_bus_rd = s0_wb_rd;
     endcase			
end


// Connect Master => Slave
assign  s0_wb_wr = (s_wbd_tid == 4'b0000) ? s_bus_wr : 'h0;
assign  s1_wb_wr = (s_wbd_tid == 4'b0001) ? s_bus_wr : 'h0;
assign  s2_wb_wr = (s_wbd_tid == 4'b0010) ? s_bus_wr : 'h0;
assign  s3_wb_wr = (s_wbd_tid == 4'b0011) ? s_bus_wr : 'h0;
assign  s4_wb_wr = (s_wbd_tid == 4'b0100) ? s_bus_wr : 'h0;
assign  s5_wb_wr = (s_wbd_tid == 4'b0101) ? s_bus_wr : 'h0;
assign  s6_wb_wr = (s_wbd_tid == 4'b0110) ? s_bus_wr : 'h0;
assign  s7_wb_wr = (s_wbd_tid == 4'b0111) ? s_bus_wr : 'h0;
assign  s8_wb_wr = (s_wbd_tid == 4'b1000) ? s_bus_wr : 'h0;

// Connect Slave to Master
assign  m0_wb_rd = (gnt == 2'b00) ? m_bus_rd : 'h0;


// Stagging FF to break write and read timing path
wb_stagging u_m_wb_stage(
         .clk_i            (clk_i              ), 
         .rst_n            (rst_n              ),
         // WishBone Input master I/P
         .m_wbd_dat_i      (m_bus_wr.wbd_dat   ),
         .m_wbd_adr_i      (m_bus_wr.wbd_adr   ),
         .m_wbd_sel_i      (m_bus_wr.wbd_sel   ),
         .m_wbd_we_i       (m_bus_wr.wbd_we    ),
         .m_wbd_cyc_i      (m_bus_wr.wbd_cyc   ),
         .m_wbd_stb_i      (m_bus_wr.wbd_stb   ),
         .m_wbd_tid_i      (m_bus_wr.wbd_tid   ),
         .m_wbd_dat_o      (m_bus_rd.wbd_dat   ),
         .m_wbd_ack_o      (m_bus_rd.wbd_ack   ),
         .m_wbd_err_o      (m_bus_rd.wbd_err   ),

         // Slave Interface
         .s_wbd_dat_i      (s_bus_rd.wbd_dat   ),
         .s_wbd_ack_i      (s_bus_rd.wbd_ack   ),
         .s_wbd_err_i      (s_bus_rd.wbd_err   ),
         .s_wbd_dat_o      (s_bus_wr.wbd_dat    ),
         .s_wbd_adr_o      (s_bus_wr.wbd_adr    ),
         .s_wbd_sel_o      (s_bus_wr.wbd_sel    ),
         .s_wbd_we_o       (s_bus_wr.wbd_we     ),
         .s_wbd_cyc_o      (s_bus_wr.wbd_cyc    ),
         .s_wbd_stb_o      (s_bus_wr.wbd_stb    ),
         .s_wbd_tid_o      (s_bus_wr.wbd_tid    )

);


endmodule

