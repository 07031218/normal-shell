#/usr/bin/env bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
# check root
#[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1
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
checkCPU
check_dependencies
${InstallMethod} install sudo -y > /dev/null 2>&1 
#安装cloudflared tunnel
install_cloudflared(){
  echo -e "${red}如果你当前是非root用户，请确认已经将当前用户加sudo执行权限，否则脚本将会出错。${plain}"
  echo -n -e "${yellow}如需继续，请输入Y，否则输入N或者n，是否需要继续<Y/n>：${plain}"
  read ct
  if [[ $ct == "" ]]||[[ $ct == "n" ]]||[[ $ct == "N" ]]; then
    echo -e "${red}程序退出···${plain}"
    exit 0
  fi
file1="/usr/bin/cloudflared"
#安装wget supervisor
sudo ${InstallMethod} install  wget  supervisor -y > /dev/null 2>&1 
#开始拉取cloudflared tunnel
if [ ! -f "$file1" ]; then
wget  "https://ghproxy.com/https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-${arch}" -O cloudflared
chmod +x cloudflared && cp cloudflared /usr/bin
fi
file="./.cloudflared/cert.pem"
if [ ! -f "$file" ]; then
echo -e "${green}请点击或者复制下方生成的授权链接，进入CF管理面板进行授权操作。${plain}"
cloudflared login
echo -e "${green}授权完成，请按照指令提示继续${plain}"
fi
  read -p "请输入需要创建的隧道名称：" tunnel_name
  cloudflared tunnel create ${tunnel_name}
  read -p "请输入域名：" tunnel_domain
  cloudflared tunnel route dns ${tunnel_name} ${tunnel_domain}
  cloudflared tunnel list
  tunel_uuid=`cloudflared tunnel list|grep ${tunnel_name}|awk -F " " '{print $1}'`
  read -p "请输入传输协议[如不填写默认http]：" tunnel_protocol
  [[ -z ${tunnel_protocol} ]] && tunnel_protocol="http"
  read -p "请输入需要反代的服务端口[如不填写默认80]：" tunnel_port
  [[ -z ${tunnel_port} ]] && tunnel_port="80"
  read -p "请输入supervisor值守的任务名称: " taskname
sudo bash -c 'cat > ~/'${tunnel_name}.yml' <<EOF
tunnel: '${tunnel_name}'
credentials-file: ~/.cloudflared/'${tunel_uuid}'.json
originRequest:
  connectTimeout: 30s
  noTLSVerify: true
ingress:
  - hostname: '${tunnel_domain}'
    service: '${tunnel_protocol}'://localhost:'${tunnel_port}'
  - service: http_status:404
EOF'

sudo bash -c 'cat >> /etc/supervisor/conf.d/'${tunnel_name}.conf' << EOF
[program:'${taskname}']

command=cloudflared tunnel --config /home/'`whoami`'/'${tunnel_name}'.yml run

autorestart=true
startsecs=10
startretries=36
redirect_stderr=true

user='$(whoami)' ; setuid to this UNIX account to run the program
log_stdout=true ; if true, log program stdout (default true)
log_stderr=true ; if true, log program stderr (def false)
logfile=/var/log/'${taskname}'.log ; child log path, use NONE for none; default AUTO
EOF'

sudo /etc/init.d/supervisor restart > /dev/null
echo -e "${green}cloudflared tunnel部署完成，脚本退出·········${plain}"
echo -e "${green}你现在可以通过http://${tunnel_domain}来访问本服务器穿透过的web服务了·········${plain}"
exit 0
}
update_supervisor(){
read -p "请输入supervisor Web服务的用户名: " username && printf "\n"
read -p "请输入supervisor Web服务的用户密码：" passwd && printf "\n"

sudo bash -c 'cat > /etc/supervisor/supervisord.conf << EOF

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
username='${username}'              ; should be same as http_username if set
password='${passwd}'              ; should be same as http_password if set
prompt=mysupervisor         ; cmd line prompt (default "supervisor")

[inet_http_server] 
port=0.0.0.0:9001
username='${username}'      
password='${passwd}'

[include]
files = /etc/supervisor/conf.d/*.conf

EOF'
/etc/init.d/supervisor restart > /dev/null
baseip=$(curl -s ipip.ooo) > /dev/null
echo -e "${green}supervisor已设置完成，后续可通过http://${baseip}:9001 来进行进程守护${plain}（${red}重启、停止、启动、日志查看${plain}）${green}管理·········${plain}"
}

uninstall_cloudflared(){
cloudflared tunnel list
echo -e "${green}以上为当前本机已存在的cloudflared tunnel隧道列表清单${plain}"
read -p "请输入需要删除的隧道名称：" tunnel_name
if [[ ${tunnel_name} != "" ]];then
  cloudflared tunnel delete ${tunnel_name}
  echo -e "${green}名为${tunnel_name}的cloudflared tunnel隧道配置已成功删除·········${plain}"
else
 echo
fi
echo -e "${yellow}开始清理准备清理隧道对应的supervisor配置文件，请根据提示操作······${plain}"
i=1
list=()
if [[ ! -d /etc/supervisor/conf.d ]]; then
  echo  "错误，未在本机器上找到supervisor的相关conf配置文件"
  exit 1
elif [[ -d /etc/supervisor/conf.d ]];then
  items=$(ls /etc/supervisor/conf.d/ -l|awk 'NR>1{print $9}')
fi
for item in $items
do
        list[i]=${item}
        i=$((i+1))
done
while [[ 0 ]]
do
        while [[ 0 ]]
        do
                echo
                echo -e "${green}本地supervisor配置列表清单:${plain}"
                # echo
        echo -e "${green}-------------------------------${plain}"
                for((j=1;j<=${#list[@]};j++))
                do
        temp="${j}：${list[j]}"
        count=$((`echo "${temp}" | wc -m` -1))
        if [ "${count}" -le 6 ];then
            temp="${temp}\t\t\t"
        elif [ "${count}" -gt 6 ] && [ "$count" -le 14 ];then
            temp="${temp}\t\t"
        elif [ "${count}" -gt 14 ];then
            temp="${temp}"
        fi
                        echo -e "${green}${temp}"
                        echo -e "${green}-------------------------------${plain}"
                done
                echo
                read -n3 -p "请选择要删除的supervisor启动服务（输入数字即可）如上述配置清单中不包含cloudflared tunnel隧道，请输入数字99退出选择：" supervisor_config_name
                if [[ ${supervisor_config_name} -eq 0 ]]; then
                  echo
                  echo -e "${red}输入不正确，请重新输入。${plain}"
                elif [[ ${supervisor_config_name} == "99" ]];then
                  exit 0
                elif [ ${supervisor_config_name} -le ${#list[@]} ] && [ -n ${supervisor_config_name} ];then
                        echo
                        echo -e "${green}您选择了：${list[supervisor_config_name]}${plain}"
                break

                else
                echo
                echo -e "${red}输入不正确，请重新输入。${plain}"
                echo
                fi
        done
        break
done
sudo rm /etc/nginx/conf.d/${list[nginx_config_name]}
sudo /etc/init.d/supervisor restart > /dev/null
sleep  3s
copyright
menu

}
copyright(){
    clear
echo -e "
—————————————————————————————————————————————————————————————
        cloudflared tunnel一键部署脚本
 ${green}
        本脚本仅适合域名已经托管在cloudflare的用户使用

        Powered  by 翔翎
${plain}
—————————————————————————————————————————————————————————————
"
}
menu() {
  echo -e "\
${red}0.${plain} 退出脚本
${green}1.${plain} 部署cloudflared tunnel
${green}2.${plain} 删除指定的cloudflared tunnel穿透任务
${green}3.${plain} 开启cloudflared tunnel进程守护
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
