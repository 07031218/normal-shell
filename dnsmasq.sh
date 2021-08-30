#/usr/bin/env bash
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE="\033[0;35m"
CYAN='\033[0;36m'
PLAIN='\033[0m'
record=$(sed -n '6p' /root/netflix-proxy/dnsmasq.conf | grep 'address=\/akadns.net\/'| sed 's/^.*address=\/akadns.net\///g')
hostIp=$(curl ip.sb)
echo -e "${GREEN}----------------------------${PLAIN}"
echo -e "${GREEN}开始检测${PLAIN}"
echo -e "${GREEN}----------------------------${PLAIN}"
hostIp=$(curl ip.sb)
echo -e "${GREEN}----------------------------${PLAIN}"
echo -e "${GREEN}获取到dnsmasq的配置是：${record}${PLAIN}"
echo -e "${GREEN}----------------------------${PLAIN}"
echo -e "${GREEN}本机当前IP是：${hostIp}${PLAIN}"
echo -e "${GREEN}----------------------------${PLAIN}"
        if [ "${hostIp}" = "${record}" ]; then
                echo -e "${GREEN}----------------------------${PLAIN}"
                echo -e "${GREEN}IP一致，无需做修改, current IP: ${hostIp}${PLAIN}"dnsmasq.sh
                echo -e "${GREEN}----------------------------${PLAIN}"
                exit
        else   
        echo -e "${GREEN}IP有更新，开始替换更新dnsmasq配置文件${PLAIN}"
cp /root/netflix-proxy/dnsmasq.conf.template /root/netflix-proxy/dnsmasq.conf &>> ${CWD}/netflix-proxy.log


    for domain in $(cat /root/netflix-proxy/proxy-domains.txt); do
        printf "address=/${domain}/${hostIp}\n"\
          | sudo tee -a /root/netflix-proxy/dnsmasq.conf &>> ${CWD}/netflix-proxy.log
    done
        echo -e "${GREEN}dnsmasq配置文件替换完毕，开始准备重启dnsmasq容器${PLAIN}"

docker restart dnsmasq
fi
echo -e "${GREEN}脚本执行完毕，退出。${PLAIN}"
exit
