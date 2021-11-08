#/usr/bin/env bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
# check root
[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1
clear
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
    InstallMethod="apt"
  elif [ -n "$if_redhat" ] && [[ "$os_version" -lt 8 ]];then
    InstallMethod="yum"
  elif [[ "$os_version" == "MacOS" ]];then
    InstallMethod="brew"  
  fi
}
check_dependencies
#安装wget、curl、unzip
${InstallMethod} install unzip wget curl git -y > /dev/null 2>&1 
#判断机器是否安装docker
if test -z "$(which docker)"; then
echo -e "检测到系统未安装docker，开始安装docker"
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun > /dev/null 2>&1 
    curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
fi


install_cqhttp(){
	mkdir cqhttp && cd /root/cqhttp && wget  "https://ghproxy.com/https://github.com/Mrs4s/go-cqhttp/releases/latest/download/go-cqhttp_1.0.0-beta7-fix2_${arch}" -O /root/cqhttp/go-cqhttp > /dev/null 2>&1 
	chmod +x /root/cqhttp/go-cqhttp
cat >> /root/cqhttp/config.yml << EOF
	# go-cqhttp 默认配置文件

account: # 账号相关
  uin: 
  password: '' # 密码为空时使用扫码登录
  encrypt: false  # 是否开启密码加密
  status: 0      # 在线状态 请参考 https://docs.go-cqhttp.org/guide/config.html#在线状态
  relogin: # 重连设置
    delay: 3   # 首次重连延迟, 单位秒
    interval: 3   # 重连间隔
    max-times: 0  # 最大重连次数, 0为无限制

  # 是否使用服务器下发的新地址进行重连
  # 注意, 此设置可能导致在海外服务器上连接情况更差
  use-sso-address: true

heartbeat:
  # 心跳频率, 单位秒
  # -1 为关闭心跳
  interval: 5

message:
  # 上报数据类型
  # 可选: string,array
  post-format: string
  # 是否忽略无效的CQ码, 如果为假将原样发送
  ignore-invalid-cqcode: false
  # 是否强制分片发送消息
  # 分片发送将会带来更快的速度
  # 但是兼容性会有些问题
  force-fragment: false
  # 是否将url分片发送
  fix-url: false
  # 下载图片等请求网络代理
  proxy-rewrite: ''
  # 是否上报自身消息
  report-self-message: false
  # 移除服务端的Reply附带的At
  remove-reply-at: false
  # 为Reply附加更多信息
  extra-reply-data: false
  # 跳过 Mime 扫描, 忽略错误数据
  skip-mime-scan: false

output:
  # 日志等级 trace,debug,info,warn,error
  log-level: warn
  # 日志时效 单位天. 超过这个时间之前的日志将会被自动删除. 设置为 0 表示永久保留.
  log-aging: 15
  # 是否在每次启动时强制创建全新的文件储存日志. 为 false 的情况下将会在上次启动时创建的日志文件续写
  log-force-new: true
  # 是否启用 DEBUG
  debug: false # 开启调试模式

# 默认中间件锚点
default-middlewares: &default
  # 访问密钥, 强烈推荐在公网的服务器设置
  access-token: ''
  # 事件过滤器文件目录
  filter: ''
  # API限速设置
  # 该设置为全局生效
  # 原 cqhttp 虽然启用了 rate_limit 后缀, 但是基本没插件适配
  # 目前该限速设置为令牌桶算法, 请参考:
  # https://baike.baidu.com/item/%E4%BB%A4%E7%89%8C%E6%A1%B6%E7%AE%97%E6%B3%95/6597000?fr=aladdin
  rate-limit:
    enabled: false # 是否启用限速
    frequency: 1  # 令牌回复频率, 单位秒
    bucket: 1     # 令牌桶大小

database: # 数据库相关设置
  leveldb:
    # 是否启用内置leveldb数据库
    # 启用将会增加10-20MB的内存占用和一定的磁盘空间
    # 关闭将无法使用 撤回 回复 get_msg 等上下文相关功能
    enable: true

# 连接服务列表
servers:
  # 添加方式，同一连接方式可添加多个，具体配置说明请查看文档
  #- http: # http 通信
  #- ws:   # 正向 Websocket
  #- ws-reverse: # 反向 Websocket
  #- pprof: #性能分析服务器
  # HTTP 通信设置
  - http:
      # 服务端监听地址
      host: 0.0.0.0
      # 服务端监听端口
      port: 8000
      # 反向HTTP超时时间, 单位秒
      # 最小值为5，小于5将会忽略本项设置
      timeout: 5
      # 长轮询拓展
      long-polling:
        # 是否开启
        enabled: false
        # 消息队列大小，0 表示不限制队列大小，谨慎使用
        max-queue-size: 2000
      middlewares:
        <<: *default # 引用默认中间件
      # 反向HTTP POST地址列表
      post:
      #- url: '' # 地址
      #  secret: ''           # 密钥
      #- url: 127.0.0.1:5701 # 地址
      #  secret: ''          # 密钥
  # 正向WS设置
  - ws:
      # 正向WS服务器监听地址
      host: 0.0.0.0
      # 正向WS服务器监听端口
      port: 8001
      middlewares:
        <<: *default # 引用默认中间件
EOF
	ehco -e "${green}cqhttp基础文件配置完毕，脚本退出${plain}"
	ehco -e "${red}请手动执行一次./go-cqhttp来绑定QQ机器人${plain}"
	exit 0
}
install_qqbot(){
	mkdir /root/qqbot && cd /root/qqbot
	baseip=$(curl -s ipip.ooo)  > /dev/null
	red -p "请输入计划启用的qqbot管理端口" qqbotport && printf "\n"
cat > /root/qqbot/docker-compose.yml << EOF
version: '3'
services:
  qqbot:
    image: asupc/qqbot
    restart: always
    privileged: true
    container_name: qqbot
    ports:
      - ${qqbotport}:5010
    volumes:
      - /root/qqbot/config:/app/linux-x64/config
      - /root/qqbot/db:/app/linux-x64/db
      - /root/qqbot/logs:/app/linux-x64/logs
      - /root/qqbot/scripts:/app/linux-x64/scripts
EOF
docker-compose up -d
ehco -e "${green}qqbot安装完毕，面板访问地址：http://${baseip}:${qqbotport}${plain}"
	exit 0
}

update_qqbot(){
	cd /root/qqbot/
	portinfo=$(docker port qqbot | head -1  | sed 's/ //g' | sed 's/5010\/tcp->0.0.0.0://g')
	docker-compose down
	docker pull asupc/qqbot:latest
	docker-compose up -d
	ehco -e "${green}更新完毕，面板访问地址：http://${baseip}:${portinfo}${plain}"
	exit 0
}
uninstall_qqbot(){
	cd /root/qqbot/
	docker-compose down
	rm -rf /root/qqbot/
	ehco -e "${green}qqbot卸载完毕，脚本退出${plain}"
	exit 0
}
uninstall_cqhttp(){
	kill -9 $( ps -e|grep go-cqhttp |awk '{print $1}') 
	rm -rf /root/cqhttp/
}
quit(){
exit
}
copyright(){
    clear
echo -e "
—————————————————————————————————————————————————————————————
        cq-http && qqbot 一键安装脚本                         
 ${green}                
        脚本托管地址：https://git.io/JP7D5
        Powered  by 翔翎   
        京豆羊毛脚本仓库监控频道：${plain}${red}https://t.me/farmercoin${plain}   
—————————————————————————————————————————————————————————————
"
}
menu() {
  echo -e "\
${green}0.${plain} 退出脚本
${green}1.${plain} 安装cq-http
${green}2.${plain} 安装qqbot
${green}3.${plain} 更新qqbot
${green}4.${plain} 卸载qqbot
${green}5.${plain} 卸载cq-http
"
get_system_info
echo -e "当前系统信息: ${Font_color_suffix}$opsy ${Green_font_prefix}$virtual${Font_color_suffix} $arch ${Green_font_prefix}$kern${Font_color_suffix}
"

  read -p "请输入数字 :" num
  case "$num" in
  0)
    quit
    ;;
  1)
    install_cqhttp
    ;;
  2)
    install_qqbot
    ;;
  3)
    update_qqbot
    ;;
  4)
    uninstall_qqbot
    ;;  
  5)
    uninstall_cqhttp
    ;;
  *)
  clear
    echo -e "${Error}:请输入正确数字 [0-5]"
    sleep 3s
    menu
    ;;
  esac
}

copyright

menu
