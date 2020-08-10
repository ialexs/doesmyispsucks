#!/usr/bin/env bash
#
# My ISP sucks. Sometimes it suck less longer at random given time. Yours?
#
# Using Speedtest.net CLI
# https://www.speedtest.net/apps/cli
#
# Crontab it.
#
# Use `speedtest_log.json`, graph it, mail it to your ISP, publish it, etc, whatever.
#
# > `ialexs`

# If error, we log as the same format as `speedtest`
# (using Zulu time format)
date=$(date --utc +%FT%TZ)

speedtest_log='speedtest_log.json'
speedtest_result='speedtest_result'

speedtesting () {
	# Empty previous test result
	cat /dev/null > $speedtest_result

	# - Manually define target server with `-s` (6612 = FirstMedia, Jakarta, Indonesia)
	# - Change to `-f csv` if you want a simple CSV format.
	#
	# speedtest -s 6612 -f json > $speedtest_result
	speedtest -f json > $speedtest_result

	if [ -s "$speedtest_result" ]
	then
	       tee -a $speedtest_log < $speedtest_result
	       exit
       else
	       echo "{\"type\":\"failed result\",\"timestamp\":\"$date\"}" | tee -a $speedtest_log
	fi
       }

speedtesting
