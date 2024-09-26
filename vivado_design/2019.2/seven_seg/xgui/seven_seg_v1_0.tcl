# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "TOTAL_SEQ_NUM" -parent ${Page_0}


}

proc update_PARAM_VALUE.MODE_SEL { PARAM_VALUE.MODE_SEL } {
	# Procedure called to update MODE_SEL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MODE_SEL { PARAM_VALUE.MODE_SEL } {
	# Procedure called to validate MODE_SEL
	return true
}

proc update_PARAM_VALUE.TOTAL_SEQ_NUM { PARAM_VALUE.TOTAL_SEQ_NUM } {
	# Procedure called to update TOTAL_SEQ_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TOTAL_SEQ_NUM { PARAM_VALUE.TOTAL_SEQ_NUM } {
	# Procedure called to validate TOTAL_SEQ_NUM
	return true
}


proc update_MODELPARAM_VALUE.TOTAL_SEQ_NUM { MODELPARAM_VALUE.TOTAL_SEQ_NUM PARAM_VALUE.TOTAL_SEQ_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TOTAL_SEQ_NUM}] ${MODELPARAM_VALUE.TOTAL_SEQ_NUM}
}

proc update_MODELPARAM_VALUE.MODE_SEL { MODELPARAM_VALUE.MODE_SEL PARAM_VALUE.MODE_SEL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MODE_SEL}] ${MODELPARAM_VALUE.MODE_SEL}
}

