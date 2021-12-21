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
////  LBIST CORE                                                  ////
////                                                              ////
////  This file is part of the logic_bist  project                ////
////  https://github.com/dineshannayya/logic_bist.git             ////
////                                                              ////
////  Description                                                 ////
////      This block manages all the lbist sequence               ////
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

module lbist_core 
   #(parameter SCW = 8   // SCAN CHAIN WIDTH
     ) 
    
    (

	input logic            mclk,
	input logic            mclk_skew,
	input logic            rst_n,
	input logic            srst, // software reset


        // Reg Bus Interface Signal
        input logic           lbist_start,   // lbist start
	input logic  [15:0]   cfg_lbist_pat, // Total Scan pattern to be run
	input logic  [15:0]   cfg_chain_depth, // Scan Chain Depth
	input logic           cfg_lbist_rsb, // Option to bypass First scan shift compare
	output logic          lbist_done,    // End of Ltest 
	output logic [31:0]   lbist_sig,     // scan signature


	// Scan Control Signal
	output logic           scan_clk,
	output logic           scan_rst_n,
	output logic           scan_mode,
	output logic           scan_en,
	output logic [SCW-1:0] scan_in,
	input  logic [SCW-1:0] scan_out

);

// FSM STATE

parameter   FSM_IDLE              = 4'b0000;
parameter   FSM_RESET_WAIT        = 4'b0001;
parameter   FSM_IDLE_WAIT         = 4'b0010;
parameter   FSM_ASSERT_SCAN_EN    = 4'b0011;
parameter   FSM_SCAN_SHIFT        = 4'b0100;
parameter   FSM_DEASSERT_SCAN_EN  = 4'b0101;
parameter   FSM_DEASSERT_SCAN_CLK = 4'b0110;
parameter   FSM_SCAN_CAPTURE      = 4'b0111;

//   Scan Sequence
// 1. scan_reset_n = 0, scan_clk_enb = 0, scan_en = 0, Wait 4 Cycle
// 2. scan_reset_n = 1, scan_clk_enb = 0, scan_en = 0, Wait 4 Cycle
// 3. scan_en = 1, Wait 4 Cycle
// 4. scan_clk_enb = 1 , Wait for Scan Depth, If Total Pattern over, Then Exit
// 5. scan_clk_enb = 0, scan_en = 0, Wait for 4 Cycle
// 6. scan_clk_en  = 1 , Wait for 1 Cycle
// 7. scan_clk_en  = 0  Go to #3

logic [3:0] state, next_state;
logic       next_scan_en;
logic       scan_clk_enb,next_scan_clk_enb;
logic [15:0]clk_cnt, next_clk_cnt;
logic       next_scan_rst_n;
logic [15:0]scan_pat_cnt,next_scan_pat_cnt;
logic       next_lbist_done;
logic       lbist_start_d;
logic       next_scan_mode;
logic       r_sshift_done; // Indicate Reset Scan shift done, This is first pattern 

always_ff @(negedge rst_n or posedge mclk_skew)
begin
   if(rst_n == 1'b0) begin
      state        <= FSM_IDLE;
      scan_en      <= '0;
      scan_clk_enb <= '0;
      clk_cnt      <= '0;
      scan_rst_n   <= '1;
      scan_pat_cnt <= '0;
      lbist_done   <= '0;
      lbist_start_d <= 0;
      scan_mode     <= 0;
      r_sshift_done <= 0;
   end else if(srst) begin
      state        <= FSM_IDLE;
      scan_en      <= '0;
      scan_clk_enb <= '0;
      clk_cnt      <= '0;
      scan_rst_n   <= '1;
      scan_pat_cnt <= '0;
      lbist_done   <= '0;
      lbist_start_d <= 0;
      scan_mode     <= 0;
      r_sshift_done <= 0;
   end else begin
      state        <= next_state;
      scan_en      <= next_scan_en;
      scan_clk_enb <= next_scan_clk_enb;
      clk_cnt      <= next_clk_cnt;
      scan_rst_n   <= next_scan_rst_n;
      scan_pat_cnt <= next_scan_pat_cnt;
      lbist_done   <= next_lbist_done;
      lbist_start_d <= lbist_start;
      scan_mode     <= next_scan_mode;
      // After first scan capture, set reset scan shift done indication
      if(state == FSM_SCAN_CAPTURE)
	r_sshift_done <= 1;

   end
end


wire lbist_pos_edge = (lbist_start_d ==0) && (lbist_start == 1);

always_comb begin
    next_state        = state;
    next_scan_en      = scan_en;
    next_scan_clk_enb = scan_clk_enb;
    next_clk_cnt      = clk_cnt;
    next_scan_rst_n   = scan_rst_n;
    next_scan_pat_cnt = scan_pat_cnt;
    next_lbist_done   = lbist_done;
    next_scan_mode    = scan_mode;
    case(state)
    FSM_IDLE:  
	    if(lbist_pos_edge) begin
	      next_lbist_done = 0;
              next_scan_pat_cnt = cfg_lbist_pat;  
	      next_scan_mode    = 1;
	      next_scan_rst_n   = 0;
	      next_scan_en      = 0;
	      next_scan_clk_enb = 0;
              next_clk_cnt      = 4;
	      next_state        = FSM_RESET_WAIT;
	   end
    FSM_RESET_WAIT: 
	    if(clk_cnt == 0) begin
	       next_scan_rst_n = 1;
	       next_scan_en    = 0;
               next_clk_cnt    = 4;
	       next_state      = FSM_IDLE_WAIT;
            end else begin
	       next_clk_cnt = next_clk_cnt - 1;
	    end
    FSM_IDLE_WAIT: 
	    if(clk_cnt == 0) begin
	       next_scan_en    = 1;
               next_clk_cnt    = 4;
	       next_state      = FSM_ASSERT_SCAN_EN;
            end else begin
	       next_clk_cnt = next_clk_cnt - 1;
	    end
    FSM_ASSERT_SCAN_EN: 
	    if(clk_cnt == 0) begin
	       next_scan_clk_enb  = 1;
               next_clk_cnt       = cfg_chain_depth;
	       next_state         = FSM_SCAN_SHIFT;
            end else begin
	       next_clk_cnt = next_clk_cnt - 1;
	    end
    FSM_SCAN_SHIFT:
	    if(clk_cnt == 0) begin
	       if(scan_pat_cnt == 0) begin
		  next_lbist_done  = 1;
	          next_scan_mode   = 0;
	          next_state       = FSM_IDLE ;
	       end else begin
                  next_scan_pat_cnt= next_scan_pat_cnt-1;
	          next_scan_clk_enb= 0;
                  next_clk_cnt     = 1;
	          next_state       = FSM_DEASSERT_SCAN_EN;
               end
            end else begin
	       next_clk_cnt = next_clk_cnt - 1;
	    end
   FSM_DEASSERT_SCAN_EN:
	    if(clk_cnt == 0) begin
	       next_scan_en     = 0;
               next_clk_cnt     = 4;
	       next_state       = FSM_DEASSERT_SCAN_CLK;
            end else begin
	       next_clk_cnt = next_clk_cnt - 1;
	    end
   FSM_DEASSERT_SCAN_CLK:
	    if(clk_cnt == 0) begin
	       next_scan_clk_enb= 1;
	       next_scan_en     = 0;
               next_clk_cnt     = 0;
	       next_state       = FSM_SCAN_CAPTURE;
            end else begin
	       next_clk_cnt = next_clk_cnt - 1;
	    end
   FSM_SCAN_CAPTURE: begin
	       next_scan_clk_enb= 0;
	       next_scan_en     = 0;
               next_clk_cnt     = 4;
	       next_state       = FSM_IDLE_WAIT;
	    end
  endcase

end


//--------------------------------
// Scan clock generation 
//--------------------------------
clk_gate u_scan_gate (

	.GCLK    (scan_clk), 
	.TE      (1'b0),
	.EN      (scan_clk_enb), 
	.CLK     (mclk)
       );



//--------------------------------
// Scan Pattern Generation
//--------------------------------
logic [31:0] tx_crc_out;

assign  scan_in = (clk_cnt[1:0] == 2'b00) ? tx_crc_out[7:0]   :
	          (clk_cnt[1:0] == 2'b01) ? tx_crc_out[15:8]  :
		  (clk_cnt[1:0] == 2'b10) ? tx_crc_out[23:16] : tx_crc_out[31:24];


// Run CRC at SCAN SHIFT PHASE at every once in 4 cycles
wire crc_tx_run   = (state == FSM_SCAN_SHIFT) & (clk_cnt[1:0] == 2'b11);
wire crc_rx_run   = (cfg_lbist_rsb) ?  r_sshift_done & (state == FSM_SCAN_SHIFT) & (clk_cnt[1:0] == 2'b11):
	               (state == FSM_SCAN_SHIFT) & (clk_cnt[1:0] == 2'b11);
wire crc_clear = lbist_pos_edge;

crc_32 u_tx_crc(
	      // List of outputs.
       .crc_out  (tx_crc_out),
	      
       // List of inputs
       .run      (crc_tx_run),   // when asserted, crc is generated
       .clear    (crc_clear), // When asserted crc is re-initialized
       .data_in  (8'h0),
       .mclk     (mclk_skew),
       .reset_n (rst_n)
                );

crc_32 u_rx_crc(
	      // List of outputs.
       .crc_out  (lbist_sig),
	      
       // List of inputs
       .run      (crc_rx_run),   // when asserted, crc is generated
       .clear    (crc_clear), // When asserted crc is re-initialized
       .data_in  (scan_out),
       .mclk     (mclk_skew),
       .reset_n (rst_n)
                );

endmodule
