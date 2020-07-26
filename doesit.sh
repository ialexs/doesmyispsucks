#!/usr/bin/env bash
#
# My ISP sucks. Sometimes it suck less longer at random given time. Yours?
#
# Using Speedtest.net CLI
# https://www.speedtest.net/apps/cli
#
# Crontab it. Use `speedtest_log.json`, graph it, mail it to your ISP, publish it, etc, whatever.
#
# > `ialexs`

date=`date +"%F %T"`

speedtest_log='speedtest_log.json'
speedtest_result='speedtest_result'

speedtesting () {
	# Empty previous test result
	cat /dev/null > $speedtest_result

	# List your target server by `speedtest -L`
	# 6612 = FirstMedia, Jakarta
	#speedtest -s 6612 -f json > $speedtest_result
	speedtest -f json > $speedtest_result

	if [ -s "$speedtest_result" ]
	then
	       cat $speedtest_result | tee -a $speedtest_log
	       exit
       else
	       echo $date", connection failed" | tee -a $speedtest_log
	fi
       }

speedtesting
