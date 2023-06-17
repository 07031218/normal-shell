import os
import subprocess
import json
from plexapi.server import PlexServer

# rclone 远程目录路径
RCLONE_REMOTE_PATH = 'nongjiale:'

# Plex 服务器配置
PLEX_BASEURL = 'http://plexurl:32400'
PLEX_TOKEN = ''

# rclone网盘目录名和对应媒体库名的映射关系
MEDIA_DIRS = {
    '电影': '电影-11',
    '剧集追新/国产剧': '华语剧追新',
    '剧集追新/欧美剧': '欧美剧追新',
    '剧集追新/日韩剧': '日韩剧追新'
}

# 获取 Plex 服务器对象
plex = PlexServer(PLEX_BASEURL, PLEX_TOKEN)

# 遍历所有要监视的目录
for media_dir in MEDIA_DIRS:
    # 打开要写入的 txt 文件，如果文件不存在则创建它
    txt_file = open(f'.{MEDIA_DIRS[media_dir]}.txt', 'a+')
    
    # 将文件指针移动到文件开头
    txt_file.seek(0)
    
    # 读取本地保存的目录大小，如果文件为空则默认为 0
    local_size = int(txt_file.read() or 0)
    
    # 构建 rclone 命令行
    cmd = ['rclone', 'size', '--json', os.path.join(RCLONE_REMOTE_PATH, media_dir)]
    
    # 执行命令并获取输出结果
    output = subprocess.check_output(cmd).decode().strip()
    
    # 解析输出结果中的目录大小
    rc_data = json.loads(output)
    rc_size = rc_data['bytes']
    
    # 如果目录大小发生变化，则刷新媒体库并更新本地保存的目录大小
    if rc_size != local_size:
        # 将目录大小写入 txt 文件
        txt_file.seek(0)
        txt_file.write(str(rc_size))
        txt_file.truncate()
        
        # 获取要刷新的媒体库对象，并刷新它
        library_name = MEDIA_DIRS[media_dir]
        library = plex.library.section(library_name)
        library.update()
        
        # 输出刷新信息
        print(f'{library_name} refreshed.')
    
    # 关闭 txt 文件
    txt_file.close()
