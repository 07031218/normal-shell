#!/bin/bash
echo -ne "请输入要做操作的文件的路径："
read filename
# 对文本每行做复制 前后间以-O 区隔
awk '{print $0" -O "$0}' $filename >${newfilename}new.txt
# 文本每行前后添加指定内容，本处代码实现行首添加webget "$wget_dir/$version 行尾添加"
awk '{print "webget \"$wget_dir/$version"$0"\""}' ${newfilename}new.txt >$filename
rm ${newfilename}new.txt
echo -e "文件处理完毕。"
exit 0
