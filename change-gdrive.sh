#!/bin/bash
mount_drive1="/nongjiale" # 磁盘1挂载点
mount_drive2="/mnt/video" # 磁盘2挂载点
nongjiale_status=$(df -h|grep ${mount_drive1}|awk '{print $1}'|sed 's/://g') # 检测当前磁盘1限额状态
old_11pan_status=$(df -h|grep ${mount_drive2}|awk '{print $1}'|sed 's/://g') # 检测当前磁盘2限额状态
nongjiale1="nongjiale-hahagaga" # 定义磁盘1的磁盘账户1
nongjiale12="nongjiale-aboy" # 定义磁盘1的磁盘账户2
old_11pan1="11pan" # 定义磁盘2的磁盘账户1
old_11pan2="11pan-anboy" # 定义磁盘2的磁盘账户2


if [[ `systemctl status rclone-${nongjiale_status}|grep 'Error 403:'` != "" ]]; then
	echo "检测到农家乐磁盘已经超额，开始切换磁盘账户…………"
	systemctl stop rclone-${nongjiale_status} && systemctl disable ${nongjiale_status} && fusermount -qzu ${mount_drive1}
	if [[ ${nongjiale_status} == ${nongjiale1} ]]; then
		systemctl enable-now rclone-${nongjiale12}
		echo "已将磁盘账户切换到${nongjiale12}"
	else
		systemctl enable-now rclone-${nongjiale11}
		echo "已将磁盘账户切换到${nongjiale11}"
	fi
fi
if [[ `systemctl status rclone-${old_11pan_status}|grep 'Error 403:'` != "" ]]; then
	echo "检测到11盘磁盘已经超额，开始切换磁盘账户…………"
	systemctl stop rclone-${old_11pan_status} && systemctl disable ${old_11pan_status} && fusermount -qzu ${mount_drive2}
	if [[ ${old_11pan_status} == ${old_11pan1} ]]; then
		systemctl enable-now rclone-${old_11pan2}
		echo "已将磁盘账户切换到${old_11pan2}"
	else
		systemctl enable-now rclone-${old_11pan1}
		echo "已将磁盘账户切换到${old_11pan1}"
	fi
fi
exit 0
