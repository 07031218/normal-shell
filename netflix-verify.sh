#!/bin/bash
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
	fi
}
version=$(curl --silent "https://github.com/sjlleo/netflix-verify/releases/latest" | sed 's#.*tag/\(.*\)".*#\1#')
checkCPU
wgetsrc=$(which wget)
if [ ! -n "$wgetsrc" ]; then
echo -e "检测到系统未安装wget，开始安装wget"
    $InstallMethod install wget -y
    checksteam
else
    checksteam
fi
checksteam(){  
#下载检测程序
wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/${version}/nf_${version}_${arch} > /dev/null 2>&1 
chmod +x nf > /dev/null 2>&1 
clear
./nf -method full
rm nf
}
exit
