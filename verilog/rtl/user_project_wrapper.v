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
/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */
`include "inc/rvj1_defines.v"
`include "caravel_defines.v"
module user_project_wrapper #(
    parameter BITS = 32
) (
    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

wire clk;
// wire reset;
assign clk = wb_clk_i;
// assign reset = wb_rst_i;
wire hehe_rstn;
assign hehe_rstn = ~la_data_in[1];

wire iram_clk0, iram_csb0_A, iram_csb0_B, iram_web0;
wire [3:0] iram_wmask0;
wire [`IRAM_ADDR_WIDTH_WORDS_PER_MACRO-1:0] iram_addr0;
wire [31:0] iram_din0, iram_dout0_A, iram_dout0_B;

wire dram_clk0, dram_csb0, dram_web0;
wire [3:0]  dram_wmask0;
wire [`DRAM_ADDR_WIDTH_WORDS-1:0] dram_addr0;
wire [31:0] dram_din0, dram_dout0;
wire icache_req_valid;
wire icache_req_ready;
wire [31:0] icache_req_addr;
wire icache_resp_valid;
wire [31:0] insn;
wire icache_resp_ready;
wire [31:0] icache_resp_address;
wire icache_cyc_o;
wire icache_stb_o;
wire icache_we_o;
wire [31:0] icache_adr_o;
wire [9:0] icache_bl_o;
wire icache_bry_o;
wire icache_ack_i;
wire [31:0] icache_dat_i;
wire dcache_req_valid;
wire dcache_req_ready;
wire dcache_opcode;
wire [31:0] dcache_req_addr;
wire [2:0] dcache_type;
wire [63:0] dcache_st_data;
wire dcache_lsq_index;
wire dcache_resp_valid;
wire dcache_resp_ready;
wire [63:0] dcache_resp_data;
wire dcache_rob_index;
wire dcache_cyc_o;
wire dcache_stb_o;
wire dcache_we_o;
wire [31:0] dcache_adr_o;
wire [9:0] dcache_bl_o;
wire dcache_bry_o;
wire dcache_ack_i;
wire [31:0] dcache_dat_i;
wire [31:0] dcache_dat_o;
wire [3:0] dcache_sel_o;

wire [3:0] soc_data_we_o;
wire soc_data_stb_o;
wire soc_data_ack_i;
wire [31:0] soc_data_adr_o;
wire [31:0] soc_data_dat_i;
wire [31:0] soc_data_dat_o;
wire [3:0] soc_data_sel_o;
wire [9:0] soc_data_bl_o;
wire soc_data_bry_o;
wire soc_data_cyc_o;

wire icache_tag_chip_en;
wire icache_tag_write_en;
wire [3:0] icache_write_tag_mask;
wire [7:0] icache_tag_index;
wire [31:0] icache_tag_data_in;
wire [31:0] icache_tag_out;
wire icache_data_chip_en;
wire icache_data_write_en;
wire [3:0] icache_write_data_mask;
wire [7:0] icache_data_index;
wire [31:0] icache_data_in;
wire [31:0] icache_data_out; 

wire dcache_tag_chip_en;
wire dcache_tag_write_en;
wire [3:0] dcache_write_tag_mask;
wire [7:0] dcache_tag_index;
wire [31:0] dcache_tag_data_in;
wire [31:0] dcache_tag_out;
wire dcache_data_chip_en_1;
wire dcache_data_write_en_1;
wire [3:0] dcache_write_data_mask_1;
wire [7:0] dcache_data_index_1;
wire [31:0] dcache_data_in_1;
wire [31:0] dcache_data_out_1;
wire dcache_data_chip_en_2;
wire dcache_data_write_en_2;
wire [3:0] dcache_write_data_mask_2;
wire [7:0] dcache_data_index_2;
wire [31:0] dcache_data_in_2;
wire [31:0] dcache_data_out_2;

rvj1_caravel_soc soc_u(
            .vccd1(vccd1),  // User area 1 1.8V power
            .vssd1(vssd1),  // User area 1 digital ground

            .la_data_in     (la_data_in),
            .la_data_out    (la_data_out),
            .la_oenb        (la_oenb),

            .gpio_in        (io_in[36-1:12]),
            .gpio_out       (io_out[36-1:12]),
            .gpio_oeb       (io_oeb),

            .user_irq       (user_irq),
            
            .wb_clk_i       (wb_clk_i),
            .wb_rst_i       (wb_rst_i),
            .wbs_stb_i      (wbs_stb_i),
            .wbs_cyc_i      (wbs_cyc_i),
            .wbs_we_i       (wbs_we_i),
            .wbs_sel_i      (wbs_sel_i),
            .wbs_dat_i      (wbs_dat_i),
            .wbs_adr_i      (wbs_adr_i),
            .wbs_ack_o      (wbs_ack_o),
            .wbs_dat_o      (wbs_dat_o),
            
            .iram_clk0      (iram_clk0),
            .iram_csb0_A    (iram_csb0_A),
            .iram_csb0_B    (iram_csb0_B),
            .iram_web0      (iram_web0),
            .iram_wmask0    (iram_wmask0),
            .iram_addr0     (iram_addr0),
            .iram_din0      (iram_din0),
            .iram_dout0_A   (iram_dout0_A),
            .iram_dout0_B   (iram_dout0_B),
            
            .dram_clk0      (dram_clk0),
            .dram_csb0      (dram_csb0),
            .dram_web0      (dram_web0),
            .dram_wmask0    (dram_wmask0),
            .dram_addr0     (dram_addr0),
            .dram_din0      (dram_din0),
            .dram_dout0     (dram_dout0),

            .cpu2dmux_we(soc_data_we_o),
            .cpu2dmux_stb(soc_data_stb_o),
            .cpu2dmux_ack(soc_data_ack_i),
            .cpu2dmux_addr(soc_data_adr_o),
            .cpu2dmux_wdata(soc_data_dat_i),
            .cpu2dmux_rdata(soc_data_dat_o),
            .cpu2dmux_sel(soc_data_sel_o),
            .cpu2dmux_bl(soc_data_bl_o),
            .cpu2dmux_bry(soc_data_bry_o),
            .cpu2dmux_cyc(soc_data_cyc_o),

            //I$
            .cpu2imux_rdata(icache_dat_i),
            .cpu2imux_addr(icache_adr_o),
            .cpu2imux_ack(icache_ack_i),
            .cpu2imux_bl(icache_bl_o),
            .cpu2imux_bry(icache_bry_o),
            .cpu2imux_we(icache_we_o),
            .cpu2imux_cyc(icache_cyc_o),
            .cpu2imux_stb(icache_stb_o)
);


wire others_wb_cyc;
wire others_wb_stb;
wire others_wb_we;
wire [VIRTUAL_ADDR_LEN - 1 : 0] others_wb_adr;
wire [WB_DATA_LEN-1:0] others_wb_dat;
wire [WB_DATA_LEN/8-1:0] others_wb_sel;
wire  others_wb_ack;

core_empty core_u (
    .clk(clk),
    .reset(hehe_rstn),

    // others ports
    .others_wb_cyc_o(others_wb_cyc),
    .others_wb_stb_o(others_wb_stb),
    .others_wb_we_o(others_wb_we),
    .others_wb_adr_o(others_wb_adr),
    .others_wb_dat_o(others_wb_dat),
    .others_wb_sel_o(others_wb_sel),
    .others_wb_ack_i(others_wb_ack),
    .others_wb_dat_i(others_wb_dat),

    // Dcache interface
    .dcache_req_valid_o(dcache_req_valid),
    .dcache_opcode(dcache_opcode),
    .dcache_req_addr(dcache_req_addr),
    .dcache_type_o(dcache_type),
    .dcache_st_data_o(dcache_st_data),
    .dcache_resp_ready_o(dcache_resp_ready),
    .dcache2back_resp_valid_i(dcache_resp_valid),
    .back2dcache_lsq_index_o(dcache_lsq_index),
    .dcache2back_resp_data_i(dcache_resp_data), 
    .dcache_req_ready_i(dcache_req_ready),
    .dcache2back_rob_index_i(dcache_rob_index),

    // Icache interface
    .icache_req_valid_o(icache_req_valid),
    .icache_req_ready_i(icache_req_ready),
    .icache_req_addr(icache_req_addr),
    .icache_resp_ready_o(icache_resp_ready),
    .icache_resp_valid_i(icache_resp_valid),
    .icache_resp_address_i(icache_resp_address),
    .insn_i(insn),

    // CSR interupt controller
    .meip(0)

);

wire [31:0] data_dout1;
sky130_sram_1kbyte_1rw1r_32x256_8 iram_inst_A (
					   	.vccd1(vccd1),	// User area 1 1.8V power
						.vssd1(vssd1),	// User area 1 digital ground
    					.clk0   (iram_clk0),
                        .csb0   (iram_csb0_A),
                        .web0   (iram_web0),
                        .wmask0 (iram_wmask0),
                        .addr0  (iram_addr0),
                        .din0   (iram_din0),
                        .dout0  (iram_dout0_A),
                        .clk1 (clk),
                        .csb1 ('1),
                        .addr1 (8'b0),
                        .dout1 (data_dout1));                                             
    
sky130_sram_1kbyte_1rw1r_32x256_8 iram_inst_B (
					   	.vccd1(vccd1),	// User area 1 1.8V power
						.vssd1(vssd1),	// User area 1 digital ground

    					.clk0   (iram_clk0),
                        .csb0   (iram_csb0_B),
                        .web0   (iram_web0),
                        .wmask0 (iram_wmask0),
                        .addr0  (iram_addr0),
                        .din0   (iram_din0),
                        .dout0  (iram_dout0_B),
                        .clk1 (clk),
                        .csb1 ('1),
                        .addr1 (8'b0),
                        .dout1 (data_dout1));  
 


sky130_sram_1kbyte_1rw1r_32x256_8  dram_inst (
							.vccd1(vccd1),	// User area 1 1.8V power
							.vssd1(vssd1),	// User area 1 digital ground

    						.clk0   (dram_clk0),
                            .csb0   (dram_csb0),
                            .web0   (dram_web0),
                            .wmask0 (dram_wmask0),
                            .addr0  (dram_addr0),
                            .din0   (dram_din0),
                            .dout0  (dram_dout0),
                            .clk1 (clk),
                            .csb1 ('1),
                            .addr1 (8'b0),
                            .dout1 (data_dout1));  


l1icache_32 #(
  .VIRTUAL_ADDR_LEN(32),
  .WB_DATA_LEN(32)
)
l1icache_u
(
    .clk (clk),
    .rstn (hehe_rstn),
 
    //req
    .req_valid_i (icache_req_valid),
    .req_ready_o (icache_req_ready),
    .req_addr_i (icache_req_addr),

    //resp
    .resp_valid_o (icache_resp_valid),
    .ld_data_o (insn),
    .resp_ready_i(icache_resp_ready),
    .resp_addr_o(icache_resp_address),

    //sram
    .tag_chip_en (icache_tag_chip_en),
    .tag_write_en (icache_tag_write_en),
    .write_tag_mask (icache_write_tag_mask),
    .tag_index (icache_tag_index),
    .tag_data_in (icache_tag_data_in),
    .tag_out (icache_tag_out),
    .data_chip_en (icache_data_chip_en),
    .data_write_en (icache_data_write_en),
    .write_data_mask (icache_write_data_mask),
    .data_index (icache_data_index),
    .data_in (icache_data_in),
    .data_out (icache_data_out),

    .wb_cyc_o (icache_cyc_o),
    .wb_stb_o (icache_stb_o),
    .wb_we_o (icache_we_o),
    .wb_adr_o (icache_adr_o),
    .wb_bl_o(icache_bl_o),
    .wb_bry_o(icache_bry_o),
    .wb_ack_i (icache_ack_i),
    .wb_dat_i (icache_dat_i)
);


l1dcache #(
  .WB_DATA_LEN(32)
)
l1dcache_u
(
    .clk (clk),
    .rstn (hehe_rstn),
    //req
    .req_valid_i (dcache_req_valid),
    .req_ready_o (dcache_req_ready),
    .opcode (dcache_opcode),
    .req_addr_i (dcache_req_addr),
    .type_i (dcache_type),
    .st_data_i (dcache_st_data),
    .rob_index_i (dcache_lsq_index),

    //resp
    .resp_ready_i (dcache_resp_ready),
    .resp_valid_o (dcache_resp_valid),
    .ld_data_o (dcache_resp_data),
    .rob_index_o (dcache_rob_index),

    .tag_chip_en (dcache_tag_chip_en),
    .tag_write_en (dcache_tag_write_en),
    .write_tag_mask (dcache_write_tag_mask),
    .tag_index (dcache_tag_index),
    .tag_data_in (dcache_tag_data_in),
    .tag_out (dcache_tag_out), 

    .data_chip_en_1 (dcache_data_chip_en_1),
    .data_write_en_1 (dcache_data_write_en_1),
    .write_data_mask_1 (dcache_write_data_mask_1),
    .data_index_1 (dcache_data_index_1),
    .data_in_1 (dcache_data_in_1),
    .data_out_1 (dcache_data_out_1), 

    .data_chip_en_2 (dcache_data_chip_en_2),
    .data_write_en_2 (dcache_data_write_en_2),
    .write_data_mask_2 (dcache_write_data_mask_2),
    .data_index_2 (dcache_data_index_2),
    .data_in_2 (dcache_data_in_2),
    .data_out_2 (dcache_data_out_2), 

    //memory
    .wb_cyc_o (dcache_cyc_o),
    .wb_stb_o (dcache_stb_o),
    .wb_we_o (dcache_we_o),
    .wb_adr_o (dcache_adr_o),
    .wb_dat_o (dcache_dat_o),
    .wb_sel_o (dcache_sel_o),
    .wb_bl_o (dcache_bl_o),
    .wb_bry_o(dcache_bry_o),
    .wb_ack_i (dcache_ack_i),
    .wb_dat_i (dcache_dat_i)
    
);

sky130_sram_1kbyte_1rw1r_32x256_8  icache_tag_ram (
							.vccd1(vccd1),	// User area 1 1.8V power
							.vssd1(vssd1),	// User area 1 digital ground

    						.clk0   (clk),
                            .csb0   (icache_tag_chip_en),
                            .web0   (icache_tag_write_en),
                            .wmask0 (icache_write_tag_mask),
                            .addr0  (icache_tag_index),
                            .din0   (icache_tag_data_in),
                            .dout0  (icache_tag_out),
                            .clk1 (clk),
                            .csb1 ('1),
                            .addr1 (8'b0),
                            .dout1 (data_dout1));  


sky130_sram_1kbyte_1rw1r_32x256_8  icache_data_ram (
							.vccd1(vccd1),	// User area 1 1.8V power
							.vssd1(vssd1),	// User area 1 digital ground

    						.clk0   (clk),
                            .csb0   (icache_data_chip_en),
                            .web0   (icache_data_write_en),
                            .wmask0 (icache_write_data_mask),
                            .addr0  (icache_data_index),
                            .din0   (icache_data_in),
                            .dout0  (icache_data_out),
                            .clk1 (clk),
                            .csb1 ('1),
                            .addr1 (8'b0),
                            .dout1 (data_dout1));  

sky130_sram_1kbyte_1rw1r_32x256_8  dcache_tag_ram (
							.vccd1(vccd1),	// User area 1 1.8V power
							.vssd1(vssd1),	// User area 1 digital ground

    						.clk0   (clk),
                            .csb0   (dcache_tag_chip_en),
                            .web0   (dcache_tag_write_en),
                            .wmask0 (dcache_write_tag_mask),
                            .addr0  (dcache_tag_index),
                            .din0   (dcache_tag_data_in),
                            .dout0  (dcache_tag_out),
                            .clk1 (clk),
                            .csb1 ('1),
                            .addr1 (8'b0),
                            .dout1 (data_dout1));  

sky130_sram_1kbyte_1rw1r_32x256_8  dcache_data_ram_1 (
							.vccd1(vccd1),	// User area 1 1.8V power
							.vssd1(vssd1),	// User area 1 digital ground

    						.clk0   (clk),
                            .csb0   (dcache_data_chip_en_1),
                            .web0   (dcache_data_write_en_1),
                            .wmask0 (dcache_write_data_mask_1),
                            .addr0  (dcache_data_index_1),
                            .din0   (dcache_data_in_1),
                            .dout0  (dcache_data_out_1),
                            .clk1 (clk),
                            .csb1 ('1),
                            .addr1 (8'b0),
                            .dout1 (data_dout1));   


sky130_sram_1kbyte_1rw1r_32x256_8  dcache_data_ram_2 (
							.vccd1(vccd1),	// User area 1 1.8V power
							.vssd1(vssd1),	// User area 1 digital ground

    						.clk0   (clk),
                            .csb0   (dcache_data_chip_en_2),
                            .web0   (dcache_data_write_en_2),
                            .wmask0 (dcache_write_data_mask_2),
                            .addr0  (dcache_data_index_2),
                            .din0   (dcache_data_in_2),
                            .dout0  (dcache_data_out_2),
                            .clk1 (clk),
                            .csb1 ('1),
                            .addr1 (8'b0),
                            .dout1 (data_dout1));  

bus_arbiter arbiter_u(
    .clk(clk), 
    .reset(hehe_rstn),

    .m2_others_wbd_dat_i(others_wb_dat),
    .m2_others_wbd_adr_i(others_wb_adr), 
    .m2_others_wbd_sel_i(others_wb_sel),
    .m2_others_wbd_we_i(others_wb_we),
    .m2_others_wbd_cyc_i(others_wb_cyc),
    .m2_others_wbd_stb_i(others_wb_stb),
    .m2_others_wbd_dat_o(others_wb_dat),
    .m2_others_wbd_ack_o(others_wb_ack),
        //加上突发
    .m2_dcache_wbd_dat_i(dcache_dat_o), 
    .m2_dcache_wbd_adr_i(dcache_adr_o), 
    .m2_dcache_wbd_sel_i(dcache_sel_o),
    .m2_dcache_wbd_we_i(dcache_we_o),
    .m2_dcache_wbd_cyc_i(dcache_cyc_o),
    .m2_dcache_wbd_stb_i(dcache_stb_o),
    .m2_dcache_wbd_dat_o(dcache_dat_i),
    .m2_dcache_wbd_ack_o(dcache_ack_i), 

    .m2_wbd_dat_o(soc_data_dat_o), 
    .m2_wbd_adr_o(soc_data_adr_o), 
    .m2_wbd_sel_o(soc_data_sel_o),
    .m2_wbd_bl_o(soc_data_bl_o),
    .m2_wbd_bry_o(soc_data_bry_o),
    .m2_wbd_we_o(soc_data_we_o),
    .m2_wbd_cyc_o(soc_data_cyc_o),
    .m2_wbd_stb_o(soc_data_stb_o),
    .m2_wbd_dat_i(soc_data_dat_i),
    .m2_wbd_ack_i(soc_data_ack_i)
);

endmodule	// user_project_wrapper

`default_nettype wire
