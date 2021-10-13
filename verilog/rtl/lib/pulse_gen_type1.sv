///////////////////////////////////////////////////////////////////////
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
//------------------------------------------------------------------------
// This module is used to generate 1ms and 1sec pulse based on 1us trigger
// pulse
//------------------------------------------------------------------------

module pulse_gen_type1(
	output logic clk_pulse,

	input logic clk,
        input logic reset_n,
	input logic trigger
);

parameter WD= 10;   // This will count from 0 to 1023
parameter MAX_CNT = 999;

logic [WD-1:0]  cnt;

assign clk_pulse = (cnt == 0) && trigger;

always @ (posedge clk or negedge reset_n)
begin
   if (reset_n == 1'b0) begin 
      cnt <= 'b0;
   end else begin 
      if(trigger) begin
          if(cnt >= MAX_CNT)
              cnt <= 0;
          else
              cnt <= cnt +1;
      end
   end
end

endmodule

