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
if cat /etc/issue | grep -Eqi "debian" && ; then
    release="debian"
elif cat /etc/issue | grep -Eqi "Armbian"; then
    release="Armbian"
elif cat /etc/issue | grep -Eqi "Ubuntu"; then
    release="ubuntu"
else
    echo -e "${red}脚本仅在Debian和Ubuntu系统上测试通过，请使用 Debian或Ubuntu系统!\n${plain}" && exit 1
fi
echo -ne "${yellow}请输入GD网盘的初始挂载点路径:${plain}"
read lowerdir
if [[ $lowerdir == "" ]]; then
	echo "${red}输入错误，程序退出。${plain}"
	exit 1
fi
echo -ne "${yellow}请输入upperdir(削刮文件)的存放路径:${plain}"
read upperdir
if [[ $upperdir == "" ]]; then
	echo "${red}输入错误，程序退出。${plain}"
	exit 1
fi
if [[ ! -d ${upperdir} ]]; then
	mkdir -p ${upperdir}
fi
echo -ne "${yellow}请输入workdir(overlay分层文件临时活动目录)的路径:${plain}"
read workdir
if [[ $workdir == "" ]]; then
	echo "${red}输入错误，程序退出。${plain}"
	exit 1
fi
if [[ ! -d ${workdir} ]]; then
	mkdir -p ${workdir}
fi
echo -ne "${yellow}请输入merga目录(overlay分层文件顶端合并目录)的路径:${plain}"
read mountdir
if [[ $mountdir == "" ]]; then
	echo "${red}输入错误，程序退出。${plain}"
	exit 1
fi
if [[ ! -d ${mountdir} ]]; then
	mkdir -p ${mountdir}
fi
$(which mount) -t overlay -o lowerdir=${lowerdir},upperdir=${upperdir},workdir=${workdir} overlay ${mountdir}
if [[ "$?" -eq 0 ]]; then
	echo "${green}已经完成overlayFS文件系统挂载,开始将挂载写入开机自启动。${plain}"
	if [[ ! -f /etc/rc.local ]]; then
		cat > /etc/rc.local <<EOF
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
 
# bash /root/bindip.sh
ip tunnel add $tunname mode ipip remote ${remoteip} local ${localip} ttl 64
ip addr add ${vip}/30 dev $tunname
ip link set $tunname up
exit 0
EOF
		echo -e "sleep 30s\n$(which mount) -t overlay -o lowerdir=${lowerdir},upperdir=${upperdir},workdir=${workdir} overlay ${mountdir}" >> /etc/rc.local
		chmod +x /etc/rc.local
		cat > /etc/systemd/system/rc-local.service <<EOF
[Unit]
Description=/etc/rc.local
After=network.target
ConditionPathExists=/etc/rc.local
 
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

 
[Install]
WantedBy=multi-user.target
EOF
		systemctl start rc-local
		systemctl enable rc-local
		if [[ "$?" -eq 0 ]]; then
		echo "${green}将挂载写入开机自启动成功。${plain}"
	fi
	else
		echo -e "sleep 30s\n$(which mount) -t overlay -o lowerdir=${lowerdir},upperdir=${upperdir},workdir=${workdir} overlay ${mountdir}" >> /etc/rc.local
		if [[ "$?" -eq 0 ]]; then
			echo "${green}将挂载写入开机自启动成功。${plain}"
		fi
	fi
else
	echo "${red}overlayFS文件系统挂载失败，程序退出。${plain}"
	exit 1
fi
