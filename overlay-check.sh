#!/bin/bash
lowerdir="/youtube-lower" # 填写GD原始挂载点路径，末尾不带/
upperdir="/youtube-upper" # 填写削刮文件存放路径，末尾不带/
workdir="/youtube-work" # 填写overlay分层文件的临时工作路径，末尾不带/
mountdir="/youtube" # 填写overlay的顶端merga路径，末尾不带/
if [[ ! -f ${upperdir}/油管专辑/xuegua.tar ]]; then
    if [[ ! -d ${upperdir}/油管专辑 ]]; then
        mkdir -p ${upperdir}/油管专辑
    fi
    cp ${lowerdir}/油管削刮包/xuegua.tar ${upperdir}/油管专辑/ && cd ${upperdir}/油管专辑/ && tar xvf xuegua.tar
    /usr/bin/mount -t overlay -o lowerdir=${lowerdir},upperdir=${upperdir},workdir=${workdir} overlay ${mountdir}
fi
if [[ `du ${lowerdir}/油管削刮包/xuegua.tar -h|awk '{print $1}'` != `du ${upperdir}/油管专辑/xuegua.tar -h|awk '{print $1}'` ]]; then
    cp ${lowerdir}/油管削刮包/xuegua.tar ${upperdir}/油管专辑/ && cd ${upperdir}/油管专辑/ && tar xvf xuegua.tar
    /usr/bin/umount ${mountdir}
    /usr/bin/mount -t overlay -o lowerdir=${lowerdir},upperdir=${upperdir},workdir=${workdir} overlay ${mountdir}
else
    echo "削刮包没有更新，程序退出。"
fi
