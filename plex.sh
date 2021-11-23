#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

function rclone_install()
{
	echo "检查Rclone......"
	rclone --version
    if [ $? -eq  0 ]; then
        echo "检查到Rclone已安装!"
    else
        echo -e "\n|   Rclone is installing ... "
        curl https://rclone.org/install.sh | sudo bash
        # 安装fuse 支持
        sudo apt-get install -y fuse
    fi
}

function gclone_install()
{
	echo "检查Gclone......"
	gclone --version
    if [ $? -eq  0 ]; then
        echo "检查到Gclone已安装!"
    else
        echo -e "\n|   Gclone is installing ... "
        bash <(wget -qO- https://raw.githubusercontent.com/07031218/normal-shell/main/gclone.sh)
    fi
}

function docker_install()
{
	echo "检查Docker......"
	docker -v
    if [ $? -eq  0 ]; then
        echo "检查到Docker已安装!"
    else
        # 安装Docker
        echo -e "\n|   Docker is installing ... "
        sudo apt-get update -y
        curl -fsSL get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        rm -f get-docker.sh
    fi
}

function download_res()
{
    echo -e "\n| Resource File Downloading ... "
    sudo mkdir /plex 
    cd /plex
    sudo curl -L https://install.emengweb.com/plex.tar.gz -o /plex/plex.tar.gz
    sudo tar zxvf plex.tar.gz
    rm -f plex.tar.gz
}

clear
echo "+============================================================+"
echo "|               Plex with Nginx&SSL Installer                |"
echo "|                                                            |"
echo "|                                       <emengweb@gmail.com> |"
echo "|------------------------------------------------------------|"
echo "|                                       https://emengweb.com |"
echo "+============================================================+"
echo -e "\n| 此Docker将自动帮您完成Nginx及SSL反带的配置，此后可直接通过https://域名进行访问Plex."
echo ""
# 安装基础组件
echo -e "\n| Basic components is installing ... "
sudo apt-get install -y curl

# 安装Rclone
rclone_install

# 安装Gclone
gclone_install

# 安装Docker
docker_install

# 下载配置资源文件
download_res

# 启动Docker Compose
#echo -e "\n| Docker Compose Starting ... "
#sudo docker-compose up

# 配置完毕
clear
echo "+============================================================+"
echo "|                                                            |"
echo "| 目录配置                                                   |"
echo "|     /plex/conf.d - Nginx虚拟主机配置目录                   |"
echo "|     /plex/config:/config - Plex数据存储目录                |"
echo "|     /plex/transcode:/transcode - 转码预留目录              |"
echo "|     /plex/disk - Rclone请挂载在此目录下，例如gd目录        |"
echo "|                                                            |"
echo "+============================================================+"
echo ""
echo -e "\n| 配置完成."
echo -e "\n| 您还需要完成以下配置："
echo -e "\n| 1、设置域名 DNS 解析到本机IP"
echo -e "\n| 2、修改 '/plex/docker-compose.yml' 文件，确保正确设置'FQDN'-域名及邮箱地址 'CERTBOT_EMAIL'"
echo -e "\n| 3、将Rclone磁盘映射至/plex/disk的子目录下，例如：/plex/disk/gd"
echo -e "\n| 以上准备工作完成后，进入/plex文件夹，输入 'docker-compose up -d' 启动 plex docker 容器，记得先映射至127.0.0.1:32400端口，打开浏览器完成plex的配置。"
echo -e "\n| 此Docker将自动帮您完成Nginx及SSL反带的配置，可直接通过https://域名进行访问Plex."
echo -e "\n| 祝好运."
