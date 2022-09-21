###############################################################################
# Created by write_sdc
# Wed Nov 10 17:01:46 2021
###############################################################################
current_design user_project_wrapper
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name user_clock2 -period 12.5000 [get_ports {user_clock2}]
set_propagated_clock [get_clocks {user_clock2}]
create_clock -name wb_clk_i -period 12.5000 [get_ports {wb_clk_i}]
set_propagated_clock [get_clocks {wb_clk_i}]

###############################################################################
# Design Rules
###############################################################################
