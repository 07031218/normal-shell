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
ip tunnel add tun0 mode ipip remote ${remoteip} ttl 255 # 创建IP隧道
ip addr add ${vip}/30 dev tun0 # 添加本机VIP
ip link set tun0 up # 启用隧道虚拟网卡
ip route add ${remotevip}/30 dev tun0 scope link src ${vip}  # 添加对端VIP走隧道的路由表
i=0
read -p "请输入要添加的路由表总数量(需要对接几个vps就填写几)：" times
while [[ $i -lt $times ]]; do
	let i++
	read -p "请添加第${i}个vps的IP地址：" vpsip
	ip route add ${vpsip} dev tun0 scope link src ${vip} # 
done
read -p "本机是否跳板机(跳板机需要开启NAT转发)[Y/n]:" yn
if [[ $yn == "Y" ]]||[[ $yn == "y" ]]; then
	iptables -t nat -A POSTROUTING -s $remotevip -j MASQUERADE
fi
echo "IPIP隧道和相关路由表已经配置完毕，开始添加自动修改对端IP定时任务脚本。"

if [[ $yn != "Y" ]] && [[ $yn != "y" ]]; then
	cat >/root/change-tunnel-ip.sh <<EOF
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
	ip tunnel add tun0 mode ipip remote \${remoteip} ttl 255
	ip addr add ${vip}/30 dev tun0
	ip link set tun0 up
	ip route add \${remotevip}/30 dev tun0 scope link src ${vip}
	\$routelist
fi
EOF
	echo "开始添加定时任务"
	bashsrc=$(which bash)
	crontab -l 2>/dev/null > /root/crontab_test 
	echo -e "*/2 * * * * ${bashsrc} /root/change-tunnel-ip.sh" >> /root/crontab_test 
	crontab /root/crontab_test 
	rm /root/crontab_test
	crontask=$(crontab -l)

	echo -------------------------------------------------------
	echo -e "设置定时任务成功，当前系统所有定时任务清单如下:\n${crontask}"
	echo -------------------------------------------------------
	echo "程序全部执行完毕，脚本退出。。"
	exit 0
fi
