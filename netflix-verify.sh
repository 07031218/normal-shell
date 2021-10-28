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
	elif [[ "$CPUArch" == "x86_64" ]];then
		arch=linux_amd64
	elif [[ "$CPUArch" == "x86_64" ]] && [ -n "$ifMacOS" ];then
		arch=darwin_amd64
		brew install wget > /dev/null 2>&1 
	fi
}	
version=$(curl --silent "https://github.com/sjlleo/netflix-verify/releases/latest" | sed 's#.*tag/\(.*\)".*#\1#')
checkCPU
#下载检测程序
wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/${version}/nf_${version}_${arch} > /dev/null 2>&1 
chmod +x nf > /dev/null 2>&1 
./nf -method full
rm nf
exit
