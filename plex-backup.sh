#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
White='\033[37m'
blue='\033[36m'
yellow='\033[0;33m'
plain='\033[0m'

bakdir="nongjiale:plex" # 此处填写rclone对应的GD路径，比如rclone config中GD的配置名是gd，保存到GD的plex目录下，则填写gd:plex
DEL_DAY=7 # 备份文件保存的天数

databasefile_dir='/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases/'
# plexdir1='/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Cache'
# plexdir2='/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Metadata'
# plexdir3='/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Media'
plexdir='/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/'
# curr_date=`date +%Y-%m-%d`
targz(){
    if [[ `which pv` == "" ]]; then
        apt install pv -y || yum install pv -y
    fi
    if [[ $1 = '' ]]; then
        echo "参数缺失，用法 'targz 压缩名 文件名/目录名'"
        exit 1
    fi

    tar -cf - $4 $3 $2  | pv -s $(du -sk $2 | awk '{print $1}') | gzip > $1
}
backup_plex(){
	service plexmediaserver stop
	cd "$databasefile_dir"
	echo -e "${yellow}❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️${plain}"
	echo -e "${White}开始打包plex削刮数据库${plain}"
	echo -e "${yellow}❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️${plain}"
	targz /root/plex-bak/plexdatabase.tar.gz ./com.plexapp.plugins.library.db
	echo -e "${yellow}❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️${plain}"
	echo -e "${White}plex削刮数据库打包完成,开始打包plex削刮缓存目录${plain}"
	echo -e "${yellow}❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️${plain}"
	# tar -czf /root/plex-bak/plexdatabase.tar.gz ./com.plexapp.plugins.library.db
	cd "$plexdir"
	targz /root/plex-bak/plex-xuegua.tar.gz  ./Metadata ./Cache ./Media
	echo -e "${yellow}❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️${plain}"
	echo -e "${White}打包plex削刮缓存目录完成，开始同步plex削刮数据库和削刮缓存到谷歌盘${plain}"
	echo -e "${yellow}❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️${plain}"
	service plexmediaserver start
	rclone copy -P /root/plex-bak/ $bakdir/$(date +%Y%m%d)
	echo -e "${yellow}❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️${plain}"
	echo -e "${White}同步plex削刮数据库和削刮缓存到谷歌盘完成，开始检查清理超${DEL_DAY}天的备份文件${plain}"
	echo -e "${yellow}❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️❄️${plain}"
	rm /root/plex-bak/plexdatabase.tar.gz /root/plex-bak/plex-xuegua.tar.gz
	# 遍历备份目录下的日期目录
	LIST=$(rclone lsd $bakdir/)
	# 获取7天前的时间，用于作比较，早于该时间的文件将删除
	SECONDS=$(date -d  "$(date  +%F) -${DEL_DAY} days" +%s)
	for index in ${LIST}
	do
	    # 对目录名进行格式化，取命名末尾的时间，格式如 20200902
	    timeString=$(echo ${index} | egrep -o "?[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]")
	    if [ -n "$timeString" ]
	    then
	        indexDate=${timeString//./-}
	        indexSecond=$( date -d ${indexDate} +%s )
	        # 与当天的时间做对比，把早于7天的备份文件删除
	        if [ $(( $SECONDS- $indexSecond )) -gt 0 ]
	        then
	            rclone rmdir $bakdir/$index
	        fi
	    fi
	done
	echo -e "${White}清理超${DEL_DAY}天的备份文件，程序退出${plain}"
}
restore_config(){
	service plexmediaserver stop
	read -p "请输入要还原的数据的备份日期[yyyymmdd]：" bakdate
	cd "$databasefile_dir"
	rclone copy -P $bakdir/${bakdate}/plexdatabase.tar.gz ./
	tar -xzvf plexdatabase.tar.gz && rm plexdatabase.tar.gz
	cd "$plexdir"
	rclone copy -P $bakdir/${bakdate}/plex-xuegua.tar.gz ./
	tar -xzvf plex-xuegua.tar.gz && rm plex-xuegua.tar.gz
	service plexmediaserver start
	echo "还原备份数据完成	，程序退出······"
	exit 0
}
menu(){
	echo -e "
${green}###########################################################${plain}
${green}#                                                         #${plain}
${green}#        Plex削刮包、数据库一键备份&还原脚本              #${plain}
${green}#        Powered  by 翔翎                                 #${plain}
${green}#                                                         #${plain}
${green}###########################################################${plain}"
echo -e "
${red}0.${plain}  退出脚本
${green}———————————————————————————————————————————————————————————${plain}
${green}1.${plain}  一键备份Plex削刮包、数据库
${green}2.${plain}  一键还原Plex削刮包、数据库
"
	read -p "请输入你要选择的功能：" num
	case "$num" in
	  0)
	    exit 0
	    ;;
	  1)
	    backup_plex
	    ;;
	  2)
	    restore_config
	    ;;
	  *)
		clear
        echo -e "${red}出现错误:请输入正确数字 [0-2]${plain}"	
     	sleep 3s
		menu
		;;
  esac
}
if [[ $1 == "b" ]]; then
	# 可通过命令 bash plexback.sh b 实现一键备份
	backup_plex
else
	menu
fi
