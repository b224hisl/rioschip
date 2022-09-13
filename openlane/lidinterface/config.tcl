set ::env(PDK) "sky130B"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"
# Design
set ::env(DESIGN_NAME) "l1dcache"
set ::env(FP_PDN_CORE_RING) "0"
# Timing configuration
set ::env(CLOCK_PERIOD) "10"
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 700 450"
set ::env(SYNTH_MAX_FANOUT) 18
set ::env(CLOCK_PORT) "clk"
set ::env(PL_TIME_DRIVEN) 1
#set ::env(FP_CORE_UTIL) {}
set ::env(PL_TARGET_DENSITY) 0.3
set ::env(CELL_PAD) 3
set ::env(GLB_RT_ALLOW_CONGESTION) 0
set ::env(ROUTING_CORES) 32
set ::env(SYNTH_USE_PG_PINS_DEFINES) "USE_POWER_PINS"
## CTS BUFFER
set ::env(DESIGN_IS_CORE) 0
set ::env(CTS_SINK_CLUSTERING_SIZE) "16"
set ::env(CLOCK_BUFFER_FANOUT) "8"
set ::env(LEC_ENABLE) 0
set ::env(FP_PDN_ENABLE_MACROS_GRID) "1"
set ::env(FP_PDN_ENABLE_GLOBAL_CONNECTIONS) "1"

set proj_dir [file dirname [file normalize [info script]]]
set verilog_root $proj_dir/../../verilog/
set ::env(VERILOG_FILES) "\ 
    $proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/cache/cacheblock/std_dffe.v \
    $proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/cache/cacheblock/std_dffr.v \
    $proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/cache/l1dcache.v
	"
set ::env(SDC_FILE) $proj_dir/base.sdc
set ::env(BASE_SDC_FILE) $proj_dir/base.sdc
set ::env(LEC_ENABLE) 0
set ::env(RUN_CVC) 0
set ::env(USE_ARC_ANTENNA_CHECK) "0"
set ::env(RT_MAX_LAYER) {met4}
set ::env(DIODE_INSERTION_STRATEGY) 3
set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
set ::env(QUIT_ON_MAGIC_DRC) "1"
set ::env(QUIT_ON_LVS_ERROR) "1"
set ::env(QUIT_ON_SLEW_VIOLATIONS) "0"
set ::env(VDD_PIN)  [list {vccd1}]
set ::env(GND_PIN)  [list {vssd1}]
set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]