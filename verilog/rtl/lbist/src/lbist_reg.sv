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
////  Logic Bist register                                         ////
////                                                              ////
////  This file is part of the logic bist project                 ////
////  https://github.com/dineshannayya/logic_bist.git             ////
////                                                              ////
////  Description                                                 ////
////      This block manges all the LBIST Register and Status     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 29 Nov 2021  Dinesh A                               ////
////          Initial version                                     ////
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

module lbist_reg (

       input logic             mclk,
       input logic             reset_n,


        // Reg Bus Interface Signal
        input logic             reg_cs,
        input logic             reg_wr,
        input logic [1:0]       reg_addr,
        input logic [31:0]      reg_wdata,
        input logic [3:0]       reg_be,

       // Outputs
        output logic [31:0]     reg_rdata,
        output logic            reg_ack,

	// BIST I/F
	output logic            cfg_lbist_rst,
	output logic            cfg_lbist_start,  // lbist start
	output logic            cfg_lbist_rsb,    // lbist reset scan compare bypass
	output logic [15:0]     cfg_lbist_pat,    // Total Scan pattern to be run
	output logic [15:0]     cfg_chain_depth,    // Scan Chain Depth


	input  logic            lbist_done,
	input  logic [31:0]     lbist_sig


        );



//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------

logic           sw_rd_en    ;
logic           sw_wr_en    ;
logic  [1:0]    sw_addr     ; // addressing 16 registers
logic  [3:0]    wr_be       ;
logic  [31:0]   sw_reg_wdata;



logic [31:0]    reg_0;       // Reg 0
logic [31:0]    reg_1;       // Reg 1

logic [31:0]    reg_out;

//-----------------------------------------------------------------------
// Main code starts here
//-----------------------------------------------------------------------


//-----------------------------------------------------------------------
// register read enable and write enable decoding logic
//-----------------------------------------------------------------------

assign       sw_addr       = reg_addr [1:0];
assign       sw_rd_en      = reg_cs & !reg_wr;
assign       sw_wr_en      = reg_cs & reg_wr;
assign       wr_be         = reg_be;
assign       sw_reg_wdata  = reg_wdata;


wire   sw_wr_en_0 = sw_wr_en & (sw_addr == 2'h0);
wire   sw_rd_en_0 = sw_rd_en & (sw_addr == 2'h0);
wire   sw_wr_en_1 = sw_wr_en & (sw_addr == 2'h1);
wire   sw_rd_en_1 = sw_rd_en & (sw_addr == 2'h1);
wire   sw_wr_en_2 = sw_wr_en & (sw_addr == 2'h2);
wire   sw_rd_en_2 = sw_rd_en & (sw_addr == 2'h2);
wire   sw_wr_en_3 = sw_wr_en & (sw_addr == 2'h3);
wire   sw_rd_en_3 = sw_rd_en & (sw_addr == 2'h3);

logic wb_req;

always_ff @(negedge reset_n or posedge mclk) begin
    if ( reset_n == 1'b0 ) begin
        wb_req    <= '0;
   end else begin
       wb_req   <= reg_cs && (reg_ack == 0) ;
   end
end


always @ (posedge mclk or negedge reset_n)
begin : preg_out_Seq
   if (reset_n == 1'b0) begin
      reg_rdata  <= 'h0;
      reg_ack    <= 1'b0;
   end else if (reg_cs && !reg_ack) begin
      reg_rdata <= reg_out ;
      reg_ack   <= 1'b1;
   end else begin
      reg_ack   <= 1'b0;
   end
end

always @( *)
begin 
  reg_out [31:0] = 32'h0;

  case (sw_addr [1:0])
    2'b00 :   reg_out [31:0] = reg_0;
    2'b01 :   reg_out [31:0] = reg_1;
    2'b10 :   reg_out [31:0] = lbist_sig;
    default : reg_out [31:0] = 'h0;
  endcase
end


//-----------------------------------------------------------------------
// Individual register assignments
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//   reg-0
//   -----------------------------------------------------------------
generic_register #(8,8'h0  ) u_reg0_be0 (
	      .we            ({8{sw_wr_en_0 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[7:0]        )
          );


assign cfg_lbist_rst    = reg_0[0];
assign cfg_lbist_start  = reg_0[1];
assign cfg_lbist_rsb  = reg_0[2];
assign reg_0[31:8]     = {lbist_done,23'b0};

//--------------------------------------------
// Reg-1
// ------------------------------------------

assign cfg_chain_depth  = reg_1[15:0];
assign cfg_lbist_pat    = reg_1[31:16];

gen_32b_reg  #(32'h4C66_8354) u_reg_1	(
	      //List of Inputs
	      .reset_n    (reset_n       ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_1    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_1       )
	      );
endmodule
