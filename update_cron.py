#!/usr/bin/env python3

import subprocess
import sys
sys.path.insert(0, '/home/connor')
from surf_schedule import get_window

on_h, on_m, off_h, off_m = get_window()

# Every 10 minutes during the active window
capture = (
    f"*/{10} {on_h}-{off_h} * * * /bin/bash /home/connor/surfcam.sh "
    f">> /home/connor/surfcam.log 2>&1"
)

# Run startup.sh at boot
reboot = "@reboot sleep 30 && /bin/bash /home/connor/startup.sh >> /home/connor/startup.log 2>&1"

# Refresh cron monthly
monthly = "0 0 1 * * /usr/bin/python3 /home/connor/update_cron.py >> /home/connor/cron.log 2>&1"

# Modem watchdog every 10 minutes
watchdog = "*/10 * * * * /bin/bash /home/connor/modem_watchdog.sh"

# Modem off at end of window
modem_off = f"{off_m + 1} {off_h} * * * /bin/bash /home/connor/modem_off.sh"

# Modem on at start of window
modem_on = f"{on_m} {on_h} * * * /bin/bash /home/connor/modem_on.sh"

cron = f"{capture}\n{reboot}\n{monthly}\n{watchdog}\n{modem_off}\n{modem_on}\n"

subprocess.run(["crontab", "-"], input=cron, text=True)
print(f"Cron updated: captures {on_h:02d}:{on_m:02d}-{off_h:02d}:{off_m:02d} every 10 min")
