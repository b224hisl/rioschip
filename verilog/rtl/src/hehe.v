`include "params.vh"
`timescale  1ns/1ps

module hehe
#(
    parameter XLEN = 64,
    parameter VIRTUAL_ADDR_LEN = 32,
    parameter WB_DATA_LEN = 32
) 
(
    input clk,
    input reset,
    input meip,
    
    // lsu <-> Soc
    output [31:0] m2_wbd_dat_o, 
    output [31:0] m2_wbd_adr_o, 
    output [3:0] m2_wbd_sel_o,
    output [9:0] m2_wbd_bl_o,
    output m2_wbd_bry_o,
    output m2_wbd_we_o,
    output m2_wbd_cyc_o,
    output m2_wbd_stb_o,
    input [31:0] m2_wbd_dat_i,
    input m2_wbd_ack_i, 
    
    /* verilator lint_off UNUSED */
    input m2_wbd_lack_i,
    input m2_wbd_err_i,
   

    // I$ <-> Soc
    output [31:0] m3_wbd_adr_o,
    output [3:0] m3_wbd_sel_o,
    output [9:0] m3_wbd_bl_o,
    output m3_wbd_bry_o,
    output m3_wbd_we_o,
    output m3_wbd_cyc_o,
    output m3_wbd_stb_o,   
    input [31:0] m3_wbd_dat_i,
    input m3_wbd_ack_i,
    input m3_wbd_lack_i,
    input m3_wbd_err_i
);

// others <> SOC
wire [31:0] m2_others_wbd_dat_o;
wire [31:0] m2_others_wbd_adr_o; 
wire [3:0] m2_others_wbd_sel_o;
wire [9:0] m2_others_wbd_bl_o;
wire m2_others_wbd_bry_o;
wire m2_others_wbd_we_o;
wire m2_others_wbd_cyc_o;
wire m2_others_wbd_stb_o;
wire [31:0] m2_others_wbd_dat_i;
wire m2_others_wbd_ack_i;

// D$ <-> Soc
wire [31:0] m2_dcache_wbd_dat_o; 
wire [31:0] m2_dcache_wbd_adr_o; 
wire [3:0] m2_dcache_wbd_sel_o;
wire [9:0] m2_dcache_wbd_bl_o;
wire m2_dcache_wbd_bry_o;
wire m2_dcache_wbd_we_o;
wire m2_dcache_wbd_cyc_o;
wire m2_dcache_wbd_stb_o;
wire [9:0] m2_dcache_wbd_bry_o;
wire m2_dcache_wbd_bl_o;
wire [31:0] m2_dcache_wbd_dat_i;
wire m2_dcache_wbd_ack_i; 





reg[1:0] lock;
reg m2_wb_sel; // 0 for others, 1 for dcache
reg [31:0] m2_dcache_wbd_dat;
reg [31:0] m2_dcache_wbd_adr; 
reg [3:0] m2_dcache_wbd_sel;
reg [9:0] m2_dcache_wbd_bl;
reg m2_dcache_wbd_bry;
reg m2_dcache_wbd_we;
reg m2_dcache_wbd_cyc;
reg m2_dcache_wbd_stb;

assign m2_wbd_cyc_o = m2_others_wbd_cyc_o | m2_dcache_wbd_cyc_o;
assign m2_wbd_stb_o = m2_others_wbd_stb_o | m2_dcache_wbd_stb_o;
assign m2_wbd_dat_o = m2_others_wbd_cyc_o? m2_others_wbd_dat_o : m2_dcache_wbd_dat_o;
assign m2_wbd_adr_o = m2_others_wbd_cyc_o? m2_others_wbd_adr_o : m2_dcache_wbd_adr_o;
assign m2_wbd_sel_o = m2_others_wbd_cyc_o? m2_others_wbd_sel_o : m2_dcache_wbd_sel_o;
assign m2_wbd_we_o = m2_others_wbd_cyc_o? m2_others_wbd_we_o : m2_dcache_wbd_we_o;

assign m2_others_wbd_dat_i = m2_wbd_dat_i;
assign m2_dcache_wbd_dat_i = m2_wbd_dat_i;
assign m2_others_wbd_ack_i = (m2_wb_sel == 0) & m2_wbd_ack_i;
assign m2_dcache_wbd_ack_i = (m2_wb_sel == 1) & m2_wbd_ack_i;
// unused wishbone interface for memory
assign m2_wbd_bry_o = m2_wbd_stb_o;
assign m2_wbd_bl_o = m2_wbd_stb_o ? 10'b1 : 10'b0 ;
assign m3_wbd_sel_o = 4'b0;

always @(posedge clk) begin
    if(reset) begin
        lock <= '0;
        m2_wb_sel <= '0;
        m2_dcache_wbd_dat <= '0;
        m2_dcache_wbd_adr <= '0;
        m2_dcache_wbd_sel <= '0;
        m2_dcache_wbd_bl <= '0;
        m2_dcache_wbd_bry <= '0;
        m2_dcache_wbd_we <= '0;
        m2_dcache_wbd_cyc <= '0;
        m2_dcache_wbd_stb <= '0;
    end
    else begin
        if(m2_wbd_stb_o & (lock == 2'b0)) begin
            lock <= 2'b01;
            if(m2_others_wbd_stb_o) begin
                m2_wb_sel <= '0;
            end
            else begin
                m2_wb_sel <= '1;
            end 
        end
        else if(m2_wbd_ack_i) begin
            if(m2_wb_sel == 0) begin
                lock <= '0;
            end
            else begin
                lock <= (lock == 2'b01) ? 2'b10 : 2'b0;
            end 
        end
    end
end

// unused wishbone interface for cache
// wire [2:0] m2_wb_cti;
// wire [1:0] m2_wb_bte;
// wire m2_wb_rty;
// wire [2:0] m3_wb_cti;
// wire [1:0] m3_wb_bte;
// wire m3_wb_rty;

// assign m2_wb_rty = 1'b1;
// assign m3_wb_rty = 1'b1;
// assign m2_wb_cti = 3'b1;
// assign m2_wb_bte = 2'b1;
 /* verilator lint_on UNUSED */
wire back2dcache_req_valid;
wire dcache2back_req_ready;
wire back2dcache_opcode;
wire [VIRTUAL_ADDR_LEN-1:0] back2dcache_req_addr;
wire [2:0] back2dcache_type;
wire [XLEN-1:0] back2dcache_st_data;
wire dcache_resp_ready;
wire dcache2back_resp_valid;
wire [XLEN-1:0] dcache2back_resp_data;
wire icache_req_valid;
wire icache_req_ready;
wire [VIRTUAL_ADDR_LEN-1:0] icache_req_addr;
/* verilator lint_off UNUSED */
wire icache_resp_ready;
wire [31:0] icache_resp_address;

wire icache_resp_valid;
wire [31:0] insn;
/* verilator lint_on UNUSED */
wire [LSU_LSQ_SIZE_WIDTH-1:0] back2dcache_lsq_index;
wire [LSU_LSQ_SIZE_WIDTH-1:0] dcache2back_rob_index;


core_empty #(
  .XLEN(XLEN),
  .VIRTUAL_ADDR_LEN(VIRTUAL_ADDR_LEN)
)
core_empty_u
(
    .clk(clk),
    .reset(reset),
    // others port
    // <> bus
    .others_wb_cyc_o(m2_others_wbd_cyc_o),
    .others_wb_stb_o(m2_others_wbd_stb_o),
    .others_wb_we_o(m2_others_wbd_we_o),
    .others_wb_adr_o(m2_others_wbd_adr_o),
    .others_wb_dat_o(m2_others_wbd_dat_o),
    .others_wb_sel_o(m2_others_wbd_sel_o),
    .others_wb_ack_i(m2_others_wbd_ack_i),
    .others_wb_dat_i(m2_others_wbd_dat_i),
    // Dcache interface
    .dcache_req_valid_o(back2dcache_req_valid),
    .dcache_opcode(back2dcache_opcode),
    .dcache_req_addr(back2dcache_req_addr),
    .dcache_type_o(back2dcache_type),  //4*2(s/u)
    .dcache_st_data_o(back2dcache_st_data),
    .dcache_resp_ready_o(dcache_resp_ready),
    .dcache2back_resp_valid_i(dcache2back_resp_valid),
    .dcache2back_resp_data_i(dcache2back_resp_data),
    .dcache_req_ready_i(dcache2back_req_ready),
    .back2dcache_lsq_index_o(back2dcache_lsq_index),
    .dcache2back_rob_index_i(dcache2back_rob_index),
    // Icache interface
    .icache_req_valid_o(icache_req_valid),
    .icache_req_ready_i(icache_req_ready),
    .icache_req_addr(icache_req_addr),
    .icache_resp_ready_o(icache_resp_ready),
    .icache_resp_valid_i(icache_resp_valid),
    .icache_resp_address_i(icache_resp_address),
    .insn_i(insn),
    .meip(meip)
);

l1dcache #(
  .WB_DATA_LEN(WB_DATA_LEN)
)
l1dcache_u
(
    .clk (clk),
    .rstn (reset),
    //req
    .req_valid_i (back2dcache_req_valid),
    .req_ready_o (dcache2back_req_ready),
    .opcode (back2dcache_opcode),
    .req_addr_i (back2dcache_req_addr),
    .type_i (back2dcache_type),
    .st_data_i (back2dcache_st_data),
    .rob_index_i (back2dcache_lsq_index),

    //resp
    .resp_ready_i (dcache_resp_ready),
    .resp_valid_o (dcache2back_resp_valid),
    .ld_data_o (dcache2back_resp_data),
    .rob_index_o (dcache2back_rob_index),

    //memory
    .wb_cyc_o (m2_dcache_wbd_cyc_o),
    .wb_stb_o (m2_dcache_wbd_stb_o),
    .wb_we_o (m2_dcache_wbd_we_o),
    .wb_adr_o (m2_dcache_wbd_adr_o),
    .wb_dat_o (m2_dcache_wbd_dat_o),
    .wb_sel_o (m2_dcache_wbd_sel_o),
    .wb_bl_o(m2_dcache_wbd_bl_o),
    .wb_bry_o(m2_dcache_wbd_bry_o),
    .wb_ack_i (m2_dcache_wbd_ack_i),
    .wb_dat_i (m2_dcache_wbd_dat_i)
    
);


l1icache_32 #(
  .VIRTUAL_ADDR_LEN(VIRTUAL_ADDR_LEN),
  .WB_DATA_LEN(WB_DATA_LEN)
)
l1icache_u
(
    .clk (clk),
    .rstn (reset),
 
    //req
    .req_valid_i (icache_req_valid),
    .req_ready_o (icache_req_ready),
    .req_addr_i (icache_req_addr),

    //resp
    .resp_valid_o (icache_resp_valid),
    .ld_data_o (insn),
    .resp_ready_i(icache_resp_ready),
    .resp_addr_o(icache_resp_address),

    .wb_cyc_o (m3_wbd_cyc_o),
    .wb_stb_o (m3_wbd_stb_o),
    .wb_we_o (m3_wbd_we_o),
    .wb_adr_o (m3_wbd_adr_o),
    .wb_bl_o(m3_wbd_bl_o),
    .wb_bry_o(m3_wbd_bry_o),
    .wb_ack_i (m3_wbd_ack_i),
    .wb_dat_i (m3_wbd_dat_i)
);


endmodule
