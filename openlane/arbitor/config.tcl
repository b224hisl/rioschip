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
set ::env(CELL_PAD) "4"
# YOU ARE NOT ALLOWED TO CHANGE ANY VARIABLES DEFINED IN THE FIXED WRAPPER CFGS 

set script_dir [file dirname [file normalize [info script]]]
set proj_dir [file dirname [file normalize [info script]]]
set ::env(DESIGN_NAME) bus_arbiter
set verilog_root $proj_dir/../../verilog/
set lef_root $proj_dir/../../lef/
set gds_root $proj_dir/../../gds/
########################################################################################################
# User Configurations
#
set ::env(DESIGN_IS_CORE) 0
## Clock configurations
set ::env(CLOCK_PORT) "clk"
#set ::env(CLOCK_NET) "mprj.clk"
set ::env(CLOCK_PERIOD) "10"
## Internal Macros
### Macro Placement
set ::env(FP_SIZING) "absolute"
#set ::env(FP_ASPECT_RATIO) 5
set ::env(DIE_AREA) "0 0 600 150"
# set ::env(GLB_RT_ADJUSTMENT) 0.4
set ::env(PL_TARGET_DENSITY) 0.55
# 0.32
set ::env(FP_PDN_CORE_RING) 0
# 0
#set ::env(MACRO_PLACEMENT_CFG) $proj_dir/macro1.cfg
# set ::env(PDN_CFG) $proj_dir/pdn_cfg.tcl
set ::env(SDC_FILE) "$proj_dir/base.sdc"
set ::env(BASE_SDC_FILE) "$proj_dir/base.sdc"
set ::env(VDD_PIN) [list {vccd1}]
set ::env(GND_PIN) [list {vssd1}]

set ::env(RT_MAX_LAYER) "met4"
# 0
set ::env(SYNTH_DEFINES) [list SYNTHESIS ]
########################################################################################################
## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$proj_dir/../../verilog/rtl_sram_out_cache/bus_arbiter.v	\
	$proj_dir/../../verilog/rtl_sram_out_cache/hehe/src/params.vh	\
	"
########################################################################################################
#set ::env(RT_MAX_LAYER) {met5}
### Macro PDN Connections

# set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 0
# set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0
set ::env(ROUTING_CORES) 32
# set ::env(CTS_SINK_CLUSTERING_SIZE) "16"
# set ::env(CLOCK_BUFFER_FANOUT) "8"
set ::env(RUN_CVC) 0
set ::env(USE_ARC_ANTENNA_CHECK) "0"
# set ::env(MAGIC_EXT_USE_GDS) "0"
#set ::env(GRT_ADJUSTMENT) 0.
# set ::env(SYNTH_MAX_FANOUT) 20
# no point in running DRC with magic once openram is in because it will find 3M issues
# try to turn off all DRC checking so the flow completes and use precheck for DRC instead.
# set ::env(MAGIC_DRC_USE_GDS) 0
# set ::env(RUN_MAGIC_DRC) 1
set ::env(QUIT_ON_LVS_ERROR) "1"
set ::env(QUIT_ON_MAGIC_DRC) "1"
set ::env(QUIT_ON_NEGATIVE_WNS) "0"
set ::env(QUIT_ON_SLEW_VIOLATIONS) "0"
set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
# set ::env(LVS_CONNECT_BY_LABEL) 1
# set ::env(YOSYS_REWRITE_VERILOG) 1
# set ::env(DIODE_INSERTION_STRATEGY) 0
########################################################################################################
