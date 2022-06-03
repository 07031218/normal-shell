#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
red='\033[0;31m'
green='\033[0;32m'
White='\033[37m'
blue='\033[36m'
yellow='\033[0;33m'
plain='\033[0m'
echoType='echo -e'
DATE=`date +%Y%m%d`
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
# echoContent skyBlue "请输入Emby系统文件夹路径,留空则默认为/opt/emby-server/"
sys_dir=/opt/emby-server/
# echoContent skyBlue "请输入Emby配置文件夹路径,留空则默认为/var/lib"
config_dir=/var/lib/
backup_emby(){
    echoContent skyBlue "请输入备份文件的存放路径⬇"
    read backto_dir
    mkdir -p $backto_dir/$DATE
    echoContent skyBlue "请输入Emby削刮库的目录路径，留空则默认为/var/lib/emby/programdata/"
    read xuegua_dir
    if [[ ${xuegua_dir} == "" ]]; then
        xuegua_dir=/var/lib/emby/programdata/
        systemctl stop emby-server
    else
        systemctl stop emby-server
        cd $xuegua_dir
        tar -czvf ${backto_dir}/${DATE}/Emby削刮包.tar.gz ./
        if [[ "$?" -eq 0 ]]; then
            clear
            echoContent green "Emby削刮包备份完成"
            sleep 5s
        else
            echoContent red "Emby削刮包备份失败"
            systemctl start emby-server
            exit 1
        fi
    fi
    cd $sys_dir
    tar -czvf ${backto_dir}/${DATE}/Emby-server数据库.tar.gz ./
    if [[ "$?" -eq 0 ]]; then
        clear
        echoContent green "Emby-server数据库备份完成"
        sleep 5s
    else
        echoContent red "Emby-server数据库备份失败"
        systemctl start emby-server
        exit 1
    fi
    cd $config_dir
    tar -czvf ${backto_dir}/${DATE}/Emby-VarLibEmby数据库.tar.gz ./emby/
    if [[ "$?" -eq 0 ]]; then
        clear
        echoContent green "Emby-VarLibEmby数据库备份完成"
    else
        echoContent red "Emby-VarLibEmby数据库备份失败"
        systemctl start emby-server
        exit 1
    fi
    echoContent yellow "恭喜，所有备份均已完成。"
    systemctl start emby-server
}
restore_emby(){
    echoContent skyBlue "请输入Emby削刮库的目录路径，留空则默认为/var/lib/emby/programdata/"
    read xuegua_dir
    if [[ ${xuegua_dir} == "" ]]; then
        xuegua_dir=/var/lib/emby/programdata/
    fi
    echoContent yellow "请输入备份文件所在的路径⬇"
    read backto_dir
    echoContent red "请确认如下目录无误再继续操作\n1、系统文件夹路径：/opt/emby-server/system\n2、配置文件夹路径：/var/lib/emby\n是否继续？[Y/N]"
    read yn
    if [[ $yn != "Y" ]] && [[ $yn != "y" ]]; then
        exit 0
    fi
    systemctl stop emby-server
    if [[ ${xuegua_dir} != "/var/lib/emby/programdata/" ]]; then
        tar -xzvf ${backto_dir}/Emby削刮包.tar.gz -C $xuegua_dir
        if [[ "$?" -eq 0 ]]; then
            clear
            echoContent green "Emby削刮包恢复完成"
            sleep 5s
        else
            echoContent red "Emby削刮包恢复失败"
            systemctl start emby-server
            exit 1
        fi
    fi
    tar -xzvf ${backto_dir}/Emby-server数据库.tar.gz -C $sys_dir
    if [[ "$?" -eq 0 ]]; then
        clear
        echoContent green "Emby-server数据库恢复完成"
        sleep 5s
    else
        echoContent red "Emby-server数据库恢复失败"
        systemctl start emby-server
        exit 1
    fi
    tar -xzvf ${backto_dir}/Emby-VarLibEmby数据库.tar.gz -C $config_dir
    if [[ "$?" -eq 0 ]]; then
        echoContent green "Emby-VarLibEmby数据库恢复完成"
    else
        echoContent red "Emby-VarLibEmby数据库恢复失败"
        systemctl start emby-server
        exit 1
    fi
    echoContent yellow "恭喜，所有恢复均已完成。"
    systemctl start emby-server
}
copyright(){
    echo -e "
${green}###########################################################${plain}
${green}#                                                         #${plain}
${green}#           Emby Server数据一键备份、还原                 #${plain}
${green}#           仅支持宿主机直装的Emby Server                 #${plain}
${green}#           BUG反馈电报群:https://t.me/EmbyDrive          #${plain}
${green}#           Blog：https://blog.20120714.xyz               #${plain}
${green}#           Power By:翔翎                                 #${plain}
${green}#                                                         #${plain}
${green}###########################################################${plain}"
}

main(){
copyright
echo -e "
${green}———————————————————————————————————————————————————————————${plain}
${green}1.${plain}  一键备份
${green}2.${plain}  一键还原
"
    echo -e "${yellow}请选择你要使用的功能${plain}"
    read -p "请输入数字 :" num   
    case "$num" in
        1)
            backup_emby
            ;;
        2)
            restore_emby
            ;;
        *)
    clear
    echo -e "${red}出现错误:请输入正确数字 ${plain}"
    sleep 2s
    copyright
    main
    ;;
  esac
}
echoContent
main
