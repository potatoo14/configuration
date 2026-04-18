#!/usr/bin/env python
# the other script is showing time wrong for some reason
# and python is way easier to understand than awk
# also using 0 imports because why not ¯\_(ツ)_/¯

with open("/proc/uptime", "r") as f:
    uptime_seconds = float(f.readline().split()[0])

uptime_seconds = int(uptime_seconds)

hours = uptime_seconds // 3600
minutes = (uptime_seconds % 3600) // 60
# seconds = uptime_seconds % 60
print(f"{hours:02d}h{minutes:02d}m")
