#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
White='\033[37m'
blue='\033[36m'
yellow='\033[0;33m'
plain='\033[0m'
[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1
opsy=$([ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$5}' /etc/os-release)
if [[ "${opsy}" == "Debian 11" ]];then
	:
else
	echo -e "${red}本脚本仅支持Debian 11,不适用当前系统，程序退出${plain}" 
	exit 0
fi
CWD=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
[ -e "${CWD}/scripts/globals" ] && . ${CWD}/scripts/globals
CountRunTimes(){
RunTimes=$(curl -s --max-time 10 "https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=http%3A%2F%2Faria2.xun-da.com%2FautoBestTrace.sh&count_bg=%2379C83D&title_bg=%2300B1FF&icon=&icon_color=%23E7E7E7&title=script+run+times&edge_flat=false" > ~/couting.txt)
TodayRunTimes=$(cat ~/couting.txt | tail -3 | head -n 1 | awk '{print $5}')
TotalRunTimes=$(cat ~/couting.txt | tail -3 | head -n 1 | awk '{print $7}')
rm -rf ~/couting.txt
}
CountRunTimes
copyright(){
echo -e "
${green}###########################################################${plain}
${green}#                                                         #${plain}
${green}#        pagermaid一键安装脚本[For Debian 11]             #${plain}
${green}#        Powered  by 翔翎                                 #${plain}
${green}#                                                         #${plain}
${green}###########################################################${plain}"
}
Goodbye(){
    echo -e "================================================"
    echo -e "${red}该脚本执行密码发布地址:${plain} ${blue}https://t.me/beeforbean ${plain}"    
    echo -e "${green}脚本执行已结束，感谢使用此脚本 ${plain}";
    echo -e "${yellow}检测脚本当天运行次数：${plain}${red}${TodayRunTimes}次; ${plain}${yellow}脚本共计运行次数：${plain}${red}${TotalRunTimes}次 ${plain}"
    echo -e "================================================"
}
install_pagermaid(){
	copyright
	echo -e "${red}即将开始安装pagermaid，${plain}${red}本脚本仅支持Debian 11${plain}"
	echo -e "${blue}脚本基于ARM64版本撰写，未测试AMD64,理论同样可行。${plain}"
	echo -e "是否继续执行脚本，如需要继续请输入y，如不继续，请按Ctrl+C退出脚本···${plain}"
	read go
	if [[ "$go" == "y" ]] || [[ "$go" == "Y" ]];then

	 #判断机器是否安装docker
#	 if test -z "$(which docker)"; then
#	 echo -e "${yellow}检测到系统未安装docker，开始安装docker{plain}"
#	 curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
#	fi
	apt update && apt-get install libffi-dev libssl-dev -y &&  apt install python3-dev -y &&  apt-get install -y python3 python3-pip && apt install git -y
	echo -e "${yellow}开始拉取pagermaid项目···${plain}"
	sleep 10s
	cd /var/lib && git clone https://github.com/xtaodada/PagerMaid-Modify.git pagermaid && cd pagermaid
	echo -e "${yellow}开始安装相关依赖和前置命令···${plain}"
	sleep 10s
	apt-get install imagemagick -y && apt-get install software-properties-common -y && apt-get update && sudo apt-get install neofetch -y && apt-get install libzbar-dev -y && sudo apt-get install tesseract-ocr tesseract-ocr-all -y &&  apt-get install redis-server -y && pip3 install -r requirements.txt && cp config.gen.yml config.yml
	echo -e "${red}开始配置TG的api_id和api_hash，请按照命令行提示操作···${plain}"
	echo -e "${yellow}请输入TG的api_id:${plain}"
	read apiid
	echo -e "${yellow}请输入TG的api_hash:${plain}"
	read apihash
	sed -i 's/api_key: \"\"/api_key: \"${apiid}\"/g' /var/lib/pagermaid/config.yml
	sed -i 's/api_key: \"\"/api_hash: \"${apihash}\"/g' /var/lib/pagermaid/config.yml
	echo -e "${yellow}5秒后将首次启动pagermaid，请按照命令行提示完成账号的首次登录操作以获取session···${plain}"
	echo -e "${yellow}获取session成功后按Ctrl+C退出程序，来进行下一步，对pagermaid进行开机自启动设置···${plain}"
	sleep 3s
	python3 -m pagermaid
	cat <<'TEXT' > /etc/systemd/system/pagermaid.service
[Unit]
Description=PagerMaid-Modify telegram utility daemon
After=network.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
WorkingDirectory=/var/lib/pagermaid
ExecStart=/usr/bin/python3 -m pagermaid
Restart=always
TEXT
systemctl start pagermaid && systemctl enable pagermaid
echo -e "${blue}pagermaid已经部署完成，程序将自动退出${plain}"
Goodbye
else
	exit 0
fi
}
install_pagermaid 
