# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

# Base Configurations. Don't Touch
# section begin
########################################################################################################
set ::env(PDK) "sky130B"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

# YOU ARE NOT ALLOWED TO CHANGE ANY VARIABLES DEFINED IN THE FIXED WRAPPER CFGS 
source $::env(DESIGN_DIR)/fixed_dont_change/fixed_wrapper_cfgs.tcl

# YOU CAN CHANGE ANY VARIABLES DEFINED IN THE DEFAULT WRAPPER CFGS BY OVERRIDING THEM IN THIS CONFIG.TCL
source $::env(DESIGN_DIR)/fixed_dont_change/default_wrapper_cfgs.tcl

set script_dir [file dirname [file normalize [info script]]]
set proj_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_project_wrapper
set verilog_root $proj_dir/../../verilog
set lef_root $proj_dir/../../lef
set gds_root $proj_dir/../../gds

########################################################################################################

# User Configurations
set ::env(DESIGN_IS_CORE) 1

## Clock configurations
set ::env(CLOCK_PORT) "user_clock2 wb_clk_i"
#set ::env(CLOCK_NET) "mprj.clk"
set ::env(CLOCK_PERIOD) "10"
set ::env(SDC_FILE) "$proj_dir/base.sdc"
set ::env(BASE_SDC_FILE) "$proj_dir/base.sdc"

## Internal Macros
### Macro Placement
set ::env(FP_SIZING) "absolute"
set ::env(FP_PDN_CORE_RING) 1
set ::env(MACRO_PLACEMENT_CFG) $proj_dir/macro.cfg

set ::env(SYNTH_USE_PG_PINS_DEFINES) "USE_POWER_PINS"
# set ::env(PDN_CFG) $proj_dir/pdn_cfg.tcl
set ::env(SYNTH_READ_BLACKBOX_LIB) 1
set ::env(SYNTH_DEFINES) [list SYNTHESIS ]
### Macro PDN Connections
set ::env(FP_PDN_ENABLE_MACROS_GRID) "1"
set ::env(FP_PDN_ENABLE_GLOBAL_CONNECTIONS) "1"
set ::env(VDD_NETS) [list {vccd1} {vccd2} {vdda1} {vdda2}]
set ::env(GND_NETS) [list {vssd1} {vssd2} {vssa1} {vssa2}]
set ::env(VDD_PIN)  [list {vccd1}]
set ::env(GND_PIN)  [list {vssd1}]
set ::env(FP_PDN_POWER_STRAPS) "vccd1 vssd1 1, vccd2 vssd2 0, vdda1 vssa1 0, vdda2 vssa2 0"

########################################################################################################
## Source Verilog Files
set ::env(VERILOG_FILES) "\
    $::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
    $proj_dir/../../verilog/rtl_sram_out_cache/user_project_wrapper.v \
	"

### Black-box verilog and views
set ::env(VERILOG_FILES_BLACKBOX) "\
    $proj_dir/../../verilog/rtl_sram_out_cache/bus_arbiter.v \
    $proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/cache/l1dcache.v \
    $proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/cache/l1icache_32.v
    $proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/core_empty/core_empty.v \
    $proj_dir/../../verilog/rtl_sram_out_cache/rvj1_caravel_soc.v \
    $proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/cache/cacheblock/sky130_sram_1kbyte_1rw1r_32x256_8.v \
	"
    
set ::env(EXTRA_LEFS) "\
    $lef_root/bus_arbiter.lef \
    $lef_root/l1dcache.lef \
    $lef_root/l1icache_32.lef \
    $lef_root/rvj1_caravel_soc.lef \
    $lef_root/core_empty.lef \
	$lef_root/sky130_sram_1kbyte_1rw1r_32x256_8.lef \
	"

set ::env(EXTRA_GDS_FILES) "\
    $gds_root/bus_arbiter.gds \
	$gds_root/l1dcache.gds \
    $gds_root/l1icache_32.gds \
    $gds_root/rvj1_caravel_soc.gds \
    $gds_root/core_empty.gds \
    $gds_root/sky130_sram_1kbyte_1rw1r_32x256_8.gds \
	"


########################################################################################################
set ::env(RT_MAX_LAYER) {met5}

 
set ::env(GRT_OBS) "                              \
	                li1   200 2920 679.78 3317.5,\
	                met1  200 2920 679.78 3317.5,\
	                met2  200 2920 679.78 3317.5,\
                        met3  200 2920 679.78 3317.5,\
						met5  200 2920 679.78 3317.5,\            

	                li1   880 2920 1359.78 3317.5,\
	                met1  880 2920 1359.78 3317.5,\
	                met2  880 2920 1359.78 3317.5,\
                        met3  880 2920 1359.78 3317.5,\
						met5  880 2920 1359.78 3317.5,\

					li1   1560 2920 2039.78 3317.5,\
	                met1  1560 2920 2039.78 3317.5,\
	                met2  1560 2920 2039.78 3317.5,\
                        met3  1560 2920 2039.78 3317.5,\
						met5  1560 2920 2039.78 3317.5,\
					
					li1   2240 2920 2719.78 3317.5,\
	                met1  2240 2920 2719.78 3317.5,\
	                met2  2240 2920 2719.78 3317.5,\
                        met3  2240 2920 2719.78 3317.5,\
						met5  2240 2920 2719.78 3317.5,\

					li1   880 200 1359.78 597.5,\
	                met1  880 200 1359.78 597.5,\
	                met2  880 200 1359.78 597.5,\
                        met3  880 200 1359.78 597.5,\
						met5  880 200 1359.78 597.5,\
					
					li1   1560 200 2039.78 597.5,\
	                met1  1560 200 2039.78 597.5,\
	                met2  1560 200 2039.78 597.5,\
                        met3  1560 200 2039.78 597.5,\
						met5  1560 200 2039.78 597.5,\
					
					li1   2240 200 2719.78 597.5,\
	                met1  2240 200 2719.78 597.5,\
	                met2  2240 200 2719.78 597.5,\
                        met3  2240 200 2719.78 597.5,\
						met5  2240 200 2719.78 597.5,\
					
                    li1   200 200 679.78 597.5,\
                    met1  200 200 679.78 597.5,\
                    met2  200 200 679.78 597.5,\
                        met3  200 200 679.78 597.5,\
	                	met5  200 200 679.78 597.5"



set ::env(FP_PDN_MACRO_HOOKS) " \
            dcache_data_ram_1 vccd1 vssd1 vccd1 vssd1, \ 
            icache_data_ram vccd1 vssd1 vccd1 vssd1, \
            iram_inst_A vccd1 vssd1 vccd1 vssd1, \
            iram_inst_B vccd1 vssd1 vccd1 vssd1, \
            icache_tag_ram  vccd1 vssd1 vccd1 vssd1, \
            dcache_data_ram_2 vccd1 vssd1 vccd1 vssd1, \
            dcache_tag_ram vccd1 vssd1 vccd1 vssd1, \
            dram_inst vccd1 vssd1 vccd1 vssd1, \
            core_u vccd1 vssd1 vccd1 vssd1,\
            l1icache_u vccd1 vssd1 vccd1 vssd1, \
            soc_u vccd1 vssd1 vccd1 vssd1,\
            arbiter_u vccd1 vssd1 vccd1 vssd1,\
            l1dcache_u vccd1 vssd1 vccd1 vssd1
    "


# The following is because there are no std cells in the example wrapper project.
# set ::env(FP_PDN_CHECK_NODES) 0
# set ::env(SYNTH_TOP_LEVEL) 0
set ::env(PL_RANDOM_GLB_PLACEMENT) 1
set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 0
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0
set ::env(FP_PDN_ENABLE_RAILS) 1
set ::env(DIODE_INSERTION_STRATEGY) 3
set ::env(FILL_INSERTION) 1
set ::env(TAP_DECAP_INSERTION) 1
set ::env(CLOCK_TREE_SYNTH) 0
set ::env(QUIT_ON_LVS_ERROR) "0"
set ::env(QUIT_ON_MAGIC_DRC) "0"
set ::env(QUIT_ON_NEGATIVE_WNS) "0"
set ::env(QUIT_ON_SLEW_VIOLATIONS) "0"
set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
# set ::env(FP_PDN_IRDROP) "0"
# set ::env(FP_PDN_HORIZONTAL_HALO) "10"
# set ::env(FP_PDN_VERTICAL_HALO) "10"
# set ::env(FP_PDN_VOFFSET) "5"
# set ::env(FP_PDN_VPITCH) "80"
# set ::env(FP_PDN_VSPACING) "15.5"
set ::env(FP_PDN_VWIDTH) "3.1"
# set ::env(FP_PDN_HOFFSET) "10"
# set ::env(FP_PDN_HPITCH) "90"
# set ::env(FP_PDN_HSPACING) "10"
set ::env(FP_PDN_HWIDTH) "3.1"
set ::env(ROUTING_CORES) "52"
set ::env(LVS_CONNECT_BY_LABEL) "1"
set ::env(YOSYS_REWRITE_VERILOG) "1"
set ::env(RUN_KLAYOUT_XOR) "0"
set ::env(KLAYOUT_XOR_GDS) "0"
set ::env(KLAYOUT_XOR_XML) "0"
set ::env(RUN_KLAYOUT) "0"
set ::env(RUN_MAGIC_DRC) 0
set ::env(RUN_KLAYOUT_DRC) 1
set ::env(FP_PDN_VPITCH) 180
set ::env(FP_PDN_HOFFSET) 50
set ::env(FP_PDN_CORE_RING_VOFFSET) 12.45
set ::env(FP_PDN_CORE_RING_HOFFSET) $::env(FP_PDN_CORE_RING_VOFFSET)
#set ::env(FP_PDN_VPITCH) 0
set ::env(FP_PDN_HPITCH) $::env(FP_PDN_VPITCH)