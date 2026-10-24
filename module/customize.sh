#!/bin/sh
SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=true
REPLACE=""
sleep 2
ui_print ""
ui_print "Author:"
ui_print "Telegram: @RiProG | Channel: @RiOpSo | Group: @RiOpSoDisc"
ui_print "GitHub: @RiProG-id"
ui_print "Support me on Sociabuzz:"
ui_print "http://sociabuzz.com/RiProG/tribe"
ui_print ""
sleep 2
SUPPORT_PATH=$(ls /sys/class/power_supply/*/constant_charge_current_max /sys/class/power_supply/*/input_current_limit /sys/class/power_supply/*/input_voltage_limit /sys/class/power_supply/*/siop_level /sys/class/power_supply/*/temp_warm /sys/class/power_supply/*/charge_control_limit 2>/dev/null)
if [ -n "$SUPPORT_PATH" ]; then
	ui_print "- Charging sysfs nodes detected."
else
	ui_print "- Warning: Standard power supply nodes not detected."
fi
ui_print ""
sleep 2
