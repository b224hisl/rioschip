//===============================================
// Filename     : rct_core.sv
// Author       : cuiluping
// Email        : luping.cui@rivai.ai
// Date         : 2022-07-27 14:46:17
// Description  : core module, including below modules
//                1) frontend
//                2) isu ( Instruction Issue Unit )
//                3) exu ( Instruction Execution Unit )
//                4) lsu ( Load Store Unit )
//                5) ptw ( Page Table Walk )
//================================================

module rct_core
import dm_cfg::*;
import dm_typedef::*;
import rct_cfg::*;
import rct_typedef::*;
(
    input                                                               clk,
    input                                                               rstn,
    input   [RCT_EFF_ADDR_W-1:0]                                        cfg_boot_pc,
    input                                                               cfg_bpu_disable,
    input                                                               cfg_icache_enable,
    input                                                               cfg_dcache_enable,
    input                                                               cfg_mmu_enable,
    input   [RCT_BUS_ADDR_W-1:0]                                        cfg_core_cache_start_addr,
    input   [RCT_BUS_ADDR_W-1:0]                                        cfg_core_cache_end_addr,
    output                                                              sleep,
    input                                                               dm_halt_req,
    output  hartinfo_t                                                  hartinfo,
    input                                                               timer_int,
    input                                                               soft_int,
    input                                                               ext_int,


    //Interface with icache
    output  [RCT_ICACHE_WAY_NUM-1:0]                                    ic_tag_csb,
    output  [RCT_ICACHE_WAY_NUM-1:0]                                    ic_tag_web,
    output  [RCT_ICACHE_WAY_NUM-1:0][RCT_ICACHE_SET_ID_W-1:0]           ic_tag_addr,
    output  [RCT_ICACHE_WAY_NUM-1:0][RCT_ICACHE_TAG_W-1:0]              ic_tag_bweb,
    output  [RCT_ICACHE_WAY_NUM-1:0][RCT_ICACHE_TAG_W-1:0]              ic_tag_din,
    input   [RCT_ICACHE_WAY_NUM-1:0][RCT_ICACHE_TAG_W-1:0]              ic_tag_dout,
    output  [RCT_ICACHE_WAY_NUM-1:0]                                    ic_data_csb,
    output  [RCT_ICACHE_WAY_NUM-1:0]                                    ic_data_web,
    output  [RCT_ICACHE_WAY_NUM-1:0][RCT_ICACHE_DATA_ADDR_W-1:0]        ic_data_addr,
    output  [RCT_ICACHE_WAY_NUM-1:0][RCT_ICACHE_FETCH_DATA_W-1:0]       ic_data_bweb,
    output  [RCT_ICACHE_WAY_NUM-1:0][RCT_ICACHE_FETCH_DATA_W-1:0]       ic_data_din,
    input   [RCT_ICACHE_WAY_NUM-1:0][RCT_ICACHE_FETCH_DATA_W-1:0]       ic_data_dout,

    //Interface with dcache
    output  [RCT_DCACHE_WAY_NUM-1:0]                                    dc_tag_csb,
    output  [RCT_DCACHE_WAY_NUM-1:0]                                    dc_tag_web,
    output  [RCT_DCACHE_WAY_NUM-1:0][RCT_DCACHE_SET_ID_W-1:0]           dc_tag_addr,
    output  [RCT_DCACHE_WAY_NUM-1:0][RCT_DCACHE_TAG_W-1:0]              dc_tag_bweb,
    output  [RCT_DCACHE_WAY_NUM-1:0][RCT_DCACHE_TAG_W-1:0]              dc_tag_din,
    input   [RCT_DCACHE_WAY_NUM-1:0][RCT_DCACHE_TAG_W-1:0]              dc_tag_dout,
    output  [RCT_DCACHE_WAY_NUM-1:0]                                    dc_data_csb,
    output  [RCT_DCACHE_WAY_NUM-1:0]                                    dc_data_web,
    output  [RCT_DCACHE_WAY_NUM-1:0][RCT_DCACHE_DATA_ADDR_W-1:0]        dc_data_addr,
    output  [RCT_DCACHE_WAY_NUM-1:0][RCT_DCACHE_RD_DATA_W-1:0]          dc_data_bweb,
    output  [RCT_DCACHE_WAY_NUM-1:0][RCT_DCACHE_RD_DATA_W-1:0]          dc_data_din,
    input   [RCT_DCACHE_WAY_NUM-1:0][RCT_DCACHE_RD_DATA_W-1:0]          dc_data_dout,

    input                                                               slv_mem_if_req_valid,
    output                                                              slv_mem_if_req_ready,
    input   mem_if_req_t                                                slv_mem_if_req,

    output                                                              slv_mem_if_resp_valid,
    input                                                               slv_mem_if_resp_ready,
    output  mem_if_resp_t                                               slv_mem_if_resp,

    output                                                              ifu_mem_if_req_valid0,
    input                                                               ifu_mem_if_req_ready0,
    output  mem_if_req_t                                                ifu_mem_if_req0,

    input                                                               ifu_mem_if_resp_valid0,
    output                                                              ifu_mem_if_resp_ready0,
    input   mem_if_resp_t                                               ifu_mem_if_resp0,

    output                                                              ifu_mem_if_req_valid1,
    input                                                               ifu_mem_if_req_ready1,
    output  mem_if_req_t                                                ifu_mem_if_req1,

    input                                                               ifu_mem_if_resp_valid1,
    output                                                              ifu_mem_if_resp_ready1,
    input   mem_if_resp_t                                               ifu_mem_if_resp1,

    output                                                              lsu_mem_if_req_valid0,
    input                                                               lsu_mem_if_req_ready0,
    output  mem_if_req_t                                                lsu_mem_if_req0,

    input                                                               lsu_mem_if_resp_valid0,
    output                                                              lsu_mem_if_resp_ready0,
    input   mem_if_resp_t                                               lsu_mem_if_resp0,

    output                                                              lsu_mem_if_req_valid1,
    input                                                               lsu_mem_if_req_ready1,
    output  mem_if_req_t                                                lsu_mem_if_req1,

    input                                                               lsu_mem_if_resp_valid1,
    output                                                              lsu_mem_if_resp_ready1,
    input   mem_if_resp_t                                               lsu_mem_if_resp1,


    output                                                              ptw_mem_if_req_valid,
    input                                                               ptw_mem_if_req_ready,
    output  mem_if_req_t                                                ptw_mem_if_req,

    input                                                               ptw_mem_if_resp_valid,
    output                                                              ptw_mem_if_resp_ready,
    input   mem_if_resp_t                                               ptw_mem_if_resp

);
//wires
rct_csr_satp_t                                          csr_satp;
rct_csr_mstatus_t                                       csr_mstatus;
rct_prv_t                                               csr_prv;
logic                                                   csr_debug_mode;
rct_data_t                                              csr_mepc;
rct_data_t                                              csr_sepc;
logic                                                   csr_single_step;
logic                                                   csr_ebreak_en;
rct_data_t                                              csr_dpc;
rct_data_t                                              csr_int_target_pc;
rct_data_t                                              csr_excp_target_pc;
logic                                                   itlb_ptw_req_valid;
logic                                                   ptw_itlb_req_ready;
rct_tlb_ptw_req_t                                       itlb_ptw_req;
logic                                                   ptw_itlb_resp_valid;
logic                                                   itlb_ptw_resp_ready;
rct_tlb_ptw_resp_t                                      ptw_itlb_resp;
logic                                                   dtlb_ptw_req_valid;
logic                                                   ptw_dtlb_req_ready;
rct_tlb_ptw_req_t                                       dtlb_ptw_req;
logic                                                   ptw_dtlb_resp_valid;
logic                                                   dtlb_ptw_resp_ready;
rct_tlb_ptw_resp_t                                      ptw_dtlb_resp;

logic   [RCT_ISSUE_NUM-1:0]                             fe_isu_valid;
logic   [RCT_ISSUE_NUM-1:0]                             isu_fe_ready;
rct_fe_isu_t[RCT_ISSUE_NUM-1:0]                         fe_isu_info;

logic                                                   bru_bp_update;
rct_bru_bp_t                                            bru_bp_update_info;

logic                                                   iru_fe_flush_pc_valid;
logic   [RCT_EFF_ADDR_W-1:0]                            iru_fe_flush_pc;

logic   [RCT_EXE_STG_NUM-1:0]                           flush;
logic   [RCT_EXE_STG_NUM-1:0]                           stall;

logic                                                   int_pending;
logic                                                   int_trapable;

logic                                                   iru_csr_int_req_grnt;
logic                                                   iru_csr_excp_grnt;
logic                                                   iru_csr_mret_grnt;
logic                                                   iru_csr_sret_grnt;
rct_data_t                                              iru_csr_epc;
rct_excp_cause_t                                        iru_csr_cause;
rct_data_t                                              iru_csr_tval;
logic                                                   iru_csr_debug_req_grnt;
logic                                                   iru_csr_dret_grnt;
rct_data_t                                              iru_csr_dpc;
rct_dcause_t                                            iru_csr_dcause;

logic                                                   isu_i0_valid;
logic                                                   i0_isu_ready;
rct_isu_alu_t                                           isu_i0_info;
logic                                                   isu_i1_valid;
logic                                                   i1_isu_ready;
rct_isu_alu_t                                           isu_i1_info;
logic                                                   isu_mul_valid;
logic                                                   mul_isu_ready;
rct_isu_mul_t                                           isu_mul_info;
logic                                                   isu_div_valid;
logic                                                   div_isu_ready;
rct_isu_div_t                                           isu_div_info;
logic                                                   isu_bru_valid;
logic                                                   bru_isu_ready;
rct_isu_bru_t                                           isu_bru_info;
logic                                                   isu_csr_valid;
logic                                                   csr_isu_ready;
rct_isu_csr_t                                           isu_csr_info;
logic                                                   isu_lsu_valid;
logic                                                   lsu_isu_ready;
rct_isu_lsu_t                                           isu_lsu_info;

logic                                                   i0_valid_ex1    ;
logic   [RCT_ARF_ID_W-1:0]                              i0_rd_ex1       ;
logic   [RCT_DATA_W-1:0]                                i0_rslt_ex1     ;
logic                                                   i0_valid_ex2    ;
logic   [RCT_ARF_ID_W-1:0]                              i0_rd_ex2       ;
logic   [RCT_DATA_W-1:0]                                i0_rslt_ex2     ;
logic                                                   i0_valid_ex3    ;
logic   [RCT_ARF_ID_W-1:0]                              i0_rd_ex3       ;
logic   [RCT_DATA_W-1:0]                                i0_rslt_ex3     ;
logic   [RCT_EFF_ADDR_W-1:0]                            i0_pc_ex3       ;
logic   [RCT_SLOT_ID_W-1:0]                             i0_slot_id_ex3  ;
logic                                                   isu_i0_ready_ex3;

logic                                                   i1_valid_ex1    ;
logic   [RCT_ARF_ID_W-1:0]                              i1_rd_ex1       ;
logic   [RCT_DATA_W-1:0]                                i1_rslt_ex1     ;
logic                                                   i1_valid_ex2    ;
logic   [RCT_ARF_ID_W-1:0]                              i1_rd_ex2       ;
logic   [RCT_DATA_W-1:0]                                i1_rslt_ex2     ;
logic                                                   i1_valid_ex3    ;
logic   [RCT_ARF_ID_W-1:0]                              i1_rd_ex3       ;
logic   [RCT_DATA_W-1:0]                                i1_rslt_ex3     ;
logic   [RCT_EFF_ADDR_W-1:0]                            i1_pc_ex3       ;
logic   [RCT_SLOT_ID_W-1:0]                             i1_slot_id_ex3  ;
logic                                                   isu_i1_ready_ex3;

logic                                                   mul_valid_ex2    ;
logic   [RCT_ARF_ID_W-1:0]                              mul_rd_ex2       ;
logic   [RCT_DATA_W-1:0]                                mul_rslt_ex2     ;
logic                                                   mul_valid_ex3    ;
logic   [RCT_ARF_ID_W-1:0]                              mul_rd_ex3       ;
logic   [RCT_DATA_W-1:0]                                mul_rslt_ex3     ;
logic   [RCT_EFF_ADDR_W-1:0]                            mul_pc_ex3       ;
logic   [RCT_SLOT_ID_W-1:0]                             mul_slot_id_ex3  ;
logic                                                   isu_mul_ready_ex3;

logic                                                   div_valid_ex3    ;
logic   [RCT_ARF_ID_W-1:0]                              div_rd_ex3       ;
logic   [RCT_DATA_W-1:0]                                div_rslt_ex3     ;
logic   [RCT_EFF_ADDR_W-1:0]                            div_pc_ex3       ;
logic   [RCT_SLOT_ID_W-1:0]                             div_slot_id_ex3  ;
logic                                                   isu_div_ready_ex3;

logic                                                   bru_valid_ex1    ;
logic   [RCT_ARF_ID_W-1:0]                              bru_rd_ex1       ;
logic   [RCT_DATA_W-1:0]                                bru_rslt_ex1     ;
logic                                                   bru_valid_ex2    ;
logic   [RCT_ARF_ID_W-1:0]                              bru_rd_ex2       ;
logic   [RCT_DATA_W-1:0]                                bru_rslt_ex2     ;
logic                                                   bru_valid_ex3    ;
logic   [RCT_ARF_ID_W-1:0]                              bru_rd_ex3       ;
logic   [RCT_DATA_W-1:0]                                bru_rslt_ex3     ;
logic   [RCT_EFF_ADDR_W-1:0]                            bru_pc_ex3       ;
logic                                                   bru_mis_pred_ex3 ;
logic   [RCT_EFF_ADDR_W-1:0]                            bru_npc_ex3       ;
logic   [RCT_SLOT_ID_W-1:0]                             bru_slot_id_ex3  ;
logic                                                   isu_bru_ready_ex3;

logic                                                   csr_valid_ex3    ;
logic   [RCT_ARF_ID_W-1:0]                              csr_rd_ex3       ;
logic   [RCT_DATA_W-1:0]                                csr_rslt_ex3     ;
logic   [RCT_EFF_ADDR_W-1:0]                            csr_pc_ex3       ;
logic   [RCT_SLOT_ID_W-1:0]                             csr_slot_id_ex3  ;
logic                                                   csr_excp_valid_ex3;
rct_excp_cause_t                                        csr_excp_cause_ex3;
rct_data_t                                              csr_excp_tval_ex3 ;
logic                                                   isu_csr_ready_ex3;

logic                                                   lsu_valid_ex3    ;
logic   [RCT_ARF_ID_W-1:0]                              lsu_rd_ex3       ;
logic   [RCT_DATA_W-1:0]                                lsu_rslt_ex3     ;
logic   [RCT_EFF_ADDR_W-1:0]                            lsu_pc_ex3       ;
logic   [RCT_SLOT_ID_W-1:0]                             lsu_slot_id_ex3  ;
logic                                                   lsu_excp_valid_ex3;
rct_excp_cause_t                                        lsu_excp_cause_ex3;
rct_data_t                                              lsu_excp_tval_ex3 ;
logic                                                   isu_lsu_ready_ex3;

logic                                                   lsu_stall_req_ex1;
logic                                                   lsu_stall_req_ex3;
logic                                                   exu_idle;
logic                                                   lsu_idle;
rct_core_frontend frontend_u
(
    .clk                            ( clk                       )
   ,.rstn                           ( rstn                      )
   ,.cfg_boot_pc                    ( cfg_boot_pc               )
   ,.cfg_bpu_disable                ( cfg_bpu_disable           )
   ,.cfg_icache_enable              ( cfg_icache_enable         )
   ,.cfg_mmu_enable                 ( cfg_mmu_enable            )
   ,.cfg_core_cache_start_addr      ( cfg_core_cache_start_addr )
   ,.cfg_core_cache_end_addr        ( cfg_core_cache_end_addr   )
   ,.csr_satp                       ( csr_satp                  )
   ,.csr_mstatus                    ( csr_mstatus               )
   ,.csr_prv                        ( csr_prv                   )
   ,.ic_tag_csb                     ( ic_tag_csb                )
   ,.ic_tag_web                     ( ic_tag_web                )
   ,.ic_tag_addr                    ( ic_tag_addr               )
   ,.ic_tag_bweb                    ( ic_tag_bweb               )
   ,.ic_tag_din                     ( ic_tag_din                )
   ,.ic_tag_dout                    ( ic_tag_dout               )
   ,.ic_data_csb                    ( ic_data_csb               )
   ,.ic_data_web                    ( ic_data_web               )
   ,.ic_data_addr                   ( ic_data_addr              )
   ,.ic_data_bweb                   ( ic_data_bweb              )
   ,.ic_data_din                    ( ic_data_din               )
   ,.ic_data_dout                   ( ic_data_dout              )
   ,.itlb_ptw_req_valid             ( itlb_ptw_req_valid        )
   ,.ptw_itlb_req_ready             ( ptw_itlb_req_ready        )
   ,.itlb_ptw_req                   ( itlb_ptw_req              )
   ,.ptw_itlb_resp_valid            ( ptw_itlb_resp_valid       )
   ,.itlb_ptw_resp_ready            ( itlb_ptw_resp_ready       )
   ,.ptw_itlb_resp                  ( ptw_itlb_resp             )
   ,.ifu_mem_if_req_valid0          ( ifu_mem_if_req_valid0     )
   ,.ifu_mem_if_req_ready0          ( ifu_mem_if_req_ready0     )
   ,.ifu_mem_if_req0                ( ifu_mem_if_req0           )
   ,.ifu_mem_if_resp_valid0         ( ifu_mem_if_resp_valid0    )
   ,.ifu_mem_if_resp_ready0         ( ifu_mem_if_resp_ready0    )
   ,.ifu_mem_if_resp0               ( ifu_mem_if_resp0          )
   ,.ifu_mem_if_req_valid1          ( ifu_mem_if_req_valid1     )
   ,.ifu_mem_if_req_ready1          ( ifu_mem_if_req_ready1     )
   ,.ifu_mem_if_req1                ( ifu_mem_if_req1           )
   ,.ifu_mem_if_resp_valid1         ( ifu_mem_if_resp_valid1    )
   ,.ifu_mem_if_resp_ready1         ( ifu_mem_if_resp_ready1    )
   ,.ifu_mem_if_resp1               ( ifu_mem_if_resp1          )
   ,.fe_isu_valid                   ( fe_isu_valid              )
   ,.isu_fe_ready                   ( isu_fe_ready              )
   ,.fe_isu_info                    ( fe_isu_info               )
   ,.bru_bp_update                  ( bru_bp_update             )
   ,.bru_bp_update_info             ( bru_bp_update_info        )
   ,.iru_fe_flush_pc_valid          ( iru_fe_flush_pc_valid     )
   ,.iru_fe_flush_pc                ( iru_fe_flush_pc           )

);
rct_core_isu    isu_u
(
    .clk                            ( clk                       )
   ,.rstn                           ( rstn                      )
   ,.sleep                          ( sleep                     )
   ,.dm_halt_req                    ( dm_halt_req               )
   ,.flush                          ( flush                     )
   ,.stall                          ( stall                     )
   ,.exu_idle                       ( exu_idle                  )
   ,.lsu_idle                       ( lsu_idle                  )

   ,.csr_prv                        ( csr_prv                   )
   ,.csr_debug_mode                 ( csr_debug_mode            )
   ,.csr_single_step                ( csr_single_step           )
   ,.csr_ebreak_en                  ( csr_ebreak_en             )
   ,.csr_dpc                        ( csr_dpc                   )
   ,.csr_mepc                       ( csr_mepc                  )
   ,.csr_sepc                       ( csr_sepc                  )
   ,.csr_int_target_pc              ( csr_int_target_pc         )
   ,.csr_excp_target_pc             ( csr_excp_target_pc        )
   ,.int_pending                    ( int_pending               )
   ,.int_trapable                   ( int_trapable              )
   ,.iru_csr_int_req_grnt           ( iru_csr_int_req_grnt      )
   ,.iru_csr_excp_grnt              ( iru_csr_excp_grnt         )
   ,.iru_csr_mret_grnt              ( iru_csr_mret_grnt         )
   ,.iru_csr_sret_grnt              ( iru_csr_sret_grnt         )
   ,.iru_csr_epc                    ( iru_csr_epc               )
   ,.iru_csr_cause                  ( iru_csr_cause             )
   ,.iru_csr_tval                   ( iru_csr_tval              )
   ,.iru_csr_debug_req_grnt         ( iru_csr_debug_req_grnt    )
   ,.iru_csr_dret_grnt              ( iru_csr_dret_grnt         )
   ,.iru_csr_dpc                    ( iru_csr_dpc               )
   ,.iru_csr_dcause                 ( iru_csr_dcause            )
   ,.fe_isu_valid                   ( fe_isu_valid              )
   ,.isu_fe_ready                   ( isu_fe_ready              )
   ,.fe_isu_info                    ( fe_isu_info               )
   ,.iru_fe_flush_pc_valid          ( iru_fe_flush_pc_valid     )
   ,.iru_fe_flush_pc                ( iru_fe_flush_pc           )

   ,.isu_i0_valid                   ( isu_i0_valid              )
   ,.i0_isu_ready                   ( i0_isu_ready              )
   ,.isu_i0_info                    ( isu_i0_info               )

   ,.isu_i1_valid                   ( isu_i1_valid              )
   ,.i1_isu_ready                   ( i1_isu_ready              )
   ,.isu_i1_info                    ( isu_i1_info               )

   ,.isu_mul_valid                  ( isu_mul_valid             )
   ,.mul_isu_ready                  ( mul_isu_ready             )
   ,.isu_mul_info                   ( isu_mul_info              )

   ,.isu_div_valid                  ( isu_div_valid             )
   ,.div_isu_ready                  ( div_isu_ready             )
   ,.isu_div_info                   ( isu_div_info              )

   ,.isu_bru_valid                  ( isu_bru_valid             )
   ,.bru_isu_ready                  ( bru_isu_ready             )
   ,.isu_bru_info                   ( isu_bru_info              )

   ,.isu_csr_valid                  ( isu_csr_valid             )
   ,.csr_isu_ready                  ( csr_isu_ready             )
   ,.isu_csr_info                   ( isu_csr_info              )

   ,.isu_lsu_valid                  ( isu_lsu_valid             )
   ,.lsu_isu_ready                  ( lsu_isu_ready             )
   ,.isu_lsu_info                   ( isu_lsu_info              )

   ,.i0_valid_ex1                   ( i0_valid_ex1              )
   ,.i0_rd_ex1                      ( i0_rd_ex1                 )
   ,.i0_rslt_ex1                    ( i0_rslt_ex1               )
   ,.i0_valid_ex2                   ( i0_valid_ex2              )
   ,.i0_rd_ex2                      ( i0_rd_ex2                 )
   ,.i0_rslt_ex2                    ( i0_rslt_ex2               )
   ,.i0_valid_ex3                   ( i0_valid_ex3              )
   ,.i0_rd_ex3                      ( i0_rd_ex3                 )
   ,.i0_rslt_ex3                    ( i0_rslt_ex3               )
   ,.i0_pc_ex3                      ( i0_pc_ex3                 )
   ,.i0_slot_id_ex3                 ( i0_slot_id_ex3            )
   ,.isu_i0_ready_ex3               ( isu_i0_ready_ex3          )

   ,.i1_valid_ex1                   ( i1_valid_ex1              )
   ,.i1_rd_ex1                      ( i1_rd_ex1                 )
   ,.i1_rslt_ex1                    ( i1_rslt_ex1               )
   ,.i1_valid_ex2                   ( i1_valid_ex2              )
   ,.i1_rd_ex2                      ( i1_rd_ex2                 )
   ,.i1_rslt_ex2                    ( i1_rslt_ex2               )
   ,.i1_valid_ex3                   ( i1_valid_ex3              )
   ,.i1_rd_ex3                      ( i1_rd_ex3                 )
   ,.i1_rslt_ex3                    ( i1_rslt_ex3               )
   ,.i1_pc_ex3                      ( i1_pc_ex3                 )
   ,.i1_slot_id_ex3                 ( i1_slot_id_ex3            )
   ,.isu_i1_ready_ex3               ( isu_i1_ready_ex3          )

   ,.mul_valid_ex2                  ( mul_valid_ex2             )
   ,.mul_rd_ex2                     ( mul_rd_ex2                )
   ,.mul_rslt_ex2                   ( mul_rslt_ex2              )
   ,.mul_valid_ex3                  ( mul_valid_ex3             )
   ,.mul_rd_ex3                     ( mul_rd_ex3                )
   ,.mul_rslt_ex3                   ( mul_rslt_ex3              )
   ,.mul_pc_ex3                     ( mul_pc_ex3                )
   ,.mul_slot_id_ex3                ( mul_slot_id_ex3           )
   ,.isu_mul_ready_ex3              ( isu_mul_ready_ex3         ) 

   ,.div_valid_ex3                  ( div_valid_ex3             )
   ,.div_rd_ex3                     ( div_rd_ex3                )
   ,.div_rslt_ex3                   ( div_rslt_ex3              )
   ,.div_pc_ex3                     ( div_pc_ex3                )
   ,.div_slot_id_ex3                ( div_slot_id_ex3           )
   ,.isu_div_ready_ex3              ( isu_div_ready_ex3         )

   ,.bru_valid_ex1                   ( bru_valid_ex1              )
   ,.bru_rd_ex1                      ( bru_rd_ex1                 )
   ,.bru_rslt_ex1                    ( bru_rslt_ex1               )
   ,.bru_valid_ex2                   ( bru_valid_ex2              )
   ,.bru_rd_ex2                      ( bru_rd_ex2                 )
   ,.bru_rslt_ex2                    ( bru_rslt_ex2               )
   ,.bru_valid_ex3                   ( bru_valid_ex3              )
   ,.bru_rd_ex3                      ( bru_rd_ex3                 )
   ,.bru_rslt_ex3                    ( bru_rslt_ex3               )
   ,.bru_pc_ex3                      ( bru_pc_ex3                 )
   ,.bru_mis_pred_ex3                ( bru_mis_pred_ex3           )
   ,.bru_npc_ex3                     ( bru_npc_ex3                )
   ,.bru_slot_id_ex3                 ( bru_slot_id_ex3            )
   ,.isu_bru_ready_ex3               ( isu_bru_ready_ex3          )


   ,.csr_valid_ex3                  ( csr_valid_ex3             )
   ,.csr_rd_ex3                     ( csr_rd_ex3                )
   ,.csr_rslt_ex3                   ( csr_rslt_ex3              )
   ,.csr_pc_ex3                     ( csr_pc_ex3                )
   ,.csr_slot_id_ex3                ( csr_slot_id_ex3           )
   ,.csr_excp_valid_ex3             ( csr_excp_valid_ex3        )
   ,.csr_excp_cause_ex3             ( csr_excp_cause_ex3        )
   ,.csr_excp_tval_ex3              ( csr_excp_tval_ex3         )
   ,.isu_csr_ready_ex3              ( isu_csr_ready_ex3         )

   ,.lsu_valid_ex3                  ( lsu_valid_ex3             )
   ,.lsu_rd_ex3                     ( lsu_rd_ex3                )
   ,.lsu_rslt_ex3                   ( lsu_rslt_ex3              )
   ,.lsu_pc_ex3                     ( lsu_pc_ex3                )
   ,.lsu_slot_id_ex3                ( lsu_slot_id_ex3           )
   ,.lsu_excp_valid_ex3             ( lsu_excp_valid_ex3        )
   ,.lsu_excp_cause_ex3             ( lsu_excp_cause_ex3        )
   ,.lsu_excp_tval_ex3              ( lsu_excp_tval_ex3         )
   ,.isu_lsu_ready_ex3              ( isu_lsu_ready_ex3         )

   ,.lsu_stall_req_ex1              ( lsu_stall_req_ex1         )
   ,.lsu_stall_req_ex3              ( lsu_stall_req_ex3         )

);

rct_core_exu    exu_u
(
    .clk                            ( clk                       )
   ,.rstn                           ( rstn                      )
   ,.stall                          ( stall                     )
   ,.flush                          ( flush                     )
   ,.idle                           ( exu_idle                  )
   ,.hartinfo                       ( hartinfo                  )
   ,.timer_int                      ( timer_int                 )
   ,.soft_int                       ( soft_int                  )
   ,.ext_int                        ( ext_int                   )
   ,.csr_debug_mode                 ( csr_debug_mode            )
   ,.csr_prv                        ( csr_prv                   )
   ,.csr_satp                       ( csr_satp                  )
   ,.csr_mstatus                    ( csr_mstatus               )
   ,.csr_single_step                ( csr_single_step           )
   ,.csr_ebreak_en                  ( csr_ebreak_en             )
   ,.csr_dpc                        ( csr_dpc                   )
   ,.csr_mepc                       ( csr_mepc                  )
   ,.csr_sepc                       ( csr_sepc                  )
   ,.csr_int_target_pc              ( csr_int_target_pc         )
   ,.csr_excp_target_pc             ( csr_excp_target_pc        )
   ,.int_pending                    ( int_pending               )
   ,.int_trapable                   ( int_trapable              )
   ,.iru_csr_int_req_grnt           ( iru_csr_int_req_grnt      )
   ,.iru_csr_excp_grnt              ( iru_csr_excp_grnt         )
   ,.iru_csr_mret_grnt              ( iru_csr_mret_grnt         )
   ,.iru_csr_sret_grnt              ( iru_csr_sret_grnt         )
   ,.iru_csr_epc                    ( iru_csr_epc               )
   ,.iru_csr_cause                  ( iru_csr_cause             )
   ,.iru_csr_tval                   ( iru_csr_tval              )
   ,.iru_csr_debug_req_grnt         ( iru_csr_debug_req_grnt    )
   ,.iru_csr_dret_grnt              ( iru_csr_dret_grnt         )
   ,.iru_csr_dpc                    ( iru_csr_dpc               )
   ,.iru_csr_dcause                 ( iru_csr_dcause            )

   ,.isu_i0_valid                   ( isu_i0_valid              )
   ,.i0_isu_ready                   ( i0_isu_ready              )
   ,.isu_i0_info                    ( isu_i0_info               )

   ,.isu_i1_valid                   ( isu_i1_valid              )
   ,.i1_isu_ready                   ( i1_isu_ready              )
   ,.isu_i1_info                    ( isu_i1_info               )

   ,.isu_mul_valid                  ( isu_mul_valid             )
   ,.mul_isu_ready                  ( mul_isu_ready             )
   ,.isu_mul_info                   ( isu_mul_info              )

   ,.isu_div_valid                  ( isu_div_valid             )
   ,.div_isu_ready                  ( div_isu_ready             )
   ,.isu_div_info                   ( isu_div_info              )

   ,.isu_bru_valid                  ( isu_bru_valid             )
   ,.bru_isu_ready                  ( bru_isu_ready             )
   ,.isu_bru_info                   ( isu_bru_info              )
   ,.bru_bp_update                  ( bru_bp_update             )
   ,.bru_bp_update_info             ( bru_bp_update_info        )

   ,.isu_csr_valid                  ( isu_csr_valid             )
   ,.csr_isu_ready                  ( csr_isu_ready             )
   ,.isu_csr_info                   ( isu_csr_info              )

   ,.i0_valid_ex1                   ( i0_valid_ex1              )
   ,.i0_rd_ex1                      ( i0_rd_ex1                 )
   ,.i0_rslt_ex1                    ( i0_rslt_ex1               )
   ,.i0_valid_ex2                   ( i0_valid_ex2              )
   ,.i0_rd_ex2                      ( i0_rd_ex2                 )
   ,.i0_rslt_ex2                    ( i0_rslt_ex2               )
   ,.i0_valid_ex3                   ( i0_valid_ex3              )
   ,.i0_rd_ex3                      ( i0_rd_ex3                 )
   ,.i0_rslt_ex3                    ( i0_rslt_ex3               )
   ,.i0_pc_ex3                      ( i0_pc_ex3                 )
   ,.i0_slot_id_ex3                 ( i0_slot_id_ex3            )
   ,.isu_i0_ready_ex3               ( isu_i0_ready_ex3          )

   ,.i1_valid_ex1                   ( i1_valid_ex1              )
   ,.i1_rd_ex1                      ( i1_rd_ex1                 )
   ,.i1_rslt_ex1                    ( i1_rslt_ex1               )
   ,.i1_valid_ex2                   ( i1_valid_ex2              )
   ,.i1_rd_ex2                      ( i1_rd_ex2                 )
   ,.i1_rslt_ex2                    ( i1_rslt_ex2               )
   ,.i1_valid_ex3                   ( i1_valid_ex3              )
   ,.i1_rd_ex3                      ( i1_rd_ex3                 )
   ,.i1_rslt_ex3                    ( i1_rslt_ex3               )
   ,.i1_pc_ex3                      ( i1_pc_ex3                 )
   ,.i1_slot_id_ex3                 ( i1_slot_id_ex3            )
   ,.isu_i1_ready_ex3               ( isu_i1_ready_ex3          )

   ,.mul_valid_ex2                  ( mul_valid_ex2             )
   ,.mul_rd_ex2                     ( mul_rd_ex2                )
   ,.mul_rslt_ex2                   ( mul_rslt_ex2              )
   ,.mul_valid_ex3                  ( mul_valid_ex3             )
   ,.mul_rd_ex3                     ( mul_rd_ex3                )
   ,.mul_rslt_ex3                   ( mul_rslt_ex3              )
   ,.mul_pc_ex3                     ( mul_pc_ex3                )
   ,.mul_slot_id_ex3                ( mul_slot_id_ex3           )
   ,.isu_mul_ready_ex3              ( isu_mul_ready_ex3         ) 

   ,.div_valid_ex3                  ( div_valid_ex3             )
   ,.div_rd_ex3                     ( div_rd_ex3                )
   ,.div_rslt_ex3                   ( div_rslt_ex3              )
   ,.div_pc_ex3                     ( div_pc_ex3                )
   ,.div_slot_id_ex3                ( div_slot_id_ex3           )
   ,.isu_div_ready_ex3              ( isu_div_ready_ex3         )

   ,.bru_valid_ex1                   ( bru_valid_ex1              )
   ,.bru_rd_ex1                      ( bru_rd_ex1                 )
   ,.bru_rslt_ex1                    ( bru_rslt_ex1               )
   ,.bru_valid_ex2                   ( bru_valid_ex2              )
   ,.bru_rd_ex2                      ( bru_rd_ex2                 )
   ,.bru_rslt_ex2                    ( bru_rslt_ex2               )
   ,.bru_valid_ex3                   ( bru_valid_ex3              )
   ,.bru_rd_ex3                      ( bru_rd_ex3                 )
   ,.bru_rslt_ex3                    ( bru_rslt_ex3               )
   ,.bru_pc_ex3                      ( bru_pc_ex3                 )
   ,.bru_mis_pred_ex3                ( bru_mis_pred_ex3           )
   ,.bru_npc_ex3                     ( bru_npc_ex3                )
   ,.bru_slot_id_ex3                 ( bru_slot_id_ex3            )
   ,.isu_bru_ready_ex3               ( isu_bru_ready_ex3          )


   ,.csr_valid_ex3                  ( csr_valid_ex3             )
   ,.csr_rd_ex3                     ( csr_rd_ex3                )
   ,.csr_rslt_ex3                   ( csr_rslt_ex3              )
   ,.csr_pc_ex3                     ( csr_pc_ex3                )
   ,.csr_slot_id_ex3                ( csr_slot_id_ex3           )
   ,.csr_excp_valid_ex3             ( csr_excp_valid_ex3        )
   ,.csr_excp_cause_ex3             ( csr_excp_cause_ex3        )
   ,.csr_excp_tval_ex3              ( csr_excp_tval_ex3         )
   ,.isu_csr_ready_ex3              ( isu_csr_ready_ex3         )

      
);
rct_core_lsu_wrapper    lsu_wrapper_u
(
    .clk                            ( clk                       )
   ,.rstn                           ( rstn                      )
   ,.stall                          ( stall                     )
   ,.flush                          ( flush                     )
   ,.idle                           ( lsu_idle                  )
   ,.cfg_dcache_enable              ( cfg_dcache_enable         )
   ,.cfg_mmu_enable                 ( cfg_mmu_enable            )
   ,.cfg_core_cache_start_addr      ( cfg_core_cache_start_addr )
   ,.cfg_core_cache_end_addr        ( cfg_core_cache_end_addr   )
   ,.csr_satp                       ( csr_satp                  )
   ,.csr_prv                        ( csr_prv                   )
   ,.csr_mstatus                    ( csr_mstatus               )
   ,.input_valid                    ( isu_lsu_valid             )
   ,.input_ready                    ( lsu_isu_ready             )
   ,.input_info                     ( isu_lsu_info              )

   ,.lsu_valid_ex3                  ( lsu_valid_ex3             )
   ,.lsu_rd_ex3                     ( lsu_rd_ex3                )
   ,.lsu_rslt_ex3                   ( lsu_rslt_ex3              )
   ,.lsu_pc_ex3                     ( lsu_pc_ex3                )
   ,.lsu_slot_id_ex3                ( lsu_slot_id_ex3           )
   ,.lsu_excp_valid_ex3             ( lsu_excp_valid_ex3        )
   ,.lsu_excp_cause_ex3             ( lsu_excp_cause_ex3        )
   ,.lsu_excp_tval_ex3              ( lsu_excp_tval_ex3         )
   ,.isu_lsu_ready_ex3              ( isu_lsu_ready_ex3         )

   ,.lsu_stall_req_ex1              ( lsu_stall_req_ex1         )
   ,.lsu_stall_req_ex3              ( lsu_stall_req_ex3         )     

   ,.dc_tag_csb                     ( dc_tag_csb                )
   ,.dc_tag_web                     ( dc_tag_web                )
   ,.dc_tag_addr                    ( dc_tag_addr               )
   ,.dc_tag_bweb                    ( dc_tag_bweb               )
   ,.dc_tag_din                     ( dc_tag_din                )
   ,.dc_tag_dout                    ( dc_tag_dout               )
   ,.dc_data_csb                    ( dc_data_csb               )
   ,.dc_data_web                    ( dc_data_web               )
   ,.dc_data_addr                   ( dc_data_addr              )
   ,.dc_data_bweb                   ( dc_data_bweb              )
   ,.dc_data_din                    ( dc_data_din               )
   ,.dc_data_dout                   ( dc_data_dout              )

   ,.dtlb_ptw_req_valid             ( dtlb_ptw_req_valid        )
   ,.ptw_dtlb_req_ready             ( ptw_dtlb_req_ready        )
   ,.dtlb_ptw_req                   ( dtlb_ptw_req              )
   ,.ptw_dtlb_resp_valid            ( ptw_dtlb_resp_valid       )
   ,.dtlb_ptw_resp_ready            ( dtlb_ptw_resp_ready       )
   ,.ptw_dtlb_resp                  ( ptw_dtlb_resp             )

   ,.lsu_mem_if_req_valid0          ( lsu_mem_if_req_valid0     )
   ,.lsu_mem_if_req_ready0          ( lsu_mem_if_req_ready0     )
   ,.lsu_mem_if_req0                ( lsu_mem_if_req0           )
   ,.lsu_mem_if_resp_valid0         ( lsu_mem_if_resp_valid0    )
   ,.lsu_mem_if_resp_ready0         ( lsu_mem_if_resp_ready0    )
   ,.lsu_mem_if_resp0               ( lsu_mem_if_resp0          )
   ,.lsu_mem_if_req_valid1          ( lsu_mem_if_req_valid1     )
   ,.lsu_mem_if_req_ready1          ( lsu_mem_if_req_ready1     )
   ,.lsu_mem_if_req1                ( lsu_mem_if_req1           )
   ,.lsu_mem_if_resp_valid1         ( lsu_mem_if_resp_valid1    )
   ,.lsu_mem_if_resp_ready1         ( lsu_mem_if_resp_ready1    )
   ,.lsu_mem_if_resp1               ( lsu_mem_if_resp1          )
   );

rct_core_ptw    ptw_u
(
    .clk                            ( clk                       )
   ,.rstn                           ( rstn                      )
   ,.csr_satp                       ( csr_satp                  )
   ,.csr_prv                        ( csr_prv                   )
   ,.csr_mstatus                    ( csr_mstatus               )

   ,.itlb_ptw_req_valid             ( itlb_ptw_req_valid        )
   ,.ptw_itlb_req_ready             ( ptw_itlb_req_ready        )
   ,.itlb_ptw_req                   ( itlb_ptw_req              )
   ,.ptw_itlb_resp_valid            ( ptw_itlb_resp_valid       )
   ,.itlb_ptw_resp_ready            ( itlb_ptw_resp_ready       )
   ,.ptw_itlb_resp                  ( ptw_itlb_resp             )

   ,.dtlb_ptw_req_valid             ( dtlb_ptw_req_valid        )
   ,.ptw_dtlb_req_ready             ( ptw_dtlb_req_ready        )
   ,.dtlb_ptw_req                   ( dtlb_ptw_req              )
   ,.ptw_dtlb_resp_valid            ( ptw_dtlb_resp_valid       )
   ,.dtlb_ptw_resp_ready            ( dtlb_ptw_resp_ready       )
   ,.ptw_dtlb_resp                  ( ptw_dtlb_resp             )

   ,.ptw_mem_if_req_valid           ( ptw_mem_if_req_valid     )
   ,.ptw_mem_if_req_ready           ( ptw_mem_if_req_ready     )
   ,.ptw_mem_if_req                 ( ptw_mem_if_req           )
   ,.ptw_mem_if_resp_valid          ( ptw_mem_if_resp_valid    )
   ,.ptw_mem_if_resp_ready          ( ptw_mem_if_resp_ready    )
   ,.ptw_mem_if_resp                ( ptw_mem_if_resp          )
);

endmodule


