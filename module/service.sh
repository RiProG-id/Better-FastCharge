#!/system/bin/sh
while [ "$(resetprop sys.boot_completed 2>/dev/null)" != "1" ]; do
	sleep 2
done
BASE=/sys/class/power_supply
TARGET_CURRENT=5750000
TARGET_VOLTAGE=12500000
TARGET_SIOP=100
TARGET_TEMP_LIMIT=500
MAX_TEMP=46
safe_write() {
	[ -f "$1" ] || return 1
	[ -w "$1" ] || chmod 0666 "$1" 2>/dev/null
	IFS= read -r OLD_VALUE <"$1" 2>/dev/null || :
	OLD_VALUE=${OLD_VALUE%"$(printf '\r')"}
	[ "$OLD_VALUE" = "$2" ] || printf '%s\n' "$2" >"$1" 2>/dev/null
	chmod 0664 "$1" 2>/dev/null
}
CURRENT_PATHS=$(ls "$BASE"/*/constant_charge_current_max "$BASE"/*/input_current_limit "$BASE"/*/charge_control_limit "$BASE"/*/current_max 2>/dev/null)
VOLTAGE_PATHS=$(ls "$BASE"/*/input_voltage_limit "$BASE"/*/voltage_max 2>/dev/null)
SIOP_PATHS=$(ls "$BASE"/*/siop_level 2>/dev/null)
TEMP_LIMIT_PATHS=$(ls "$BASE"/*/temp_warm "$BASE"/*/temp_hot 2>/dev/null)
BATTERY_TEMP_PATHS=$(ls "$BASE"/*/temp "$BASE"/battery/temp 2>/dev/null)
CHARGER_STATUS_PATHS=$(ls "$BASE"/usb/online "$BASE"/usb/present "$BASE"/ac/online "$BASE"/ac/present "$BASE"/charger/online "$BASE"/main/online "$BASE"/battery/status 2>/dev/null)
PREVIOUS_CHARGER_STATE=0
while :; do
	sleep 5
	CHARGER_CONNECTED=0
	for NODE in $CHARGER_STATUS_PATHS; do
		[ -f "$NODE" ] || continue
		IFS= read -r VALUE <"$NODE" 2>/dev/null || :
		VALUE=${VALUE%"$(printf '\r')"}
		case "$VALUE" in
		1 | Charging)
			CHARGER_CONNECTED=1
			break
			;;
		esac
	done
	if [ "$CHARGER_CONNECTED" != "$PREVIOUS_CHARGER_STATE" ]; then
		PREVIOUS_CHARGER_STATE=$CHARGER_CONNECTED
		[ "$CHARGER_CONNECTED" = 1 ] || continue
		for NODE in $CURRENT_PATHS; do
			safe_write "$NODE" "$TARGET_CURRENT"
		done
		for NODE in $VOLTAGE_PATHS; do
			safe_write "$NODE" "$TARGET_VOLTAGE"
		done
		for NODE in $SIOP_PATHS; do
			safe_write "$NODE" "$TARGET_SIOP"
		done
		for NODE in $TEMP_LIMIT_PATHS; do
			safe_write "$NODE" "$TARGET_TEMP_LIMIT"
		done
	fi
	[ "$CHARGER_CONNECTED" = 1 ] || continue
	MAX_BATTERY_TEMP=0
	for NODE in $BATTERY_TEMP_PATHS; do
		[ -f "$NODE" ] || continue
		IFS= read -r RAW_TEMP <"$NODE" 2>/dev/null || :
		case "$RAW_TEMP" in
		'' | *[!0-9]*) continue ;;
		esac
		if [ "$RAW_TEMP" -gt 10000 ]; then
			BATTERY_TEMP=$((RAW_TEMP / 1000))
		elif [ "$RAW_TEMP" -gt 1000 ]; then
			BATTERY_TEMP=$((RAW_TEMP / 100))
		elif [ "$RAW_TEMP" -gt 100 ]; then
			BATTERY_TEMP=$((RAW_TEMP / 10))
		else
			BATTERY_TEMP=$RAW_TEMP
		fi
		[ "$BATTERY_TEMP" -le "$MAX_BATTERY_TEMP" ] || MAX_BATTERY_TEMP=$BATTERY_TEMP
	done
	if [ "$MAX_BATTERY_TEMP" -ge "$MAX_TEMP" ]; then
		reboot -p
	fi
done
