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
set ::env(SYNTH_USE_PG_PINS_DEFINES) "USE_POWER_PINS"
set script_dir [file dirname [file normalize [info script]]]
set proj_dir [file dirname [file normalize [info script]]]
set ::env(DESIGN_NAME) core_empty
set verilog_root $proj_dir/../../verilog/
########################################################################################################
# User Configurations
#
set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0
set ::env(RT_MAX_LAYER) "met4"
## Clock configurations
set ::env(CLOCK_PORT) "clk"
#set ::env(CLOCK_NET) "mprj.clk"
set ::env(CLOCK_PERIOD) "10"
## Internal Macros
### Macro Placement
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 1600 1600"
set ::env(PL_TARGET_DENSITY) 0.32
# 1
#set ::env(MACRO_PLACEMENT_CFG) $proj_dir/macro1.cfg
# set ::env(PDN_CFG) $proj_dir/pdn_cfg.tcl

set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]
set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]
########################################################################################################
## Source Verilog Files
set ::env(VERILOG_FILES) "\
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
	"

#
set ::env(ROUTING_CORES) 54
set ::env(RUN_CVC) 0
set ::env(USE_ARC_ANTENNA_CHECK) "0"
set ::env(MAGIC_EXT_USE_GDS) "0"
#set ::env(GRT_ADJUSTMENT) 0.
set ::env(SYNTH_MAX_FANOUT) 20
# 0
set ::env(RUN_MAGIC_DRC) 1
set ::env(QUIT_ON_LVS_ERROR) "0"
set ::env(QUIT_ON_MAGIC_DRC) "0"
set ::env(QUIT_ON_NEGATIVE_WNS) "0"
set ::env(QUIT_ON_SLEW_VIOLATIONS) "0"
set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
########################################################################################################


set ::env(RUN_KLAYOUT_XOR) "0"