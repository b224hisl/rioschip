set ::env(EXTRA_LEFS) "\
	$script_dir/../../lef/wrapped_function_generator.lef \
	$script_dir/../../lef/wrapped_ibnalhaytham.lef \
	$script_dir/../../lef/wrapped_etpu.lef \
	$script_dir/../../lef/wrapped_silife.lef \
	$script_dir/../../lef/wrapped_snn_network.lef \
	$script_dir/../../lef/wrapped_mbsFSK.lef \
	$script_dir/../../lef/wb_bridge_2way.lef \
	$script_dir/../../lef/wb_openram_wrapper.lef \
	$script_dir/../../lef/sky130_sram_1kbyte_1rw1r_32x256_8.lef "
set ::env(EXTRA_GDS_FILES) "\
	$script_dir/../../gds/wrapped_function_generator.gds \
	$script_dir/../../gds/wrapped_ibnalhaytham.gds \
	$script_dir/../../gds/wrapped_etpu.gds \
	$script_dir/../../gds/wrapped_silife.gds \
	$script_dir/../../gds/wrapped_snn_network.gds \
	$script_dir/../../gds/wrapped_mbsFSK.gds \
	$script_dir/../../gds/wb_bridge_2way.gds \
	$script_dir/../../gds/wb_openram_wrapper.gds \
	$script_dir/../../gds/sky130_sram_1kbyte_1rw1r_32x256_8.gds "
