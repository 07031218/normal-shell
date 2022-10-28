#!/bin/bash
xuegua_dir="" # 削刮库目录,如未自定义，留空即可
embylib_dir="/var/lib/" # Emby默认Libray数据库和削刮包缓存目录,不要修改
embyserver_dir="/opt/emby-server/" # Emby主程序相关目录，如果不需要备份主程序，删除内容留空即可
bak_dir="" # 备份文件存放目录，需要自行填写，最末尾不要/
DATE=`date +%Y%m%d` # 时间格式化，勿动

DEL_DAY=7 # 备份脚本保存的天数，默认7天，支持自定义修改
if [[ $bak_dir == "" ]]; then
    echo "`date '+%Y-%m-%d %H:%M:%S'` ⚠️ 检测到未配置备份目录，程序退出" >> /root/emby_bak_error.log
    echo "`date '+%Y-%m-%d %H:%M:%S'` ⚠️ 检测到未配置备份目录，程序退出"
    exit 1
fi
targz(){
    if [[ `which pv` == "" ]]; then
        apt install pv -y || yum install pv -y
    fi
    if [[ $1 = '' ]]; then
        echo "参数缺失，用法 'targz 压缩名 文件名/目录名'"
        exit 1
    fi
    tar -cf - $3 $2  | pv -s $(du -sk $2 | awk '{print $1}') | gzip > $1
}
# 创建日期目录
mkdir -p $bak_dir/${DATE}
# 停止Emby Server服务
systemctl stop emby-server
if [[ $xuegua_dir != "" ]]; then
    cd $xuegua_dir
    targz $bak_dir/${DATE}/Emby削刮包.tar.gz ./
    if [[ $? -eq 0 ]]; then
        echo "Emby削刮包备份完成······"
    else
        echo "`date '+%Y-%m-%d %H:%M:%S'` Emby削刮包备份失败" >> /root/emby_bak_error.log
        systemctl start emby-server
        exit 1
    fi
    cd $embylib_dir
    # 备份VarLibEmby数据库(排除包含帐户数据相关的文件)
    targz $bak_dir/${DATE}/Emby-VarLibEmby数据库.tar.gz ./emby '--exclude ./emby/data/device.txt'
    if [[ $? -eq 0 ]]; then
        echo "LibEmby数据库备份完成······"
    else
        echo "`date '+%Y-%m-%d %H:%M:%S'` LibEmby数据库备份失败" >> /root/emby_bak_error.log
        systemctl start emby-server
        exit 1
    fi
else
    cd $xuegua_dir
    targz $bak_dir/${DATE}/Emby削刮包和LibEmby数据库.tar.gz ./
    if [[ $? -eq 0 ]]; then
        echo "Emby削刮包和LibEmby数据库备份完成······"
    else
        echo "`date '+%Y-%m-%d %H:%M:%S'` Emby削刮包和LibEmby数据库备份失败" >> /root/emby_bak_error.log
        systemctl start emby-server
        exit 1
    fi
fi
if [[ $embyserver_dir != "" ]]; then
    cd $embyserver_dir
    targz $bak_dir/${DATE}/Emby-server主程序.tar.gz ./
    if [[ $? -eq 0 ]]; then
        echo "Emby-server主程序备份完成······"
    else
        echo "`date '+%Y-%m-%d %H:%M:%S'` Emby-server主程序备份失败" >> /root/emby_bak_error.log
        systemctl start emby-server
        exit 1
    fi
fi
systemctl start emby-server # 启动Emby Server服务
# 遍历备份目录下的日期目录
LIST=$(ls $bak_dir)
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
            rm -rf $bak_dir/$index
        fi
    fi
done
