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

# To be fair. We don't test to our own ISP :)
# Server list from `speedtest -L` in speedtest-list-from-XX.txt
server_id=(12807 12909 13039 16919 11118 7582 12936 17288 7162)
server_jp=(14623 20976 28910 15047 24333 32907 33558 34122 24537 8407)
server_my=(1899 3758 5721 1701 11557 20140 10327 11850 8700 9454)
server_sg=(23467 35031 13623 2054 367 4235 5935 7311 7556 26654)

speedtest_log='speedtest_log.json'
speedtest_result='speedtest_result'

speedtesting () {
	# Empty previous test result
	cat /dev/null > $speedtest_result

	# - Manually define target server with `-s` (6612 = FirstMedia, Jakarta, Indonesia. 797=Biznet)
	# speedtest -s 6612 -f json > $speedtest_result
	#
	# - Change to `-f csv` if you want a simple CSV format.
	# - shuffle from server_XX as you like
	speedtest -s $(shuf -e ${server_id[@]} | head -n 1) -f json > $speedtest_result

	if [ -s "$speedtest_result" ]
	then
	       tee -a $speedtest_log < $speedtest_result
	       exit
       else
	       echo "{\"type\":\"failed result\",\"timestamp\":\"$date\"}" | tee -a $speedtest_log
	fi
       }

speedtesting

