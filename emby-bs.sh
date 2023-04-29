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

sys_dir=/opt/emby-server/
config_dir=/var/lib/


backto_dir="" # 填写gd网盘挂载路径下面其中一个文件夹作为数据备份存放目录
xuegua_dir="" # 填写自定义削刮文件的存放路径，如未曾自定义过削刮文件存放目录，则留空即可
baksys="" # 是否备份Emby主程序的开关，如果要备份Emby的主程序，则填写Y或者y，否则留空即可


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
targz(){
    if [[ `which pv` == "" ]]; then
        apt install pv -y || yum install pv -y
    fi
    if [[ $1 = '' ]]; then
        echo "参数缺失，用法 'targz 压缩名 文件名/目录名'"
        exit 1
    fi

    tar -cf - $3 $2 | pv -s $(du -sk $2 | awk '{print $1}') | gzip > $1
}
untar(){
    if [[ `which pv` == "" ]]; then
        apt install pv -y || yum install pv -y
    fi
    total_size=`du -sk $1 | awk '{print $1}'`
    echo
    pv -s $((${total_size} * 1020)) $1 | tar zxf - -C $2
}

backup_emby(){
    mkdir -p $backto_dir/$DATE
    echoContent white "即将开始对Emby Server进行备份，需要一定的时间，请耐心等待······"
    sleep 3s
    if [[ ${xuegua_dir} == "" ]]; then
        xuegua_dir=$config_dir
        systemctl stop emby-server
        cd $xuegua_dir
        echoContent yellow "Emby削刮包和数据库备份中，请耐心等待······"
        targz ${backto_dir}/${DATE}/Emby削刮包和LibEmby数据库.tar.gz ./emby
        if [[ "$?" -eq 0 ]]; then
                # clear
            echoContent green "Emby削刮包和LibEmby数据库备份完成"
            sleep 5s
        else
            echoContent red "Emby削刮包和LibEmby数据库备份失败"
            systemctl start emby-server
            exit 1
        fi
        if [[ $baksys == "Y" ]]||[[ $baksys == "y" ]]; then
            cd $sys_dir
            echoContent yellow "Emby-server主程序备份中，请耐心等待······"
            targz ${backto_dir}/${DATE}/Emby-server主程序.tar.gz ./
            if [[ "$?" -eq 0 ]]; then
                # clear
                echoContent green "Emby-server主程序备份完成"
                sleep 5s
            else
                echoContent red "Emby-server主程序备份失败"
                systemctl start emby-server
                exit 1
            fi
        fi
        echoContent yellow "恭喜，所有备份均已完成。"
        systemctl start emby-server
    else
        systemctl stop emby-server
        cd $xuegua_dir
        echoContent yellow "Emby削刮包备份中，请耐心等待······"
        targz ${backto_dir}/${DATE}/Emby削刮包.tar.gz ./
        if [[ "$?" -eq 0 ]]; then
            # clear
            echoContent green "Emby削刮包备份完成"
            sleep 5s
        else
            echoContent red "Emby削刮包备份失败"
            systemctl start emby-server
            exit 1
        fi
        cd $config_dir
        echoContent yellow "LibEmby数据库备份中，请耐心等待······"
        # 备份VarLibEmby数据库(排除包含帐户数据相关的文件)
        targz ${backto_dir}/${DATE}/LibEmby数据库.tar.gz ./emby
        if [[ "$?" -eq 0 ]]; then
            # clear
            echoContent green "LibEmby数据库备份完成"
        else
            echoContent red "LibEmby数据库备份失败"
            systemctl start emby-server
            exit 1
        fi
        if [[ $baksys == "Y" ]]||[[ $baksys == "y" ]]; then
            cd $sys_dir
            echoContent yellow "Emby-server主程序备份中，请耐心等待······"
            targz ${backto_dir}/${DATE}/Emby-server主程序.tar.gz ./
            if [[ "$?" -eq 0 ]]; then
                # clear
                echoContent green "Emby-server主程序备份完成"
                sleep 5s
            else
                echoContent red "Emby-server主程序备份失败"
                systemctl start emby-server
                exit 1
            fi
        fi
        echoContent yellow "恭喜，所有备份均已完成。"
        systemctl start emby-server
    fi
}
restore_emby(){
    echoContent yellow "是否还原Emby-sever主程序？[Y/N]:"
    read restore_sys
        i=1
        list=()
        if [[ ! -d ${backto_dir} ]]; then
                echoContent red "错误，未检索到备份数据目录。"
                exit 1
        elif [[ -d ${backto_dir} ]];then
                items=$(ls ${backto_dir}/ -l|awk 'NR>1{print $9}')
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
                        echoContent skyBlue "当前[yyyy-mm-dd]格式数据备份列表如下:"
                        # echo
                echoContent skyBlue "-------------------------------"
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
                                echoContent skyBlue "${temp}"
                                echoContent skyBlue "-------------------------------"
                        done
                        echo
                        read -n3 -p "请选择要使用的备份档（输入数字即可）：" bak_date_name
                        if [[ ${bak_date_name} -eq 0 ]]; then
                          echo
                          echoContent red "输入不正确，请重新输入。"
                        elif [ ${bak_date_name} -le ${#list[@]} ] && [ -n ${bak_date_name} ];then
                                echo
                                echoContent purple "您选择了：${list[bak_date_name]}"
                                break
                        else
                          echo
                          echoContent red "输入不正确，请重新输入。"
                          echo
                        fi
                 
                done
            break
        done
    echoContent red "即将开始还原操作，是否继续执行:[Y/N]"
    read yn
    if [[ $yn != "Y" ]] && [[ $yn != "y" ]]; then
        exit 0
    fi
    systemctl stop emby-server
    if [[ ${xuegua_dir} == "" ]]; then
        xuegua_dir=$config_dir
        echoContent yellow "Emby削刮包和LibEmby数据库恢复中，请耐心等待······"
        untar ${backto_dir}/${list[bak_date_name]}/Emby削刮包和LibEmby数据库.tar.gz $xuegua_dir
        if [[ "$?" -eq 0 ]]; then
                # clear
            echoContent green "Emby削刮包和LibEmby数据库恢复完成"
            sleep 5s
        else
            echoContent red "Emby削刮包和LibEmby数据库失败"
            systemctl start emby-server
            exit 1
        fi
    else
        echoContent yellow "Emby削刮包恢复中，请耐心等待······"
        untar ${backto_dir}/${list[bak_date_name]}/Emby削刮包.tar.gz $xuegua_dir
        if [[ "$?" -eq 0 ]]; then
            echoContent green "Emby削刮包恢复完成"
            sleep 3s
        else
            echoContent red "Emby削刮包恢复失败"
            systemctl start emby-server
            exit 1
        fi
        echoContent yellow "LibEmby数据库恢复中，请耐心等待······"
        untar ${backto_dir}/${list[bak_date_name]}/LibEmby数据库.tar.gz $config_dir
        if [[ "$?" -eq 0 ]]; then
            echoContent green "LibEmby数据库恢复完成"
        else
            echoContent red "LibEmby数据库恢复失败"
            systemctl start emby-server
            exit 1
        fi
    fi
    if [[ $restore_sys == "y" ]]||[[ $restore_sys == "Y" ]]; then
        echoContent yellow "Emby-server主程序恢复中，请耐心等待······"
        untar ${backto_dir}/${list[bak_date_name]}/Emby-server主程序.tar.gz $sys_dir
        if [[ "$?" -eq 0 ]]; then
            # clear
            echoContent green "Emby-server主程序恢复完成"
            sleep 5s
        else
            echoContent red "Emby-server主程序恢复失败"
            systemctl start emby-server
            exit 1
        fi
    fi
    systemctl start emby-server
    echoContent yellow "恭喜，所有恢复均已完成。"
}
copyright(){
    clear
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
${red}0.${plain}  退出脚本
${green}———————————————————————————————————————————————————————————${plain}
${green}1.${plain}  一键备份
${green}2.${plain}  一键还原
"
    echo -e "${yellow}请选择你要使用的功能${plain}"
    read -p "请输入数字 :" num   
    case "$num" in
        0)
            exit 0
            ;;
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
if [[ $1 == "b" ]]; then
    # 可通过命令 bash emby-bs.sh b 实现一键备份
    backup_emby
else
    main
fi
