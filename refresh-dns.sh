#/usr/bin/env bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE="\033[0;35m"
CYAN='\033[0;36m'
PLAIN='\033[0m'
#安装dig命令
yum install bind-utils -y  2> /dev/null || apt-get install dnsutils  -y 
#定义变量
HOST="nf"
DOMAIN="20120714.xyz"
URL=${HOST}.${DOMAIN}
#IP=`ping ${URL} -c 1 |awk 'NR==2 {print $4}' |awk -F ':' '{print $1}'`
#IP=`ping ${URL} -c 1 |awk 'NR==2 {print $5}' |awk -F ':' '{print $1}' |sed -nr "s#\(##gp"|sed -nr "s#\)##gp"`
#dig命令获取域名的ip地址
IP=`dig ${URL} @223.5.5.5 | awk -F "[ ]+" '/IN/{print $1}' | awk 'NR==2 {print $5}'`
echo "解锁dns服务器IP地址是 ${IP}"



echo "${YELLOW}开始修改本机DNS服务器地址${PLAIN}"
chattr -i /etc/resolv.conf && echo -e "nameserver $IP\nnameserver 8.8.8.8" > /etc/resolv.conf && chattr +i /etc/resolv.conf
echo "${GREEN}修改DNS服务器地址完成，开始畅游Netflix吧^_^${PLAIN}"
