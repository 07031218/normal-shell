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
yum install bind-utils -y > /dev/null 2>&1 || apt-get install dnsutils  -y > /dev/null 2>&1
#检测dig命令是否安装成功
#hash dig 2> /dev/null || { echo -e >&2 "${RED}出现异常 dnsutils 没有安装成功，脚本无法继续，将自动退出...${PLAIN}"; exit 1; }
#定义变量
URL=armsgp.20120714.xyz
#IP=`ping ${URL} -c 1 |awk 'NR==2 {print $4}' |awk -F ':' '{print $1}'`
#IP=`ping ${URL} -c 1 |awk 'NR==2 {print $5}' |awk -F ':' '{print $1}' |sed -nr "s#\(##gp"|sed -nr "s#\)##gp"`
#dig命令获取域名的ip地址
IP=$(ping armsgp.20120714.xyz -c 1 |awk 'NR==2 {print $5}' |awk -F ':' '{print $1}' |sed -nr "s#\(##gp"|sed -nr "s#\)##gp")

echo -e "${BLUE}当前解锁服务器IP地址是 ${IP} ${PLAIN}"
record=$(sed -n '1p' /etc/resolv.conf | grep 'nameserver'| sed 's/^.*nameserver//g' | sed 's/\"//g' | sed 's/\,//g' | sed 's/ //g')
        if [[ -n "${record}" ]] && [[ "${IP}" = "${record}" ]]; then
                echo -e "${GREEN}-----------------------------------------------------------------------------${PLAIN}"
                echo -e "${GREEN}DNS解锁服务器地址无变化，无需修改, current IP: ${IP}${PLAIN}"
                echo -e "${GREEN}-----------------------------------------------------------------------------${PLAIN}"
                exit
        elif [ ! -n "${record}" ]; then
        echo -e "${red}DNS服务器出现空白bug，开始修正${PLAIN}"
        #chattr -i /etc/resolv.conf && echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > /etc/resolv.conf && chattr +i /etc/resolv.conf
        #IP1=`dig ${URL} @223.5.5.5 | awk -F "[ ]+" '/IN/{print $1}' | awk 'NR==2 {print $5}'`
        #echo -e "${YELLOW}解锁服务器IP获取完成，开始修改本机DNS服务器地址${PLAIN}"
        chattr -i /etc/resolv.conf && echo -e "nameserver ${IP}\nnameserver 8.8.8.8" > /etc/resolv.conf && chattr +i /etc/resolv.conf
        echo -e "${GREEN}错误修正完成，开始畅游Netflix吧^_^ ${PLAIN}"     
        else
        echo -e "${YELLOW}解锁服务器IP有变化，开始修改DNS服务器地址${PLAIN}"
        chattr -i /etc/resolv.conf && echo -e "nameserver ${IP}\nnameserver 8.8.8.8" > /etc/resolv.conf && chattr +i /etc/resolv.conf
        echo -e "${GREEN}修改DNS服务器地址完成，开始畅游Netflix吧^_^ ${PLAIN}"
        fi
