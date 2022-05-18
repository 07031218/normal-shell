#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
White='\033[37m'
blue='\033[36m'
yellow='\033[0;33m'
plain='\033[0m'
clear
# check root
[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1
checkos(){
  ifTermux=$(echo $PWD | grep termux)
  ifMacOS=$(uname -a | grep Darwin)
  ifsynology=$(uname -a | grep synology)
  if [ -n "$ifTermux" ];then
    os_version=Termux
  elif [ -n "$ifMacOS" ];then
    os_version=MacOS
  elif [ -n "$ifsynology" ]; then
    os_version=synology
  if test -z "$(which ipkg)"; then
    echo -e "${green}检测到系统未安装ipkg，开始安装ipkg${plain}"
    wget http://ipkg.nslu2-linux.org/feeds/optware/syno-i686/cross/unstable/syno-i686-bootstrap_1.2-7_i686.xsh && chmod +x syno-i686-bootstrap_1.2-7_i686.xsh && sh syno-i686-bootstrap_1.2-7_i686.xsh && ipkg update
  fi
  else  
    os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
  fi
  
  if [[ "$os_version" == "2004" ]] || [[ "$os_version" == "10" ]] || [[ "$os_version" == "11" ]];then
    ssll="-k --ciphers DEFAULT@SECLEVEL=1"
  fi
}
checkos
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
checkCPU
check_dependencies(){
  os_detail=$(cat /etc/os-release 2> /dev/null)
  if_debian=$(echo $os_detail | grep 'ebian')
  if_redhat=$(echo $os_detail | grep 'rhel')
  if [ -n "$if_debian" ];then
    InstallMethod="apt"
  elif [ -n "$if_redhat" ] && [[ "$os_version" -lt 8 ]];then
    InstallMethod="yum"
  elif [[ "$os_version" == "MacOS" ]];then
    InstallMethod="brew"
  elif [[ $os_version == "synology" ]]; then
    InstallMethod="ipkg"
  fi
}
check_dependencies
${InstallMethod} install -y xz-utils openssl gawk file wget
clear
local_ip=$(ip a 2>&1 | grep -w 'inet' | grep 'global' | grep -E '\ 1(92|0|72|00|1)\.' | sed 's/.*inet.//g' | sed 's/\/[0-9][0-9].*$//g' | head -n 1)
gateway=$(route | grep 'default' | awk '{print $2}')
echo -e "${red}注意：本脚本针对GCP主机原版系统DD到其他自定义系统，如您不是GCP主机请Ctrl+C退出执行脚本${plain}"
echo -n -e "${yellow}请选择你要DD到的系统：\n1、Debian\n2、Ubuntu\n3、Centos\n>：${plain}"
read chose
if [[ $chose == "1" ]]; then
	sysinfo=d
elif [[ $chose == "2" ]]; then
	sysinfo=u
elif [[ $chose == "3" ]]; then
	sysinfo=c
fi
echo -n -e "${yellow}请输入系统版本号：\n如 Debian 11输入11，Ubuntu 20.04输入20.04，Centos 6.9输入6.9 \n>：${plain}"
read version
echo -n -e "${yellow}请输入系统Bit版本：32或64 \n>:${plain}"
read bits
echo -n -e "${yellow}请输入系统DD之后的登陆密码\n>：${plain}"
read password
echo -n -e "${yellow}您设置的密码为:${plain}${red}${password}${plain}  ${red}请确认是否正式开始DD系统[Y/N]${plain}\n>："
read yn
if [[ $yn == "y" ]]||[[ $yn == "Y" ]]; then
	bash <(wget --no-check-certificate -qO- 'https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/main/InstallNET.sh') --ip-addr ${local_ip} --ip-gate ${gateway} --ip-mask 255.255.255.0 -${sysinfo} ${version} -v ${bits} -a -p ${password}
fi
