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

       output logic                bist_clk         ,
       output logic                bist_rst_n       ,
       output logic                mem_clk_out      ,
       input  logic                mem_clk          ,

       output logic                wbd_int_rst_n    ,

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

	// MBIST I/F
	output  logic              bist_en,
	output logic               bist_run,
	output logic               bist_shift,
	output logic               bist_load,
	output logic               bist_sdi,

	input logic [3:0]          bist_error_cnt,
	input logic                bist_correct,
	input logic                bist_error,
	input logic                bist_done,
	input logic                bist_sdo,

      // MEM A PORT 
        output   logic             func_clk_a,
        output   logic             func_cen_a,
        output   logic  [8:0]      func_addr_a,
        input    logic  [31:0]     func_dout_a,

       // Functional B Port
        output   logic              func_clk_b,
        output   logic              func_cen_b,
        output   logic              func_web_b,
        output   logic [3:0]        func_mask_b,
        output   logic  [8:0]       func_addr_b,
        output   logic  [31:0]      func_din_b,

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
logic [2:0]         sw_addr    ;
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

logic  [3:0]        cfg_bist_clk_ctrl;
logic  [3:0]        cfg_mem_clk_ctrl;
logic  [7:0]        cfg_glb_ctrl;

// Slave Port
logic               wbs_clk_out      ;  // System clock
logic               wbs_cyc_o        ;  // strobe/request
logic               wbs_stb_o        ;  // strobe/request
logic [31:0]        wbs_adr_o        ;  // address
logic               wbs_we_o         ;  // write
logic [31:0]        wbs_dat_o        ;  // data output
logic [3:0]         wbs_sel_o        ;  // byte enable
logic [31:0]        wbs_dat_i        ;  // data input
logic               wbs_ack_i        ;  // acknowlegement
logic               wbs_err_i        ;  // error

logic [31:0]        cfg_bist_ctrl    ;
logic [31:0]        cfg_bist_status  ;
logic               ser_acc          ; // Serial Access
logic               non_ser_acc      ; // Non Serial Access
logic [31:0]        serail_dout      ;
logic               serial_ack       ;

assign io_out = 'h0;
assign io_oeb  = 'h0;
assign la_data_out = 'h0;


assign wbm_rst_n = !wbm_rst_i;
assign wbs_rst_n = !wbm_rst_i;

sky130_fd_sc_hd__bufbuf_16 u_buf_wb_rst     (.A(cfg_glb_ctrl[0]),.X(wbd_int_rst_n));
sky130_fd_sc_hd__bufbuf_16 u_buf_bist_rst   (.A(cfg_glb_ctrl[1]),.X(bist_rst_n));


// To reduce the load/Timing Wishbone I/F, Strobe is register to create
// multi-cycle
logic wb_req;
logic wb_req_d;
logic wb_req_pedge;
always_ff @(negedge wbm_rst_n or posedge wbm_clk_i) begin
    if ( wbm_rst_n == 1'b0 ) begin
        wb_req     <= '0;
        wb_req_d   <= '0;
   end else begin
       wb_req   <= wbm_stb_i && (wbm_ack_o == 0) ;
       wb_req_d <= wb_req;
   end
end

// Detect pos edge of request
assign wb_req_pedge = (wb_req_d ==0) && (wb_req==1'b1);

assign  wbm_dat_o   = (reg_sel) ? reg_rdata : wbm_dat_int;  // data input
assign  wbm_ack_o   = (reg_sel) ? reg_ack   : wbm_ack_int; // acknowlegement
assign  wbm_err_o   = (reg_sel) ? 1'b0      : wbm_err_int;  // error

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

assign sw_addr       = wbm_adr_i [4:2];
assign sw_rd_en      = reg_sel & !wbm_we_i;
assign sw_wr_en      = reg_sel & wbm_we_i;

assign  sw_wr_en_0 = sw_wr_en && (sw_addr=='h0);
assign  sw_wr_en_1 = sw_wr_en && (sw_addr=='h1);
assign  sw_wr_en_2 = sw_wr_en && (sw_addr=='h2);
assign  sw_wr_en_3 = sw_wr_en && (sw_addr=='h3);
assign  sw_wr_en_4 = sw_wr_en && (sw_addr=='h4);
assign  sw_rd_en_5 = sw_rd_en && (sw_addr=='h5);


assign ser_acc = sw_wr_en_4 | sw_rd_en_5;
assign non_ser_acc = reg_sel ? !ser_acc : 1'b0;

always @ (posedge wbm_clk_i or negedge wbm_rst_n)
begin : preg_out_Seq
   if (wbm_rst_n == 1'b0) begin
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


//-------------------------------------
// Global + Clock Control
// -------------------------------------
assign cfg_glb_ctrl         = reg_1[7:0];
assign cfg_bist_clk_ctrl    = reg_1[11:8];
assign cfg_mem_clk_ctrl     = reg_1[15:12];
assign cfg_bank_sel         = reg_1[23:16];


// BIST Control
assign bist_en           = cfg_bist_ctrl[0];
assign bist_run          = cfg_bist_ctrl[1];
assign bist_load         = cfg_bist_ctrl[2];

// BIST Status
assign cfg_bist_status   = {25'h0,bist_error_cnt,bist_correct,bist_error,bist_done};


always @( *)
begin 
  reg_out [31:0] = 8'd0;

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


generic_register #(32,32'hAABBCCDD  ) u_chip_id (
	      .we            ({32{sw_wr_en_0}}   ),		 
	      .data_in       (wbm_dat_i[31:0]    ),
	      .reset_n       (wbm_rst_n         ),
	      .clk           (wbm_clk_i         ),
	      
	      //List of Outs
	      .data_out      (reg_0[31:0])
          );

generic_register #(32,32'h100000  ) u_glb_ctrl (
	      .we            ({32{sw_wr_en_1}}  ),		 
	      .data_in       (wbm_dat_i[31:0]   ),
	      .reset_n       (wbm_rst_n         ),
	      .clk           (wbm_clk_i         ),
	      
	      //List of Outs
	      .data_out      (reg_1[31:0]       )
          );



generic_register #(32,0  ) u_clk_ctrl1 (
	      .we            ({32{sw_wr_en_2}}   ),		 
	      .data_in       (wbm_dat_i[31:0]    ),
	      .reset_n       (wbm_rst_n          ),
	      .clk           (wbm_clk_i          ),
	      
	      //List of Outs
	      .data_out      (cfg_bist_ctrl[31:0])
          );




ser_inf_32b u_ser_intf
       (

    // Master Port
       .rst_n       (wbm_rst_n),  // Regular Reset signal
       .clk         (wbm_clk_i),  // System clock
       .reg_wr      (sw_wr_en_4 & wb_req_pedge),  // Write Request
       .reg_rd      (sw_rd_en_5 & wb_req_pedge),  // Read Request
       .reg_wdata   (wbm_dat_i) ,  // data output
       .reg_rdata   (serail_dout),  // data input
       .reg_ack     (serial_ack),  // acknowlegement

    // Slave Port
       .sdi         (bist_sdi),    // Serial SDI
       .shift       (bist_shift),  // Shift Signal
       .sdo         (bist_sdo)     // Serial SDO

    );


//--------------------------------------------------
// Wishbone Master to Wishbone Slave 
// -------------------------------------------------

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
       .wbs_clk_i   (mem_clk     ),  
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

// Memory Write PORT
assign func_clk_b     = mem_clk;
assign func_cen_b     = !wbs_stb_o;
assign func_web_b     = !wbs_we_o;
assign func_mask_b    = wbs_sel_o;
assign func_addr_b    = wbs_adr_o[10:2];
assign func_din_b     = wbs_dat_o;

assign func_clk_a     = mem_clk;
assign func_cen_a     = (wbs_stb_o == 1'b1 && wbs_we_o == 1'b0 && wbs_ack_i ==0) ? 1'b0 : 1'b1;
assign func_addr_a    = wbs_adr_o[10:2];
assign wbs_dat_i      = func_dout_a;

assign wbs_err_i   = 1'b0;

logic func_cen_a_d;

always_ff @(negedge wbs_rst_n or posedge mem_clk) begin
    if ( wbs_rst_n == 1'b0 ) begin
	func_cen_a_d <= 'h0;
   end else begin
       func_cen_a_d <= func_cen_a;
   end
end

assign wbs_ack_i = (wbs_stb_o == 1'b1 && wbs_we_o == 1'b1) ? 1'b1 :  // Write Phase
                   (wbs_stb_o == 1'b1 && wbs_we_o == 1'b0) ? !func_cen_a_d : 1'b0; // Once Cycle Delay Read Ack

//----------------------------------
// Generate BIST Clock Generation
//----------------------------------
wire   bist_clk_div;
wire   bist_ref_clk;
wire   bist_clk_int;

wire             cfg_bist_clk_src_sel   = cfg_bist_clk_ctrl[0];
wire             cfg_bist_clk_div       = cfg_bist_clk_ctrl[1];
wire [1:0]       cfg_bist_clk_ratio     = cfg_bist_clk_ctrl[3:2];
assign bist_ref_clk = (cfg_bist_clk_src_sel) ? user_clock2 :user_clock1;
assign bist_clk_int = (cfg_bist_clk_div)     ? bist_clk_div : bist_ref_clk;

sky130_fd_sc_hd__clkbuf_16 u_clkbuf_bist (.A (bist_clk_int), . X(bist_clk));

clk_ctl #(1) u_bistclk (
   // Outputs
       .clk_o         (bist_clk_div      ),
   // Inputs
       .mclk          (bist_ref_clk      ),
       .reset_n       (reset_n            ), 
       .clk_div_ratio (cfg_bist_clk_ratio)
   );


//----------------------------------
// Generate MEM Clock Generation
//----------------------------------
wire   mem_clk_div;
wire   mem_ref_clk;
wire   mem_clk_int;

wire       cfg_mem_clk_src_sel   = cfg_mem_clk_ctrl[0];
wire       cfg_mem_clk_div       = cfg_mem_clk_ctrl[1];
wire [1:0] cfg_mem_clk_ratio     = cfg_mem_clk_ctrl[3:2];

assign mem_ref_clk = (cfg_mem_clk_src_sel) ? user_clock2 : user_clock1;
assign mem_clk_int = (cfg_mem_clk_div)     ? mem_clk_div : mem_ref_clk;


sky130_fd_sc_hd__clkbuf_16 u_clkbuf_mem (.A (mem_clk_int), . X(mem_clk_out));

clk_ctl #(1) u_memclk (
   // Outputs
       .clk_o         (mem_clk_div      ),
   // Inputs
       .mclk          (mem_ref_clk      ),
       .reset_n       (reset_n          ), 
       .clk_div_ratio (cfg_mem_clk_ratio)
   );

endmodule
