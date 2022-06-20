#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
if [[ $EUID -ne 0 ]]; then
  echo -e "${red}本脚本必须root账号运行，请切换root用户后再执行本脚本!${plain}"
  exit 1
fi
apt update||yum update
apt install curl -y||yum install curl -y
clear
install_vertex(){
  local_ip=$(ip a 2>&1 | grep -w 'inet' | grep 'global' | grep -E '\ 1(92|0|72|00|1)\.' | sed 's/.*inet.//g' | sed 's/\/[0-9][0-9].*$//g' | head -n 1)
  baseip=$(curl -s ipip.ooo)  > /dev/null
  if test -z "$(which docker)"; then
    echo -e "${yellow}检测到系统未安装docker，开始安装docker${plain}"
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
    if [[ "$#" -eq 0 ]]; then
      echo -e "${green}docker安装成功······${plain}"
    else
      echo -e "${red}docker安装失败······${plain}"
      exit 1
    fi
  fi
  if test -z `which docker-compose`;then
    echo -e "${yellow}检测到系统未安装docker-compose，开始安装docker-compose${plain}"
    curl -L https://get.daocloud.io/docker/compose/releases/download/v2.4.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    if [[ "$#" -eq 0 ]]; then
       echo -e "${green}docker-compose安装成功······${plain}"
    else
      echo -e "${red}docker-compose安装失败······${plain}"
      exit 1
    fi
  fi
  mkdir -p /root/vertex && chmod 777 /root/vertex
  cd /root
  cat >/root/docker-compose.yml <<EOF
  version: "2.0"
  services:
    vertex:
      image: lswl/vertex:latest
      container_name: vertex
      restart: always
      tty: true
      network_mode: bridge
      hostname: vertex
      volumes:
        - /root/vertex:/vertex
      environment:
        - TZ=Asia/Shanghai
      ports: 
        - 3000:3000
    vertex-base:
      image: lswl/vertex-base:latest
EOF
  docker-compose up -d
  sleep 5s
  password=`cat /root/vertex/data/password`
  echo -e "${green}Vertex安装完毕，面板访问地址：http://${baseip}:3000 或 http://${local_ip}:3000\n用户名:admin\n密  码:${plain} ${red}${password}${plain}${green}\n进入vertex面板后通过${plain} ${red}全局设置${plain} ${green}修改密码 ${plain}"
}
uninstall_vertex(){
  cd /root
  docker-compose down
  echo -ne "${yellow}是否删除vertex映射目录和相关本地镜像[Yy/Nn]${plain}"
  read yn
  if [[ $yn == "Y" ]]||[[  $yn == "y" ]]; then
    rm -rf /root/vertex
    docker rmi lswl/vertex:latest
    docker rmi lswl/vertex-base:latest
    echo -e "${yellow}vertex映射目录和相关本地镜像已删除${plain}"
    exit 0
  else
    echo -e "${yellow}按照您的选择，vertex映射目录给予保留，程序自动退出${plain}"
    exit 0
  fi
}
copyright(){
echo -e "
${green}###########################################################${plain}
${green}#                                                         #${plain}
${green}#              Vertex 一键部署脚本                        #${plain}
${green}#              Powered  by 翔翎                           #${plain}
${green}#                                                         #${plain}
${green}###########################################################${plain}"
}
main(){
  echo -e "
${red}0.${plain} 退出脚本
${green}1.${plain} 安装vertex
${green}2.${plain} 卸载vertex
"
  read -p "请输入数字 :" num
  case "$num" in
  0)
    exit 0
    ;;
  1)
    install_vertex
    ;;
  2)
    uninstall_vertex
    ;;
  *)
  clear
    echo -e "${Error}:请输入正确数字 [0-2]"
    sleep 5s
    menu
    ;;
  esac
}
copyright
main
