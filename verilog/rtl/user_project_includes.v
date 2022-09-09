// +------------+--------------------+-----------------+--------------------------------------------------------+------------------------------------------+
// | project id | title              | author          | repo                                                   | commit                                   |
// +------------+--------------------+-----------------+--------------------------------------------------------+------------------------------------------+
// | 0          | Function generator | Matt Venn       | https://github.com/mattvenn/wrapped_function_generator | 701095fd880ad3bb80d6cec1d214a04e5676a65d |
// | 1          | ibnalhaytham       | Farhad Modaresi | https://github.com/sfmth/wrapped_ibnalhaytham          | 0627452464db56b813a3aae8899e8339a358fac9 |
// | 3          | Educational tpu    | Camilo Soto     | https://github.com/tucanae47/wrapped_etpu              | d25b41070e74c47a00c1f264af068523c52c584a |
// | 2          | SiLife             | Uri Shaked      | https://github.com/wokwi/wrapped_silife                | aec0f0f7ad458675d961a8289d16064bf15964f6 |
// | 4          | snn-asic           | Peng Zhou       | https://github.com/pengzhouzp/wrapped_snn_network      | d0f3a80e664bf6327274c5fef0ace2af40db311b |
// | 5          | wrapped mbs fsk    | James Rosenthal | https://github.com/jdrosent/wrapped_mbsFSK             | ac3713d3220f225a6de8481bd3b72e245614e064 |
// +------------+--------------------+-----------------+--------------------------------------------------------+------------------------------------------+
`include "wrapped_function_generator/wrapper.v" // 0
`include "wrapped_ibnalhaytham/wrapper.v" // 1
`include "wrapped_etpu/wrapper.v" // 3
`include "wrapped_silife/wrapper.v" // 2
`include "wrapped_snn_network/wrapper.v" // 4
`include "wrapped_mbsFSK/wrapper.v" // 5
// shared projects
`include "wb_bridge/src/wb_bridge_2way.v"
`include "wb_openram_wrapper/src/register_rw.v"
`include "wb_openram_wrapper/src/wb_port_control.v"
`include "wb_openram_wrapper/src/wb_openram_wrapper.v"
`include "openram_z2a/src/sky130_sram_1kbyte_1rw1r_32x256_8.v"