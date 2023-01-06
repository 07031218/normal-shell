import os
input_dir = "" # 输入文件存放的路径，最末尾不带/
for root, dirs, files in os.walk(input_dir):
    for name in files:
        if os.path.splitext(name)[-1] == ".webm":
            print(root, name)
            os.system("ffmpeg -i '%s/%s' -vf 'scale=trunc(iw/2)*2:trunc(ih/2)*2' '%s/%s.%s'.mp4" % (root, name, root, name.split(".")[0], name.split(".")[1])) # 注意：根据输出文件名格式修改占位符
            os.system("rm '%s/%s'" % (root, name))
