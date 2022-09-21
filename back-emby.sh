#!/bin/bash

# 削刮库目录
xuegua_dir="/home/Emby"
# Emby数据库等配置目录,默认不要修改
embylib_dir="/var/lib/"
# Emby主程序相关目录
embyserver_dir="/opt/emby-server/"
# 备份文件存放目录
bak_dir="/nongjiale/emby-server-bak"
# 时间格式化，如 20220602
DATE=`date +%Y%m%d`
# 备份脚本保存的天数
DEL_DAY=7
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
mkdir -p $bak_dir/$DATE
# 停止Emby Server服务
systemctl stop emby-server
if [[ $xuegua_dir != "" ]]; then
    cd $xuegua_dir
    targz $bak_dir/$DATE/Emby削刮包.tar.gz ./
    echo "Emby削刮包备份完成······"
fi
cd $embyserver_dir
targz $bak_dir/${DATE}/Emby-server数据库.tar.gz ./
echo "Emby-server数据库备份完成······"
cd $embylib_dir
# 备份VarLibEmby数据库(排除包含帐户数据相关的文件)
targz $bak_dir/${DATE}/Emby-VarLibEmby数据库.tar.gz ./emby '--exclude ./emby/data/device.txt --exclude ./emby/data/users.db --exclude ./emby/data/activitylog.db --exclude ./emby/data/authentication.db --exclude ./emby/data/displaypreferences.db'
echo "Emby-VarLibEmby数据库备份完成······"
# 启动Emby Server服务
systemctl start emby-server

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
