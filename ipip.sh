#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
White='\033[37m'
blue='\033[36m'
yellow='\033[0;33m'
plain='\033[0m'
echoType='echo -e'
DATE=`date +%Y%m%d`
install_ipip(){
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
	read -p "请输入要创建的tun网卡名称：" tunname
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
	ip tunnel add $tunname mode ipip remote ${remoteip} local $(ip a 2>&1 | grep -w 'inet' | grep 'global' | grep -E '\ 1(92|0|72|00|1)\.' | sed 's/.*inet.//g' | sed 's/\/[0-9][0-9].*$//g' | head -n 1) ttl 64 # 创建IP隧道
	ip addr add ${vip}/30 dev $tunname # 添加本机VIP
	ip link set $tunname up # 启用隧道虚拟网卡
	ip route add ${remotevip}/32 dev $tunname scope link src ${vip}
	if [[ `iptables -t nat -L|grep "${remotevip}"` == "" ]]; then
		iptables -t nat -A POSTROUTING -s ${remotevip} -j MASQUERADE
	fi
	if [[ `sysctl -p|grep "net.ipv4.ip_forward = 1"` == "" ]]; then
		echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
		sysctl -p /etc/sysctl.conf
	fi
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
	ip tunnel del $tunname >/dev/null &
	ip tunnel add $tunname mode ipip remote \${remoteip} local \$(ip a 2>&1 | grep -w 'inet' | grep 'global' | grep -E '\ 1(92|0|72|00|1)\.' | sed 's/.*inet.//g' | sed 's/\/[0-9][0-9].*$//g' | head -n 1) ttl 64
	ip addr add ${vip}/30 dev $tunname
	ip link set $tunname up
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
}
copyright(){
    clear
    echo -e "
${green}###########################################################${plain}
${green}#                                                         #${plain}
${green}#       IPIP tunnel隧道、Wireguard一键部署脚本            #${plain}
${green}#               Power By:翔翎                             #${plain}
${green}#                                                         #${plain}
${green}###########################################################${plain}"
}

main(){
copyright
echo -e "
${red}0.${plain}  退出脚本
${green}———————————————————————————————————————————————————————————${plain}
${green}1.${plain}  一键部署IPIP隧道
${green}2.${plain}  一键部署wierguard
"
    echo -e "${yellow}请选择你要使用的功能${plain}"
    read -p "请输入数字 :" num   
    case "$num" in
        0)
            exit 0
            ;;
        1)
            install_ipip
            ;;
        2)
            bash <(curl -sL https://raw.githubusercontent.com/07031218/normal-shell/main/wireguard.sh)
            ;;
        *)
    clear
    echo -e "${red}出现错误:请输入正确数字 ${plain}"
    sleep 2s
    copyright
    main
    ;;
  esac
}
main
