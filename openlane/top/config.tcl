########################################################################################################
set ::env(PDK) "sky130B"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

set script_dir [file dirname [file normalize [info script]]]
set proj_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) top
set verilog_root $proj_dir/../../verilog

########################################################################################################

# User Configurations
set ::env(DESIGN_IS_CORE) 0
## Clock configurations
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "12.5"
set ::env(SDC_FILE) "$proj_dir/base.sdc"
set ::env(BASE_SDC_FILE) "$proj_dir/base.sdc"
#set ::env(FP_PIN_ORDER_CFG) "$proj_dir/pin.cfg"
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 1950 1950"
set ::env(PL_TARGET_DENSITY) 0.34
set ::env(FP_PDN_CORE_RING) 0
set ::env(SYNTH_USE_PG_PINS_DEFINES) "USE_POWER_PINS"
set ::env(SYNTH_DEFINES) [list SYNTHESIS ]
set ::env(VDD_NETS) [list {vccd1}]
 set ::env(GND_NETS) [list {vssd1}]
set ::env(VDD_PIN)  [list {vccd1}]
set ::env(GND_PIN)  [list {vssd1}]
########################################################################################################
## Source Verilog Files
set ::env(VERILOG_FILES) "\
    $::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
    $proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/params.vh	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/pipeline/backend.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/pipeline/frontend.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/units/gshare.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/units/ins_buffer.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/units/new_alu.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/units/new_fu.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/units/rcu.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/units/counter_tmp.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/units/physical_regfile.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/units/fetch.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/units/excep_ctrl.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/units/counter.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/units/counter_rob.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/units/decode.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/units/btb.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/units/csr.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/units/fifo.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/units/fifo_tmp.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/lsu/ac.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/lsu/agu.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/lsu/cu.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/lsu/lsq.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/lsu/lr.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/lsu/nblsu.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/core_empty.v	\
    $proj_dir/../../verilog/rtl_sram_out_cache/bus_arbiter.v \
    $proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/cache/cacheblock/std_dffe.v \
    $proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/cache/cacheblock/std_dffr.v \
    $proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/cache/l1dcache.v \
    $proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/cache/l1icache_32.v \
    $proj_dir/../../verilog/rtl_sram_out_cache/caravel_defines.v \
    $proj_dir/../../verilog/rtl_sram_out_cache/inc/rvj1_defines.v \
	$proj_dir/../../verilog/rtl_sram_out_cache/rvj1_caravel_soc.v \
	$proj_dir/../../verilog/rtl_sram_out_cache/instr_ram_mux.v \
	$proj_dir/../../verilog/rtl_sram_out_cache/data_ram_mux.v \
	$proj_dir/../../verilog/rtl_sram_out_cache/wishbone_mux.v \
	$proj_dir/../../verilog/rtl_sram_out_cache/gpio.v \
	$proj_dir/../../verilog/rtl_sram_out_cache/timer.v \
    $proj_dir/../../verilog/rtl_sram_out_cache/top.v
	"
########################################################################################################
set ::env(RT_MAX_LAYER) {met4}
set ::env(DIODE_INSERTION_STRATEGY) 3
set ::env(FILL_INSERTION) 1
set ::env(TAP_DECAP_INSERTION) 1
set ::env(QUIT_ON_LVS_ERROR) "0"
set ::env(QUIT_ON_MAGIC_DRC) "0"
set ::env(QUIT_ON_NEGATIVE_WNS) "0"
set ::env(QUIT_ON_SLEW_VIOLATIONS) "0"
set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
set ::env(SYNTH_MAX_FANOUT) 20
set ::env(ROUTING_CORES) "58"
set ::env(RUN_CVC) 0
set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 5