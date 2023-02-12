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
	localip=$(ip a |grep brd|grep global|awk '{print $2}'|awk -F "/" '{print $1}')
	echo "${remoteip}" >/root/.tunnel-ip.txt
	ip tunnel add $tunname mode ipip remote ${remoteip} local $localip ttl 64 # 创建IP隧道
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
# 	cat > /etc/init.d/$tunname <<-EOF
# #! /bin/bash
# ip tunnel add $tunname mode ipip remote ${remoteip} local ${localip} ttl 64
# ip addr add ${vip}/30 dev $tunname
# ip link set $tunname up
# EOF
# 	chmod +x /etc/init.d/$tunname
#     cd /etc/init.d
#     if [ `awk -F'[= ."]' '/VERSION_ID/{print $3}' /etc/os-release` == "18" ]
#     then
#         update-rc.d $tunname defaults 90
#     else
#         update-rc.d $tunname defaults
#     fi
cat > /etc/rc.local <<EOF
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
 
# bash /root/bindip.sh
ip tunnel add $tunname mode ipip remote ${remoteip} local ${localip} ttl 64
ip addr add ${vip}/30 dev $tunname
ip link set $tunname up
exit 0
EOF

chmod +x /etc/rc.local
cat > /etc/systemd/system/rc-local.service <<EOF
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
 
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
 
[Install]
WantedBy=multi-user.target
EOF
systemctl enable rc-local
	cat >/root/change-tunnel-ip_${ddnsname}.sh <<EOF
#!/bin/bash
if [[ \`dig ${ddnsname} @8.8.8.8| grep 'ANSWER SECTION'\` == "" ]]; then
	remoteip="${ddnsname}"
else
	remoteip=\$(dig ${ddnsname} @8.8.8.8 | awk -F "[ ]+" '/IN/{print \$1}' | awk 'NR==2 {print \$5}')
fi
oldip="\$(cat /root/.tunnel-ip.txt)"
localip=$(ip a |grep brd|grep global|awk '{print $2}'|awk -F "/" '{print $1}')
if [[ \$oldip != \$remoteip ]]; then
	ip tunnel del $tunname >/dev/null &
	ip tunnel add $tunname mode ipip remote \${remoteip} local \${localip} ttl 64
	ip addr add ${vip}/30 dev $tunname
	ip link set $tunname up
	sed -i "s/ip tunnel add $tunname mode ipip remote \${oldip} local ${localip} ttl 64/ip tunnel add $tunname mode ipip remote \${remoteip} local ${localip} ttl 64/g" /etc/rc.local
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
install_wg(){
	apt-get update 
	apt-get install wireguard -y
	if [[ ! -f /etc/wireguard/privatekey ]]; then
		wg genkey | tee /etc/wireguard/privatekey | wg pubkey | tee /etc/wireguard/publickey
	fi
	localprivatekey=$(cat /etc/wireguard/privatekey)
	netcardname=$(ls /sys/class/net | awk '/^e/{print}')
	read -p "请输入对端wg使用的V-ip地址:" revip
	read -p "请输入本机wg使用的v-ip地址:" localip1
	read -p "请输入ros端wg的公钥内容:" rospublickey
	read -p "请输入ros端wg调用的端口号:" wgport
	allowedip1=$(echo $revip|awk -F "." '{print  $1"."$2"."$3}')
	if [[ -f /etc/wireguard/wg0.conf ]]; then
		read -p "请给本机wg配置文件取个名(英文):" filename
		if [[ -f /etc/wireguard/${filename}.conf ]]; then
			echo "⚠️  已存在同样名称的配置文件，程序退出，请重新执行程序。"
			exit 1
		fi
	read -p "请输入对端ipip隧道IP段(例如 192.168.2.1 只填写 192.168.2 即可)：" ipduan
	echo "[Interface]
ListenPort = $wgport
Address = $localip1/24
PostUp   = iptables -t nat -A POSTROUTING -o $netcardname -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -o $netcardname -j MASQUERADE
PrivateKey = $localprivatekey
	
[Peer]
PublicKey = $rospublickey
AllowedIPs = $ipduan.0/24,$allowedip1.0/24
Endpoint = ${revip}:$wgport
PersistentKeepalive = 25" > /etc/wireguard/$filename.conf
	sed -i "/exit 0/i\wg-quick up $filename" /etc/rc.local
	wg-quick up $filename
	vpspublickey=$(cat /etc/wireguard/publickey)
	# vip=$(ip a|grep "scope global"|grep "/30"|awk '{print $2}'|awk -F "/" '{print $1}')
	linstenport=$(cat /etc/wireguard/$filename.conf|grep "ListenPort"|awk '{print $3}')
	echo "    "
	echo -e "${green}------------------------------------------------------------${plain}"
	echo -e  "${green}请在ros的wireguard选项卡里边的Peers里添加配置，具体填写如下信息：${plain}\nPublic key 填写：${yellow}${vpspublickey}${plain}\nEndpoint port 填写：${yellow}${linstenport}${plain}\nAllowed Address填写：${green}0.0.0.0/0\n祝使用愉快。${plain}"
	else
		read -p "请输入对端ipip隧道IP段(例如 192.168.2.1 只填写 192.168.2 即可)：" ipduan
		echo "[Interface]
ListenPort = $wgport
Address = $localip1/24
PostUp   = iptables -t nat -A POSTROUTING -o $netcardname -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -o $netcardname -j MASQUERADE
PrivateKey = $localprivatekey

[Peer]
PublicKey = $rospublickey
AllowedIPs = $ipduan.0/24,$allowedip1.0/24
Endpoint = ${revip}:$wgport
PersistentKeepalive = 25" > /etc/wireguard/wg0.conf
	sed -i '/exit 0/i\wg-quick up wg0' /etc/rc.local
    chmod 600 /etc/wireguard/wg0.conf
	wg-quick up wg0
	vpspublickey=$(cat /etc/wireguard/publickey)
	vip=$(ip a|grep "scope global"|grep "/30"|awk '{print $2}'|awk -F "/" '{print $1}')
	linstenport=$(cat /etc/wireguard/wg0.conf|grep "ListenPort"|awk '{print $3}')
	echo "    "
	echo -e "${green}------------------------------------------------------------${plain}"
	echo -e  "${green}请在ros的wireguard选项卡里边的Peers里添加配置，具体填写如下信息：${plain}\nPublic key 填写：${yellow}${vpspublickey}${plain}\nEndpoint 填写：${yellow}${vip}${plain}\nEndpoint port 填写：${yellow}${linstenport}${plain}\nAllowed Address填写：${green}0.0.0.0/0\n祝使用愉快。${plain}"
	fi

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
${green}2.${plain}  一键部署wireguard
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
            install_wg
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
