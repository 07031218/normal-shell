#/usr/bin/env bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

echo -e "${red}开始进行安装,请根据命令提示操作${plain}"
# globals
CWD=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
[ -e "${CWD}/scripts/globals" ] && . ${CWD}/scripts/globals

# import functions
[ -e "/lib/lsb/init-functions" ] && . /lib/lsb/init-functions
[ -e "${CWD}/scripts/functions" ] && . ${CWD}/scripts/functions

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
${InstallMethod} install unzip wget curl -y > /dev/null 2>&1 

mkdir nvjdc && cd nvjdc 
mkdir -p  .local-chromium/Linux-884014 && cd .local-chromium/Linux-884014
wget https://mirrors.huaweicloud.com/chromium-browser-snapshots/Linux_x64/884014/chrome-linux.zip > /dev/null 2>&1 
unzip chrome-linux.zip > /dev/null 2>&1 
rm  -f chrome-linux.zip > /dev/null 2>&1 

cd .. && cd ..
read -p "请输入青龙服务器在web页面中显示的名称: " QLName && printf "\n"
read -p "请输入青龙OpenApi Client ID: " ClientID && printf "\n"
read -p "请输入青龙OpenApi Client Secret: " ClientSecret && printf "\n"
read -p "请输入青龙服务器的url地址（类似http://192.168.2.2:5700）: " QLurl && printf "\n"
cat >> Config.json << EOF
{
  ///最大支持几个网页
  "MaxTab": "4",
  //网站标题
  "Title": "NolanJDCloud",
  //网站公告
  "Announcement": "本项目脚本收集于互联网，为了您的财产安全，请关闭京东免密支付。",
  ///多青龙配置
  "Config": [
    {
      //序号必须从1开始
      "QLkey": 1,
      //服务器名称
      "QLName": "${QLName}",
      //青龙url
      "QLurl": "${QLurl}",
      //青龙2,9 OpenApi Client ID
      "QL_CLIENTID": "${ClientID}",
      //青龙2,9 OpenApi Client Secret
      "QL_SECRET": "${ClientSecret}",
      //青龙面包最大ck容量
      "QL_CAPACITY": 45,
      //消息推送二维码
      "QRurl":""
    }
  ]

}
EOF
#判断机器是否安装docker
if test -z "$(which docker)"; then
echo -e "检测到系统未安装docker，开始安装docker"
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun > /dev/null 2>&1 
    curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
fi

#拉取nvjdc镜像
log_action_begin_msg "开始拉取nvjdc镜像文件"
docker pull nolanhzy/nvjdc:0.3   > /dev/null
log_action_end_msg $?

#创建并启动nvjdc容器
log_action_begin_msg "开始创建nvjdc容器"
docker run   --name nvjdc -p 5788:80 -d  -v  "$(pwd)"/Config.json:/app/Config/Config.json:ro \
-v "$(pwd)"/.local-chromium:/app/.local-chromium  \
-it --privileged=true  nolanhzy/nvjdc:0.3 

log_action_end_msg $?
baseip=$(curl -s ipip.ooo)  > /dev/null

echo -e "${green}安装完毕,面板访问地址：http://${baseip}:5788${plain}"
