#!/usr/bin/env python3

from datetime import datetime

def get_window():
    month = datetime.now().month

    if month in (11, 12, 1, 2):
        return (7, 30, 16, 0)   # 7:30 AM - 4:00 PM
    elif month in (3, 4, 10):
        return (7, 0, 17, 30)   # 7:00 AM - 5:30 PM
    else:  # 5, 6, 7, 8, 9
        return (6, 30, 17, 30)  # 6:30 AM - 5:30 PM

if __name__ == "__main__":
    on_h, on_m, off_h, off_m = get_window()
    print(f"Window: {on_h:02d}:{on_m:02d} - {off_h:02d}:{off_m:02d}")
