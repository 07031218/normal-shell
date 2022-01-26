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
yellow="${lightblue}"
yellowb="\033[1;33m"
blue="\033[0;34m"
blueb="\033[1;34m"
purple="\033[0;35m"
purpleb="\033[1;35m"
lightblue="\033[0;36m"
lightblueb="\033[1;36m"
copyright(){
	clear
echo -e "
${green}###########################################################${end}
${green}#                                                         #${end}
${green}#        一键脚本大锅烩                                   #${end}
${green}#        Powered  by 翔翎                                 #${end}
${green}#                                                         #${end}
${green}###########################################################${end}"
}
checkCPU(){
  CPUArch=$(uname -m)
  if [[ "$CPUArch" == "aarch64" ]];then
    arch=linux_arm64
  elif [[ "$CPUArch" == "i686" ]];then
    arch=linux_386
  elif [[ "$CPUArch" == "arm" ]];then
    arch=linux_arm
  elif [[ "$CPUArch" == "x86_64" ]] && [ -n "$ifMacOS" ];then
    arch=darwin_amd64
  elif [[ "$CPUArch" == "x86_64" ]];then
    arch=linux_amd64    
  fi
}
checkos(){
  ifTermux=$(echo $PWD | grep termux)
  ifMacOS=$(uname -a | grep Darwin)
  if [ -n "$ifTermux" ];then
    os_version=Termux
  elif [ -n "$ifMacOS" ];then
    os_version=MacOS  
  else  
    os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
  fi
  
  if [[ "$os_version" == "2004" ]] || [[ "$os_version" == "10" ]] || [[ "$os_version" == "11" ]];then
    ssll="-k --ciphers DEFAULT@SECLEVEL=1"
  fi
}
checkCPU
wireguard(){
	bash <(curl -sL https://ghproxy.20120714.xyz/https://github.com/07031218/normal-shell/blob/main/wireguard.sh)
}
reinstall_os(){
	echo -n -e "${lightblue}脚本兼容Azure、腾讯云、Oracle Cloud、AWS${end}，${yellowb}请设置DD后系统的ROOT密码：${end}"
	read password
	echo -n -e "${red}请输入 Y 确认开始DD系统：${end}"
	read yn
	if [[ $yn == "Y" ]]||[[ $yn == "y" ]]; then
		bash <(wget --no-check-certificate -qO- 'https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/main/InstallNET.sh') -d 11 -v 64 -p $password --mirror 'https://mirrors.huaweicloud.com/debian/'
	else
		echo -e "${red}取消DD系统，程序退出···${end}"
	fi	
}
install_clash-ui(){
	bash <(curl -sL https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/c-m/main/install)
}
install_x-ui(){
	bash <(curl -Ls https://gh.xlj.workers.dev/https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
}
argo-tunnel(){
	bash <(curl -sL https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/net/onekey-argo-tunnel.sh)
}
onekey-nginx-ssl(){
	bash <(curl -s https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/one-key-for-let-s-Encrypt/main/run.sh) 
}
ql-nvjdc(){
	if [[ $arch == "linux_arm64" ]];then
		wget https://ghproxy.20120714.xyz/https://github.com/07031218/normal-shell/blob/main/nvjdc/OK-arm -O OK && chmod +x OK && ./OK
	elif [[ $arch == "linux_amd64" ]];then
		wget https://ghproxy.20120714.xyz/https://github.com/07031218/normal-shell/blob/main/nvjdc/OK -O OK && chmod +x OK && ./OK
	else
		echo -e "${red}错误：${end}${lightblue}不支持当前系统架构，脚本退出···${end}";exit 1
	fi
}
media(){
	if [[ $arch == "linux_arm64" ]];then
		wget https://ghproxy.20120714.xyz/https://github.com/07031218/normal-shell/blob/main/oracle/oracle-arm -O oracle && chmod 777 oracle && ./oracle
	elif [[ $arch == "linux_amd64" ]];then
		wget https://ghproxy.20120714.xyz/https://github.com/07031218/normal-shell/blob/main/oracle/oracle -O oracle && chmod 777 oracle && ./oracle
	else
		echo -e "${red}错误：${end}${lightblue}不支持当前系统架构，脚本退出···${end}";exit 1	
	fi
}
media-verify(){
	bash <(curl -sL https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/main/netflix-verify.sh)
}
speedtest(){
	bash <(curl -Lso- https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/main/superspeed.sh)
}
menu() {
  echo -e "
${red}0.${end}  退出脚本
${green}———————————————————————————————————————————————————————————${end}
${green}1.${end}  一键部署&卸载wireguard
${green}2.${end}  一键DD系统到Debian 11
${green}3.${end}  一键部署Clash_ui [Clash+Mosdns]
${green}4.${end}  一键部署x-ui
${green}5.${end}  一键部署Argo Tunnel
${green}6.${end}  一键安装nginx并部署签发SSL
${green}7.${end}  一键青龙、Nvjdc
${green}8.${end}  一键部署流媒体解锁等
${green}9.${end}  一键奈飞解锁检测
${green}10.${end} 一键测速
"
  read -p "请输入数字 :" num
  case "$num" in
  0)
    exit 0
    ;;
  1)
    wireguard
    ;;
  2)
    reinstall_os
    ;;
  3)
    install_clash-ui
    ;;
  4)
    install_x-ui
    ;;
  5)
    argo-tunnel
    ;; 
  6)
    onekey-nginx-ssl
    ;;  
  7)
    ql-nvjdc
    ;;  
  8)
    media
    ;; 
  9)
    media-verify
    ;;
  10)
    speedtest
    ;;           
  *)
  clear
    echo -e "${red}出现错误:请输入正确数字 [0-10]${end}"
    sleep 3s
    copyright
    menu
    ;;
  esac
}
copyright
menu
