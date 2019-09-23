# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AUDIO_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INPUTCLOCK_FREQUENCY" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MCLK_FACTOR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SAMPLE_RATE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SCLK_FACTOR" -parent ${Page_0}


}

proc update_PARAM_VALUE.AUDIO_DATA_WIDTH { PARAM_VALUE.AUDIO_DATA_WIDTH } {
	# Procedure called to update AUDIO_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AUDIO_DATA_WIDTH { PARAM_VALUE.AUDIO_DATA_WIDTH } {
	# Procedure called to validate AUDIO_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.INPUTCLOCK_FREQUENCY { PARAM_VALUE.INPUTCLOCK_FREQUENCY } {
	# Procedure called to update INPUTCLOCK_FREQUENCY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INPUTCLOCK_FREQUENCY { PARAM_VALUE.INPUTCLOCK_FREQUENCY } {
	# Procedure called to validate INPUTCLOCK_FREQUENCY
	return true
}

proc update_PARAM_VALUE.MCLK_FACTOR { PARAM_VALUE.MCLK_FACTOR } {
	# Procedure called to update MCLK_FACTOR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MCLK_FACTOR { PARAM_VALUE.MCLK_FACTOR } {
	# Procedure called to validate MCLK_FACTOR
	return true
}

proc update_PARAM_VALUE.SAMPLE_RATE { PARAM_VALUE.SAMPLE_RATE } {
	# Procedure called to update SAMPLE_RATE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SAMPLE_RATE { PARAM_VALUE.SAMPLE_RATE } {
	# Procedure called to validate SAMPLE_RATE
	return true
}

proc update_PARAM_VALUE.SCLK_FACTOR { PARAM_VALUE.SCLK_FACTOR } {
	# Procedure called to update SCLK_FACTOR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SCLK_FACTOR { PARAM_VALUE.SCLK_FACTOR } {
	# Procedure called to validate SCLK_FACTOR
	return true
}


proc update_MODELPARAM_VALUE.AUDIO_DATA_WIDTH { MODELPARAM_VALUE.AUDIO_DATA_WIDTH PARAM_VALUE.AUDIO_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AUDIO_DATA_WIDTH}] ${MODELPARAM_VALUE.AUDIO_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.INPUTCLOCK_FREQUENCY { MODELPARAM_VALUE.INPUTCLOCK_FREQUENCY PARAM_VALUE.INPUTCLOCK_FREQUENCY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INPUTCLOCK_FREQUENCY}] ${MODELPARAM_VALUE.INPUTCLOCK_FREQUENCY}
}

proc update_MODELPARAM_VALUE.SAMPLE_RATE { MODELPARAM_VALUE.SAMPLE_RATE PARAM_VALUE.SAMPLE_RATE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SAMPLE_RATE}] ${MODELPARAM_VALUE.SAMPLE_RATE}
}

proc update_MODELPARAM_VALUE.MCLK_FACTOR { MODELPARAM_VALUE.MCLK_FACTOR PARAM_VALUE.MCLK_FACTOR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MCLK_FACTOR}] ${MODELPARAM_VALUE.MCLK_FACTOR}
}

proc update_MODELPARAM_VALUE.SCLK_FACTOR { MODELPARAM_VALUE.SCLK_FACTOR PARAM_VALUE.SCLK_FACTOR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SCLK_FACTOR}] ${MODELPARAM_VALUE.SCLK_FACTOR}
}

