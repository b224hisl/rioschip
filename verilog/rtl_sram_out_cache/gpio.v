////////////////////////////////////////////////////////////////////////////////                                          
// SPDX-FileCopyrightText: 2022, Jure Vreca                                   //                                          
//                                                                            //                                          
// Licenseunder the Apache License, Version 2.0(the "License");               //                                          
// you maynot use this file except in compliance with the License.            //                                           
// You may obtain a copy of the License at                                    //                                          
//                                                                            //                                          
//      http://www.apache.org/licenses/LICENSE-2.0                            //                                          
//                                                                            //                                          
// Unless required by applicable law or agreed to in writing, software        //                                          
// distributed under the License is distributed on an "AS IS" BASIS,          //                                          
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   //                                          
// See the License for the specific language governing permissions and        //                                          
// limitations under the License.                                             //                                          
// SPDX-License-Identifier: Apache-2.0                                        //                                          
// SPDX-FileContributor: Jure Vreca <jurevreca12@gmail.com>                   //                                          
////////////////////////////////////////////////////////////////////////////////      
////////////////////////////////////////////////////////////////////////////////
// Engineer:       Jure Vreca - jurevreca12@gmail.com                         //
//                                                                            //
//                                                                            //
//                                                                            //
// Design Name:    wbuart_wrap                                                //
// Project Name:   rvj1-caravel-soc                                           //
// Language:       System Verilog                                             //
//                                                                            //
// Description:    Wraps the wbuart module.                                   //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module	gpio #(
        parameter BASE_ADDR = 32'h3001_0000   // This is in a seperate address space to that of Caravel
	) (
		`ifdef USE_POWER_PINS
  		inout vccd1,	// User area 1 1.8V supply
        inout vssd1,	// User area 1 digital ground
		`endif
		
		input	wire		clk_i, 
		input   wire		rst_i,

		// Wishbone inputs
		input	wire		wbs_cyc_i,
		input	wire		wbs_stb_i, 
		input   wire		wbs_we_i,
		input	wire [31:0]	wbs_adr_i,
		input	wire [31:0]	wbs_dat_i,
		input	wire [3:0]	wbs_sel_i,
		output	reg		    wbs_ack_o,
		output	reg [31:0]	wbs_dat_o,
		
		input	wire [24-1:0] gpio_in,
		output	reg  [24-1:0] gpio_out,
		output  wire [38-1:0] gpio_oeb
	);
    localparam ADDR_WIDTH = 1;
	localparam ADDR_LO_MASK = (1 << ADDR_WIDTH) - 1;
    localparam ADDR_HI_MASK = 32'hffff_ffff - ADDR_LO_MASK;
	localparam GPIO_WRITE_ADDR = 0;
	localparam GPIO_READ_ADDR = 1;

    wire wb_cyc, wb_stb;
	reg [24-1:0] gpio_in_ff;

	// WISHBONE LOGIC
    assign wb_cyc = wbs_cyc_i & ((wbs_adr_i & ADDR_HI_MASK) == BASE_ADDR);
    assign wb_stb = wbs_stb_i & ((wbs_adr_i & ADDR_HI_MASK) == BASE_ADDR);
	always @(posedge clk_i) begin
		if (rst_i) begin
			gpio_out <= 24'b0;
			wbs_ack_o <= 1'b0;
			wbs_dat_o <= 32'b0;
		end
		else if (wb_cyc && wb_stb && wbs_we_i && ~wbs_ack_o && (wbs_adr_i & ADDR_LO_MASK) == GPIO_WRITE_ADDR) begin
			gpio_out <= wbs_dat_i[24-1:0];
			wbs_ack_o <= 1'b1;
		end
		else if (wb_cyc && wb_stb && ~wbs_we_i && ~wbs_ack_o && (wbs_adr_i & ADDR_LO_MASK) == GPIO_READ_ADDR) begin
			wbs_dat_o <= {8'b0, gpio_in_ff};	
		end
		else begin
			wbs_ack_o <= 1'b0;
		end
	end

	// GPIO IN LOGIC
	assign gpio_oeb = 38'b0;

	always @(posedge clk_i) begin
		if (rst_i) 
			gpio_in_ff <= 24'b0;
		else 
			gpio_in_ff <= gpio_in; 
	end
endmodule
