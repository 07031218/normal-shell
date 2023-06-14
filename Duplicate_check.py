import subprocess
diskdir1 = "" # 输入GD盘1的rclone config名称(可带盘下路径),如GD1:电影
diskdir2 = "" # 输入GD盘2的rclone config名称(可带盘下路径),如GD2:电影 
diskdir3 = "" # 输入GD盘3的rclone config名称(可带盘下路径),如GD3:电影
diskdir4 = "" # 输入GD盘4的rclone config名称(可带盘下路径),如GD4:电影

# 获取磁盘1下面所有目录名称
p1 = subprocess.Popen(['rclone', 'lsd', f'{diskdir1}'], stdout=subprocess.PIPE)
p2 = subprocess.Popen(["awk '{print $5}'"], shell=True, stdin=p1.stdout, stdout=subprocess.PIPE)
p3 = subprocess.Popen(["sed 's/([0-9]*)//g'"], shell=True, stdin=p2.stdout, stdout=subprocess.PIPE)
out, err = p3.communicate()
disk1_dirs = out.decode('utf-8').strip().split()
# 获取其他磁盘下面的匹配目录名称
matched_dirs = []
for disk in [f'{diskdir2}', f'{diskdir3}', f'{diskdir4}']:
    p1 = subprocess.Popen(['rclone', 'lsd', f'{disk}'], stdout=subprocess.PIPE)
    p2 = subprocess.Popen(["awk '{print $5}'"], shell=True, stdin=p1.stdout, stdout=subprocess.PIPE)
    out, err = p2.communicate()
    dirs = out.decode('utf-8').strip().split()
    for dir in dirs:
        if dir in disk1_dirs:
            matched_dirs.append(dir)

# 输出匹配目录名称
j = 0
for i in matched_dirs:
	j += 1
print(f"在分类中查重发现重复的文件目录总数量{j}个，他们是:{matched_dirs}")
