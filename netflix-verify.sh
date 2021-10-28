#!/bin/bash

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
	fi
}	
version=$(curl --silent "https://github.com/sjlleo/netflix-verify/releases/latest" | sed 's#.*tag/\(.*\)".*#\1#')
checkCPU
#下载检测程序
wget -O /root/nf https://github.com/sjlleo/netflix-verify/releases/download/${version}/nf_${version}_${arch} > /dev/null 2>&1 
chmod +x /root/nf > /dev/null 2>&1 
/root/nf -method full
rm /root/nf
exit
