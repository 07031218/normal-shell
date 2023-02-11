#!/bin/bash
if [[ `lsmod|grep ipip` == "" ]]; then
	modprobe ipip
fi
if [[ `which dig` == "" ]]; then
	apt-get install dnsutils  -y>/dev/null ||yum  install dnsutils  -y >/dev/null 
fi
if [[ `which iptables` == "" ]]; then
	apt install iptables -y>/dev/null ||yum install iptables -y>/dev/null 
fi
echo -ne "请输入对段设备的ddns域名或者IP："
read ddnsname
echo -ne "请输入tun网口的V-IP："
read vip
echo -ne "请输入对端的V-IP："
read remotevip
if [[ `dig ${ddnsname} @8.8.8.8| grep 'ANSWER SECTION'` == "" ]]; then
	remoteip=${ddnsname}
else
	remoteip=$(dig ${ddnsname} @8.8.8.8 | awk -F "[ ]+" '/IN/{print $1}' | awk 'NR==2 {print $5}')
fi
echo "${remoteip}" >/root/.tunnel-ip.txt
ip tunnel add tun0 mode ipip remote ${remoteip} local $(ip a 2>&1 | grep -w 'inet' | grep 'global' | grep -E '\ 1(92|0|72|00|1)\.' | sed 's/.*inet.//g' | sed 's/\/[0-9][0-9].*$//g' | head -n 1) ttl 64 # 创建IP隧道
ip addr add ${vip}/30 dev tun0 # 添加本机VIP
ip link set tun0 up # 启用隧道虚拟网卡
ip route add ${remotevip}/32 dev tun0 scope link src ${vip}
if [[ `iptables -t nat -L|grep "${remotevip}"` == "" ]]; then
	iptables -t nat -A POSTROUTING -s ${remotevip} -j MASQUERADE
fi
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
cat >/root/change-tunnel-ip_${ddnsname}.sh <<EOF
#!/bin/bash
if [[ \`dig ${ddnsname} @8.8.8.8| grep 'ANSWER SECTION'\` == "" ]]; then
	remoteip="${ddnsname}"
else
	remoteip=\$(dig ${ddnsname} @8.8.8.8 | awk -F "[ ]+" '/IN/{print \$1}' | awk 'NR==2 {print \$5}')
fi
oldip="\$(cat /root/.tunnel-ip.txt)"
routelist=\$(ip route list|sed "\$d")
if [[ \$oldip != \$remoteip ]]; then
	ip tunnel del tun0 >/dev/null &
	ip tunnel add tun0 mode ipip remote \${remoteip} local \$(ip a 2>&1 | grep -w 'inet' | grep 'global' | grep -E '\ 1(92|0|72|00|1)\.' | sed 's/.*inet.//g' | sed 's/\/[0-9][0-9].*$//g' | head -n 1) ttl 64
	ip addr add ${vip}/30 dev tun0
	ip link set tun0 up
	ip route add \${remotevip}/32 dev tun0 scope link src ${vip}
fi
EOF
echo "开始添加定时任务"
bashsrc=$(which bash)
crontab -l 2>/dev/null > /root/crontab_test 
echo -e "*/2 * * * * ${bashsrc} /root/change-tunnel-ip_${ddnsname}.sh" >> /root/crontab_test 
crontab /root/crontab_test 
rm /root/crontab_test
crontask=$(crontab -l)

echo -------------------------------------------------------
echo -e "设置定时任务成功，当前系统所有定时任务清单如下:\n${crontask}"
echo -------------------------------------------------------
echo "程序全部执行完毕，脚本退出。。"
exit 0
