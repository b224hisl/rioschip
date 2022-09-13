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
set ::env(PDK) "sky130B"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"
set ::env(DESIGN_NAME) rvj1_caravel_soc
set script_dir [file dirname [file normalize [info script]]]
set ::env(DESIGN_IS_CORE) "0"
set ::env(FP_PDN_CORE_RING) "0"
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "wb_clk_i"

set ::env(ROUTING_CORES) "20"

set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]
set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]


set ::env(CTS_SINK_CLUSTERING_SIZE) "16"
set ::env(CLOCK_BUFFER_FANOUT) "8"
set ::env(LEC_ENABLE) 0

set ::env(VERILOG_FILES) "\
        $script_dir/../../verilog/rtl_sram_out_cache/caravel_defines.v \
        $script_dir/../../verilog/rtl_sram_out_cache/inc/rvj1_defines.v \
	$script_dir/../../verilog/rtl_sram_out_cache/rvj1_caravel_soc.v \
	$script_dir/../../verilog/rtl_sram_out_cache/instr_ram_mux.v \
	$script_dir/../../verilog/rtl_sram_out_cache/data_ram_mux.v \
	$script_dir/../../verilog/rtl_sram_out_cache/wishbone_mux.v \
	$script_dir/../../verilog/rtl_sram_out_cache/gpio.v \
	$script_dir/../../verilog/rtl_sram_out_cache/timer.v \
	"


set ::env(SDC_FILE) "$script_dir/base.sdc"
set ::env(BASE_SDC_FILE) "$script_dir/base.sdc"

set ::env(LEC_ENABLE) 0

## Floorplan
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 600 1050"
set ::env(CELL_PAD) "4"

set ::env(PL_TARGET_DENSITY) 0.55


set ::env(RT_MAX_LAYER) {met4}
#set ::env(GLB_RT_MAXLAYER) "5"
set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 10
set ::env(DIODE_INSERTION_STRATEGY) 3
set ::env(RUN_CVC) 0


set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
set ::env(QUIT_ON_MAGIC_DRC) "1"
set ::env(QUIT_ON_LVS_ERROR) "1"
set ::env(QUIT_ON_SLEW_VIOLATIONS) "0"


