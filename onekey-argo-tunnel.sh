#/usr/bin/env bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
# check root
[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1
clear
checkCPU(){
  CPUArch=$(uname -m)
  if [[ "$CPUArch" == "aarch64" ]];then
    arch=linux-arm64
  elif [[ "$CPUArch" == "i686" ]];then
    arch=linux-386
  elif [[ "$CPUArch" == "arm" ]];then
    arch=linux-arm
  elif [[ "$CPUArch" == "x86_64" ]] && [ -n "$ifMacOS" ];then
    arch=darwin-amd64
  elif [[ "$CPUArch" == "x86_64" ]];then
    arch=linux-amd64
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
quit(){
exit 0
}
#安装argo tunnel
install_cloudflared(){
checkCPU
check_dependencies
file1="/usr/bin/cloudflared"
#安装wget supervisor
${InstallMethod} install  wget  supervisor -y > /dev/null 2>&1 
#开始拉取argo tunnel
if [ ! -f "$file1" ]; then
wget  "https://ghproxy.com/https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-${arch}" -O cloudflared
chmod +x cloudflared && cp cloudflared /usr/bin
fi
file="/root/.cloudflared/cert.pem"
if [ ! -f "$file" ]; then
echo -e "${green}请点击或者复制下方生成的授权链接，进入CF管理面板进行授权操作。${plain}"
cloudflared login
echo -e "${green}授权完成，请按照指令提示继续${plain}"
fi
read -p "请输入计划启用argo tunnel穿透的域名(不需要输入http://): " httpurl && printf "\n"
read -p "请输入本地web服务的url地址（需要带http://）: " localurl && printf "\n"
read -p "请输入supervisor值守的任务名称: " taskname && printf "\n"
read -p "请输入supervisor将要值守的conf文件名，后缀需要为.conf 如argo.conf :" filename && printf "\n"

cat >> /etc/supervisor/conf.d/${filename} << EOF
[program:${taskname}]

command=cloudflared tunnel --hostname  ${httpurl} --url ${localurl} --no-tls-verify

autorestart=true
startsecs=10
startretries=36
redirect_stderr=true

user=root ; setuid to this UNIX account to run the program
log_stdout=true ; if true, log program stdout (default true)
log_stderr=true ; if true, log program stderr (def false)
logfile=/var/log/jindou cf-tunnel.log ; child log path, use NONE for none; default AUTO
EOF

/etc/init.d/supervisor restart > /dev/null
echo -e "${green}argo tunnel部署完成，脚本退出·········${plain}"
echo -e "${green}你现在可以通过http://${httpurl}来访问本服务器穿透过的web服务了·········${plain}"
exit 0
}
update_supervisor(){
read -p "请输入supervisor Web服务的用户名: " username && printf "\n"
read -p "请输入supervisor Web服务的用户密码：" passwd && printf "\n"

cat > /etc/supervisor/supervisord.conf << EOF

[supervisord]
http_port=127.0.0.1:9001  ; (alternately, ip_address:port specifies AF_INET)
logfile=/var/log/supervisor/supervisord.log ; (main log file;default $CWD/supervisord.log)
logfile_maxbytes=50MB       ; (max main logfile bytes b4 rotation;default 50MB)
logfile_backups=10          ; (num of main logfile rotation backups;default 10)
loglevel=info               ; (logging level;default info; others: debug,warn)
pidfile=/var/run/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
nodaemon=false              ; (start in foreground if true;default false)
minfds=1024                 ; (min. avail startup file descriptors;default 1024)
minprocs=200                ; (min. avail process descriptors;default 200)

[supervisorctl]
serverurl=http://127.0.0.1:9001 ; use an http:// url to specify an inet socket
username=${username}              ; should be same as http_username if set
password=${passwd}              ; should be same as http_password if set
prompt=mysupervisor         ; cmd line prompt (default "supervisor")

[inet_http_server] 
port=0.0.0.0:9001
username=${username}      
password=${passwd}

[include]
files = /etc/supervisor/conf.d/*.conf

EOF
/etc/init.d/supervisor restart > /dev/null
baseip=$(curl -s ipip.ooo) > /dev/null
echo -e "${green}supervisor已设置完成，后续可通过http://${baseip}:9001 来进行进程守护${plain}（${red}重启、停止、启动、日志查看${plain}）${green}管理·········${plain}"
}

uninstall_cloudflared(){
read -p "请输入要删除的argo穿透任务对应的conf配置文件名，文件位于/etc/supervisor/conf.d目录下 :" filename && printf "\n"
rm /etc/supervisor/conf.d/${filename}
/etc/init.d/supervisor restart > /dev/null
echo -e "${green}指定的argo穿透任务已成功删除·········${plain}"
sleep  3s
copyright
menu

}
copyright(){
    clear
echo -e "
—————————————————————————————————————————————————————————————
        argo tunnel一键部署脚本
 ${green}
        本脚本仅适合域名已经托管在cloudflare的用户使用

        Powered  by 翔翎
${plain}
—————————————————————————————————————————————————————————————
"
}
menu() {
  echo -e "\
${green}0.${plain} 退出脚本
${green}1.${plain} 部署argo tunnel
${green}2.${plain} 删除指定的argo穿透任务
${green}3.${plain} 开启Argo Tunnel进程守护
"

  read -p "请输入数字 :" num
  case "$num" in
  0)
    quit
    ;;
  1)
    install_cloudflared
    ;;
  2)
    uninstall_cloudflared
    ;;
  3)
    update_supervisor
    ;;	
  *)
  clear
    echo -e "错误:请输入正确数字 [0-3]"
    sleep 3s
    copyright
    menu
    ;;
  esac
}

copyright

menu
