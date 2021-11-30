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
////  Clock Gate with Scan over-ride                              ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 28 Nov 2021, Dinesh A                             ////
////          Initial Version                                     ////
//////////////////////////////////////////////////////////////////////
module clk_gate ( 
	output logic GCLK,  // Gated Clock Out

	input logic CLK, // Functional Clock
	input logic EN,  // Functional Enable
	input logic TE   // SCAN MODE/SCAN Enable
       );

`ifndef SYNTHESIS
   reg clk_enb;
   always_latch begin
       if(CLK == 0)
   	clk_enb = EN | TE;
   end
   
   assign GCLK = clk_enb & CLK;
`else
    sky130_fd_sc_hd__sdlclkp_2 u_clk_gate ( 
	                             .GCLK (GCLK), 
				     .SCE  (TE),
	                             .GATE (EN), 
				     .CLK (CLK)
			           );

`endif

endmodule

