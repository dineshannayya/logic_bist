module lbist_top
   #(parameter SCW = 8   // SCAN CHAIN WIDTH
     )
    (
	// Wishbone Reg I/F
	input logic            wb_clk,
	input logic            wb_rst_n,
	input logic            wb_cs,
	input logic [1:0]      wb_addr,
	input logic            wb_wr,
	input logic [31:0]     wb_wdata,
	input logic [3:0]      wb_be,

	output logic [31:0]    wb_rdata,
	output logic           wb_ack,
	output logic           wb_err,

	// LBIST I/F
	input  logic           lbist_clk,
	input  logic           lbist_clk_skew, // bist clock with additional clock skew


	// Scan Control Signal
	output logic           scan_clk,
	output logic           scan_rst_n,
	output logic           scan_mode,
	output logic           scan_en,
	output logic [SCW-1:0] scan_in,
	input  logic [SCW-1:0] scan_out

);

//----------------------------------------------
// Local Decleration
// ---------------------------------------------

logic           lbist_rst_n        ;
logic           lbist_reg_cs       ;
logic [1:0]     lbist_reg_addr     ;
logic           lbist_reg_wr       ;
logic [31:0]    lbist_reg_wdata    ;
logic [3:0]     lbist_reg_be       ;

logic [31:0]    lbist_reg_rdata    ;
logic           lbist_reg_ack      ;

logic           cfg_lbist_srst     ;
logic           cfg_lbist_start    ; // lbist start
logic           cfg_lbist_rsb      ; // lbist reset scan compare bypass

logic [15:0]    cfg_lbist_pat      ; // Total Scan pattern to be run
logic [15:0]    cfg_chain_depth    ; // Scan chain depth


logic           lbist_done         ;
logic [31:0]    lbist_sig          ;

//------------------------------------
// LBIST Reset Synchronizer
// -----------------------------------

reset_sync  u_lbist_reset (
	      .scan_mode  (1'b0         ),
              .dclk       (lbist_clk_skew), // Destination clock domain
	      .arst_n     (wb_rst_n     ), // active low async reset
              .srst_n     (lbist_rst_n  )
          );

// -------------------------------------------------
// Wishbone to LBIST register Synchronizer
// ------------------------------------------------

async_reg_bus #(.AW(2)) u_async_reg (
    // Initiator declartion
          .in_clk                (wb_clk),
          .in_reset_n            (wb_rst_n),
       // Reg Bus Master
          // outputs
          .in_reg_rdata          (wb_rdata),
          .in_reg_ack            (wb_ack),
          .in_reg_timeout        (wb_err),

          // Inputs
          .in_reg_cs             (wb_cs),
          .in_reg_addr           (wb_addr),
          .in_reg_wdata          (wb_wdata),
          .in_reg_wr             (wb_wr),
          .in_reg_be             (wb_be),

    // Target Declaration
          .out_clk               (lbist_clk_skew),
          .out_reset_n           (lbist_rst_n),
      // Reg Bus Slave
          // output
          .out_reg_cs            (lbist_reg_cs),
          .out_reg_addr          (lbist_reg_addr),
          .out_reg_wdata         (lbist_reg_wdata),
          .out_reg_wr            (lbist_reg_wr),
          .out_reg_be            (lbist_reg_be),

          // Inputs
          .out_reg_rdata         (lbist_reg_rdata),
          .out_reg_ack           (lbist_reg_ack)
   );

//------------------------------
// LBIST local Register
// ----------------------------

lbist_reg u_reg (
       .mclk             (lbist_clk_skew   ),
       .reset_n          (lbist_rst_n      ),


        // Reg Bus Interface Signal
       .reg_cs          (lbist_reg_cs     ),
       .reg_wr          (lbist_reg_wr     ),
       .reg_addr        (lbist_reg_addr   ),
       .reg_wdata       (lbist_reg_wdata  ),
       .reg_be          (lbist_reg_be     ),

       // Outputs
       .reg_rdata       (lbist_reg_rdata  ),
       .reg_ack         (lbist_reg_ack    ),

	// BIST I/F
       .cfg_lbist_rst   (cfg_lbist_srst   ),
       .cfg_lbist_start (cfg_lbist_start  ),  // lbist start
       .cfg_lbist_rsb   (cfg_lbist_rsb    ),  // lbist reset scan bypass
       .cfg_lbist_pat   (cfg_lbist_pat    ),    // Total Scan pattern to be run
       .cfg_chain_depth (cfg_chain_depth  ),    // Scan Chain Depth


       .lbist_done      (lbist_done       ),
       .lbist_sig       (lbist_sig        )


        );

//-----------------------------------------------------
//  LBIST core manges all the scan sequence
//-----------------------------------------------------

lbist_core 
   #(.SCW(SCW)   // SCAN CHAIN WIDTH
     ) 
    
    u_lbist_core (

	.mclk            (lbist_clk         ),
	.mclk_skew       (lbist_clk_skew    ),
	.rst_n           (lbist_rst_n       ),
	.srst            (cfg_lbist_srst    ), // software reset


        // Reg Bus Interface Signal
        .lbist_start     (cfg_lbist_start   ),// ltest start
        .cfg_lbist_rsb   (cfg_lbist_rsb    ),  // lbist reset scan bypass
	.cfg_lbist_pat   (cfg_lbist_pat     ),// Total Scan pattern to be run
        .cfg_chain_depth (cfg_chain_depth   ),    // Scan Chain Depth
	.lbist_done      (lbist_done        ),// End of Ltest 
	.lbist_sig       (lbist_sig         ),// scan signature


	// Scan Control Signal
	.scan_clk       (scan_clk          ),
	.scan_rst_n     (scan_rst_n        ),
	.scan_mode      (scan_mode         ),
	.scan_en        (scan_en           ),
	.scan_in        (scan_in           ),
	.scan_out       (scan_out          )

);








endmodule


