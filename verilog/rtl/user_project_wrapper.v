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
 * THIS FILE HAS BEEN GENERATED USING multi_tools_project CODEGEN
 * IF YOU NEED TO MAKE EDITS TO IT, EDIT codegen/caravel_iface_header.txt
 *
 *-------------------------------------------------------------
 */

module user_project_wrapper #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vdda1,       // User area 1 3.3V supply
    inout vdda2,       // User area 2 3.3V supply
    inout vssa1,       // User area 1 analog ground
    inout vssa2,       // User area 2 analog ground
    inout vccd1,       // User area 1 1.8V supply
    inout vccd2,       // User area 2 1.8v supply
    inout vssd1,       // User area 1 digital ground
    inout vssd2,       // User area 2 digital ground
`endif

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

    // generate active wires
    wire [31: 0] active;
    assign active = la_data_in[31:0];
    
    // when proving tristates are all good, assume only one project is active at a time
    `ifdef FORMAL
        always @* assume($onehot0(active));
    `endif

    // split remaining 96 logic analizer wires into 3 chunks
    wire [31: 0] la1_data_in, la1_data_out, la1_oenb;
    assign la1_data_in = la_data_in[63:32];
    assign la_data_out[63:32] = la1_data_out;
    assign la1_oenb = la_oenb[63:32];

    wire [31: 0] la2_data_in, la2_data_out, la2_oenb;
    assign la2_data_in = la_data_in[95:64];
    assign la_data_out[95:64] = la2_data_out;
    assign la2_oenb = la_oenb[95:64];

    wire [31: 0] la3_data_in, la3_data_out, la3_oenb;
    assign la3_data_in = la_data_in[127:96];
    assign la_data_out[127:96] = la3_data_out;
    assign la3_oenb = la_oenb[127:96];



    // Signals connecting user project to wishbone bridge
    wire        wbs_uprj_stb_i;
    wire        wbs_uprj_cyc_i;
    wire        wbs_uprj_we_i;
    wire [3:0]  wbs_uprj_sel_i;
    wire [31:0] wbs_uprj_dat_i;
    wire [31:0] wbs_uprj_adr_i;
    wire        wbs_uprj_ack_o;
    wire [31:0] wbs_uprj_dat_o;

    // Signals connecting user project to OpenRAM via its wrapper
    // shared openram wishbone bus wires
    wire         rambus_wb_clk_o;            // clock
    wire         rambus_wb_rst_o;            // reset
    wire         rambus_wb_stb_o;            // write strobe
    wire         rambus_wb_cyc_o;            // cycle
    wire         rambus_wb_we_o ;            // write enable
    wire [3:0]   rambus_wb_sel_o;            // write word select
    wire [31:0]  rambus_wb_dat_o;            // ram data out
    wire [9:0]   rambus_wb_adr_o;            // 10bit address
    wire         rambus_wb_ack_i;            // ack
    wire [31:0]  rambus_wb_dat_i;            // ram data in

    // Signals connecting OpenRAM wrapper to wishbone bridge
    wire        wbs_oram_stb_i;
    wire        wbs_oram_cyc_i;
    wire        wbs_oram_we_i;
    wire [3:0]  wbs_oram_sel_i;
    wire [31:0] wbs_oram_dat_i;
    wire [10:0] wbs_oram_adr_i;		// 11bit address (latencies CSR + 1kB OpenRAM)
    wire        wbs_oram_ack_o;
    wire [31:0] wbs_oram_dat_o;

    // Bridge splitting caravel wishbone traffic into two streams: user project and OpenRAM wrapper
    wb_bridge_2way #(
        .BUSB_ADDR_WIDTH(11)
    ) wb_bridge_2way(
    `ifdef USE_POWER_PINS
        .vccd1 (vccd1),
        .vssd1 (vssd1),
    `endif        
        // Wishbone UFP (Upward Facing Port) => caravel / picorv32
        .wb_clk_i (wb_clk_i),
        .wb_rst_i (wb_rst_i),
        .wbs_stb_i (wbs_stb_i),
        .wbs_cyc_i (wbs_cyc_i),
        .wbs_we_i (wbs_we_i),
        .wbs_sel_i (wbs_sel_i[3:0]),
        .wbs_dat_i (wbs_dat_i),
        .wbs_adr_i (wbs_adr_i),
        .wbs_ack_o (wbs_ack_o),
        .wbs_dat_o (wbs_dat_o),

        // Wishbone A (Downward Facing Port) => user project
        .wbm_a_stb_o (wbs_uprj_stb_i),
        .wbm_a_cyc_o (wbs_uprj_cyc_i),
        .wbm_a_we_o (wbs_uprj_we_i),
        .wbm_a_sel_o (wbs_uprj_sel_i[3:0]),
        .wbm_a_dat_i (wbs_uprj_dat_o[31:0]),
        .wbm_a_adr_o (wbs_uprj_adr_i[31:0]),	
        .wbm_a_ack_i (wbs_uprj_ack_o),
        .wbm_a_dat_o (wbs_uprj_dat_i[31:0]),

        // Wishbone B (Downward Facing Port) => OpenRAM wrapper/shim
        .wbm_b_stb_o (wbs_oram_stb_i),
        .wbm_b_cyc_o (wbs_oram_cyc_i),
        .wbm_b_we_o (wbs_oram_we_i),
        .wbm_b_sel_o (wbs_oram_sel_i[3:0]),
        .wbm_b_dat_i (wbs_oram_dat_o[31:0]),
        .wbm_b_adr_o (wbs_oram_adr_i[10:0]),	
        .wbm_b_ack_i (wbs_oram_ack_o),
        .wbm_b_dat_o (wbs_oram_dat_i[31:0])               
    );

    // Signals connecting OpenRAM memory block to OpenRAM wrapper
    wire oram_clk0;             // clock
    wire oram_csb0;             // active low chip select
    wire oram_web0;             // active low write control
    wire [3:0] oram_wmask0;     // write (byte) mask
    wire [7:0] oram_addr0;      // address
    wire [31:0] oram_din0;      // data in
    wire [31:0] oram_dout0;     // data out
    wire oram_clk1;             // clock
    wire oram_csb1;             // active low chip select
    wire [7:0] oram_addr1;      // address
    wire [31:0] oram_dout1;     // data out

    // Dual port OpenRAM wrapper for wishbone
    wb_openram_wrapper #(
        .RAM_ADDR_WIDTH(8)
    ) wb_openram_wrapper(
    `ifdef USE_POWER_PINS
        .vccd1 (vccd1),
        .vssd1 (vssd1),
    `endif
        // Selecting which port will be writable (0 -> A, 1 -> B)        
        .writable_port_req (active[31]),

        // Wishbone port A <= caravel (via wb_bridge)
        .wb_a_clk_i (wb_clk_i),
        .wb_a_rst_i (wb_rst_i),
        .wbs_a_stb_i (wbs_oram_stb_i),
        .wbs_a_cyc_i (wbs_oram_cyc_i),
        .wbs_a_we_i (wbs_oram_we_i),
        .wbs_a_sel_i (wbs_oram_sel_i[3:0]),
        .wbs_a_dat_i (wbs_oram_dat_i[31:0]),
        .wbs_a_adr_i (wbs_oram_adr_i[10:0]),
        .wbs_a_ack_o (wbs_oram_ack_o),
        .wbs_a_dat_o (wbs_oram_dat_o[31:0]),

        // Wishbone port B <= user project (rambus)
        .wb_b_clk_i (rambus_wb_clk_o),
        .wb_b_rst_i (rambus_wb_rst_o),
        .wbs_b_stb_i (rambus_wb_stb_o),
        .wbs_b_cyc_i (rambus_wb_cyc_o),
        .wbs_b_we_i (rambus_wb_we_o),
        .wbs_b_sel_i (rambus_wb_sel_o[3:0]),
        .wbs_b_dat_i (rambus_wb_dat_o[31:0]),
        .wbs_b_adr_i (rambus_wb_adr_o[9:0]),
        .wbs_b_ack_o (rambus_wb_ack_i),
        .wbs_b_dat_o (rambus_wb_dat_i[31:0]),

        // OpenRAM interface - almost dual port: RW + R
        // Port 0: RW
        .ram_clk0 (oram_clk0),
        .ram_csb0 (oram_csb0),
        .ram_web0 (oram_web0),
        .ram_wmask0 (oram_wmask0[3:0]),
        .ram_addr0 (oram_addr0[7:0]),
        .ram_din0 (oram_din0[31:0]),       
        .ram_dout0 (oram_dout0[31:0]),      
        
        // Port 1: R
        .ram_clk1 (oram_clk1),
        .ram_csb1 (oram_csb1),
        .ram_addr1 (oram_addr1[7:0]),  
        .ram_dout1 (oram_dout1[31:0])
    );


    // OpenRAM block
    sky130_sram_1kbyte_1rw1r_32x256_8 openram_1kB
    (
    `ifdef USE_POWER_PINS
        .vccd1 (vccd1),
        .vssd1 (vssd1),
    `endif

        .clk0 (oram_clk0),
        .csb0 (oram_csb0),
        .web0 (oram_web0),
        .wmask0 (oram_wmask0[3:0]),
        .addr0 (oram_addr0[7:0]),
        .din0 (oram_din0[31:0]),
        .dout0 (oram_dout0[31:0]),

        .clk1 (oram_clk1),
        .csb1 (oram_csb1),
        .addr1 (oram_addr1[7:0]),
        .dout1 (oram_dout1[31:0])
    );


    // start of user project module instantiation
    wrapped_function_generator wrapped_function_generator_0(
        `ifdef USE_POWER_PINS
        .vccd1 (vccd1),
        .vssd1 (vssd1),
        `endif
        .wb_clk_i (wb_clk_i),
        .active (active[0]),
        .io_in (io_in[37:0]),
        .io_out (io_out[37:0]),
        .io_oeb (io_oeb[37:0]),
        .wb_rst_i (wb_rst_i),
        .wbs_stb_i (wbs_uprj_stb_i),
        .wbs_cyc_i (wbs_uprj_cyc_i),
        .wbs_we_i (wbs_uprj_we_i),
        .wbs_sel_i (wbs_uprj_sel_i[3:0]),
        .wbs_dat_i (wbs_uprj_dat_i[31:0]),
        .wbs_adr_i (wbs_uprj_adr_i[31:0]),
        .wbs_ack_o (wbs_uprj_ack_o),
        .wbs_dat_o (wbs_uprj_dat_o[31:0]),
        .rambus_wb_clk_o (rambus_wb_clk_o),
        .rambus_wb_rst_o (rambus_wb_rst_o),
        .rambus_wb_stb_o (rambus_wb_stb_o),
        .rambus_wb_cyc_o (rambus_wb_cyc_o),
        .rambus_wb_we_o (rambus_wb_we_o),
        .rambus_wb_sel_o (rambus_wb_sel_o[3:0]),
        .rambus_wb_dat_o (rambus_wb_dat_o[31:0]),
        .rambus_wb_adr_o (rambus_wb_adr_o[9:0]),
        .rambus_wb_ack_i (rambus_wb_ack_i),
        .rambus_wb_dat_i (rambus_wb_dat_i[31:0])
    );

    wrapped_ibnalhaytham wrapped_ibnalhaytham_1(
        `ifdef USE_POWER_PINS
        .vccd1 (vccd1),
        .vssd1 (vssd1),
        `endif
        .wb_clk_i (wb_clk_i),
        .active (active[1]),
        .la1_data_in (la1_data_in[31:0]),
        .la1_data_out (la1_data_out[31:0]),
        .la1_oenb (la1_oenb[31:0]),
        .io_in (io_in[37:0]),
        .io_out (io_out[37:0]),
        .io_oeb (io_oeb[37:0]),
        .user_clock2 (user_clock2)
    );

    wrapped_etpu wrapped_etpu_3(
        `ifdef USE_POWER_PINS
        .vccd1 (vccd1),
        .vssd1 (vssd1),
        `endif
        .wb_clk_i (wb_clk_i),
        .active (active[3]),
        .wb_rst_i (wb_rst_i),
        .wbs_stb_i (wbs_uprj_stb_i),
        .wbs_cyc_i (wbs_uprj_cyc_i),
        .wbs_we_i (wbs_uprj_we_i),
        .wbs_sel_i (wbs_uprj_sel_i[3:0]),
        .wbs_dat_i (wbs_uprj_dat_i[31:0]),
        .wbs_adr_i (wbs_uprj_adr_i[31:0]),
        .wbs_ack_o (wbs_uprj_ack_o),
        .wbs_dat_o (wbs_uprj_dat_o[31:0]),
        .io_in (io_in[37:0]),
        .io_out (io_out[37:0]),
        .io_oeb (io_oeb[37:0])
    );

    wrapped_silife wrapped_silife_2(
        `ifdef USE_POWER_PINS
        .vccd1 (vccd1),
        .vssd1 (vssd1),
        `endif
        .wb_clk_i (wb_clk_i),
        .active (active[2]),
        .la1_data_in (la1_data_in[31:0]),
        .la1_data_out (la1_data_out[31:0]),
        .la1_oenb (la1_oenb[31:0]),
        .io_in (io_in[37:0]),
        .io_out (io_out[37:0]),
        .io_oeb (io_oeb[37:0]),
        .wb_rst_i (wb_rst_i),
        .wbs_stb_i (wbs_uprj_stb_i),
        .wbs_cyc_i (wbs_uprj_cyc_i),
        .wbs_we_i (wbs_uprj_we_i),
        .wbs_sel_i (wbs_uprj_sel_i[3:0]),
        .wbs_dat_i (wbs_uprj_dat_i[31:0]),
        .wbs_adr_i (wbs_uprj_adr_i[31:0]),
        .wbs_ack_o (wbs_uprj_ack_o),
        .wbs_dat_o (wbs_uprj_dat_o[31:0])
    );

    wrapped_snn_network wrapped_snn_network_4(
        `ifdef USE_POWER_PINS
        .vccd1 (vccd1),
        .vssd1 (vssd1),
        `endif
        .wb_clk_i (wb_clk_i),
        .active (active[4]),
        .io_in (io_in[37:0]),
        .io_out (io_out[37:0]),
        .io_oeb (io_oeb[37:0])
    );

    wrapped_mbsFSK wrapped_mbsFSK_5(
        `ifdef USE_POWER_PINS
        .vccd1 (vccd1),
        .vssd1 (vssd1),
        `endif
        .wb_clk_i (wb_clk_i),
        .active (active[5]),
        .la1_data_in (la1_data_in[31:0]),
        .la1_data_out (la1_data_out[31:0]),
        .la1_oenb (la1_oenb[31:0]),
        .io_in (io_in[37:0]),
        .io_out (io_out[37:0]),
        .io_oeb (io_oeb[37:0])
    );

    // end of module instantiation

endmodule	// user_project_wrapper
`default_nettype wire