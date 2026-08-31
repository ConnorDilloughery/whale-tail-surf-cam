# Whale Tail Surf Cam

A remote surf camera at Whale Tail, CA, running on a Raspberry Pi with a cellular modem uplink. Captures a timestamped still every 10 minutes during daylight hours and pushes it to S3, powering down the modem overnight to conserve battery on a power-constrained field install.

## How it works

- **`surfcam.sh`** — captures a still with `rpicam-still`, overlays a location/timestamp watermark with ImageMagick, and uploads it to S3, overwriting the previous frame.
- **`surf_schedule.py`** — defines the active capture window per season (daylight hours shift through the year):
  - Winter (Nov–Feb): 7:30 AM – 4:00 PM
  - Spring/Fall (Mar, Apr, Oct): 7:00 AM – 5:30 PM
  - Summer (May–Sep): 6:30 AM – 5:30 PM
- **`update_cron.py`** — reads the current window from `surf_schedule.py` and regenerates the full crontab (capture cadence, boot handler, modem on/off times, watchdog, and its own monthly re-run on the 1st).
- **`modem_on.sh`** / **`modem_off.sh`** — send AT commands (`AT+CFUN=1` / `AT+CPOF`) over serial (`/dev/ttyUSB2`) to power the cellular modem up at the start of the window and down 1 minute after it ends, since the modem is the biggest power draw on site and doesn't need to be up outside daylight capture hours.
- **`startup.sh`** — run via `@reboot`; waits for connectivity, syncs system time over NTP, pushes that time to the RTC, regenerates the crontab for the current day, and reprograms the RTC's next wake/sleep times (via `set_wittypi.sh`, a thin wrapper around the WittyPi HAT's vendor scripts — not included here since it's third-party).
- **`modem_watchdog.sh`** — runs every 10 minutes; pings out, and if that fails, resets the modem over serial and logs the outcome.

## Deployment notes

- Runs entirely on cron — no daemon/systemd unit, `update_cron.py` self-regenerates the schedule monthly so it stays correct as daylight hours shift through the seasons.
- Modem timing after a cold boot: if the Pi powers on mid-window it starts capturing on the next 10-minute tick; if it boots after that day's shutoff time, the modem won't come back up until the next scheduled `modem_on` run.
- The whole capture pipeline is designed around a power-constrained field deployment — duty-cycling the modem, not just the camera, was the main lever for extending battery life on site.
