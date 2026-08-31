#!/bin/bash

FAIL_COUNT_FILE="/tmp/modem_fail_count"
MAX_FAILS=1

FAILS=$(cat "$FAIL_COUNT_FILE" 2>/dev/null || echo 0)

if ping -c 1 -W 5 8.8.8.8 > /dev/null 2>&1; then
    echo 0 > "$FAIL_COUNT_FILE"
    exit 0
fi

if [ "$FAILS" -ge "$MAX_FAILS" ]; then
    echo "$(date): Modem offline, max retries reached, skipping reset." >> ~/watchdog.log
    exit 0
fi

echo "$(date): Internet down, resetting modem..." >> ~/watchdog.log
python3 -c "import serial; s=serial.Serial('/dev/ttyUSB2',115200,timeout=2); s.write(b'AT+CFUN=1,1\r\n'); s.close()"
sleep 20

if ping -c 1 -W 5 8.8.8.8 > /dev/null 2>&1; then
    echo "$(date): Modem reset succeeded." >> ~/watchdog.log
    echo 0 > "$FAIL_COUNT_FILE"
else
    echo "$(date): Modem reset failed, still no internet." >> ~/watchdog.log
    echo $((FAILS + 1)) > "$FAIL_COUNT_FILE"
fi
if ping -c 1 -W 5 8.8.8.8 > /dev/null 2>&1; then
    echo "$(date): Modem reset succeeded." >> ~/watchdog.log
    echo 0 > "$FAIL_COUNT_FILE"
else
    echo "$(date): Modem reset failed, still no internet." >> ~/watchdog.log
    echo $((FAILS + 1)) > "$FAIL_COUNT_FILE"
fi
