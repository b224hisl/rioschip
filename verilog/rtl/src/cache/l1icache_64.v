module  l1icache_64 
#(
    parameter VIRTUAL_ADDR_LEN = 32,
    parameter WB_DATA_LEN = 32
)
(
    /* verilator lint_off UNUSED */
    input clk,
    input rstn,
    
    //req
    input  req_valid_i,
    output req_ready_o,
    input [VIRTUAL_ADDR_LEN - 1 : 0] req_addr_i,


    //resp
    output resp_valid_o,
    output [31:0] ld_data_o,
    input  resp_ready_i,
    output [31:0] resp_addr_o,
    //memory
    output wb_cyc_o,
    output wb_stb_o,
    output wb_we_o,
    output [VIRTUAL_ADDR_LEN - 1 : 0] wb_adr_o,
    input  wb_ack_i,
    input  [WB_DATA_LEN -1:0] wb_dat_i
);
wire req_hsk;
wire refill_hsk;
wire req_hsk_q;
reg mshr_is_full = '0;
reg [VIRTUAL_ADDR_LEN - 1 : 0] addr_save;
wire [31:0] ld_data_cache;
wire [31:0] ld_data_refill;
wire [31:0] tag_out;
wire [63:0] data_out;
wire ld_tag_is_hit;
wire ld_tag_is_miss;
wire ld_tag_is_hit_q;
wire ld_tag_is_miss_q;
wire [7:0] index;
wire tag_chip_en;
wire tag_write_en;
wire [3:0] write_tag_mask;
wire [31:0] tag_data_in;
wire data_chip_en;
wire data_write_en;
wire [7:0] write_data_mask;
wire [63:0] data_in;
wire burst;
wire burst_q;
wire [31:0] refill_buffer;
wire [31:0] refill_buffer_q;
wire [63:0] refill_data;
wire resp_valid_q;
wire resp_hsk;
wire resp_hsk_q;
wire [31:0] ld_data_q;
wire [31:0] tag_dout1;
wire [63:0] data_dout1;
reg [31:0] req_addr;

always @(posedge clk) begin
    if(req_hsk) begin
        req_addr <= req_addr_i;
    end
end

assign resp_addr_o = req_addr;
/* verilator lint_off PINCONNECTEMPTY */
/////////clean sram
reg [7:0] counter = 8'b00000000;
reg reset = '1;
reg start;
always @(posedge clk) begin

    if(rstn) begin
    reset <= '1;
    if(counter != 8'b11111111) begin
        counter <= counter +1;
    end else if(counter == 8'b11111111) begin
        counter <= 8'b00000000;
    end

    end else begin
        reset <= '0;
    end
end


////////////////////////////////////////
// tag data sram
sky130_sram_1kbyte_1rw1r_32x256_8 sky130_sram_1kbyte_1rw1r_32x256_8_tag(
    .clk0 (clk),
    .csb0 (tag_chip_en),
    .web0 (tag_write_en),
    .wmask0 (write_tag_mask),
    .addr0 (index),
    .din0 (tag_data_in),
    .dout0 (tag_out),
    .clk1 (clk),
    .csb1 ('1),
    .addr1 (8'b0),
    .dout1 (tag_dout1)
);//0 clean 1 dirty 0 valid 1 invalid

sky130_sram_1rw1r_64x256_8 sky130_sram_1rw1r_64x256_8_data(
    .clk0 (clk),
    .csb0 (data_chip_en),
    .web0 (data_write_en),
    .wmask0 (write_data_mask),
    .addr0 (index),
    .din0 (data_in),
    .dout0 (data_out),
    .clk1 (clk),
    .csb1 ('1),
    .addr1 (8'b0),
    .dout1 (data_dout1)
);
assign tag_chip_en = ~(req_hsk | reset | refill_hsk);
assign data_chip_en = ~(req_hsk | reset | refill_hsk);

assign index = reset ? counter :
               refill_hsk ? addr_save[10:3] :
               req_hsk ? req_addr_i[10:3] :
               8'b0;

assign data_write_en = ~(reset | refill_hsk);
assign tag_write_en = ~(reset | refill_hsk);


assign write_data_mask = reset ? 8'b11111111 :
                         refill_hsk ? 8'b11111111 :
                         8'b0;

assign write_tag_mask = reset ? 4'b1111 :
                        refill_hsk ? 4'b1111 :
                        4'b0;

assign data_in = reset ? 64'hFFFFFFFFFFFFFFFF :
                 refill_hsk ? refill_data :
                 64'b0;

                
assign tag_data_in = reset ? 32'hFFFFFFFF :// F
                     refill_hsk ? {11'b0,addr_save[31:11]} :
                     32'b0;                       
///////////////save tag data out
reg [31:0] tag_out_save;
reg [63:0] data_out_save;

always @(posedge clk) begin
    if(req_hsk_q) begin
        tag_out_save <= tag_out;
        data_out_save <= data_out;
    end
end

///////////////save req 

always @(posedge clk) begin
    if (req_hsk) begin
        addr_save <= req_addr_i;
    end
end
always @(posedge clk) begin
    if(~rstn) begin
        start <= 1'b1;
    end  
    if(rstn) begin
        start <= 1'b0;
    end
end
assign req_hsk = req_valid_i & req_ready_o & start;
assign ld_tag_is_hit = req_hsk_q & (addr_save[31:11] == tag_out[20:0]) & (tag_out[30] == 0);

assign ld_tag_is_miss = req_hsk_q ? ~ld_tag_is_hit : 1'b0;
std_dffr #(.WIDTH(1)) REQ_HSK_1 (.clk(clk),.rstn(rstn),.d(req_hsk),.q(req_hsk_q));
std_dffr #(.WIDTH(1)) S1_LD_TAG_IS_HIT (.clk(clk),.rstn(rstn),.d(ld_tag_is_hit),.q(ld_tag_is_hit_q));
std_dffr #(.WIDTH(1)) S1_LD_TAG_IS_MISS (.clk(clk),.rstn(rstn),.d(ld_tag_is_miss),.q(ld_tag_is_miss_q));


/////miss
always @(posedge clk) begin
    if(rstn) begin
        mshr_is_full <= '0;
    end
    if(ld_tag_is_miss & ~mshr_is_full) begin
        mshr_is_full <= '1;
    end 
    if(refill_hsk) begin
        mshr_is_full <= '0;
    end

end
assign refill_data = {wb_dat_i,refill_buffer};
assign refill_buffer = wb_ack_i & burst ? wb_dat_i :
                       refill_buffer_q;
std_dffr #(.WIDTH(32)) REFILL_BUFFER (.clk(clk),.rstn(rstn),.d(refill_buffer),.q(refill_buffer_q));
assign burst = (wb_ack_i & ~burst_q) ? 1'b1:
               (wb_ack_i & burst_q) ? 1'b0:
               burst_q;
std_dffr #(.WIDTH(1)) BURST (.clk(clk),.rstn(rstn),.d(burst),.q(burst_q));
wire cache_mem_is_write;
assign cache_mem_is_write = 1'b0;
assign wb_stb_o = wb_ack_i ? 1'b0 :
                  wb_cyc_o;
assign wb_cyc_o = 
                  refill_hsk ? 1'b0:
                  mshr_is_full ? 1'b1 :
                  1'b0;


assign wb_we_o = cache_mem_is_write;
assign wb_adr_o = ~burst ? {addr_save[31:3],3'b000} :  
                   burst ? {addr_save[31:3],3'b100} :
                   32'b0;                                      

///refill
assign refill_hsk = (wb_ack_i & burst_q) ? 1'b1 : 1'b0;

//req_ready_o
assign req_ready_o = refill_hsk ? 1'b0 :
                     resp_hsk ? 1'b1 :
                     req_hsk_q ? 1'b0:
                     resp_valid_o & ~resp_ready_i ? 1'b0:
                     mshr_is_full ? 1'b0:
                     1'b1;


/////resp

assign ld_data_cache = ld_tag_is_hit_q & ~addr_save[2] ? data_out_save[31:0] :
                       ld_tag_is_hit_q & addr_save[2] ? data_out_save[63:32] :
                       32'b0;

assign ld_data_refill = refill_hsk & ~addr_save[2] ? refill_data[31:0] :
                        refill_hsk & addr_save[2] ? refill_data[63:32] :
                        32'b0;

assign ld_data_o =   refill_hsk ? ld_data_refill :
                     ld_tag_is_hit_q ? ld_data_cache :
                     resp_valid_o ? ld_data_q :
                     32'b0;
std_dffr #(.WIDTH(32)) LD_DATA (.clk(clk),.rstn(rstn),.d(ld_data_o),.q(ld_data_q));

assign resp_valid_o = resp_hsk_q ? 1'b0:
                      refill_hsk ? 1'b1 :
                      ld_tag_is_hit_q ? 1'b1 :
                      resp_valid_q;


assign resp_hsk = resp_valid_o & resp_ready_i;
std_dffr #(.WIDTH(1)) RESP_VALID (.clk(clk),.rstn(rstn),.d(resp_valid_o),.q(resp_valid_q));
std_dffr #(.WIDTH(1)) RESP_HSK (.clk(clk),.rstn(rstn),.d(resp_hsk),.q(resp_hsk_q));
/* verilator lint_on PINCONNECTEMPTY */
    /* verilator lint_on UNUSED */
endmodule
