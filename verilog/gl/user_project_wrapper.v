module user_project_wrapper (user_clock2,
    vccd1,
    vccd2,
    vdda1,
    vdda2,
    vssa1,
    vssa2,
    vssd1,
    vssd2,
    wb_clk_i,
    wb_rst_i,
    wbs_ack_o,
    wbs_cyc_i,
    wbs_stb_i,
    wbs_we_i,
    analog_io,
    io_in,
    io_oeb,
    io_out,
    la_data_in,
    la_data_out,
    la_oenb,
    user_irq,
    wbs_adr_i,
    wbs_dat_i,
    wbs_dat_o,
    wbs_sel_i);
 input user_clock2;
 input vccd1;
 input vccd2;
 input vdda1;
 input vdda2;
 input vssa1;
 input vssa2;
 input vssd1;
 input vssd2;
 input wb_clk_i;
 input wb_rst_i;
 output wbs_ack_o;
 input wbs_cyc_i;
 input wbs_stb_i;
 input wbs_we_i;
 inout [28:0] analog_io;
 input [37:0] io_in;
 output [37:0] io_oeb;
 output [37:0] io_out;
 input [127:0] la_data_in;
 output [127:0] la_data_out;
 input [127:0] la_oenb;
 output [2:0] user_irq;
 input [31:0] wbs_adr_i;
 input [31:0] wbs_dat_i;
 output [31:0] wbs_dat_o;
 input [3:0] wbs_sel_i;

 wire bist_clk;
 wire bist_correct;
 wire bist_done;
 wire bist_en;
 wire bist_error;
 wire \bist_error_cnt[0] ;
 wire \bist_error_cnt[1] ;
 wire \bist_error_cnt[2] ;
 wire \bist_error_cnt[3] ;
 wire bist_load;
 wire bist_rst_n;
 wire bist_run;
 wire bist_sdi;
 wire bist_sdo;
 wire bist_shift;
 wire \func_addr_a[10] ;
 wire \func_addr_a[2] ;
 wire \func_addr_a[3] ;
 wire \func_addr_a[4] ;
 wire \func_addr_a[5] ;
 wire \func_addr_a[6] ;
 wire \func_addr_a[7] ;
 wire \func_addr_a[8] ;
 wire \func_addr_a[9] ;
 wire \func_addr_b[10] ;
 wire \func_addr_b[2] ;
 wire \func_addr_b[3] ;
 wire \func_addr_b[4] ;
 wire \func_addr_b[5] ;
 wire \func_addr_b[6] ;
 wire \func_addr_b[7] ;
 wire \func_addr_b[8] ;
 wire \func_addr_b[9] ;
 wire func_cen_a;
 wire func_cen_b;
 wire func_clk_a;
 wire func_clk_b;
 wire \func_din_b[0] ;
 wire \func_din_b[10] ;
 wire \func_din_b[11] ;
 wire \func_din_b[12] ;
 wire \func_din_b[13] ;
 wire \func_din_b[14] ;
 wire \func_din_b[15] ;
 wire \func_din_b[16] ;
 wire \func_din_b[17] ;
 wire \func_din_b[18] ;
 wire \func_din_b[19] ;
 wire \func_din_b[1] ;
 wire \func_din_b[20] ;
 wire \func_din_b[21] ;
 wire \func_din_b[22] ;
 wire \func_din_b[23] ;
 wire \func_din_b[24] ;
 wire \func_din_b[25] ;
 wire \func_din_b[26] ;
 wire \func_din_b[27] ;
 wire \func_din_b[28] ;
 wire \func_din_b[29] ;
 wire \func_din_b[2] ;
 wire \func_din_b[30] ;
 wire \func_din_b[31] ;
 wire \func_din_b[3] ;
 wire \func_din_b[4] ;
 wire \func_din_b[5] ;
 wire \func_din_b[6] ;
 wire \func_din_b[7] ;
 wire \func_din_b[8] ;
 wire \func_din_b[9] ;
 wire \func_dout_a[0] ;
 wire \func_dout_a[10] ;
 wire \func_dout_a[11] ;
 wire \func_dout_a[12] ;
 wire \func_dout_a[13] ;
 wire \func_dout_a[14] ;
 wire \func_dout_a[15] ;
 wire \func_dout_a[16] ;
 wire \func_dout_a[17] ;
 wire \func_dout_a[18] ;
 wire \func_dout_a[19] ;
 wire \func_dout_a[1] ;
 wire \func_dout_a[20] ;
 wire \func_dout_a[21] ;
 wire \func_dout_a[22] ;
 wire \func_dout_a[23] ;
 wire \func_dout_a[24] ;
 wire \func_dout_a[25] ;
 wire \func_dout_a[26] ;
 wire \func_dout_a[27] ;
 wire \func_dout_a[28] ;
 wire \func_dout_a[29] ;
 wire \func_dout_a[2] ;
 wire \func_dout_a[30] ;
 wire \func_dout_a[31] ;
 wire \func_dout_a[3] ;
 wire \func_dout_a[4] ;
 wire \func_dout_a[5] ;
 wire \func_dout_a[6] ;
 wire \func_dout_a[7] ;
 wire \func_dout_a[8] ;
 wire \func_dout_a[9] ;
 wire \func_mask_b[0] ;
 wire \func_mask_b[1] ;
 wire \func_mask_b[2] ;
 wire \func_mask_b[3] ;
 wire func_web_b;
 wire \mem_addr_a[10] ;
 wire \mem_addr_a[2] ;
 wire \mem_addr_a[3] ;
 wire \mem_addr_a[4] ;
 wire \mem_addr_a[5] ;
 wire \mem_addr_a[6] ;
 wire \mem_addr_a[7] ;
 wire \mem_addr_a[8] ;
 wire \mem_addr_a[9] ;
 wire \mem_addr_b[10] ;
 wire \mem_addr_b[2] ;
 wire \mem_addr_b[3] ;
 wire \mem_addr_b[4] ;
 wire \mem_addr_b[5] ;
 wire \mem_addr_b[6] ;
 wire \mem_addr_b[7] ;
 wire \mem_addr_b[8] ;
 wire \mem_addr_b[9] ;
 wire mem_cen_a;
 wire mem_cen_b;
 wire mem_clk_a;
 wire mem_clk_b;
 wire mem_clk_out;
 wire \mem_din_b[0] ;
 wire \mem_din_b[10] ;
 wire \mem_din_b[11] ;
 wire \mem_din_b[12] ;
 wire \mem_din_b[13] ;
 wire \mem_din_b[14] ;
 wire \mem_din_b[15] ;
 wire \mem_din_b[16] ;
 wire \mem_din_b[17] ;
 wire \mem_din_b[18] ;
 wire \mem_din_b[19] ;
 wire \mem_din_b[1] ;
 wire \mem_din_b[20] ;
 wire \mem_din_b[21] ;
 wire \mem_din_b[22] ;
 wire \mem_din_b[23] ;
 wire \mem_din_b[24] ;
 wire \mem_din_b[25] ;
 wire \mem_din_b[26] ;
 wire \mem_din_b[27] ;
 wire \mem_din_b[28] ;
 wire \mem_din_b[29] ;
 wire \mem_din_b[2] ;
 wire \mem_din_b[30] ;
 wire \mem_din_b[31] ;
 wire \mem_din_b[3] ;
 wire \mem_din_b[4] ;
 wire \mem_din_b[5] ;
 wire \mem_din_b[6] ;
 wire \mem_din_b[7] ;
 wire \mem_din_b[8] ;
 wire \mem_din_b[9] ;
 wire \mem_dout_a[0] ;
 wire \mem_dout_a[10] ;
 wire \mem_dout_a[11] ;
 wire \mem_dout_a[12] ;
 wire \mem_dout_a[13] ;
 wire \mem_dout_a[14] ;
 wire \mem_dout_a[15] ;
 wire \mem_dout_a[16] ;
 wire \mem_dout_a[17] ;
 wire \mem_dout_a[18] ;
 wire \mem_dout_a[19] ;
 wire \mem_dout_a[1] ;
 wire \mem_dout_a[20] ;
 wire \mem_dout_a[21] ;
 wire \mem_dout_a[22] ;
 wire \mem_dout_a[23] ;
 wire \mem_dout_a[24] ;
 wire \mem_dout_a[25] ;
 wire \mem_dout_a[26] ;
 wire \mem_dout_a[27] ;
 wire \mem_dout_a[28] ;
 wire \mem_dout_a[29] ;
 wire \mem_dout_a[2] ;
 wire \mem_dout_a[30] ;
 wire \mem_dout_a[31] ;
 wire \mem_dout_a[3] ;
 wire \mem_dout_a[4] ;
 wire \mem_dout_a[5] ;
 wire \mem_dout_a[6] ;
 wire \mem_dout_a[7] ;
 wire \mem_dout_a[8] ;
 wire \mem_dout_a[9] ;
 wire \mem_mask_b[0] ;
 wire \mem_mask_b[1] ;
 wire \mem_mask_b[2] ;
 wire \mem_mask_b[3] ;
 wire mem_web_b;

 mbist_top u_mbist (.bist_clk(bist_clk),
    .bist_correct(bist_correct),
    .bist_done(bist_done),
    .bist_en(bist_en),
    .bist_error(bist_error),
    .bist_load(bist_load),
    .bist_run(bist_run),
    .bist_sdi(bist_sdi),
    .bist_sdo(bist_sdo),
    .bist_shift(bist_shift),
    .func_cen_a(func_cen_a),
    .func_cen_b(func_cen_b),
    .func_clk_a(func_clk_a),
    .func_clk_b(func_clk_b),
    .func_web_b(func_web_b),
    .mem_cen_a(mem_cen_a),
    .mem_cen_b(mem_cen_b),
    .mem_clk_a(mem_clk_a),
    .mem_clk_b(mem_clk_b),
    .mem_web_b(mem_web_b),
    .rst_n(bist_rst_n),
    .vccd1(vccd1),
    .vssd1(vssd1),
    .bist_error_cnt({\bist_error_cnt[3] ,
    \bist_error_cnt[2] ,
    \bist_error_cnt[1] ,
    \bist_error_cnt[0] }),
    .func_addr_a({\func_addr_a[10] ,
    \func_addr_a[9] ,
    \func_addr_a[8] ,
    \func_addr_a[7] ,
    \func_addr_a[6] ,
    \func_addr_a[5] ,
    \func_addr_a[4] ,
    \func_addr_a[3] ,
    \func_addr_a[2] }),
    .func_addr_b({\func_addr_b[10] ,
    \func_addr_b[9] ,
    \func_addr_b[8] ,
    \func_addr_b[7] ,
    \func_addr_b[6] ,
    \func_addr_b[5] ,
    \func_addr_b[4] ,
    \func_addr_b[3] ,
    \func_addr_b[2] }),
    .func_din_b({\func_din_b[31] ,
    \func_din_b[30] ,
    \func_din_b[29] ,
    \func_din_b[28] ,
    \func_din_b[27] ,
    \func_din_b[26] ,
    \func_din_b[25] ,
    \func_din_b[24] ,
    \func_din_b[23] ,
    \func_din_b[22] ,
    \func_din_b[21] ,
    \func_din_b[20] ,
    \func_din_b[19] ,
    \func_din_b[18] ,
    \func_din_b[17] ,
    \func_din_b[16] ,
    \func_din_b[15] ,
    \func_din_b[14] ,
    \func_din_b[13] ,
    \func_din_b[12] ,
    \func_din_b[11] ,
    \func_din_b[10] ,
    \func_din_b[9] ,
    \func_din_b[8] ,
    \func_din_b[7] ,
    \func_din_b[6] ,
    \func_din_b[5] ,
    \func_din_b[4] ,
    \func_din_b[3] ,
    \func_din_b[2] ,
    \func_din_b[1] ,
    \func_din_b[0] }),
    .func_dout_a({\func_dout_a[31] ,
    \func_dout_a[30] ,
    \func_dout_a[29] ,
    \func_dout_a[28] ,
    \func_dout_a[27] ,
    \func_dout_a[26] ,
    \func_dout_a[25] ,
    \func_dout_a[24] ,
    \func_dout_a[23] ,
    \func_dout_a[22] ,
    \func_dout_a[21] ,
    \func_dout_a[20] ,
    \func_dout_a[19] ,
    \func_dout_a[18] ,
    \func_dout_a[17] ,
    \func_dout_a[16] ,
    \func_dout_a[15] ,
    \func_dout_a[14] ,
    \func_dout_a[13] ,
    \func_dout_a[12] ,
    \func_dout_a[11] ,
    \func_dout_a[10] ,
    \func_dout_a[9] ,
    \func_dout_a[8] ,
    \func_dout_a[7] ,
    \func_dout_a[6] ,
    \func_dout_a[5] ,
    \func_dout_a[4] ,
    \func_dout_a[3] ,
    \func_dout_a[2] ,
    \func_dout_a[1] ,
    \func_dout_a[0] }),
    .func_mask_b({\func_mask_b[3] ,
    \func_mask_b[2] ,
    \func_mask_b[1] ,
    \func_mask_b[0] }),
    .mem_addr_a({\mem_addr_a[10] ,
    \mem_addr_a[9] ,
    \mem_addr_a[8] ,
    \mem_addr_a[7] ,
    \mem_addr_a[6] ,
    \mem_addr_a[5] ,
    \mem_addr_a[4] ,
    \mem_addr_a[3] ,
    \mem_addr_a[2] }),
    .mem_addr_b({\mem_addr_b[10] ,
    \mem_addr_b[9] ,
    \mem_addr_b[8] ,
    \mem_addr_b[7] ,
    \mem_addr_b[6] ,
    \mem_addr_b[5] ,
    \mem_addr_b[4] ,
    \mem_addr_b[3] ,
    \mem_addr_b[2] }),
    .mem_din_b({\mem_din_b[31] ,
    \mem_din_b[30] ,
    \mem_din_b[29] ,
    \mem_din_b[28] ,
    \mem_din_b[27] ,
    \mem_din_b[26] ,
    \mem_din_b[25] ,
    \mem_din_b[24] ,
    \mem_din_b[23] ,
    \mem_din_b[22] ,
    \mem_din_b[21] ,
    \mem_din_b[20] ,
    \mem_din_b[19] ,
    \mem_din_b[18] ,
    \mem_din_b[17] ,
    \mem_din_b[16] ,
    \mem_din_b[15] ,
    \mem_din_b[14] ,
    \mem_din_b[13] ,
    \mem_din_b[12] ,
    \mem_din_b[11] ,
    \mem_din_b[10] ,
    \mem_din_b[9] ,
    \mem_din_b[8] ,
    \mem_din_b[7] ,
    \mem_din_b[6] ,
    \mem_din_b[5] ,
    \mem_din_b[4] ,
    \mem_din_b[3] ,
    \mem_din_b[2] ,
    \mem_din_b[1] ,
    \mem_din_b[0] }),
    .mem_dout_a({\mem_dout_a[31] ,
    \mem_dout_a[30] ,
    \mem_dout_a[29] ,
    \mem_dout_a[28] ,
    \mem_dout_a[27] ,
    \mem_dout_a[26] ,
    \mem_dout_a[25] ,
    \mem_dout_a[24] ,
    \mem_dout_a[23] ,
    \mem_dout_a[22] ,
    \mem_dout_a[21] ,
    \mem_dout_a[20] ,
    \mem_dout_a[19] ,
    \mem_dout_a[18] ,
    \mem_dout_a[17] ,
    \mem_dout_a[16] ,
    \mem_dout_a[15] ,
    \mem_dout_a[14] ,
    \mem_dout_a[13] ,
    \mem_dout_a[12] ,
    \mem_dout_a[11] ,
    \mem_dout_a[10] ,
    \mem_dout_a[9] ,
    \mem_dout_a[8] ,
    \mem_dout_a[7] ,
    \mem_dout_a[6] ,
    \mem_dout_a[5] ,
    \mem_dout_a[4] ,
    \mem_dout_a[3] ,
    \mem_dout_a[2] ,
    \mem_dout_a[1] ,
    \mem_dout_a[0] }),
    .mem_mask_b({\mem_mask_b[3] ,
    \mem_mask_b[2] ,
    \mem_mask_b[1] ,
    \mem_mask_b[0] }));
 sky130_sram_2kbyte_1rw1r_32x512_8 u_sram_2kb (.csb0(mem_cen_b),
    .csb1(mem_cen_a),
    .web0(mem_web_b),
    .clk0(mem_clk_b),
    .clk1(mem_clk_a),
    .vccd1(vccd1),
    .vssd1(vssd1),
    .addr0({\mem_addr_b[10] ,
    \mem_addr_b[9] ,
    \mem_addr_b[8] ,
    \mem_addr_b[7] ,
    \mem_addr_b[6] ,
    \mem_addr_b[5] ,
    \mem_addr_b[4] ,
    \mem_addr_b[3] ,
    \mem_addr_b[2] }),
    .addr1({\mem_addr_a[10] ,
    \mem_addr_a[9] ,
    \mem_addr_a[8] ,
    \mem_addr_a[7] ,
    \mem_addr_a[6] ,
    \mem_addr_a[5] ,
    \mem_addr_a[4] ,
    \mem_addr_a[3] ,
    \mem_addr_a[2] }),
    .din0({\mem_din_b[31] ,
    \mem_din_b[30] ,
    \mem_din_b[29] ,
    \mem_din_b[28] ,
    \mem_din_b[27] ,
    \mem_din_b[26] ,
    \mem_din_b[25] ,
    \mem_din_b[24] ,
    \mem_din_b[23] ,
    \mem_din_b[22] ,
    \mem_din_b[21] ,
    \mem_din_b[20] ,
    \mem_din_b[19] ,
    \mem_din_b[18] ,
    \mem_din_b[17] ,
    \mem_din_b[16] ,
    \mem_din_b[15] ,
    \mem_din_b[14] ,
    \mem_din_b[13] ,
    \mem_din_b[12] ,
    \mem_din_b[11] ,
    \mem_din_b[10] ,
    \mem_din_b[9] ,
    \mem_din_b[8] ,
    \mem_din_b[7] ,
    \mem_din_b[6] ,
    \mem_din_b[5] ,
    \mem_din_b[4] ,
    \mem_din_b[3] ,
    \mem_din_b[2] ,
    \mem_din_b[1] ,
    \mem_din_b[0] }),
    .dout0({_NC1,
    _NC2,
    _NC3,
    _NC4,
    _NC5,
    _NC6,
    _NC7,
    _NC8,
    _NC9,
    _NC10,
    _NC11,
    _NC12,
    _NC13,
    _NC14,
    _NC15,
    _NC16,
    _NC17,
    _NC18,
    _NC19,
    _NC20,
    _NC21,
    _NC22,
    _NC23,
    _NC24,
    _NC25,
    _NC26,
    _NC27,
    _NC28,
    _NC29,
    _NC30,
    _NC31,
    _NC32}),
    .dout1({\mem_dout_a[31] ,
    \mem_dout_a[30] ,
    \mem_dout_a[29] ,
    \mem_dout_a[28] ,
    \mem_dout_a[27] ,
    \mem_dout_a[26] ,
    \mem_dout_a[25] ,
    \mem_dout_a[24] ,
    \mem_dout_a[23] ,
    \mem_dout_a[22] ,
    \mem_dout_a[21] ,
    \mem_dout_a[20] ,
    \mem_dout_a[19] ,
    \mem_dout_a[18] ,
    \mem_dout_a[17] ,
    \mem_dout_a[16] ,
    \mem_dout_a[15] ,
    \mem_dout_a[14] ,
    \mem_dout_a[13] ,
    \mem_dout_a[12] ,
    \mem_dout_a[11] ,
    \mem_dout_a[10] ,
    \mem_dout_a[9] ,
    \mem_dout_a[8] ,
    \mem_dout_a[7] ,
    \mem_dout_a[6] ,
    \mem_dout_a[5] ,
    \mem_dout_a[4] ,
    \mem_dout_a[3] ,
    \mem_dout_a[2] ,
    \mem_dout_a[1] ,
    \mem_dout_a[0] }),
    .wmask0({\mem_mask_b[3] ,
    \mem_mask_b[2] ,
    \mem_mask_b[1] ,
    \mem_mask_b[0] }));
 wb_host u_wb_host (.bist_clk(bist_clk),
    .bist_correct(bist_correct),
    .bist_done(bist_done),
    .bist_en(bist_en),
    .bist_error(bist_error),
    .bist_load(bist_load),
    .bist_rst_n(bist_rst_n),
    .bist_run(bist_run),
    .bist_sdi(bist_sdi),
    .bist_sdo(bist_sdo),
    .bist_shift(bist_shift),
    .func_cen_a(func_cen_a),
    .func_cen_b(func_cen_b),
    .func_clk_a(func_clk_a),
    .func_clk_b(func_clk_b),
    .func_web_b(func_web_b),
    .mem_clk(mem_clk_out),
    .mem_clk_out(mem_clk_out),
    .user_clock1(wb_clk_i),
    .user_clock2(user_clock2),
    .vccd1(vccd1),
    .vssd1(vssd1),
    .wbm_ack_o(wbs_ack_o),
    .wbm_clk_i(wb_clk_i),
    .wbm_cyc_i(wbs_cyc_i),
    .wbm_rst_i(wb_rst_i),
    .wbm_stb_i(wbs_stb_i),
    .wbm_we_i(wbs_we_i),
    .bist_error_cnt({\bist_error_cnt[3] ,
    \bist_error_cnt[2] ,
    \bist_error_cnt[1] ,
    \bist_error_cnt[0] }),
    .func_addr_a({\func_addr_a[10] ,
    \func_addr_a[9] ,
    \func_addr_a[8] ,
    \func_addr_a[7] ,
    \func_addr_a[6] ,
    \func_addr_a[5] ,
    \func_addr_a[4] ,
    \func_addr_a[3] ,
    \func_addr_a[2] }),
    .func_addr_b({\func_addr_b[10] ,
    \func_addr_b[9] ,
    \func_addr_b[8] ,
    \func_addr_b[7] ,
    \func_addr_b[6] ,
    \func_addr_b[5] ,
    \func_addr_b[4] ,
    \func_addr_b[3] ,
    \func_addr_b[2] }),
    .func_din_b({\func_din_b[31] ,
    \func_din_b[30] ,
    \func_din_b[29] ,
    \func_din_b[28] ,
    \func_din_b[27] ,
    \func_din_b[26] ,
    \func_din_b[25] ,
    \func_din_b[24] ,
    \func_din_b[23] ,
    \func_din_b[22] ,
    \func_din_b[21] ,
    \func_din_b[20] ,
    \func_din_b[19] ,
    \func_din_b[18] ,
    \func_din_b[17] ,
    \func_din_b[16] ,
    \func_din_b[15] ,
    \func_din_b[14] ,
    \func_din_b[13] ,
    \func_din_b[12] ,
    \func_din_b[11] ,
    \func_din_b[10] ,
    \func_din_b[9] ,
    \func_din_b[8] ,
    \func_din_b[7] ,
    \func_din_b[6] ,
    \func_din_b[5] ,
    \func_din_b[4] ,
    \func_din_b[3] ,
    \func_din_b[2] ,
    \func_din_b[1] ,
    \func_din_b[0] }),
    .func_dout_a({\func_dout_a[31] ,
    \func_dout_a[30] ,
    \func_dout_a[29] ,
    \func_dout_a[28] ,
    \func_dout_a[27] ,
    \func_dout_a[26] ,
    \func_dout_a[25] ,
    \func_dout_a[24] ,
    \func_dout_a[23] ,
    \func_dout_a[22] ,
    \func_dout_a[21] ,
    \func_dout_a[20] ,
    \func_dout_a[19] ,
    \func_dout_a[18] ,
    \func_dout_a[17] ,
    \func_dout_a[16] ,
    \func_dout_a[15] ,
    \func_dout_a[14] ,
    \func_dout_a[13] ,
    \func_dout_a[12] ,
    \func_dout_a[11] ,
    \func_dout_a[10] ,
    \func_dout_a[9] ,
    \func_dout_a[8] ,
    \func_dout_a[7] ,
    \func_dout_a[6] ,
    \func_dout_a[5] ,
    \func_dout_a[4] ,
    \func_dout_a[3] ,
    \func_dout_a[2] ,
    \func_dout_a[1] ,
    \func_dout_a[0] }),
    .func_mask_b({\func_mask_b[3] ,
    \func_mask_b[2] ,
    \func_mask_b[1] ,
    \func_mask_b[0] }),
    .io_oeb({io_oeb[37],
    io_oeb[36],
    io_oeb[35],
    io_oeb[34],
    io_oeb[33],
    io_oeb[32],
    io_oeb[31],
    io_oeb[30],
    io_oeb[29],
    io_oeb[28],
    io_oeb[27],
    io_oeb[26],
    io_oeb[25],
    io_oeb[24],
    io_oeb[23],
    io_oeb[22],
    io_oeb[21],
    io_oeb[20],
    io_oeb[19],
    io_oeb[18],
    io_oeb[17],
    io_oeb[16],
    io_oeb[15],
    io_oeb[14],
    io_oeb[13],
    io_oeb[12],
    io_oeb[11],
    io_oeb[10],
    io_oeb[9],
    io_oeb[8],
    io_oeb[7],
    io_oeb[6],
    io_oeb[5],
    io_oeb[4],
    io_oeb[3],
    io_oeb[2],
    io_oeb[1],
    io_oeb[0]}),
    .io_out({io_out[37],
    io_out[36],
    io_out[35],
    io_out[34],
    io_out[33],
    io_out[32],
    io_out[31],
    io_out[30],
    io_out[29],
    io_out[28],
    io_out[27],
    io_out[26],
    io_out[25],
    io_out[24],
    io_out[23],
    io_out[22],
    io_out[21],
    io_out[20],
    io_out[19],
    io_out[18],
    io_out[17],
    io_out[16],
    io_out[15],
    io_out[14],
    io_out[13],
    io_out[12],
    io_out[11],
    io_out[10],
    io_out[9],
    io_out[8],
    io_out[7],
    io_out[6],
    io_out[5],
    io_out[4],
    io_out[3],
    io_out[2],
    io_out[1],
    io_out[0]}),
    .la_data_out({la_data_out[127],
    la_data_out[126],
    la_data_out[125],
    la_data_out[124],
    la_data_out[123],
    la_data_out[122],
    la_data_out[121],
    la_data_out[120],
    la_data_out[119],
    la_data_out[118],
    la_data_out[117],
    la_data_out[116],
    la_data_out[115],
    la_data_out[114],
    la_data_out[113],
    la_data_out[112],
    la_data_out[111],
    la_data_out[110],
    la_data_out[109],
    la_data_out[108],
    la_data_out[107],
    la_data_out[106],
    la_data_out[105],
    la_data_out[104],
    la_data_out[103],
    la_data_out[102],
    la_data_out[101],
    la_data_out[100],
    la_data_out[99],
    la_data_out[98],
    la_data_out[97],
    la_data_out[96],
    la_data_out[95],
    la_data_out[94],
    la_data_out[93],
    la_data_out[92],
    la_data_out[91],
    la_data_out[90],
    la_data_out[89],
    la_data_out[88],
    la_data_out[87],
    la_data_out[86],
    la_data_out[85],
    la_data_out[84],
    la_data_out[83],
    la_data_out[82],
    la_data_out[81],
    la_data_out[80],
    la_data_out[79],
    la_data_out[78],
    la_data_out[77],
    la_data_out[76],
    la_data_out[75],
    la_data_out[74],
    la_data_out[73],
    la_data_out[72],
    la_data_out[71],
    la_data_out[70],
    la_data_out[69],
    la_data_out[68],
    la_data_out[67],
    la_data_out[66],
    la_data_out[65],
    la_data_out[64],
    la_data_out[63],
    la_data_out[62],
    la_data_out[61],
    la_data_out[60],
    la_data_out[59],
    la_data_out[58],
    la_data_out[57],
    la_data_out[56],
    la_data_out[55],
    la_data_out[54],
    la_data_out[53],
    la_data_out[52],
    la_data_out[51],
    la_data_out[50],
    la_data_out[49],
    la_data_out[48],
    la_data_out[47],
    la_data_out[46],
    la_data_out[45],
    la_data_out[44],
    la_data_out[43],
    la_data_out[42],
    la_data_out[41],
    la_data_out[40],
    la_data_out[39],
    la_data_out[38],
    la_data_out[37],
    la_data_out[36],
    la_data_out[35],
    la_data_out[34],
    la_data_out[33],
    la_data_out[32],
    la_data_out[31],
    la_data_out[30],
    la_data_out[29],
    la_data_out[28],
    la_data_out[27],
    la_data_out[26],
    la_data_out[25],
    la_data_out[24],
    la_data_out[23],
    la_data_out[22],
    la_data_out[21],
    la_data_out[20],
    la_data_out[19],
    la_data_out[18],
    la_data_out[17],
    la_data_out[16],
    la_data_out[15],
    la_data_out[14],
    la_data_out[13],
    la_data_out[12],
    la_data_out[11],
    la_data_out[10],
    la_data_out[9],
    la_data_out[8],
    la_data_out[7],
    la_data_out[6],
    la_data_out[5],
    la_data_out[4],
    la_data_out[3],
    la_data_out[2],
    la_data_out[1],
    la_data_out[0]}),
    .wbm_adr_i({wbs_adr_i[31],
    wbs_adr_i[30],
    wbs_adr_i[29],
    wbs_adr_i[28],
    wbs_adr_i[27],
    wbs_adr_i[26],
    wbs_adr_i[25],
    wbs_adr_i[24],
    wbs_adr_i[23],
    wbs_adr_i[22],
    wbs_adr_i[21],
    wbs_adr_i[20],
    wbs_adr_i[19],
    wbs_adr_i[18],
    wbs_adr_i[17],
    wbs_adr_i[16],
    wbs_adr_i[15],
    wbs_adr_i[14],
    wbs_adr_i[13],
    wbs_adr_i[12],
    wbs_adr_i[11],
    wbs_adr_i[10],
    wbs_adr_i[9],
    wbs_adr_i[8],
    wbs_adr_i[7],
    wbs_adr_i[6],
    wbs_adr_i[5],
    wbs_adr_i[4],
    wbs_adr_i[3],
    wbs_adr_i[2],
    wbs_adr_i[1],
    wbs_adr_i[0]}),
    .wbm_dat_i({wbs_dat_i[31],
    wbs_dat_i[30],
    wbs_dat_i[29],
    wbs_dat_i[28],
    wbs_dat_i[27],
    wbs_dat_i[26],
    wbs_dat_i[25],
    wbs_dat_i[24],
    wbs_dat_i[23],
    wbs_dat_i[22],
    wbs_dat_i[21],
    wbs_dat_i[20],
    wbs_dat_i[19],
    wbs_dat_i[18],
    wbs_dat_i[17],
    wbs_dat_i[16],
    wbs_dat_i[15],
    wbs_dat_i[14],
    wbs_dat_i[13],
    wbs_dat_i[12],
    wbs_dat_i[11],
    wbs_dat_i[10],
    wbs_dat_i[9],
    wbs_dat_i[8],
    wbs_dat_i[7],
    wbs_dat_i[6],
    wbs_dat_i[5],
    wbs_dat_i[4],
    wbs_dat_i[3],
    wbs_dat_i[2],
    wbs_dat_i[1],
    wbs_dat_i[0]}),
    .wbm_dat_o({wbs_dat_o[31],
    wbs_dat_o[30],
    wbs_dat_o[29],
    wbs_dat_o[28],
    wbs_dat_o[27],
    wbs_dat_o[26],
    wbs_dat_o[25],
    wbs_dat_o[24],
    wbs_dat_o[23],
    wbs_dat_o[22],
    wbs_dat_o[21],
    wbs_dat_o[20],
    wbs_dat_o[19],
    wbs_dat_o[18],
    wbs_dat_o[17],
    wbs_dat_o[16],
    wbs_dat_o[15],
    wbs_dat_o[14],
    wbs_dat_o[13],
    wbs_dat_o[12],
    wbs_dat_o[11],
    wbs_dat_o[10],
    wbs_dat_o[9],
    wbs_dat_o[8],
    wbs_dat_o[7],
    wbs_dat_o[6],
    wbs_dat_o[5],
    wbs_dat_o[4],
    wbs_dat_o[3],
    wbs_dat_o[2],
    wbs_dat_o[1],
    wbs_dat_o[0]}),
    .wbm_sel_i({wbs_sel_i[3],
    wbs_sel_i[2],
    wbs_sel_i[1],
    wbs_sel_i[0]}));
endmodule
