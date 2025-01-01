#!/bin/bash
# 定义磁盘挂载点和账户
mount_drive1="/nongjiale" # 磁盘1挂载点
mount_drive2="/mnt/video" # 磁盘2挂载点
nongjiale1="nongjiale-hahagaga"
nongjiale2="nongjiale-anboy"
old_11pan1="11pan"
old_11pan2="11pan-anboy"

# 获取挂载点对应的设备名
nongjiale_status=$(df -h | awk -v mount="$mount_drive1" '$NF == mount {gsub(":", "", $1); print $1}')
old_11pan_status=$(df -h | awk -v mount="$mount_drive2" '$NF == mount {gsub(":", "", $1); print $1}')

# 切换农家乐磁盘账户
if systemctl status rclone-"$nongjiale_status" 2>/dev/null | grep -q 'Error 403:'; then
    echo "检测到农家乐磁盘已超额，开始切换磁盘账户……"
    systemctl stop rclone-"$nongjiale_status" && systemctl disable rclone-"$nongjiale_status"
    fusermount -qzu "$mount_drive1"
    if [[ "$nongjiale_status" == "$nongjiale1" ]]; then
        systemctl enable --now rclone-"$nongjiale2"
        echo "已将磁盘账户切换到 $nongjiale2"
    else
        systemctl enable --now rclone-"$nongjiale1"
        echo "已将磁盘账户切换到 $nongjiale1"
    fi
fi

# 切换11盘磁盘账户
if systemctl status rclone-"$old_11pan_status" 2>/dev/null | grep -q 'Error 403:'; then
    echo "检测到11盘磁盘已超额，开始切换磁盘账户……"
    systemctl stop rclone-"$old_11pan_status" && systemctl disable rclone-"$old_11pan_status"
    fusermount -qzu "$mount_drive2"
    if [[ "$old_11pan_status" == "$old_11pan1" ]]; then
        systemctl enable --now rclone-"$old_11pan2"
        echo "已将磁盘账户切换到 $old_11pan2"
    else
        systemctl enable --now rclone-"$old_11pan1"
        echo "已将磁盘账户切换到 $old_11pan1"
    fi
fi
