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
////    0.2 - Mar 15 2021, Dinesh A                               ////
////          1. To fix the bug in caravel mgmt soc address range ////
////          reduction to 0x3000_0000 to 0x300F_FFFF             ////
////          Address Map has changes as follows                  ////
////          0x3008_0000 to 0x3008_00FF - Local Wishbone Reg     ////
////          0x3000_0000 to 0x3007_FFFF - SOC access with        ////
////              indirect Map {Bank_Sel[15:3], wbm_adr_i[18:0]}  ////
////          2.wbm_cyc_i need to qualified with wbm_stb_i        ////  
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

module wb_host 
   #(parameter SCW = 8   // SCAN CHAIN WIDTH
     ) (

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
    
   // lbist Clock Skew Adjust
       input   logic               lbist_clk_int    , 
       output  logic               lbist_clk_out    ,
       input   logic [3:0]         cfg_cska_lbist   , // clock skew adjust for web host

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


       input   logic                io_in,
	output   logic  [37:0]      io_out,
	output   logic  [37:0]      io_oeb,
        input    logic  [35:0]      la_data_in,
        output   logic  [127:0]     la_data_out,

	// Scan Control Signal
	output logic           scan_clk,
	output logic           scan_rst_n,
	output logic           scan_mode,
	output logic           scan_en,
	output logic [SCW-1:0] scan_in,
	input  logic [SCW-1:0] scan_out

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

logic               wb_reg_sel    ; // Local Register Select
logic [31:0]        wb_reg_rdata  ;
logic [31:0]        wb_reg_out    ;
logic               wb_reg_ack    ;

logic               lbist_reg_sel    ;   // LBIST Register Select
logic [31:0]        lbist_reg_rdata  ;
logic               lbist_reg_ack    ;
logic               lbist_reg_err    ;

logic [1:0]         sw_addr    ;
logic               sw_rd_en   ;
logic               sw_wr_en   ;
logic               sw_wr_en_0;
logic               sw_wr_en_1;
logic               sw_wr_en_2;
logic               sw_wr_en_3;
logic               sw_wr_en_4;
logic               sw_rd_en_5;
logic [15:0]         cfg_bank_sel;
logic [31:0]        wbm_adr_int;
logic               wbm_stb_int;
logic [31:0]        reg_0;  // Software_Reg_0
logic [31:0]        reg_1;  // Software_Reg_0

logic  [3:0]        cfg_wb_clk_ctrl;
logic  [3:0]        cfg_lbist_clk_ctrl;
logic  [7:0]        cfg_glb_ctrl;
logic               cfg_la_lbist;

// uart Master Port
logic               wbm_uart_cyc_i        ;  // strobe/request
logic               wbm_uart_stb_i        ;  // strobe/request
logic [31:0]        wbm_uart_adr_i        ;  // address
logic               wbm_uart_we_i         ;  // write
logic [31:0]        wbm_uart_dat_i        ;  // data output
logic [3:0]         wbm_uart_sel_i        ;  // byte enable
logic [31:0]        wbm_uart_dat_o        ;  // data input
logic               wbm_uart_ack_o        ;  // acknowlegement
logic               wbm_uart_err_o        ;  // error

// Selected Master Port
logic               wb_cyc_i              ;  // strobe/request
logic               wb_stb_i              ;  // strobe/request
logic [31:0]        wb_adr_i              ;  // address
logic               wb_we_i               ;  // write
logic [31:0]        wb_dat_i              ;  // data output
logic [3:0]         wb_sel_i              ;  // byte enable
logic [31:0]        wb_dat_o              ;  // data input
logic               wb_ack_o              ;  // acknowlegement
logic               wb_err_o              ;  // error
logic [31:0]        wb_adr_int            ;
logic               wb_stb_int            ;
logic [31:0]        wb_dat_int            ; // data input
logic               wb_ack_int            ; // acknowlegement
logic               wb_err_int            ; // error

logic               lbist_clk_skew   ;  // LBIST clock
logic               scan_mode_int    ;
// LBIST  Control Signal
logic               lbist_scan_clk;
logic               lbist_scan_rst_n;
logic               lbist_scan_mode;
logic               lbist_scan_en;
logic [SCW-1:0]     lbist_scan_in;

logic               uartm_rxd             ;
logic               uartm_txd             ;

// Drive UART TXD/RXD
assign uartm_rxd = io_in;
assign io_oeb[0] = 1'b1;
assign io_out[0] = 1'b0;

assign io_out[1] = uartm_txd;
assign io_oeb[1] = 1'b0;

assign io_out[37:2] = 'h0;
assign io_oeb[37:2] = 'h0;

//---------------------------------------------------
// Local OR LA based Logic BIST Selection
// --------------------------------------------------

assign scan_clk      = (cfg_la_lbist) ? la_data_in[35] : lbist_scan_clk; 
assign scan_rst_n    = (cfg_la_lbist) ? la_data_in[34] : lbist_scan_rst_n; 
assign scan_mode_int = (cfg_la_lbist) ? la_data_in[33]  : lbist_scan_mode; 
assign scan_en       = (cfg_la_lbist) ? la_data_in[32]  : lbist_scan_en; 
assign scan_in       = (cfg_la_lbist) ? la_data_in[31:24]: lbist_scan_in; 
assign la_data_out   = {120'h0,scan_out};


//-------------------
assign user_irq  = 'h0;

//--------------------------------------------------------------------------------
// Look like wishbone reset removed early than user Power up sequence
// To control the reset phase, we have added additional control through la[0]
// ------------------------------------------------------------------------------
wire    arst_n = !wbm_rst_i & la_data_in[0];
reset_sync  u_wbm_rst (
	      .scan_mode  (1'b0           ),
              .dclk       (wbm_clk_i      ), // Destination clock domain
	      .arst_n     (arst_n         ), // active low async reset
              .srst_n     (wbm_rst_n      )
          );

reset_sync  u_wbs_rst (
	      .scan_mode  (1'b0           ),
              .dclk       (wbs_clk_i      ), // Destination clock domain
	      .arst_n     (arst_n         ), // active low async reset
              .srst_n     (wbs_rst_n      )
          );

// UART Master
uart2wb u_uart2wb (  
        .arst_n          (wbm_rst_n         ), //  sync reset
        .app_clk         (wbm_clk_i         ), //  sys clock    

	// configuration control
       .cfg_tx_enable    (la_data_in[1]     ), // Enable Transmit Path
       .cfg_rx_enable    (la_data_in[2]     ), // Enable Received Path
       .cfg_stop_bit     (la_data_in[3]     ), // 0 -> 1 Start , 1 -> 2 Stop Bits
       .cfg_baud_16x     (la_data_in[15:4]  ), // 16x Baud clock generation
       .cfg_pri_mod      (la_data_in[17:16] ), // priority mode, 0 -> nop, 1 -> Even, 2 -> Odd

    // Master Port
       .wbm_cyc_o        (wbm_uart_cyc_i ),  // strobe/request
       .wbm_stb_o        (wbm_uart_stb_i ),  // strobe/request
       .wbm_adr_o        (wbm_uart_adr_i ),  // address
       .wbm_we_o         (wbm_uart_we_i  ),  // write
       .wbm_dat_o        (wbm_uart_dat_i ),  // data output
       .wbm_sel_o        (wbm_uart_sel_i ),  // byte enable
       .wbm_dat_i        (wbm_uart_dat_o ),  // data input
       .wbm_ack_i        (wbm_uart_ack_o ),  // acknowlegement
       .wbm_err_i        (wbm_uart_err_o ),  // error

       // Status information
       .frm_error        (), // framing error
       .par_error        (), // par error

       .baud_clk_16x     (), // 16x Baud clock

       // Line Interface
       .rxd              (uartm_rxd) , // uart rxd
       .txd              (uartm_txd)   // uart txd

     );


// Arbitor to select between external wb vs uart wb
wire [1:0] grnt;
wb_arb u_arb(
	.clk      (wbm_clk_i), 
	.rstn     (wbm_rst_n), 
	.req      ({1'b0,wbm_uart_stb_i,(wbm_stb_i & wbm_cyc_i)}), 
	.gnt      (grnt)
        );

// Select  the master based on the grant
assign wb_cyc_i = (grnt == 2'b00) ? wbm_cyc_i               : wbm_uart_cyc_i; 
assign wb_stb_i = (grnt == 2'b00) ? (wbm_cyc_i & wbm_stb_i) : wbm_uart_stb_i; 
assign wb_adr_i = (grnt == 2'b00) ? wbm_adr_i : wbm_uart_adr_i; 
assign wb_we_i  = (grnt == 2'b00) ? wbm_we_i  : wbm_uart_we_i; 
assign wb_dat_i = (grnt == 2'b00) ? wbm_dat_i : wbm_uart_dat_i; 
assign wb_sel_i = (grnt == 2'b00) ? wbm_sel_i : wbm_uart_sel_i; 

assign wbm_dat_o = (grnt == 2'b00) ? wb_dat_o : 'h0;
assign wbm_ack_o = (grnt == 2'b00) ? wb_ack_o : 'h0;
assign wbm_err_o = (grnt == 2'b00) ? wb_err_o : 'h0;


assign wbm_uart_dat_o = (grnt == 2'b01) ? wb_dat_o : 'h0;
assign wbm_uart_ack_o = (grnt == 2'b01) ? wb_ack_o : 'h0;
assign wbm_uart_err_o = (grnt == 2'b01) ? wb_err_o : 'h0;





ctech_buf  u_scan_buf (.A(scan_mode_int), .X(scan_mode));
// Reset bypass for scan mode
ctech_mux2x1 u_wb_rst_scan_sel   (.A0 (cfg_glb_ctrl[0]), .A1 (scan_rst_n), .S  (scan_mode), .X  (wbd_int_rst_n));
ctech_mux2x1 u_bist_rst_scan_sel (.A0 (cfg_glb_ctrl[1]), .A1 (scan_rst_n), .S  (scan_mode), .X  (bist_rst_n));

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
wire [31:0]  wb_dat_o1   = (wb_reg_sel) ? wb_reg_rdata : (lbist_reg_sel) ? lbist_reg_rdata : wb_dat_int;  // data input
wire         wb_ack_o1   = (wb_reg_sel) ? wb_reg_ack   : (lbist_reg_sel) ? lbist_reg_ack   : wb_ack_int; // acknowlegement
wire         wb_err_o1   = (wb_reg_sel) ? 1'b0         : (lbist_reg_sel) ? lbist_reg_err   : wb_err_int;  // error

logic wb_req;
// Hold fix for STROBE
wire  wb_stb_d1,wb_stb_d2,wb_stb_d3;
ctech_delay_buf u_delay1_stb0 (.X(wb_stb_d1),.A(wb_stb_i));
ctech_delay_buf u_delay2_stb1 (.X(wb_stb_d2),.A(wb_stb_d1));
ctech_delay_buf u_delay2_stb2 (.X(wb_stb_d3),.A(wb_stb_d2));
always_ff @(negedge wbm_rst_n or posedge wbm_clk_i) begin
    if ( wbm_rst_n == 1'b0 ) begin
        wb_req    <= '0;
	wb_dat_o <= '0;
	wb_ack_o <= '0;
	wb_err_o <= '0;
   end else begin
       wb_req   <= wb_stb_d3 && ((wb_ack_o == 0) && (wb_ack_o1 == 0)) ;
       wb_ack_o <= wb_ack_o1;
       wb_err_o <= wb_err_o1;
       if(wb_ack_o1) // Keep last data in the bus
          wb_dat_o <= wb_dat_o1;
   end
end


//-----------------------------------------------------------------------
// Local register decide based on address[19] == 1
//
// Locally there register are define to control the reset and clock for user
// area
//-----------------------------------------------------------------------
// caravel user space is 0x3000_0000 to 0x3007_FFFF
// So we have allocated 
// 0x3008_0000 - 0x3008_00FF - Assigned to WB Host Address Space
// Since We need more than 16MB Address space to access SDRAM/SPI we have
// added indirect MSB 8 bit address select option
// So Address will be {Bank_Sel[15:2], wbm_adr_i[17:0]}
// ---------------------------------------------------------------------
assign wb_reg_sel       = wb_req & (wb_adr_i[19:18] == 2'b10);
assign lbist_reg_sel    = wb_req & (wb_adr_i[19:18] == 2'b11);

assign sw_addr       = wb_adr_i [3:2];
assign sw_rd_en      = wb_reg_sel & !wb_we_i;
assign sw_wr_en      = wb_reg_sel & wb_we_i;

assign  sw_wr_en_0 = sw_wr_en && (sw_addr==0);
assign  sw_wr_en_1 = sw_wr_en && (sw_addr==1);
assign  sw_wr_en_2 = sw_wr_en && (sw_addr==2);
assign  sw_wr_en_3 = sw_wr_en && (sw_addr==3);

always @ (posedge wbm_clk_i or negedge wbm_rst_n)
begin : preg_out_Seq
   if (wbm_rst_n == 1'b0)
   begin
      wb_reg_rdata  <= 'h0;
      wb_reg_ack    <= 1'b0;
   end
   else if (sw_rd_en && !wb_reg_ack) 
   begin
      wb_reg_rdata <= wb_reg_out ;
      wb_reg_ack   <= 1'b1;
   end
   else if (sw_wr_en && !wb_reg_ack) 
      wb_reg_ack          <= 1'b1;
   else
   begin
      wb_reg_ack        <= 1'b0;
   end
end


//-------------------------------------
// Global + Clock Control
// -------------------------------------
assign cfg_glb_ctrl         = reg_0[7:0];
assign cfg_wb_clk_ctrl      = reg_0[11:8];
assign cfg_lbist_clk_ctrl   = reg_0[15:12];
assign cfg_la_lbist         = reg_0[31];  // Use LA as Logic BIST


always @( *)
begin 
  wb_reg_out [31:0] = 32'h0;

  case (sw_addr [1:0])
    2'b00 :   wb_reg_out [31:0] = reg_0;
    2'b01 :   wb_reg_out [31:0] = {16'h0,cfg_bank_sel [15:0]};     
    2'b10 :   wb_reg_out [31:0] = cfg_clk_ctrl1 [31:0];    
    2'b11 :   wb_reg_out [31:0] = cfg_clk_ctrl2 [31:0];     
    default : wb_reg_out [31:0] = 'h0;
  endcase
end


gen_32b_reg  #(32'h00) u_glb_ctrl	(
	      //List of Inputs
	      .reset_n    (wbm_rst_n     ),
	      .clk        (wbm_clk_i     ),
	      .cs         (sw_wr_en_0    ),
	      .we         (wb_sel_i     ),		 
	      .data_in    (wb_dat_i  ),
	      
	      //List of Outs
	      .data_out   (reg_0       )
	      );


generic_register #(16,16'h1000 ) u_bank_sel (
	      .we            ({16{sw_wr_en_1}}   ),		 
	      .data_in       (wb_dat_i[15:0]    ),
	      .reset_n       (wbm_rst_n         ),
	      .clk           (wbm_clk_i         ),
	      
	      //List of Outs
	      .data_out      (cfg_bank_sel[15:0] )
          );


generic_register #(32,0  ) u_clk_ctrl1 (
	      .we            ({32{sw_wr_en_2}}   ),		 
	      .data_in       (wb_dat_i[31:0]    ),
	      .reset_n       (wbm_rst_n          ),
	      .clk           (wbm_clk_i          ),
	      
	      //List of Outs
	      .data_out      (cfg_clk_ctrl1[31:0])
          );

generic_register #(32,0  ) u_clk_ctrl2 (
	      .we            ({32{sw_wr_en_3}}  ),		 
	      .data_in       (wb_dat_i[31:0]   ),
	      .reset_n       (wbm_rst_n         ),
	      .clk           (wbm_clk_i         ),
	      
	      //List of Outs
	      .data_out      (cfg_clk_ctrl2[31:0])
          );


assign wb_stb_int = wb_req & (!wb_reg_sel & !lbist_reg_sel);

// Since design need more than 16MB address space, we have implemented
// indirect access
assign wb_adr_int = {cfg_bank_sel[15:2],wb_adr_i[17:0]};  

// During scan mode, feedback the input back for better scan coverage
logic               wbs_cyc_o1       ;  // strobe/request
logic               wbs_stb_o1       ;  // strobe/request
logic [31:0]        wbs_adr_o1       ;  // address
logic               wbs_we_o1        ;  // write
logic [31:0]        wbs_dat_o1       ;  // data output
logic [3:0]         wbs_sel_o1       ;  // byte enable


assign wbs_cyc_o     = (scan_mode) ? wbs_ack_i      : wbs_cyc_o1;
assign wbs_stb_o     = (scan_mode) ? wbs_ack_i      : wbs_stb_o1;
assign wbs_adr_o     = (scan_mode) ? wbs_dat_i      : wbs_adr_o1;
assign wbs_we_o      = (scan_mode) ? wbs_ack_i      : wbs_we_o1;
assign wbs_dat_o     = (scan_mode) ? wbs_dat_i      : wbs_dat_o1;
assign wbs_sel_o     = (scan_mode) ? wbs_dat_i[3:0] : wbs_sel_o1;

async_wb u_async_wb(
// Master Port
       .wbm_rst_n   (wbm_rst_n     ),  
       .wbm_clk_i   (wbm_clk_i     ),  
       .wbm_cyc_i   (wb_cyc_i      ),  
       .wbm_stb_i   (wb_stb_int    ),  
       .wbm_adr_i   (wb_adr_int    ),  
       .wbm_we_i    (wb_we_i       ),  
       .wbm_dat_i   (wb_dat_i      ),  
       .wbm_sel_i   (wb_sel_i      ),  
       .wbm_dat_o   (wb_dat_int    ),  
       .wbm_ack_o   (wb_ack_int    ),  
       .wbm_err_o   (wb_err_int    ),  

// Slave Port
       .wbs_rst_n   (wbs_rst_n     ),  
       .wbs_clk_i   (wbs_clk_i     ),  
       .wbs_cyc_o   (wbs_cyc_o1    ),  
       .wbs_stb_o   (wbs_stb_o1    ),  
       .wbs_adr_o   (wbs_adr_o1    ),  
       .wbs_we_o    (wbs_we_o1     ),  
       .wbs_dat_o   (wbs_dat_o1    ),  
       .wbs_sel_o   (wbs_sel_o1    ),  
       .wbs_dat_i   (wbs_dat_i     ),  
       .wbs_ack_i   (wbs_ack_i     ),  
       .wbs_err_i   (wbs_err_i     )

    );


//--------------------------------
// LBIST TOP
// -------------------------------

lbist_top 
   #(.SCW(SCW)   // SCAN CHAIN WIDTH
     ) u_lbist (
	// Wishbone Reg I/F
	.wb_clk              (wbm_clk_i),
	.wb_rst_n            (wbm_rst_n),
	.wb_cs               (lbist_reg_sel),
	.wb_addr             (sw_addr),
	.wb_wr               (wb_we_i),
	.wb_wdata            (wb_dat_i),
	.wb_be               (wb_sel_i),

	.wb_rdata            (lbist_reg_rdata),
	.wb_ack              (lbist_reg_ack),
	.wb_err              (lbist_reg_err),

	// LBIST I/F
	.lbist_clk           (lbist_clk),
	.lbist_clk_skew      (lbist_clk_int),


	// Scan Control Signal
	.scan_clk            (lbist_scan_clk),
	.scan_rst_n          (lbist_scan_rst_n),
	.scan_mode           (lbist_scan_mode),
	.scan_en             (lbist_scan_en),
	.scan_in             (lbist_scan_in),
	.scan_out            (scan_out)
);


//----------------------------------
// Generate Internal WishBone Clock
//----------------------------------
logic       wb_clk_div;
logic       wbs_clk;
logic       cfg_wb_clk_div;
logic [2:0] cfg_wb_clk_ratio;

assign    cfg_wb_clk_ratio =  cfg_wb_clk_ctrl[2:0];
assign    cfg_wb_clk_div   =  cfg_wb_clk_ctrl[3];


//assign wbs_clk_out  = (cfg_wb_clk_div)  ? wb_clk_div : wbm_clk_i;

ctech_mux2x1 u_wbs_clk_sel (.A0 (wbm_clk_i), .A1 (wb_clk_div), .S  (cfg_wb_clk_div), .X  (wbs_clk));
ctech_mux2x1 u_wbs_clk_scan_sel (.A0 (wbs_clk), .A1 (scan_clk), .S  (scan_mode), .X  (wbs_clk_out));


clk_ctl #(2) u_wbclk (
   // Outputs
       .clk_o         (wb_clk_div      ),
   // Inputs
       .mclk          (wbm_clk_i       ),
       .reset_n       (wbm_rst_n        ), 
       .clk_div_ratio (cfg_wb_clk_ratio )
   );

//----------------------------------
// Generate Internal WishBone Clock
//----------------------------------
logic       lbist_clk_div;
logic       cfg_lbist_clk_div;
logic [2:0] cfg_lbist_clk_ratio;

assign    cfg_lbist_clk_ratio =  cfg_lbist_clk_ctrl[2:0];
assign    cfg_lbist_clk_div   =  cfg_lbist_clk_ctrl[3];


//assign wbs_clk_out  = (cfg_wb_clk_div)  ? wb_clk_div : wbm_clk_i;
ctech_mux2x1 u_lbist_clk_sel (.A0 (wbm_clk_i), .A1 (lbist_clk_div), .S  (cfg_lbist_clk_div), .X  (lbist_clk));


clk_ctl #(2) u_lbist_clk (
   // Outputs
       .clk_o         (lbist_clk_div      ),
   // Inputs
       .mclk          (wbm_clk_i       ),
       .reset_n       (wbm_rst_n        ), 
       .clk_div_ratio (cfg_lbist_clk_ratio )
   );

// wb_host clock skew control
clk_skew_adjust u_skew_lbist
       (
`ifdef USE_POWER_PINS
               .vccd1      (vccd1                      ),// User area 1 1.8V supply
               .vssd1      (vssd1                      ),// User area 1 digital ground
`endif
	       .clk_in     (lbist_clk                  ), 
	       .sel        (cfg_cska_lbist             ), 
	       .clk_out    (lbist_clk_out              ) 
       );

endmodule
