#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

LOG=/home/connor/startup.log
echo "=== Startup $(date) ===" >> $LOG

# Wait for internet connectivity
echo "Waiting for internet..." >> $LOG
for i in {1..12}; do
    if ping -c 1 -W 5 8.8.8.8 > /dev/null 2>&1; then
        echo "Internet up after ${i}0s" >> $LOG
        break
    fi
    sleep 10
done

# Sync time via NTP
echo "Syncing time..." >> $LOG
sudo ntpdate -u time.google.com >> $LOG 2>&1

# Sync system time to RTC
bash -c "source /home/connor/wittypi/utilities.sh && system_to_rtc" >> $LOG 2>&1
echo "RTC synced." >> $LOG

# Update cron
python3 /home/connor/update_cron.py >> $LOG 2>&1

# Calculate today's shutdown and tomorrow's startup
TODAY_DAY=$(date +%-d)
TOMORROW_DAY=$(date -d tomorrow +%-d)

ON_H=$(python3 -c "from surf_schedule import get_window; w=get_window(); print(w[0])" 2>/dev/null)
ON_M=$(python3 -c "from surf_schedule import get_window; w=get_window(); print(w[1])" 2>/dev/null)
OFF_H=$(python3 -c "from surf_schedule import get_window; w=get_window(); print(w[2])" 2>/dev/null)
OFF_M=$(python3 -c "from surf_schedule import get_window; w=get_window(); print(w[3])" 2>/dev/null)

echo "Window: ${ON_H}:${ON_M} - ${OFF_H}:${OFF_M}" >> $LOG

# Program Witty Pi
bash /home/connor/set_wittypi.sh $TOMORROW_DAY $ON_H $ON_M $TODAY_DAY $OFF_H $OFF_M >> $LOG 2>&1

echo "Witty Pi programmed." >> $LOG
