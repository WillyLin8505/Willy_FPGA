vlib work
vlib activehdl

vlib activehdl/xilinx_vip
vlib activehdl/xpm
vlib activehdl/xil_defaultlib
vlib activehdl/axi_infrastructure_v1_1_0
vlib activehdl/axi_vip_v1_1_6
vlib activehdl/processing_system7_vip_v1_0_8
vlib activehdl/lib_cdc_v1_0_2
vlib activehdl/proc_sys_reset_v5_0_13

vmap xilinx_vip activehdl/xilinx_vip
vmap xpm activehdl/xpm
vmap xil_defaultlib activehdl/xil_defaultlib
vmap axi_infrastructure_v1_1_0 activehdl/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_6 activehdl/axi_vip_v1_1_6
vmap processing_system7_vip_v1_0_8 activehdl/processing_system7_vip_v1_0_8
vmap lib_cdc_v1_0_2 activehdl/lib_cdc_v1_0_2
vmap proc_sys_reset_v5_0_13 activehdl/proc_sys_reset_v5_0_13

vlog -work xilinx_vip  -sv2k12 "+incdir+D:/xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"D:/xilinx/Vivado/2019.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -sv2k12 "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"D:/xilinx/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/xilinx/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"D:/xilinx/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_ila_0_0/sim/design_1_ila_0_0.v" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_6  -sv2k12 "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/dc12/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_8  -sv2k12 "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/2d50/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_processing_system7_0_0/sim/design_1_processing_system7_0_0.v" \

vcom -work lib_cdc_v1_0_2 -93 \
"../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work proc_sys_reset_v5_0_13 -93 \
"../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/design_1/ip/design_1_proc_sys_reset_0_0/sim/design_1_proc_sys_reset_0_0.vhd" \
"../../../bd/design_1/ipshared/1a51/seven_seg.vhd" \
"../../../bd/design_1/ip/design_1_seven_seg_1_0/sim/design_1_seven_seg_1_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+../../../../seven_seg.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/sim/design_1.v" \

vlog -work xil_defaultlib \
"glbl.v"

