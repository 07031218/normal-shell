#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
clear
[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1
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
install_rsync(){
	$InstallMethod install rsync screen -y
}
install_rsync
start_rsync(){
	echo -n -e "${yellow}请输入你要同步的源文件或者源文件夹路径：${plain}"
	read sourcedir
	echo -n -e "${yellow}请输入你要同步到的目标文件或者目标文件夹路径：${plain}"
	read targetdir
	echo -n -e "${yellow}请输入screen作业进程等名称：${plain}"
	read scr
  screen_name=${scr}
  screen -dmS $screen_name
  cmd=$"rsync -avzuP ${sourcedir} ${targetdir}";
  screen -x -S $screen_name -p 0 -X stuff "$cmd"
  screen -x -S $screen_name -p 0 -X stuff $'\n'
}
start_rsync
