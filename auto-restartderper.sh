#!/bin/bash
cat > /root/restartderper.sh <<EOF
#!/bin/bash
if [[ \$(systemctl status derper|grep "handshake error") != "" ]]; then
	systemctl restart derper
	echo `date '+%Y-%m-%d %H:%M:%S'` "derper出现错误，重启完成" >> /root/derper.log
else
	echo "derper运行正常，无需重启，脚本退出"
	exit 0
fi
EOF
echo "开始添加定时任务"
bashsrc=$(which bash)
crontab -l 2>/dev/null > /root/crontab_test 
echo -e "*/5 * * * * ${bashsrc} /root/restartderper.sh" >> /root/crontab_test 
crontab /root/crontab_test 
rm /root/crontab_test
crontask=$(crontab -l)

echo -------------------------------------------------------
echo -e "设置定时任务成功，当前系统所有定时任务清单如下:\n${crontask}"
echo -------------------------------------------------------

exit 0
