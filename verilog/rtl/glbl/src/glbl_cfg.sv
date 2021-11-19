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
////  Global confg register                                       ////
////                                                              ////
////  This file is part of the mbist_ctrl  project                ////
////  https://github.com/dineshannayya/mbist_ctrl.git             ////
////                                                              ////
////  Description                                                 ////
////      This block generate all the global config and status    ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 18 Nov 2021  Dinesh A                               ////
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

module glbl_cfg (

`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

       input logic             mclk,
       input logic             reset_n,

	// Clock Skew Adjust
       input   logic           wbd_clk_int      , 
       input  logic [3:0]      cfg_cska_glbl    ,
       output  logic           wbd_clk_glbl      , // clock skew adjust for web host


        // Reg Bus Interface Signal
        input logic             reg_cs,
        input logic             reg_wr,
        input logic [7:0]       reg_addr,
        input logic [31:0]      reg_wdata,
        input logic [3:0]       reg_be,

       // Outputs
        output logic [31:0]     reg_rdata,
        output logic            reg_ack,

	// BIST I/F
	output logic [3:0]      bist_en,
	output logic [3:0]      bist_run,
	output logic [3:0]      bist_load,

	output logic [3:0]      bist_sdi,
	output logic [3:0]      bist_shift,
	input  logic [3:0]      bist_sdo,

	input logic [3:0]       bist_done,
	input logic [3:0]       bist_error,
	input logic [3:0]       bist_correct,
	input logic [3:0]       bist_error_cnt0,
	input logic [3:0]       bist_error_cnt1,
	input logic [3:0]       bist_error_cnt2,
	input logic [3:0]       bist_error_cnt3

        );



//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------

logic           sw_rd_en    ;
logic           sw_wr_en    ;
logic  [2:0]    sw_addr     ; // addressing 16 registers
logic  [3:0]    wr_be       ;
logic  [31:0]   sw_reg_wdata;



logic [31:0]    reg_0;            // Software_Reg 0
logic [31:0]    reg_1;            // Software Reg 1
logic [31:0]    cfg_bist_ctrl;    // BIST control
logic [31:0]    cfg_bist_status;  // BIST Status
logic [31:0]    serail_dout;      // BIST Serial Signature

logic [31:0]    reg_out;

//-----------------------------------------------------------------------
// Main code starts here
//-----------------------------------------------------------------------

// wb_host clock skew control
clk_skew_adjust u_skew_glbl
       (
`ifdef USE_POWER_PINS
               .vccd1      (vccd1                      ),// User area 1 1.8V supply
               .vssd1      (vssd1                      ),// User area 1 digital ground
`endif
	       .clk_in     (wbd_clk_int                ), 
	       .sel        (cfg_cska_glbl              ), 
	       .clk_out    (wbd_clk_glbl               ) 
       );

//-----------------------------------------------------------------------
// register read enable and write enable decoding logic
//-----------------------------------------------------------------------

assign       sw_addr       = reg_addr [4:2];
assign       sw_rd_en      = reg_cs & !reg_wr;
assign       sw_wr_en      = reg_cs & reg_wr;
assign       wr_be         = reg_be;
assign       sw_reg_wdata  = reg_wdata;


wire   sw_wr_en_0 = sw_wr_en & (sw_addr == 3'h0);
wire   sw_rd_en_0 = sw_rd_en & (sw_addr == 3'h0);
wire   sw_wr_en_1 = sw_wr_en & (sw_addr == 3'h1);
wire   sw_rd_en_1 = sw_rd_en & (sw_addr == 3'h1);
wire   sw_wr_en_2 = sw_wr_en & (sw_addr == 3'h2);
wire   sw_rd_en_2 = sw_rd_en & (sw_addr == 3'h2);
wire   sw_wr_en_3 = sw_wr_en & (sw_addr == 3'h3);
wire   sw_rd_en_3 = sw_rd_en & (sw_addr == 3'h3);
wire   sw_wr_en_4 = sw_wr_en & (sw_addr == 3'h4);
wire   sw_rd_en_4 = sw_rd_en & (sw_addr == 3'h4);
wire   sw_wr_en_5 = sw_wr_en & (sw_addr == 3'h5);
wire   sw_rd_en_5 = sw_rd_en & (sw_addr == 3'h5);


logic wb_req;
logic wb_req_d;
logic wb_req_pedge;

always_ff @(negedge reset_n or posedge mclk) begin
    if ( reset_n == 1'b0 ) begin
        wb_req    <= '0;
	wb_req_d  <= '0;
   end else begin
       wb_req   <= reg_cs && (reg_ack == 0) ;
       wb_req_d <= wb_req;
   end
end

// Detect pos edge of request
assign wb_req_pedge = (wb_req_d ==0) && (wb_req==1'b1);
//-----------------------------------------------------------------
// Reg 4/5 are BIST Serial I/F register and it takes minimum 32
// cycle to respond ACK back
// ----------------------------------------------------------------
wire ser_acc     = sw_wr_en_4 | sw_rd_en_5;
wire non_ser_acc = reg_cs ? !ser_acc : 1'b0;
wire serial_ack;

always @ (posedge mclk or negedge reset_n)
begin : preg_out_Seq
   if (reset_n == 1'b0) begin
      reg_rdata  <= 'h0;
      reg_ack    <= 1'b0;
   end else if (ser_acc && serial_ack)  begin
      reg_rdata <= serail_dout ;
      reg_ack   <= 1'b1;
   end else if (non_ser_acc && !reg_ack) begin
      reg_rdata <= reg_out ;
      reg_ack   <= 1'b1;
   end else begin
      reg_ack        <= 1'b0;
   end
end

always @( *)
begin 
  reg_out [31:0] = 32'h0;

  case (sw_addr [2:0])
    3'b000 :   reg_out [31:0] = reg_0;
    3'b001 :   reg_out [31:0] = reg_1;
    3'b010 :   reg_out [31:0] = cfg_bist_ctrl [31:0];    
    3'b011 :   reg_out [31:0] = cfg_bist_status [31:0];     
    3'b100 :   reg_out [31:0] = 'h0; // Serial Write Data
    3'b101 :   reg_out [31:0] = serail_dout; // This is with  Shift
    3'b110 :   reg_out [31:0] = serail_dout; // This is previous Shift 
    default : reg_out [31:0] = 'h0;
  endcase
end


//-----------------------------------------------------------------------
// Individual register assignments
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//   reg-0
//   -----------------------------------------------------------------
generic_register #(8,8'h11  ) u_reg0_be0 (
	      .we            ({8{sw_wr_en_0 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[7:0]        )
          );

generic_register #(8,8'h22  ) u_reg0_be1 (
	      .we            ({8{sw_wr_en_0 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[15:8]        )
          );
generic_register #(8,8'h33  ) u_reg0_be2 (
	      .we            ({8{sw_wr_en_0 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[23:16]        )
          );

generic_register #(8,8'h44  ) u_reg0_be3 (
	      .we            ({8{sw_wr_en_0 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[31:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[31:24]        )
          );

//-----------------------------------------------------------------------
//   reg-1
//   -----------------------------------------------------------------
generic_register #(8,8'hAA  ) u_reg1_be0 (
	      .we            ({8{sw_wr_en_1 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[7:0]        )
          );

generic_register #(8,8'hBB  ) u_reg1_be1 (
	      .we            ({8{sw_wr_en_1 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[15:8]        )
          );
generic_register #(8,8'hCC  ) u_reg1_be2 (
	      .we            ({8{sw_wr_en_1 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[23:16]        )
          );

generic_register #(8,8'hDD  ) u_reg1_be3 (
	      .we            ({8{sw_wr_en_1 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[31:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[31:24]        )
          );

//-----------------------------------------------------------------------
//   reg-2
//   -----------------------------------------------------------------
// Bist control
assign bist_en[0]           = cfg_bist_ctrl[0];
assign bist_run[0]          = cfg_bist_ctrl[1];
assign bist_load[0]         = cfg_bist_ctrl[2];

assign bist_en[1]           = cfg_bist_ctrl[4];
assign bist_run[1]          = cfg_bist_ctrl[5];
assign bist_load[1]         = cfg_bist_ctrl[6];

assign bist_en[2]           = cfg_bist_ctrl[8];
assign bist_run[2]          = cfg_bist_ctrl[9];
assign bist_load[2]         = cfg_bist_ctrl[10];

assign bist_en[3]           = cfg_bist_ctrl[12];
assign bist_run[3]          = cfg_bist_ctrl[13];
assign bist_load[3]         = cfg_bist_ctrl[14];

wire [3:0] bist_serial_sel  = cfg_bist_ctrl[31:28];


generic_register #(8,8'h0  ) u_bist_ctrl_be0 (
	      .we            ({8{sw_wr_en_2 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (cfg_bist_ctrl[7:0]        )
          );

generic_register #(8,8'h0  ) u_bist_ctrl_be1 (
	      .we            ({8{sw_wr_en_2 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (cfg_bist_ctrl[15:8]        )
          );
generic_register #(8,8'h0  ) u_bist_ctrl_be2 (
	      .we            ({8{sw_wr_en_2 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (cfg_bist_ctrl[23:16]        )
          );

generic_register #(8,8'h0  ) u_bist_ctrl_be3 (
	      .we            ({8{sw_wr_en_2 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[31:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (cfg_bist_ctrl[31:24]        )
          );


//-----------------------------------------------------------------------
//   reg-3
//-----------------------------------------------------------------

assign cfg_bist_status   = {  bist_error_cnt3, 1'b0, bist_correct[3], bist_error[3], bist_done[3],
	                      bist_error_cnt2, 1'b0, bist_correct[2], bist_error[2], bist_done[2],
	                      bist_error_cnt1, 1'b0, bist_correct[1], bist_error[1], bist_done[1],
	                      bist_error_cnt0, 1'b0, bist_correct[0], bist_error[0], bist_done[0]
			   };

//-----------------------------------------------------------------------
//   reg-4 => Write to Serail I/F
//   reg-5 => READ  from Serail I/F
//-----------------------------------------------------------------
wire   bist_sdi_int;
wire   bist_shift_int;
wire   bist_sdo_int;

assign bist_sdo_int = (bist_serial_sel == 4'b0000) ? bist_sdo[0] :
                      (bist_serial_sel == 4'b0001) ? bist_sdo[1] :
                      (bist_serial_sel == 4'b0010) ? bist_sdo[2] :
                      (bist_serial_sel == 4'b0011) ? bist_sdo[3] : 1'b0;

assign  bist_shift[0] = (bist_serial_sel == 4'b0000) ? bist_shift_int : 1'b0;
assign  bist_shift[1] = (bist_serial_sel == 4'b0001) ? bist_shift_int : 1'b0;
assign  bist_shift[2] = (bist_serial_sel == 4'b0010) ? bist_shift_int : 1'b0;
assign  bist_shift[3] = (bist_serial_sel == 4'b0011) ? bist_shift_int : 1'b0;

assign  bist_sdi[0] = (bist_serial_sel == 4'b0000) ? bist_sdi_int : 1'b0;
assign  bist_sdi[1] = (bist_serial_sel == 4'b0001) ? bist_sdi_int : 1'b0;
assign  bist_sdi[2] = (bist_serial_sel == 4'b0010) ? bist_sdi_int : 1'b0;
assign  bist_sdi[3] = (bist_serial_sel == 4'b0011) ? bist_sdi_int : 1'b0;

ser_inf_32b u_ser_intf
       (

    // Master Port
       .rst_n       (reset_n),  // Regular Reset signal
       .clk         (mclk),  // System clock
       .reg_wr      (sw_wr_en_4 & wb_req_pedge),  // Write Request
       .reg_rd      (sw_rd_en_5 & wb_req_pedge),  // Read Request
       .reg_wdata   (reg_wdata) ,  // data output
       .reg_rdata   (serail_dout),  // data input
       .reg_ack     (serial_ack),  // acknowlegement

    // Slave Port
       .sdi         (bist_sdi_int),    // Serial SDI
       .shift       (bist_shift_int),  // Shift Signal
       .sdo         (bist_sdo_int) // Serial SDO

    );



endmodule
