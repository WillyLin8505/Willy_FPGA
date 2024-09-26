connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw C:/Users/sssss/OneDrive/vivado_part/2019.2/seven_seg/zed/export/zed/hw/zed.xsa -mem-ranges [list {0x40000000 0xbfffffff}]
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
source C:/Users/sssss/OneDrive/vivado_part/2019.2/seven_seg/zedboard/_ide/psinit/ps7_init.tcl
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "*A9*#0"}
dow C:/Users/sssss/OneDrive/vivado_part/2019.2/seven_seg/zedboard/Release/zedboard.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "*A9*#0"}
con
