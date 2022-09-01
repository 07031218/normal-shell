#!/bin/bash
# check root
echoType='echo -e'
echoContent(){
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
apt install lsof -y || yum install lsof -y
clear
[[ $EUID -ne 0 ]] && echo -e "${red}错误: $ 必须使用root用户运行此脚本！\n" && exit 1

function check_docker(){
  if test -z "$(which docker)"; then
    echoContent yellow "检测到系统未安装docker，开始安装docker"
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
  fi
  if test -z "$(which docker-compose)"; then
    echoContent yellow "检测到系统未安装docker-compose，开始安装docker-compose"
    curl -L "https://github.com/docker/compose/releases/download/v2.10.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
  fi
}
function install_all(){
  check_docker
  cat >/root/docker-compose.yml<<EOF
version: "3"
services: 
#自动追剧必备
  qbittorrent:
    image: ghcr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    network_mode: "host"
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Shanghai
      - WEBUI_PORT=8088
    volumes:
      - /home/qbittorrent/config:/config
      - /downloads:/downloads
      - /home/qbittorrent/watch:/watch  
    restart: unless-stopped
  nas-tools:
    image: jxxghp/nas-tools:latest
    container_name: nas-tools
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Shanghai
    ports:
      - 3000:3000
    volumes:
      - /home/nastools/config:/config
      - /mnt:/mnt
      - /downloads:/downloads
    restart: always
  jackett:
    image: lscr.io/linuxserver/jackett
    container_name: jackett
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Shanghai
      - AUTO_UPDATE=true 
    volumes:
      - /home/jackett:/config
      - /downloads:/downloads
    ports:
      - 9117:9117
    restart: always
  flaresolverr:
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    environment:
      - LOG_LEVEL=${LOG_LEVEL:-info}
      - LOG_HTML=${LOG_HTML:-false}
      - CAPTCHA_SOLVER=${CAPTCHA_SOLVER:-none}
      - TZ=Asia/Shanghaiœ
    ports:
      - "${PORT:-8191}:8191"
    restart: unless-stopped
  chinesesubfinder:
    container_name: chinesesubfinder
    image: allanpk716/chinesesubfinder:latest
    volumes:
      - /home/chinesesubfinder:/config
      - /mnt:/mnt
      - /home/chinesesubfinder/cache:/app/cache
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Shanghai
    ports:
      - 19035:19035
    restart: unless-stopped
EOF
  echoContent yellow `echo -ne "请问是否安装Emby到本机[y/n]"`
  read embyyn
  if [[ ${embyyn} == "Y" ]]||[[ ${embyyn} == "y" ]]; then
    cat>>/root/docker-compose.yml <<EOF
  emby:
    image: lscr.io/linuxserver/emby
    container_name: emby
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Shanghai
    volumes:
      - /home/emby:/config
      - /mnt:/mnt 
    ports:
      - 8096:8096
      - 8920:8920
    restart: unless-stopped
EOF
  else
    echo
  fi
  docker-compose -f /root/docker-compose.yml up -d
  if [[ $? -eq 0 ]]; then
    echoContent green "一键梭哈安装完毕······"
    # jackett_api_key=`cat /home/jackett/Jackett/ServerConfig.json|sed -n '5p'|awk -F ":" '{print $2}'|sed "s/\"//g"|sed "s/,//g"|sed "s/ //g"`
    # sed -i "221c \  api_key: ${jackett_api_key}" /home/nastools/config/config.yaml
    # echoContent yellow "导入jackket的api_key到nas-tools配置文件完毕"
    # echoContent yellow "开始重启nas-tools容器"
    # docker restart nas-tools
    # echoContent green "重启nas-tools容器完毕，已加载新配置"
    if [[ ${embyyn} == "Y" ]]||[[ ${embyyn} == "y" ]]; then
      echoContent green "qbittorrent端口8088（初始用户名admin，密码adminadmin），nas-tools端口3000（初始用户名admin，密码password），Emby端口8096"
    else
      echoContent green "qbittorrent端口8088（初始用户名admin，密码adminadmin），nas-tools端口3000（初始用户名admin，密码password）"
    fi
  else
    echoContent red "一键梭哈安装失败······"
  fi
  echoContent yellow `echo -ne "请问是否反代Nas-tools[y/n]"`
  read proxyyn
  if [[ ${proxyyn} == "Y" ]]||[[ ${proxyyn} == "y" ]]; then
    insall_proxy
  else
    exit 0
  fi
}
function insall_proxy(){
  echoContent purple  "请选择反代方式：\n1、Cloudflared Tunnel穿透(墙内建议选择此项，域名需要托管在Cloudflare)\n2、Nginx反代"
  read pproxy
  if [[ ${pproxy} == "1" ]]; then
    bash <(curl -sL https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/net/onekey-argo-tunnel.sh)
  elif [[ ${pproxy} == "2" ]]; then
    echoContent yellow "开始安装nginx并准备签发证书，请提前将相应域名的A记录解析到该机器······\n在下面执行步骤中，有询问y或n的地方全部输入y"
    sleep 3s
    bash <(curl -sL https://cdn.jsdelivr.net/gh/07031218/one-key-for-let-s-Encrypt@main/run.sh)
    # echoContent purple  `echo -n -e "是否要对nas-tools进行反代处理,请输入Y/N："`
    # read ppproxy
    # if [[ ${ppproxy} == "Y" ]]||[[ ${ppproxy} == "y" ]]; then
      read -p "请输入前面注册的域名地址,http://" domain && printf "\n"
      sed -i '18,$d' /etc/nginx/conf.d/${domain}.conf
      cat > proxypass.conf << EOF
    #PROXY-START/
    location / {
      proxy_pass http://127.0.0.1:3000;
    }
    #PROXY-END/
    location /.well-known/acme-challenge/ {
            alias /certs/${domain}/certificate/challenges/;
            try_files \$uri =404;
    }
    location /download {
            autoindex on;
            autoindex_exact_size off;
            autoindex_localtime on;
    }
}
EOF
    sed  -i '17r proxypass.conf' /etc/nginx/conf.d/${domain}.conf
    rm proxypass.conf
    service nginx restart
    echoContent green "反代完成，你现在可以通过https://${domain} 来访问nas-tools了"
    # fi
  fi
  if [[ `lsof -i:8096|awk 'NR>1{print $2}'` != "" ]]; then
    echoContent yellow `echo -n -e "检测到该机器安装了Emby-Server，请问是否需要反代Emby[Y/n]:"`
    read pppproxy
    if [[ ${pppproxy} == "Y" ]]||[[ ${pppproxy} == "y" ]]; then
####
      if [[ ${pproxy} == "1" ]]; then
        bash <(curl -sL https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/net/onekey-argo-tunnel.sh)
      elif [[ ${pproxy} == "2" ]]; then
        echoContent yellow "开始安装nginx并准备签发证书，请提前将相应域名的A记录解析到该机器······\n在下面执行步骤中，有询问y或n的地方全部输入y"
        sleep 3s
        bash <(curl -sL https://cdn.jsdelivr.net/gh/07031218/one-key-for-let-s-Encrypt@main/run.sh)
        # echoContent purple  `echo -n -e "是否要对nas-tools进行反代处理,请输入Y/N："`
        # read ppproxy
        # if [[ ${ppproxy} == "Y" ]]||[[ ${ppproxy} == "y" ]]; then
          read -p "请输入前面注册的域名地址,http://" domain && printf "\n"
          sed -i '18,$d' /etc/nginx/conf.d/${domain}.conf
          cat > proxypass.conf << EOF
  #PROXY-START/
      location  ~* \.(php|jsp|cgi|asp|aspx)\$
      {
          proxy_pass http://127.0.0.1:8096;
          proxy_set_header Host \$host;
          proxy_set_header X-Real-IP \$remote_addr;
          proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
          proxy_set_header REMOTE-HOST \$remote_addr;
      }
      location / {
          proxy_pass http://127.0.0.1:8096;
          proxy_set_header Host \$host;
          proxy_set_header X-Real-IP \$remote_addr;
          #proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
          proxy_set_header REMOTE-HOST \$remote_addr;
           
          # Plex start
          # 解决视频预览进度条无法拖动的问题
          proxy_set_header Range \$http_range;
          proxy_set_header If-Range \$http_if_range;
          proxy_no_cache \$http_range \$http_if_range;
          
          # 反带流式，不进行缓冲
          client_max_body_size 0;
          proxy_http_version 1.1;
          proxy_request_buffering off;
          #proxy_ignore_client_abort on;
          
          # 同时反带WebSocket协议
          proxy_set_header X-Forwarded-For \$remote_addr:\$remote_port;
          proxy_set_header Upgrade \$http_upgrade;
          proxy_set_header Connection upgrade; 
          
          gzip off;
          # Plex end
          
          add_header X-Cache \$upstream_cache_status;
          
                  
          #Set Nginx Cache
          add_header Cache-Control no-cache;
          expires 12h;
      }
       
      #PROXY-END/
      location /.well-known/acme-challenge/ {
              alias /certs/${domain}/certificate/challenges/;
              try_files \$uri =404;
      }
    location /download {
            autoindex on;
            autoindex_exact_size off;
            autoindex_localtime on;
    }
  }
EOF
        sed  -i '17r proxypass.conf' /etc/nginx/conf.d/${domain}.conf
        rm proxypass.conf
        service nginx restart
        echoContent green "反代完成，你现在可以通过https://${domain} 来访问Emby-server了"
        # fi
      fi
####
    fi
  fi
  
}

function menu(){
    echoContent green "
###########################################################
#                                                         #
#           Nas-tools 一键梭哈脚本                        #
#                    Powerby 翔翎                         #
#                    Blog：https://blog.20120714.xyz      #
#                                                         #
###########################################################"
}
menu
echoContent red "请注意：不建议内存低于2GB的设备执行安装"
echo
echoContent yellow `echo -ne "输入[Y/y]开始安装，Ctrl+C退出脚本"`
read yn
if [[ ${yn} == "Y" ]]||[[ ${yn} == "y" ]]; then
  install_all
fi
