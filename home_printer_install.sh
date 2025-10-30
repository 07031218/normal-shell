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
clear
checkCPU(){
  CPUArch=$(uname -m)
  if [[ "$CPUArch" == "aarch64" ]];then
    arch=linux-arm64
  elif [[ "$CPUArch" == "x86_64" ]];then
    arch=linux-amd64
    else
    echo -e "${red}不支持当前系统，程序退出···${end}" 
    exit 0
  fi
}
checkCPU
check_dependencies(){

  os_detail=$(cat /etc/os-release 2> /dev/null)
  if_debian=$(echo $os_detail | grep 'ebian')
  if_redhat=$(echo $os_detail | grep 'rhel')
  if [ -n "$if_debian" ];then
    InstallMethod="apt-get"
  elif [ -n "$if_redhat" ] && [[ "$os_version" -lt 8 ]];then
    InstallMethod="yum"
  elif [[ "$os_version" == "MacOS" ]];then
    InstallMethod="brew"  
  fi
}
check_dependencies
install_cups(){
echo -n -e "${yellow}开始编译安装cups服务,请问是否继续，输入[Y/N]:${end}"
read yn
if [[ $yn == "y" ]]||[[ $yn == "y" ]]; then
$InstallMethod install gcc g++ -y
$InstallMethod install --reinstall make -y
wget https://gh-proxy.com/https://github.com/apple/cups/releases/download/v2.3.3/cups-2.3.3-source.tar.gz -O cups-2.3.3-source.tar.gz && tar xzvf cups-2.3.3-source.tar.gz && cd /root/cups-2.3.3 && ./configure && make && make install
cp /usr/lib64/* /usr/lib/
echo -n -e "${blue}请输入当前设备的网段，比如192.168.2.1则输入192.168.2.0，请正确输入：${end}"
read ipduan
sed -i "27c Allow ${ipduan}/24" /etc/cups/cupsd.conf
sed -i "32c Allow ${ipduan}/24" /etc/cups/cupsd.conf
sed -i '12c Listen 0.0.0.0:631' /etc/cups/cupsd.conf
/etc/init.d/cups start
echo -e "${green}Cups服务安装完毕，相关打印机对应驱动请自行从官网下载安装······${end}"
else
	echo -e "${red}取消安装，程序退出······${end}"
exit 0
fi
}
install_printer(){
	echo -n -e "${yellow}开始安装Brother打印机驱动，请根据命令行提示操作,是否继续，请输入[Y/N]:${end}"
	read yorn
	if [[ $yorn == "y" ]]||[[ $yorn == "Y" ]]; then
		bash <(curl -sL https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/main/linux-brprinter-installer.sh)
	elif [[ $yorn == "N" ]]||[[ $yorn == "n" ]]; then
		echo -e "${red}根据操作要求，取消安装，程序退出······${end}"
		exit 0
	else
		echo -e "${red}输入错误，程序退出！！！${end}"
		exit 1
	fi
}
copyright(){
echo -e "
${green}###########################################################${end}
${green}#                                                         #${end}
${green}#           家里Brother打印机一键安装脚本                 #${end}
${green}#           Powered  by 翔翎                              #${end}
${green}#                                                         #${end}
${green}###########################################################${end}"
}
menu() {
  echo -e "
${red}0.${end}  退出脚本
${green}———————————————————————————————————————————————————————————${end}
${green}1.${end}  一键部署Cups打印服务
${green}2.${end}  一键安装Brother打印机驱动
"
  read -p "请输入数字 :" num
  case "$num" in
  0)
    exit 0
    ;;
  1)
    install_cups
    ;;
  2)
    install_printer
    ;;
  *)
  clear
    echo -e "${red}出现错误:请输入正确数字 [0-2]${end}"
    sleep 3s
    copyright
    menu
    ;;
  esac
}
copyright
menu
