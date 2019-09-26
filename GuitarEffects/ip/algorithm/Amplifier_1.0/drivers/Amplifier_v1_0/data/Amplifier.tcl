

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "Amplifier" "NUM_INSTANCES" "DEVICE_ID"  "C_S_SETTING_AXI_BASEADDR" "C_S_SETTING_AXI_HIGHADDR"
}
