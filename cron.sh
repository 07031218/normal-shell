#bin/bash
echo "开始进行解锁"
bash <(curl -L -s https://git.io/JR7RH)
echo "开始添加定时任务"
crontab -l 2>/dev/null > /root/crontab_test 
echo '*/5 * * * * bash <(curl -L -s https://git.io/JR7RH)' >> /root/crontab_test 
crontab /root/crontab_test 
crontask=$(crontab -l)

echo -------------------------------------------------------
echo -e "设置定时任务成功，当前系统所有定时任务清单如下:\n${crontask}"
echo -------------------------------------------------------

exit
