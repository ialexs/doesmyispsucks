#!/usr/bin/env bash
#
# https://github.com/ialexs/doesmyispsucks
#
# Reformat `speedtest_log.json` to
# `speedtest_log.csv`, `speedtest_log_short.csv` `speedtest_log_short_fixed.csv`
# (for easy reporting to ISP)
#
# Requirements in the README

speedtest_log='speedtest_log.json'

parselog () {
# Parse json as csv header
jq -rf parse_header.jq $speedtest_log | head -n 1 > speedtest_log.csv

# Parse json as csv content
jq -rf parse_csv.jq $speedtest_log >> speedtest_log.csv
echo -e "\nParsing $speedtest_log to speedtest_log.csv ...done"

# Get important fields for easy reporting
cut -d, -f1,2,4,12,5,8,11,12,19,22,26 speedtest_log.csv > speedtest_log_short.csv
echo -e "Creating speedtest_log_short.csv ...done"
}

# Fixing timestamp, download.bandwidth, upload.bandwidth. Using Pandas

fix_csv_py="
#!/usr/bin/env python

import pandas as pd

# Import csv log
df = pd.read_csv('speedtest_log_short.csv', parse_dates=['timestamp'])

# Fix timestamp
df['timestamp'] = df['timestamp'].dt.tz_convert('Asia/Jakarta')

# Fix download/upload bandwidth. Bps to Mbps
df['download.bandwidth'] = df['download.bandwidth'].div(125000)
df['upload.bandwidth'] = df['upload.bandwidth'].div(125000)

# Spit the output back to a new csv
df.to_csv('speedtest_log_short_fixed.csv', index=False)

print('\nConvert timezone, convert Bps to Mbps ...done\nCreating speedtest_log_short_fixed.csv ...done')
"

recentlog ()
{
# Utilize csvlook (from csvkit) and `header`
echo -e "\n# Last five entries:\n"
cat speedtest_log_short_fixed.csv \
	| cut -d, -f 2,3,4,5,10 \
	| tail -n 5 \
	| header -a "Date,Ping (ms),DL (Mbps),UL (Mbps),Speedtest URL Result" \
	| csvlook

echo -e "\n# Last 12hrs - 15 mins interval download bandwidth (Mbps)\n"
< speedtest_log_short_fixed.csv cut -d, -f2,4 | tail -n 48 | jp -input csv -width 100 -height 10 -canvas braille
}

# miaw..

figlet -f small "Does My ISP Sucks?" | lolcat
parselog
python -c "$fix_csv_py"
recentlog
echo ""

# NOTES:
#
# From `speedtest -help`:
# Machine readable formats (csv, tsv, json, jsonl, json-pretty)
# use bytes as the unit of measure with max precision
#
# Divide `*.bandwidth` by 125.000 to convert it to Mbps
# - https://en.wikipedia.org/wiki/Data-rate_units#Megabit_per_second
#
# Time in Zulu time (GMT+0)
# - https://en.wikipedia.org/wiki/Coordinated_Universal_Time
#
# Fields number for reference, chop as you like:
#
#     1	"type"
#     2	"timestamp"
#     3	"ping.jitter"
#     4	"ping.latency"
#     5	"download.bandwidth"
#     6	"download.bytes"
#     7	"download.elapsed"
#     8	"upload.bandwidth"
#     9	"upload.bytes"
#    10	"upload.elapsed"
#    11	"packetLoss"
#    12	"isp"
#    13	"interface.internalIp"
#    14	"interface.name"
#    15	"interface.macAddr"
#    16	"interface.isVpn"
#    17	"interface.externalIp"
#    18	"server.id"
#    19	"server.name"
#    20	"server.location"
#    21	"server.country"
#    22	"server.host"
#    23	"server.port"
#    24	"server.ip"
#    25	"result.id"
#    26	"result.url"
