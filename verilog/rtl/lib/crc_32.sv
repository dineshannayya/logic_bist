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
////  crc_32.v: CRC is generated on when run is asserted.         ////
////            The 32-bit crc shift register is reset to         ////
////            all 1's when either clear asserted                ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 28 Nov 2021, Dinesh A                             ////
////          Initial Version                                     ////
//////////////////////////////////////////////////////////////////////

module crc_32 (
	      // List of outputs.
	      output logic [31:0] crc_out,
	      
	      // List of inputs
	      input logic  run,    // when asserted, crc is generated
	      input logic  clear , // When asserted crc is re-initialized
              input logic [7:0] data_in,
	      input logic  mclk,
	      input logic  reset_n
                );
  

//----------------------------------	
// define local signals here.
//----------------------------------	
  
  logic[31:0]	current_crc, next_crc;
  

  assign crc_out = ~current_crc;
  
  // 32-bit crc shift register for crc calculation.
  
  always @(posedge mclk or negedge reset_n)
    begin
      if (!reset_n)
	begin
	  current_crc <= 32'hffffffff;
	end
      else
	begin
	  if (clear )
	    begin
	      current_crc <= 32'hffffffff;
	    end
	  else if (run)  // generate crc 
	    begin
	      current_crc <= next_crc;
	    end // else: !if(tx_reset_crc )
	end // else: !if(reset_n)
    end // always @ (posedge mclk or negedge reset_n)

  // combinational logic to generate next_crc
  
  always_comb 
    begin

            next_crc[0]  = current_crc[8] ^ current_crc[2] ^ data_in[2];
	    next_crc[1]  = current_crc[9] ^ current_crc[0] ^ data_in[0] ^
	                   current_crc[3] ^ data_in[3]; 
	    next_crc[2]  = current_crc[10] ^ current_crc[0] ^ data_in[0] ^
	                   current_crc[1] ^ data_in[1] ^ current_crc[4]  ^
		           data_in[4];
	    next_crc[3]  = current_crc[11] ^ current_crc[1] ^ data_in[1] ^
	                   current_crc[2] ^ data_in[2] ^ current_crc[5]  ^
		           data_in[5];
	    next_crc[4]  = current_crc[12] ^ current_crc[2] ^ data_in[2] ^
	                   current_crc[3] ^ data_in[3] ^ current_crc[6]  ^
		           current_crc[0] ^ data_in[0] ^ data_in[6];
	    next_crc[5]  = current_crc[13] ^ current_crc[3] ^ data_in[3] ^
	                   current_crc[4] ^ data_in[4] ^ current_crc[7]  ^
		           current_crc[1] ^ data_in[1] ^ data_in[7];
	    next_crc[6]  = current_crc[14] ^ current_crc[4] ^ data_in[4] ^
	                   current_crc[5] ^ data_in[5];
	    next_crc[7]  = current_crc[15] ^ current_crc[5] ^ data_in[5] ^
	                   current_crc[6] ^ current_crc[0] ^ data_in[0]  ^
		           data_in[6];
	    next_crc[8]  = current_crc[16] ^ current_crc[0] ^ data_in[0] ^
	                   current_crc[6] ^ current_crc[0] ^ data_in[0]  ^
		           data_in[6] ^ current_crc[7] ^ current_crc[1]  ^
		           data_in[1] ^ data_in[7];
	    next_crc[9]  = current_crc[17] ^ current_crc[1] ^ data_in[1] ^
	                   current_crc[7] ^ current_crc[1] ^ data_in[1]  ^
		           data_in[7];
	    next_crc[10]  = current_crc[18] ^ current_crc[2] ^ data_in[2];
	    next_crc[11]  = current_crc[19] ^ current_crc[3] ^ data_in[3];
	    next_crc[12]  = current_crc[20] ^ current_crc[0] ^ data_in[0] ^
	                    current_crc[4] ^ data_in[4];
	    next_crc[13]  = current_crc[21] ^ current_crc[0] ^ data_in[0] ^
	                    current_crc[1] ^ data_in[1] ^ current_crc[5]  ^
		            data_in[5];
	    next_crc[14]  = current_crc[22] ^ current_crc[0] ^ data_in[0] ^
	                    current_crc[1] ^ data_in[1] ^ current_crc[2]  ^
		            data_in[2] ^ current_crc[6] ^ current_crc[0]  ^
		            data_in[0] ^ data_in[6];
	    next_crc[15]  = current_crc[23] ^ current_crc[1] ^ data_in[1] ^
	                    current_crc[2] ^ data_in[2] ^ current_crc[3]  ^
		            data_in[3] ^ current_crc[7] ^ current_crc[1]  ^
		            data_in[1] ^ data_in[7];
	    next_crc[16]  = current_crc[24] ^ current_crc[0] ^ data_in[0] ^
	                    current_crc[2] ^ data_in[2] ^ current_crc[3]  ^
		            data_in[3] ^ current_crc[4] ^ data_in[4];
	    next_crc[17]  = current_crc[25] ^ current_crc[0] ^ data_in[0] ^
	                    current_crc[1] ^ data_in[1] ^ current_crc[3]  ^
		            data_in[3] ^ current_crc[4] ^ data_in[4]  ^
		            current_crc[5] ^ data_in[5]; 
	    next_crc[18]  = current_crc[26] ^ current_crc[1] ^ data_in[1] ^
	                    current_crc[2] ^ data_in[2] ^ current_crc[4]  ^
		            data_in[4] ^ current_crc[5] ^ data_in[5]  ^
		            current_crc[6] ^ current_crc[0] ^ data_in[0]  ^
		            data_in[6];
	    next_crc[19]  = current_crc[27] ^ current_crc[0] ^ data_in[0] ^
	                    current_crc[2] ^ data_in[2] ^ current_crc[3]  ^
		            data_in[3] ^ current_crc[5] ^ data_in[5]  ^
		            current_crc[6] ^ current_crc[0] ^ data_in[0]  ^
		            data_in[6] ^ current_crc[7] ^ current_crc[1]  ^
		            data_in[1] ^ data_in[7];
	    next_crc[20]  = current_crc[28] ^ current_crc[0] ^ data_in[0] ^
	                    current_crc[1] ^ data_in[1] ^ current_crc[3]  ^
		            data_in[3] ^ current_crc[4] ^ data_in[4]  ^
		            current_crc[6] ^ current_crc[0] ^ data_in[0]  ^
		            data_in[6] ^ current_crc[7] ^ current_crc[1]  ^
		            data_in[1] ^ data_in[7];
	    next_crc[21]  = current_crc[29] ^ current_crc[1] ^ data_in[1] ^
                            current_crc[2] ^ data_in[2] ^ current_crc[4]  ^
                            data_in[4] ^ current_crc[5] ^ data_in[5]  ^
                            current_crc[7] ^ current_crc[1] ^ data_in[1]  ^ 
                            data_in[7];
	    next_crc[22]  = current_crc[30] ^ current_crc[0] ^ data_in[0] ^
                            current_crc[2] ^ data_in[2] ^ current_crc[3]  ^
                            data_in[3] ^ current_crc[5] ^ data_in[5]  ^
                            current_crc[6] ^ current_crc[0] ^ data_in[0]  ^
                            data_in[6];
	    next_crc[23]  = current_crc[31] ^ current_crc[0] ^ data_in[0] ^
                            current_crc[1] ^ data_in[1] ^ current_crc[3]  ^
                            data_in[3] ^ current_crc[4] ^ data_in[4]  ^
                            current_crc[6] ^ current_crc[0] ^ data_in[0]  ^
                            data_in[6] ^ current_crc[7] ^ current_crc[1]  ^
                            data_in[1] ^ data_in[7];
	    next_crc[24]  = current_crc[0] ^ data_in[0] ^ current_crc[1]  ^ 
                            data_in[1] ^ current_crc[2] ^ data_in[2]    ^
                            current_crc[4] ^ data_in[4] ^ current_crc[5]  ^
                            data_in[5] ^ current_crc[7] ^ current_crc[1]  ^
                            data_in[1] ^ data_in[7];
	    next_crc[25]  = current_crc[1] ^ data_in[1] ^ current_crc[2]  ^ 
	                    data_in[2] ^ current_crc[3] ^ data_in[3]    ^ 
                            current_crc[5] ^ data_in[5] ^ current_crc[6]  ^ 
                            current_crc[0]  ^ data_in[0] ^ data_in[6]; 
	    next_crc[26]  = current_crc[2] ^ data_in[2] ^ current_crc[3]  ^ 
                            data_in[3] ^ current_crc[4] ^ data_in[4]    ^ 
                            current_crc[6] ^ current_crc[0] ^ data_in[0]  ^ 
                            data_in[6]  ^ current_crc[7] ^ current_crc[1] ^ 
                            data_in[1]  ^ data_in[7];
	    next_crc[27]  = current_crc[3] ^ data_in[3] ^ current_crc[4]  ^ 
                            data_in[4] ^ current_crc[5] ^ data_in[5]    ^ 
                            current_crc[7] ^ current_crc[1] ^ data_in[1]  ^ 
                            data_in[7];
	    next_crc[28]  = current_crc[4] ^data_in[4] ^ current_crc[5]   ^ 
                            data_in[5] ^ current_crc[6] ^ current_crc[0]  ^ 
                            data_in[0] ^ data_in[6];
	    next_crc[29]  = current_crc[5] ^ data_in[5] ^ current_crc[6]  ^ 
                            current_crc[0] ^ data_in[0] ^ data_in[6]    ^ 
                            current_crc[7] ^ current_crc[1] ^ data_in[1]  ^ 
                            data_in[7];
	    next_crc[30]  = current_crc[6] ^ current_crc[0] ^ data_in[0]  ^ 
                            data_in[6] ^ current_crc[7] ^ current_crc[1]  ^
                            data_in[1] ^ data_in[7];
	    next_crc[31]  = current_crc[7] ^ current_crc[1] ^ data_in[1] ^ 
                            data_in[7];
    end   // always
  
endmodule
