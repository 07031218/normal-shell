#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echoType='echo -e'
echoContent() {
  case $1 in
  # 红色
  "red")
    # shellcheck disable=SC2154
    ${echoType} "\033[31m$2\033[0m"
    ;;
    # 绿色
  "green")
    ${echoType} "\033[32m$2\033[0m"
    ;;
    # 黄色
  "yellow")
    ${echoType} "\033[33m$2\033[0m"
    ;;
    # 蓝色
  "blue")
    ${echoType} "\033[34m$2\033[0m"
    ;;
    # 紫色
  "purple")
    ${echoType} "\033[35m$2\033[0m"
    ;;
    # 天蓝色
  "skyBlue")
    ${echoType} "\033[36m$2\033[0m"
    ;;
    # 白色
  "white")
    ${echoType} "\033[37m$2\033[0m"
    ;;
  esac
}
[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1
apt install sudo -y || yum install sudo -y
clear
add_user(){
	echoContent green "请输入要添加用户的用户名⬇️"
	read user
	sudo useradd \
	--system \
	--shell /bin/bash \
	--create-home \
	--home-dir /home/${user} \
	${user}
	echoContent red "请为用户名${user}设置登陆密码⬇️"
	read pass
	echo ${user}:${pass} | chpasswd
	sed -i "/PasswordAuthentication no/c PasswordAuthentication yes" /etc/ssh/sshd_config
	echo "${user}    ALL=(ALL:ALL) ALL" >>/etc/sudoers
	echo "AllowUsers root ${user}" >>/etc/ssh/sshd_config
	service sshd restart
	service ssh restart
	echoContent green "新用户${user}增加成功，现在可通过密码 ${pass} 登陆ssh，脚本执行完毕，即将退出"
	exit 0
}
del_user(){
	echoContent green "请输入要删除的用户名⬇️"
	read user
	userdel -r ${user}
	sed -i "/${user}    ALL=(ALL:ALL) ALL/d" /etc/sudoers
	echoContent yellow "用户${user}已成功删除，脚本退出"
	exit 0
}
menu() {
	echoContent skyBlue "请选择你要执行的功能"
	echoContent red "0.	退出脚本"
	echoContent green "1.	增加用户"
	echoContent green "2.	删除用户" 
  read -p "请输入数字 :" num
  case "$num" in
  0)
    exit 0
    ;;
  1)
    add_user
    ;;
  2)
    del_user
    ;;          
  *)
  clear
    echoContent red "出现错误:请输入正确数字 [0-2]"
    sleep 3s
    clear
    menu
    ;;
  esac
}
menu
