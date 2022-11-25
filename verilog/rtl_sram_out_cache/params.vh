`ifndef PARAMS_VH
`define PARAMS_VH
// MACROS
// `define LSU_SELFCHECK   
// `define LSU_ALU_SELFCHECK
`define USE_NBLSU

`define va_vpn0 20:12
`define va_vpn1 29:21
`define va_vpn2 38:30

`define pa_ppn0 20:12
`define pa_ppn1 29:21
`define pa_ppn2 55:30

`define pte_n 63:63
`define pte_pbmt 62:61
`define pte_ppn  53:10
`define pte_ppn2 53:28
`define pte_ppn1 27:19
`define pte_ppn0 18:10
`define pte_rsw 9:8
`define pte_d 7:7
`define pte_a 6:6
`define pte_g 5:5
`define pte_u 4:4
`define pte_x 3:3
`define pte_w 2:2
`define pte_r 1:1
`define pte_v 0:0
`define pte_xwr 3:1

`define sstatus_mxr 19:19
`define sstatus_sum 18:18

// global params 
/*verilator lint_off UNUSED */
parameter XLEN = 64;  
parameter VIRTUAL_ADDR_LEN = 32;
parameter PHYSICAL_ADDR_LEN = 32;
parameter IMM_LEN = 32;
parameter AXI_ID_WIDTH = 10;
parameter DCACHE_WB_DATA_LEN = 32;
// parameter RESET_VECTOR = 32'h8000_0000;
parameter RESET_VECTOR = 32'h3000_0000;

parameter EXCEPTION_CODE_WIDTH = 4;
parameter PHY_REG_ADDR_WIDTH = 6;
parameter VIR_REG_ADDR_WIDTH = 5;
parameter PC_WIDTH = VIRTUAL_ADDR_LEN;
parameter CSR_ADDR_LEN = 12;

parameter BUS_MAP_ADDR_UPPER = 32'h3003_0000;
parameter BUS_MAP_ADDR_LOWER = 32'h3000_FFFF;
parameter WB_DATA_LEN = 32;

parameter FAKE_MEM_ADDR_LEN = 16;
parameter FAKE_MEM_SIZE = 8192; // 2 ^ 13
parameter FAKE_MEM_DEPTH = FAKE_MEM_ADDR_LEN - 3; //
parameter FAKE_CACHE_MSHR_DEPTH = 2;
parameter FAKE_CACHE_MSHR_WIDTH = 1;
parameter FAKE_CACHE_DELAY_WIDTH = 5;
parameter FAKE_MEM_DELAY_BASE = 3;

// Memory Model
parameter U_MODE = 0;
parameter S_MODE = 1;
parameter M_MODE = 3;

parameter ACCESS_MODE_READ = 0;
parameter ACCESS_MODE_WRITE = 1;
parameter ACCESS_MODE_EXECUTE = 2;

parameter SATP_PPN_WIDTH = 44;
parameter SATP_ASID_WIDTH = 16;
parameter SATP_MODE_WIDTH = 4;
// ROB 
parameter ROB_SIZE = 4;
parameter ROB_INDEX_WIDTH = 2;
// parameter ROB_OP_WIDTH = 2;
parameter ROB_SIZE_WIDTH = 2;
parameter FRLIST_DATA_WIDTH = 6;
parameter FRLIST_DEPTH = 35; //p0 is not in the fifo FRLIST_DEPTH = PHY_REG_SIZE - 1
parameter FRLIST_DEPTH_WIDTH = 6; //combine with physical register later
parameter PHY_REG_SIZE = 36;
parameter PHY_REG_SIZE_WIDTH = 6;
// exception code
parameter EXCEPTION_INSTR_ADDR_MISALIGNED =  4'h0;
parameter EXCEPTION_INSTR_ACCESS_FAULT =  4'h1;
parameter EXCEPTION_ILLEGAL_INSTRUCTION =  4'h2;
parameter EXCEPTION_BREAKPOINT =  4'h3;
parameter EXCEPTION_LOAD_ADDR_MISALIGNED =  4'h4;
parameter EXCEPTION_LOAD_ACCESS_FAULT =  4'h5;
parameter EXCEPTION_STORE_ADDR_MISALIGNED =  4'h6;
parameter EXCEPTION_STORE_ACCESS_FAULT =  4'h7;
parameter EXCEPTION_ENV_CALL_U =  4'h8;
parameter EXCEPTION_ENV_CALL_S =  4'h9;
// parameter  =  4'ha}; // NO EXCEPTION IN 10
parameter EXCEPTION_ENV_CALL_M =  4'hb;
parameter EXCEPTION_INSTR_PAGE_FAULT =  4'hc;
parameter EXCEPTION_LOAD_PAGE_FAULT =  4'hd;
// parameter EXCEPTION_ =  4'he}; // NO EXCEPTION IN 14
parameter EXCEPTION_STORE_PAGE_FAULT =  4'hf;

// These are the ALU values also used in the ISA
parameter ALU_ADD_SUB = 3'b000;
parameter ALU_SLL     = 3'b001;
parameter ALU_SLT     = 3'b010;
parameter ALU_SLTU    = 3'b011;
parameter ALU_XOR     = 3'b100;
parameter ALU_SRL_SRA = 3'b101;
parameter ALU_OR      = 3'b110;
parameter ALU_AND_CLR = 3'b111;

parameter ALU_SEL_REG = 2'b00;
parameter ALU_SEL_IMM = 2'b01;
parameter ALU_SEL_PC  = 2'b10;
parameter ALU_SEL_CSR = 2'b11;

parameter CMP_EQ  = 3'b000;
parameter CMP_NE  = 3'b001;
parameter CMP_LT  = 3'b110;
parameter CMP_GE  = 3'b111;
parameter CMP_LTU = 3'b100;
parameter CMP_GEU = 3'b101;

parameter WRITE_SEL_ALU     = 2'b00;
parameter WRITE_SEL_CSR     = 2'b01;
parameter WRITE_SEL_LOAD    = 2'b10;
parameter WRITE_SEL_NEXT_PC = 2'b11;
// LSU
parameter LSU_LSQ_SIZE = 2;
parameter LSU_LSQ_SIZE_WIDTH = 1; // log(LSU_LSQ_SIZE)
parameter LSU_LOAD_QUEUE_ENTRY_WIDTH = 1 + 1 + 1 + 1 +  EXCEPTION_CODE_WIDTH + 1 + 1 + 2
            + PHY_REG_ADDR_WIDTH + ROB_INDEX_WIDTH + PHYSICAL_ADDR_LEN;
            
parameter LSU_STORE_QUEUE_SIZE = LSU_LSQ_SIZE;
parameter LSU_STORE_QUEUE_SIZE_WIDTH = LSU_LSQ_SIZE_WIDTH; // log(LSU_STORE_QUEUE_SIZE)
/*verilator lint_off UNUSED */
`endif // PARAMS_VH



