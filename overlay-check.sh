#!/bin/bash
lowerdir="/youtube-lower" # 填写GD原始挂载点路径，末尾不带/
upperdir="/youtube-upper" # 填写削刮文件存放路径，末尾不带/
workdir="/youtube-work" # 填写overlay分层文件的临时工作路径，末尾不带/
mountdir="/youtube" # 填写overlay的顶端merga路径，末尾不带/
rcloneconfig="sa-anboy0714" # 填写GD网盘的rclone config配置名称
if [[ ! -f ${upperdir}/油管专辑/xuegua.tar ]]; then
    if [[ ! -d ${upperdir}/油管专辑 ]]; then
        mkdir -p ${upperdir}/油管专辑
    fi
    cp ${lowerdir}/油管削刮包/xuegua.tar ${upperdir}/油管专辑/ && cd ${upperdir}/油管专辑/ && tar xvf xuegua.tar
    /usr/bin/mount -t overlay -o lowerdir=${lowerdir},upperdir=${upperdir},workdir=${workdir} overlay ${mountdir}
fi
if [[ `rclone size ${rcloneconfig}:油管削刮包/xuegua.tar|sed -n '2p'|awk '{print $5}'|sed 's/(//'` != `du ${upperdir}/油管专辑/xuegua.tar -b|awk '{print $1}'` ]]; then
    rclone copy ${rcloneconfig}:油管削刮包/xuegua.tar ${upperdir}/油管专辑/ -P && cd ${upperdir}/油管专辑/ && tar xvf xuegua.tar
    /usr/bin/umount ${mountdir}
    systemctl stop rclone-sa-anboy0714
    systemctl start rclone-sa-anboy0714
    /usr/bin/mount -t overlay -o lowerdir=${lowerdir},upperdir=${upperdir},workdir=${workdir} overlay ${mountdir}
else
    echo "削刮包没有更新，程序退出。"
fi
