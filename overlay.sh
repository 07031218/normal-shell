#!/bin/bash
RED='\E[1;31m'
RED_W='\E[41;37m'
END='\E[0m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
check_root(){
    if [[ $EUID -ne 0 ]]; then
           echo -e "${Red}本脚本必须root账号运行，请切换root用户后再执行本脚本!${END}"
           exit 1
    fi
}
check_root
echo -ne "${yellow}请输入GD网盘的初始挂载点路径:${plain}"
read lowerdir
echo -ne "${yellow}请输入upperdir(削刮文件)的存放路径:${plain}"
read upperdir
if [[ ! -d ${upperdir} ]]; then
	mkdir -p ${upperdir}
fi
echo -ne "${yellow}请输入workdir(overlay分层文件临时活动目录)的路径:${plain}"
read workdir
if [[ ! -d ${workdir} ]]; then
	mkdir -p ${workdir}
fi
echo -ne "${yellow}请输入merga目录(overlay分层文件顶端合并目录)的路径:${plain}"
read mountdir
if [[ ! -d ${mountdir} ]]; then
	mkdir -p ${mountdir}
fi
$(which mount) -t overlay -o lowerdir=${lowerdir},upperdir=${upperdir},workdir=${workdir} overlay ${mountdir}
if [[ "$?" -eq 0 ]]; then
	echo "${green}已经完成overlayFS文件系统挂载,开始将挂载写入开机自启动。${plain}"
	echo "overlay ${mountdir} overlay lowerdir=${lowerdir},upperdir=${upperdir},workdir=${workdir} 0 0" >>/etc/fstab
	if [[ "$?" -eq 0 ]]; then
		echo "${green}将挂载写入开机自启动成功。${plain}"
	fi
else
	echo "${red}overlayFS文件系统挂载失败，程序退出。${plain}"
fi
