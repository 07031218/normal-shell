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
url_cdn="https://gh.xlj.workers.dev"
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

webget(){
  if curl --version > /dev/null 2>&1;then
    [ "$3" = "echooff" ] && progress='-s' || progress='-#'
    [ -z "$4" ] && redirect='-L' || redirect=''
    result=$(curl -w %{http_code} --connect-timeout 5 $progress $redirect -ko $1 $2)
  else
    if wget --version > /dev/null 2>&1;then
      [ "$3" = "echooff" ] && progress='-q' || progress='-q --show-progress'
      [ "$4" = "rediroff" ] && redirect='--max-redirect=0' || redirect=''
      certificate='--no-check-certificate'
      timeout='--timeout=3'
    fi
    [ "$3" = "echoon" ] && progress=''
    [ "$3" = "echooff" ] && progress='-q'
    wget $progress $redirect $certificate $timeout -O $1 $2 
    [ $? -eq 0 ] && result="200"
  fi
}
install_v2raym(){
  $InstallMethod update >/dev/null && $InstallMethod install unzip -y >/dev/null
  echo -e "${yellowb}开始下载v2raym···${end}"
  webget /root/v2manager.zip "$url_cdn/https://github.com/07031218/normal-shell/raw/net/v2raym/v2manager-$arch.zip"
  unzip v2manager.zip && cd v2manager && chmod +x v2raym && mkdir -p /root/v2ray && cd /root/v2ray 
  echo -e "${yellowb}开始下载v2ray···${end}"
  if [[ $arch == "linux_arm64" ]]; then
    wget "$url_cdn/https://github.com/v2fly/v2ray-core/releases/download/v4.31.0/v2ray-linux-arm64-v8a.zip" && unzip v2ray-linux-arm64-v8a.zip
    echo -e "${yellowb}v2ray下载完成，开始进行v2ray和v2raym程序部署···${end}"
      mkdir -p /usr/bin/v2ray/ && cp /root/v2ray/v2ctl /usr/bin/v2ray/ && cp /root/v2ray/v2ray /usr/bin/v2ray/ && cp /root/v2ray/geosite.dat /usr/bin/v2ray/
  iptables -F && $InstallMethod install supervisor -y && rm -f /etc/supervisor/supervisord.conf && cd /etc/supervisor && wget http://aria2.xun-da.com/supervisord.conf && cd /etc/supervisor/conf.d && wget http://aria2.xun-da.com/v2manager.conf  && service supervisor restart &&  chmod +x /usr/local/bin/v2ray && chmod +x /usr/local/bin/v2ctl  && service supervisor restart 
  echo -e "${yellowb}程序部署完成。。。${end}"
  elif [[ $arch == "linux_amd64" ]]; then
    wget "$url_cdn/https://github.com/v2fly/v2ray-core/releases/download/v4.31.0/v2ray-linux-64.zip" && unzip v2ray-linux-64.zip
    echo -e "${yellowb}v2ray下载完成，开始进行v2ray和v2raym程序部署···${end}"
    cp /root/v2ray/v2ctl /usr/local/bin/ && cp /root/v2ray/v2ray /usr/local/bin/ && cp /root/v2ray/geosite.dat /usr/local/bin/
  iptables -F && $InstallMethod install supervisor -y && rm -f /etc/supervisor/supervisord.conf && cd /etc/supervisor && wget http://aria2.xun-da.com/supervisord.conf && cd /etc/supervisor/conf.d && wget http://aria2.xun-da.com/v2manager.conf  && service supervisor restart &&  chmod +x /usr/local/bin/v2ray && chmod +x /usr/local/bin/v2ctl  && service supervisor restart 
  echo -e "${yellowb}程序部署完成。。。${end}"
  else
    echo -e "${red}不支持当前系统架构，程序自动退出${end}" && exit 1
  fi
}
uninstall_v2raym(){
  echo -n -e "${red}注意：即将开始卸载v2manager····,请确认是否继续，[Y/N]:${end}"
  read yn
  if [[ $yn == "Y" ]]||[[ $yn == "y" ]]; then
      service supervisor stop && rm /etc/supervisor/conf.d/v2manager.conf && kill -9 $(lsof -i:419 | awk '{print $2}' | sed -n '2p') && kill -9 $(lsof -i:8300 | awk '{print $2}' | sed -n '2p')
  rm -rf /root/v2manager /root/v2ray && rm /usr/local/bin/v2ctl /usr/local/bin/v2ray /usr/local/bin/geosite.dat
  service supervisor restart
else
  exit 0
  fi
  echo -n -e "${yellow}v2manager卸载完成，程序退出······${end}"
  exit 0
}
copyright(){
echo -e "
${green}###########################################################${end}
${green}#                                                         #${end}
${green}#        v2manager一键部署、卸载脚本                      #${end}
${green}#        Powered  by 翔翎                                 #${end}
${green}#                                                         #${end}
${green}###########################################################${end}"
}
menu() {
  echo -e "
${red}0.${end}  退出脚本
${green}———————————————————————————————————————————————————————————${end}
${green}1.${end}  一键部署v2manager
${green}2.${end}  卸载v2manager
"
  read -p "请输入数字 :" num
  case "$num" in
  0)
    quit
    ;;
  1)
    install_v2raym
    ;;
  2)
    uninstall_v2raym
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
