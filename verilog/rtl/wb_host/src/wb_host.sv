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
////  Wishbone host Interface                                     ////
////                                                              ////
////  This file is part of the mbist_ctrl  project                ////
////  https://github.com/dineshannayya/mbist_ctrl.git             ////
////                                                              ////
////  Description                                                 ////
////      This block does async Wishbone from one clock to other  ////
////      clock domain                                            ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 25th Feb 2021, Dinesh A                             ////
////          initial version                                     ////
////    0.2 - 14th Nov 2021, Dinesh A                             ////
////          reset_n connectivity fix for bist and memclock      ////
////    0.1 - Nov 16 2021, Dinesh A                               ////
////          Wishbone out are register for better timing         //// 
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

module wb_host (

`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
       input logic                 user_clock1      ,
       input logic                 user_clock2      ,
       output logic [2:0]          user_irq         ,

       output logic                wbd_int_rst_n    ,
       output logic                bist_rst_n       ,

    // Master Port
       input   logic               wbm_rst_i        ,  // Regular Reset signal
       input   logic               wbm_clk_i        ,  // System clock
       input   logic               wbm_cyc_i        ,  // strobe/request
       input   logic               wbm_stb_i        ,  // strobe/request
       input   logic [31:0]        wbm_adr_i        ,  // address
       input   logic               wbm_we_i         ,  // write
       input   logic [31:0]        wbm_dat_i        ,  // data output
       input   logic [3:0]         wbm_sel_i        ,  // byte enable
       output  logic [31:0]        wbm_dat_o        ,  // data input
       output  logic               wbm_ack_o        ,  // acknowlegement
       output  logic               wbm_err_o        ,  // error

    // Clock Skew Adjust
       input   logic               wbd_clk_int      , 
       output  logic               wbd_clk_wh       ,
       input   logic [3:0]         cfg_cska_wh      , // clock skew adjust for web host

    // Slave Port
       output  logic               wbs_clk_out      ,  // System clock
       input   logic               wbs_clk_i        ,  // System clock
       output  logic               wbs_cyc_o        ,  // strobe/request
       output  logic               wbs_stb_o        ,  // strobe/request
       output  logic [31:0]        wbs_adr_o        ,  // address
       output  logic               wbs_we_o         ,  // write
       output  logic [31:0]        wbs_dat_o        ,  // data output
       output  logic [3:0]         wbs_sel_o        ,  // byte enable
       input   logic [31:0]        wbs_dat_i        ,  // data input
       input   logic               wbs_ack_i        ,  // acknowlegement
       input   logic               wbs_err_i        ,  // error

       output logic [31:0]         cfg_clk_ctrl1    ,
       output logic [31:0]         cfg_clk_ctrl2    ,
	// MBIST I/F


	output   logic  [37:0]      io_out,
	output   logic  [37:0]      io_oeb,
        output   logic  [127:0]     la_data_out

    );


//--------------------------------
// local  dec
//
//--------------------------------
logic               wbm_rst_n;
logic               wbs_rst_n;
logic [31:0]        wbm_dat_int; // data input
logic               wbm_ack_int; // acknowlegement
logic               wbm_err_int; // error

logic               reg_sel    ;
logic [1:0]         sw_addr    ;
logic               sw_rd_en   ;
logic               sw_wr_en   ;
logic [31:0]        reg_rdata  ;
logic [31:0]        reg_out    ;
logic               reg_ack    ;
logic               sw_wr_en_0;
logic               sw_wr_en_1;
logic               sw_wr_en_2;
logic               sw_wr_en_3;
logic               sw_wr_en_4;
logic               sw_rd_en_5;
logic [7:0]         cfg_bank_sel;
logic [31:0]        wbm_adr_int;
logic               wbm_stb_int;
logic [31:0]        reg_0;  // Software_Reg_0
logic [31:0]        reg_1;  // Software_Reg_0

logic  [3:0]        cfg_wb_clk_ctrl;
logic  [7:0]        cfg_glb_ctrl;

assign io_out = 'h0;
assign io_oeb  = 'h0;
assign la_data_out = 'h0;

assign user_irq  = 'h0;
assign wbm_rst_n = !wbm_rst_i;
assign wbs_rst_n = !wbm_rst_i;

sky130_fd_sc_hd__bufbuf_16 u_buf_wb_rst     (.A(cfg_glb_ctrl[0]),.X(wbd_int_rst_n));
sky130_fd_sc_hd__bufbuf_16 u_buf_bist_rst   (.A(cfg_glb_ctrl[1]),.X(bist_rst_n));

// wb_host clock skew control
clk_skew_adjust u_skew_wh
       (
`ifdef USE_POWER_PINS
               .vccd1      (vccd1                      ),// User area 1 1.8V supply
               .vssd1      (vssd1                      ),// User area 1 digital ground
`endif
	       .clk_in     (wbd_clk_int               ), 
	       .sel        (cfg_cska_wh               ), 
	       .clk_out    (wbd_clk_wh                ) 
       );

// To reduce the load/Timing Wishbone I/F, Strobe is register to create
// multi-cycle
wire [31:0]  wbm_dat_o1   = (reg_sel) ? reg_rdata : wbm_dat_int;  // data input
wire         wbm_ack_o1   = (reg_sel) ? reg_ack   : wbm_ack_int; // acknowlegement
wire         wbm_err_o1   = (reg_sel) ? 1'b0      : wbm_err_int;  // error

logic wb_req;
// Hold fix for STROBE
wire  wbm_stb_d1,wbm_stb_d2,wbm_stb_d3;
sky130_fd_sc_hd__dlygate4sd3_1 u_delay1_stb0 (.X(wbm_stb_d1),.A(wbm_stb_i));
sky130_fd_sc_hd__dlygate4sd3_1 u_delay2_stb1 (.X(wbm_stb_d2),.A(wbm_stb_d1));
sky130_fd_sc_hd__dlygate4sd3_1 u_delay2_stb2 (.X(wbm_stb_d3),.A(wbm_stb_d2));
always_ff @(negedge wbm_rst_n or posedge wbm_clk_i) begin
    if ( wbm_rst_n == 1'b0 ) begin
        wb_req    <= '0;
	wbm_dat_o <= '0;
	wbm_ack_o <= '0;
	wbm_err_o <= '0;
   end else begin
       wb_req    <= wbm_stb_d3 && ((wbm_ack_o == 0) && (wbm_ack_o1 == 0)) ;
       wbm_dat_o <= wbm_dat_o1;
       wbm_ack_o <= wbm_ack_o1;
       wbm_err_o <= wbm_err_o1;
   end
end


//-----------------------------------------------------------------------
// Local register decide based on address[31] == 1
//
// Locally there register are define to control the reset and clock for user
// area
//-----------------------------------------------------------------------
// caravel user space is 0x3000_0000 to 0x30FF_FFFF
// So we have allocated 
// 0x3000_0000 - 0x307F_7FFF - To SRAM Address Space
// 0x3080_0000 - 0x3080_00FF - Assigned to WB Host Address Space
// ---------------------------------------------------------------------
assign reg_sel       = wb_req & (wbm_adr_i[23] == 1'b1);

assign sw_addr       = wbm_adr_i [3:2];
assign sw_rd_en      = reg_sel & !wbm_we_i;
assign sw_wr_en      = reg_sel & wbm_we_i;

assign  sw_wr_en_0 = sw_wr_en && (sw_addr==0);
assign  sw_wr_en_1 = sw_wr_en && (sw_addr==1);
assign  sw_wr_en_2 = sw_wr_en && (sw_addr==2);
assign  sw_wr_en_3 = sw_wr_en && (sw_addr==3);

always @ (posedge wbm_clk_i or negedge wbm_rst_n)
begin : preg_out_Seq
   if (wbm_rst_n == 1'b0)
   begin
      reg_rdata  <= 'h0;
      reg_ack    <= 1'b0;
   end
   else if (sw_rd_en && !reg_ack) 
   begin
      reg_rdata <= reg_out ;
      reg_ack   <= 1'b1;
   end
   else if (sw_wr_en && !reg_ack) 
      reg_ack          <= 1'b1;
   else
   begin
      reg_ack        <= 1'b0;
   end
end


//-------------------------------------
// Global + Clock Control
// -------------------------------------
assign cfg_glb_ctrl         = reg_0[7:0];
assign cfg_wb_clk_ctrl      = reg_0[11:8];


always @( *)
begin 
  reg_out [31:0] = 32'h0;

  case (sw_addr [1:0])
    2'b00 :   reg_out [31:0] = reg_0;
    2'b01 :   reg_out [31:0] = {24'h0,cfg_bank_sel [7:0]};     
    2'b10 :   reg_out [31:0] = cfg_clk_ctrl1 [31:0];    
    2'b11 :   reg_out [31:0] = cfg_clk_ctrl2 [31:0];     
    default : reg_out [31:0] = 'h0;
  endcase
end



generic_register #(32,0  ) u_glb_ctrl (
	      .we            ({32{sw_wr_en_0}}   ),		 
	      .data_in       (wbm_dat_i[31:0]    ),
	      .reset_n       (wbm_rst_n         ),
	      .clk           (wbm_clk_i         ),
	      
	      //List of Outs
	      .data_out      (reg_0[31:0])
          );

generic_register #(8,8'h00 ) u_bank_sel (
	      .we            ({8{sw_wr_en_1}}   ),		 
	      .data_in       (wbm_dat_i[7:0]    ),
	      .reset_n       (wbm_rst_n         ),
	      .clk           (wbm_clk_i         ),
	      
	      //List of Outs
	      .data_out      (cfg_bank_sel[7:0] )
          );


generic_register #(32,0  ) u_clk_ctrl1 (
	      .we            ({32{sw_wr_en_2}}   ),		 
	      .data_in       (wbm_dat_i[31:0]    ),
	      .reset_n       (wbm_rst_n          ),
	      .clk           (wbm_clk_i          ),
	      
	      //List of Outs
	      .data_out      (cfg_clk_ctrl1[31:0])
          );

generic_register #(32,0  ) u_clk_ctrl2 (
	      .we            ({32{sw_wr_en_3}}  ),		 
	      .data_in       (wbm_dat_i[31:0]   ),
	      .reset_n       (wbm_rst_n         ),
	      .clk           (wbm_clk_i         ),
	      
	      //List of Outs
	      .data_out      (cfg_clk_ctrl2[31:0])
          );


assign wbm_stb_int = wb_req & !reg_sel;

// Since design need more than 16MB address space, we have implemented
// indirect access
assign wbm_adr_int = {4'b0000,cfg_bank_sel[7:0],wbm_adr_i[19:0]};  

async_wb u_async_wb(
// Master Port
       .wbm_rst_n   (wbm_rst_n     ),  
       .wbm_clk_i   (wbm_clk_i     ),  
       .wbm_cyc_i   (wbm_cyc_i     ),  
       .wbm_stb_i   (wbm_stb_int   ),  
       .wbm_adr_i   (wbm_adr_int   ),  
       .wbm_we_i    (wbm_we_i      ),  
       .wbm_dat_i   (wbm_dat_i     ),  
       .wbm_sel_i   (wbm_sel_i     ),  
       .wbm_dat_o   (wbm_dat_int   ),  
       .wbm_ack_o   (wbm_ack_int   ),  
       .wbm_err_o   (wbm_err_int   ),  

// Slave Port
       .wbs_rst_n   (wbs_rst_n     ),  
       .wbs_clk_i   (wbs_clk_i     ),  
       .wbs_cyc_o   (wbs_cyc_o     ),  
       .wbs_stb_o   (wbs_stb_o     ),  
       .wbs_adr_o   (wbs_adr_o     ),  
       .wbs_we_o    (wbs_we_o      ),  
       .wbs_dat_o   (wbs_dat_o     ),  
       .wbs_sel_o   (wbs_sel_o     ),  
       .wbs_dat_i   (wbs_dat_i     ),  
       .wbs_ack_i   (wbs_ack_i     ),  
       .wbs_err_i   (wbs_err_i     )

    );


//----------------------------------
// Generate Internal WishBone Clock
//----------------------------------
logic       wb_clk_div;
logic       cfg_wb_clk_div;
logic [2:0] cfg_wb_clk_ratio;

assign    cfg_wb_clk_ratio =  cfg_wb_clk_ctrl[2:0];
assign    cfg_wb_clk_div   =  cfg_wb_clk_ctrl[3];


//assign wbs_clk_out  = (cfg_wb_clk_div)  ? wb_clk_div : wbm_clk_i;
ctech_mux2x1 u_wbs_clk_sel (.A0 (wbm_clk_i), .A1 (wb_clk_div), .S  (cfg_wb_clk_div), .X  (wbs_clk_out));


clk_ctl #(2) u_wbclk (
   // Outputs
       .clk_o         (wb_clk_div      ),
   // Inputs
       .mclk          (wbm_clk_i       ),
       .reset_n       (wbm_rst_n        ), 
       .clk_div_ratio (cfg_wb_clk_ratio )
   );


endmodule
