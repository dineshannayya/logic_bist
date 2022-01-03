// SPDX-FileCopyrightText: 2020 Efabless Corporation
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

`default_nettype none

`timescale 1 ns / 1 ps

`include "uprj_netlists.v"
`include "caravel_netlists.v"
`include "spiflash.v"
`include "uart_agent.v"

module uart_master_tb;
	reg clock;
	reg RSTB;
	reg CSB;
	reg power1, power2;
	reg power3, power4;

	wire gpio;
	wire [37:0] mprj_io;
	wire [7:0] mprj_io_0;
	wire [15:0] checkbits;

//----------------------------------
// Uart Configuration
// ---------------------------------
reg [1:0]      uart_data_bit        ;
reg	       uart_stop_bits       ; // 0: 1 stop bit; 1: 2 stop bit;
reg	       uart_stick_parity    ; // 1: force even parity
reg	       uart_parity_en       ; // parity enable
reg	       uart_even_odd_parity ; // 0: odd parity; 1: even parity

reg [7:0]      uart_data            ;
reg [15:0]     uart_divisor         ;	// divided by n * 16
reg [15:0]     uart_timeout         ;// wait time limit

reg [15:0]     uart_rx_nu           ;
reg [15:0]     uart_tx_nu           ;
reg [7:0]      uart_write_data [0:39];
reg 	       uart_fifo_enable     ;	// fifo mode disable

reg [31:0]     read_data     ;
reg            flag;
reg            test_fail     ;


	assign checkbits = mprj_io[31:16];

	assign mprj_io[3] = (CSB == 1'b1) ? 1'b1 : 1'bz;

	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.

	always #12.5 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
	end

	`ifdef WFDUMP
	initial begin
		$dumpfile("simx.vcd");
		$dumpvars(1, uart_master_tb);
		$dumpvars(1, uart_master_tb.uut);
		$dumpvars(1, uart_master_tb.uut.mprj);
		$dumpvars(1, uart_master_tb.uut.mprj.u_wb_host);
		$dumpvars(1, uart_master_tb.uut.mprj.u_wb_host.u_uart2wb);
		$dumpvars(1, uart_master_tb.tb_master_uart);
		//$dumpvars(2, uart_master_tb.uut.mprj.u_pinmux);
	end
       `endif

	initial begin

		// Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (400) begin
			repeat (1000) @(posedge clock);
			// $display("+1000 cycles");
		end
		$display("%c[1;31m",27);
		$display ("##########################################################");
		`ifdef GL
		   $display ("Monitor: Timeout, Test UART Master (GL) Failed");
		`else
		   $display ("Monitor: Timeout, Test UART Master (RTL) Failed");
		`endif
		$display ("##########################################################");
		$display("%c[0m",27);
		$finish;
	end

	initial begin
            uart_data_bit           = 2'b11;
            uart_stop_bits          = 1; // 0: 1 stop bit; 1: 2 stop bit;
            uart_stick_parity       = 0; // 1: force even parity
            uart_parity_en          = 0; // parity enable
            uart_even_odd_parity    = 1; // 0: odd parity; 1: even parity
            uart_divisor            = 15;// divided by n * 16
            uart_timeout            = 600;// wait time limit
            uart_fifo_enable        = 0;	// fifo mode disable
            tb_master_uart.debug_mode = 0; // disable debug display
            tb_master_uart.uart_init;
            tb_master_uart.control_setup (uart_data_bit, uart_stop_bits, uart_parity_en, uart_even_odd_parity, 
        	                          uart_stick_parity, uart_timeout, uart_divisor);
	   wait(checkbits == 16'h AB60);
		$display("Monitor: UART Master Test Started");

           repeat (4000) @(posedge clock);
           //$write ("\n(%t)Response:\n",$time);
           flag = 0;
           while(flag == 0)
           begin
                tb_master_uart.read_char(read_data,flag);
                $write ("%c",read_data);
           end



           // Remove Wb Reset
           uartm_reg_write('h3080_0000,'h1);

           repeat (2) @(posedge clock);
           #1;

           $display("Monitor: Writing  expected value");
           
           test_fail = 0;
           uartm_reg_read_check(32'h30000000,32'h44332211);
           uartm_reg_read_check(32'h30000004,32'hDDCCBBAA);

           uartm_reg_write(32'h30020000,32'h11223344);
           uartm_reg_write(32'h30020004,32'h22334455);

           uartm_reg_read_check(32'h30000000,32'h11223344);
           uartm_reg_read_check(32'h30000004,32'h22334455);

           $display("###################################################");
           if(test_fail == 0) begin
              `ifdef GL
                  $display("Monitor: Standalone User UART Master (GL) Passed");
              `else
                  $display("Monitor: Standalone User Uart Master (RTL) Passed");
              `endif
           end else begin
               `ifdef GL
                   $display("Monitor: Standalone User Uart Master (GL) Failed");
               `else
                   $display("Monitor: Standalone User Uart Master (RTL) Failed");
               `endif
            end
           $display("###################################################");
           #100

	    $finish;
	end

	initial begin
		RSTB <= 1'b0;
		CSB  <= 1'b1;		// Force CSB high
		#2000;
		RSTB <= 1'b1;	    	// Release reset
		#170000;
		CSB = 1'b0;		// CSB can be released
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		power3 <= 1'b0;
		power4 <= 1'b0;
		#100;
		power1 <= 1'b1;
		#100;
		power2 <= 1'b1;
		#100;
		power3 <= 1'b1;
		#100;
		power4 <= 1'b1;
	end

	//always @(mprj_io) begin
	//	#1 $display("MPRJ-IO state = %b ", mprj_io[7:0]);
	//end

	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD3V3 = power1;
	wire VDD1V8 = power2;
	wire USER_VDD3V3 = power3;
	wire USER_VDD1V8 = power4;
	wire VSS = 1'b0;

	caravel uut (
		.vddio	  (VDD3V3),
		.vssio	  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (USER_VDD3V3),
		.vdda2    (USER_VDD3V3),
		.vssa1	  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (USER_VDD1V8),
		.vccd2	  (USER_VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock	  (clock),
		.gpio     (gpio),
        .mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("uart_master.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);




`ifndef GL // Drive Power for Hold Fix Buf
    // All standard cell need power hook-up for functionality work
    initial begin
    end
`endif    


//---------------------------
//  UART Agent integration
// --------------------------
wire uart_txd,uart_rxd;

assign uart_txd   = mprj_io[1];
assign mprj_io[0]  = uart_rxd ;
 
uart_agent tb_master_uart(
	.mclk                (clock              ),
	.txd                 (uart_rxd           ),
	.rxd                 (uart_txd           )
	);


`include "uart_master_tasks.sv"

endmodule
`default_nettype wire
