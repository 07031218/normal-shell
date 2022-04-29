#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
White='\033[37m'
blue='\033[36m'
yellow='\033[0;33m'
plain='\033[0m'
databasefile_dir="/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases/"
plexdir1="/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Cache"
plexdir2="/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Metadata"
plexdir3="/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Media"
plexdir="/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/"
# curr_date=`date +%Y-%m-%d`
backup_plex(){
	service plexmediaserver stop
	cd $databasefile_dir
	tar -czvf /root/plexdatabase.tar.gz ./com.plexapp.plugins.library.db
	cd $plexdir
	tar -czvPf /root/plex-xuegua.tar.gz -C ./Metadata ./Cache ./Media
	service plexmediaserver start
}
restore_config(){
	service plexmediaserver stop
	cd $databasefile_dir
	rsync -avzuP /nongjiale/plexdatabase.tar.gz ./
	tar -xzvf plexdatabase.tar.gz
	cd $plexdir
	rsync -avzuP /nongjiale/plex-xuegua.tar.gz ./
	tar -xzvf plex-xuegua.tar.gz
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
	    quit
	    ;;
	  1)
	    install_ql
	    ;;
	  2)
	    install_depend
	    ;;
	  *)
		clear
        echo -e "${red}出现错误:请输入正确数字 [0-2]${plain}"	
     	sleep 3s
		menu
		;;
  esac
}
menu
