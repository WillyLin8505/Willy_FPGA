vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xilinx_vip
vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/axi_infrastructure_v1_1_0
vlib modelsim_lib/msim/axi_vip_v1_1_6
vlib modelsim_lib/msim/processing_system7_vip_v1_0_8
vlib modelsim_lib/msim/lib_cdc_v1_0_2
vlib modelsim_lib/msim/proc_sys_reset_v5_0_13

vmap xilinx_vip modelsim_lib/msim/xilinx_vip
vmap xpm modelsim_lib/msim/xpm
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap axi_infrastructure_v1_1_0 modelsim_lib/msim/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_6 modelsim_lib/msim/axi_vip_v1_1_6
vmap processing_system7_vip_v1_0_8 modelsim_lib/msim/processing_system7_vip_v1_0_8
vmap lib_cdc_v1_0_2 modelsim_lib/msim/lib_cdc_v1_0_2
vmap proc_sys_reset_v5_0_13 modelsim_lib/msim/proc_sys_reset_v5_0_13

vlog -work xilinx_vip -64 -incr -sv -L axi_vip_v1_1_6 -L processing_system7_vip_v1_0_8 -L xilinx_vip "+incdir+D:/xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm -64 -incr -sv -L axi_vip_v1_1_6 -L processing_system7_vip_v1_0_8 -L xilinx_vip "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"D:/xilinx/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/xilinx/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"D:/xilinx/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_ila_0_0/sim/design_1_ila_0_0.v" \

vlog -work axi_infrastructure_v1_1_0 -64 -incr "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_6 -64 -incr -sv -L axi_vip_v1_1_6 -L processing_system7_vip_v1_0_8 -L xilinx_vip "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/dc12/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_8 -64 -incr -sv -L axi_vip_v1_1_6 -L processing_system7_vip_v1_0_8 -L xilinx_vip "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/2d50/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_processing_system7_0_0/sim/design_1_processing_system7_0_0.v" \

vcom -work lib_cdc_v1_0_2 -64 -93 \
"../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work proc_sys_reset_v5_0_13 -64 -93 \
"../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/design_1/ip/design_1_proc_sys_reset_0_0/sim/design_1_proc_sys_reset_0_0.vhd" \
"../../../bd/design_1/ipshared/1a51/seven_seg.vhd" \
"../../../bd/design_1/ip/design_1_seven_seg_1_0/sim/design_1_seven_seg_1_0.vhd" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/sim/design_1.v" \

vlog -work xil_defaultlib \
"glbl.v"

