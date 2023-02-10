apt install ntpdate -y
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate ntp.sjtu.edu.cn
ntpsrc=$(which ntpdate)
crontab -l 2>/dev/null > /root/crontab_test 
echo -e "*/5 * * * * ${ntpsrc} ntp.sjtu.edu.cn" >> /root/crontab_test 
crontab /root/crontab_test 
rm /root/crontab_test
crontask=$(crontab -l)
