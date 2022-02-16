#!/bin/bash
end="\033[0m"
black="\033[0;30m"
blackb="\033[1;30m"
white="\033[0;37m"
whiteb="\033[1;37m"
red="\033[0;31m"
redb="\033[1;31m"
green="\033[0;32m"
greenb="\033[1;32m"
yellow="\033[0;33m"
yellowb="\033[1;33m"
blue="\033[0;34m"
blueb="\033[1;34m"
purple="\033[0;35m"
purpleb="\033[1;35m"
lightblue="\033[0;36m"
lightblueb="\033[1;36m"
# check root
[[ $EUID -ne 0 ]] && echo -e "${red}错误:  必须使用root用户运行此脚本!\n${end}" && exit 1
# check os
if [ -f /etc/redhat-release ]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
else
    release=""
fi

# os version
if [[ -f /etc/os-release ]]; then
    os_version=$(awk -F'[= ."]' '/VERSION_ID/{print $3}' /etc/os-release)
fi
if [[ -z "$os_version" && -f /etc/lsb-release ]]; then
    os_version=$(awk -F'[= ."]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
fi

if [[ x"${release}" == x"debian" ]]; then
    if [[ ${os_version} -lt 11 ]]; then
        echo -e "${red}请使用 Debian 11 或更高版本的系统!\n${end}" && exit 1
    fi
fi
rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
    echo $(($num%$max+$min))  
}
wireguard_install(){
	if [ $os_version == "18" ]; then
        apt-get update -y
        apt-get install -y software-properties-common
        apt-get install -y openresolv
        add-apt-repository -y ppa:wireguard/wireguard
        apt-get update -y
        apt-get install -y wireguard curl
    elif [ $os_version == "11" ];then
    	apt install wireguard -y
    elif [ $os_version == "10" ]; then
    	echo 'deb http://ftp.debian.org/debian buster-backports main' | tee /etc/apt/sources.list.d/buster-backports.list
    	apt update && apt install wireguard -y
    fi
    echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf
    sysctl -p
    echo "1"> /proc/sys/net/ipv4/ip_forward
    mkdir -p /etc/wireguard
    cd /etc/wireguard
    wg genkey | tee sprivatekey | wg pubkey > spublickey
    wg genkey | tee cprivatekey | wg pubkey > cpublickey
    s1=$(cat sprivatekey)
    s2=$(cat spublickey)
    c1=$(cat cprivatekey)
    c2=$(cat cpublickey)
    serverip=$(curl ipv4.icanhazip.com)
    port=$(rand 10000 60000)
    eth=$(ls /sys/class/net | awk '/^e/{print}')
    cat > /etc/wireguard/wg0.conf <<-EOF
[Interface]
PrivateKey = $s1
Address = 10.1.1.1/24 
PostUp   = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $eth -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $eth -j MASQUERADE
ListenPort = $port
DNS = 8.8.8.8,8.8.4.4
MTU = 1420
[Peer]
PublicKey = $c2
AllowedIPs = 10.10.10.2/32
EOF
cat > /etc/wireguard/client.conf <<-EOF
[Interface]
PrivateKey = $c1
Address = 10.10.10.2/24 
DNS = 8.8.8.8,8.8.4.4
MTU = 1420
[Peer]
PublicKey = $s2
Endpoint = $serverip:$port
AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF
apt-get install -y qrencode
cat > /etc/init.d/wgstart <<-EOF
#! /bin/bash
### BEGIN INIT INFO
# Provides:		wgstart
# Required-Start:	$remote_fs $syslog
# Required-Stop:    $remote_fs $syslog
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
# Short-Description:	wgstart
### END INIT INFO
wg-quick up wg0
EOF
chmod +x /etc/init.d/wgstart
    cd /etc/init.d
    if [ $os_version == "18" ]
    then
        update-rc.d wgstart defaults 90
    else
        update-rc.d wgstart defaults
    fi
    chmod 600 /etc/wireguard/wg0.conf
    wg-quick up wg0
    
    content=$(cat /etc/wireguard/client.conf)
    echo -e "${yellowb}电脑端请下载/etc/wireguard/client.conf，手机端可直接使用软件扫码${end}"
    echo "${content}" | qrencode -o - -t UTF8
}
wireguard_remove(){

    wg-quick down wg0
    apt-get remove -y wireguard
    rm -rf /etc/wireguard
    rm /etc/init.d/wgstart
}
add_user(){
    echo -e "${yellowb}给新用户起个名字，不能和已有用户重复${end}"
    read -p "请输入用户名：" newname
    cd /etc/wireguard/
    cp client.conf $newname.conf
    wg genkey | tee temprikey | wg pubkey > tempubkey
    ipnum=$(grep Allowed /etc/wireguard/wg0.conf | tail -1 | awk -F '[ ./]' '{print $6}')
    newnum=$((10#${ipnum}+1))
    sed -i 's%^PrivateKey.*$%'"PrivateKey = $(cat temprikey)"'%' $newname.conf
    sed -i 's%^Address.*$%'"Address = 10.1.1.$newnum\/24"'%' $newname.conf

cat >> /etc/wireguard/wg0.conf <<-EOF
[Peer]
PublicKey = $(cat tempubkey)
AllowedIPs = 10.1.1.$newnum/32
EOF
    wg set wg0 peer $(cat tempubkey) allowed-ips 10.1.1.$newnum/32
    echo -e "${yellowb}添加完成，文件：/etc/wireguard/$newname.conf${end}"
    rm -f temprikey tempubkey
    content=$(cat /etc/wireguard/$newname.conf)
    echo -e "${yellowb}电脑端请下载/etc/wireguard/$newname.conf，手机端可直接使用软件扫码${end}"
    echo "${content}" | qrencode -o - -t UTF8
}
del_user(){
	echo -e "${yellowb}/etc/wireguard目录下包含如下配置文件，其中wg0.conf为服务端配置文件${end}"
    path="/etc/wireguard" ; files=$(ls $path) ; for filename in $files ; do echo $filename ; done
	echo -n -e "${yellowb}请输入需要删除的用户：${end}"
	read delname
	iprule=$(cat /etc/wireguard/$delname.conf |grep Address | awk '{print $3}' | awk -F "/" '{print $1}')
	rm /etc/wireguard/$delname.conf 
	key=$(wg |grep -B 1 "${iprule}" | head -1 |awk -F ":" '{print $2}')
	wg set wg0 peer $key remove
	wg-quick save wg0
	echo  -e "${yellowb}用户已删除，脚本执行完毕${end}"
}
#开始菜单
start_menu(){
    clear
    echo -e "${green} ====================================${end}"
    echo -e "${green} 介绍：wireguard一键脚本              ${end}"
    echo -e "${green} 支持系统：Ubuntu、Debian                 ${end}"
    echo -e "${green} 作者：翔翎                    ${end}"
    echo -e "${green} ====================================${end}"
    echo
    echo -e "${lightblue} 1. 安装wireguard${end}"
    echo -e "${lightblue} 2. 查看客户端二维码${end}"
    echo -e "${red} 3. 卸载wireguard${end}"
    echo -e "${lightblue} 4. 增加用户${end}"
    echo -e "${lightblue} 5. 删除用户${end}"    
    echo -e "${red} 0.${end} 退出脚本"
    echo
    read -p "请输入数字:" num
    case "$num" in
    1)
    wireguard_install
    ;;
    2)
    echo -e "${green}/etc/wireguard目录下包含如下配置文件，其中wg0.conf为服务端配置文件${end}"
    path="/etc/wireguard" ; files=$(ls $path) ; for filename in $files ; do echo $filename ; done
    echo -n -e "${green}请输入需要查看的配置文件的文件名(不包含.conf)：${end}"
    read username
    content=$(cat /etc/wireguard/$username.conf)
    echo -e "${yellowb}请用手机客户端软件扫码进行配置${end}"
    echo "${content}" | qrencode -o - -t UTF8
    ;;
    3)
    wireguard_remove
    ;;
    4)
    add_user
    ;;
    5)
    del_user
    ;;    
    0)
    exit 0
    ;;
    *)
    clear
    echo -e "请输入正确数字"
    sleep 2s
    start_menu
    ;;
    esac
}

start_menu
