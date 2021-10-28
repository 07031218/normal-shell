#!/bin/bash

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
	fi
}	
version=$(curl --silent "https://github.com/sjlleo/netflix-verify/releases/latest" | sed 's#.*tag/\(.*\)".*#\1#')
checkCPU
wget -O /root/nf https://github.com/sjlleo/netflix-verify/releases/download/${version}/nf_${version}_${arch} && chmod +x /root/nf && /root/nf
exit
