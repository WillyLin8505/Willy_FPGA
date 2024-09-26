#
# This file was created by Xilinx Vitis tool.
#


#
# tools
#

RM = rm -f
RMDIR = rm -rf

#
# variables
#

SDCARD_GEN = sdcard_gen
GENERATE_BIF = ::scw::generate_bif

XPFM_PATH = C:/Users/sssss/OneDrive/vivado_part/2019.2/seven_seg/zed/export/zed/zed.xpfm
SYS_CONFIG = zed
DOMAINS = standalone_domain
BIF_PATH = C:/Users/sssss/OneDrive/vivado_part/2019.2/seven_seg/zedboard_system/Debug/system.bif

SD_FILES = --elf C:/Users/sssss/OneDrive/vivado_part/2019.2/seven_seg/zedboard/Debug/zedboard.elf,ps7_cortexa9_0

#
# primary build targets
#

all: sd_card

sd_card:
	-@echo Generating bif file for the system project
	generate_system_bif.bat 53294 ${XPFM_PATH} ${DOMAINS} ${BIF_PATH}
	${SDCARD_GEN} --xpfm ${XPFM_PATH} --sys_config ${SYS_CONFIG} --bif ${BIF_PATH} --no_bitstream ${SD_FILES}

clean:
	$(RMDIR) ./_sds
	${RMDIR} sd_card
	${RM} system.bif

.PHONY: all sd_card clean


