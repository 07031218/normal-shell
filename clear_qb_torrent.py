import qbittorrentapi
import os
import logging

# 脚本主要目的是用来清理qb里任务文件已经被转移的种子任务。适用于部分用户使用nas-tools的rclone移动来进行追剧的应用场景

# 设置日志格式和级别
logging.basicConfig(filename='qbittorrent.log', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

conn_info = dict(
    host="", # 填写qbittorrent的URL地址
    port=8088, # 填写qbittorrent的端口
    username="", # 填写qbittorrent的用户名
    password="", # 填写qbittorrent的密码
)

qbt_client = qbittorrentapi.Client(**conn_info)

completed_tasks = qbt_client.torrents_info(status_filter="completed")
download_dir = "" # 填写qb的下载保存目录路径，最末尾带/
i = 0
for task in completed_tasks:
    # 获取任务的文件列表
    qbt_client.torrents_pause(torrent_hashes=task.hash) # 暂停已经下载完成的任务，防止被PT站判定为假做种
    files = qbt_client.torrents_files(torrent_hash=task.hash)
    # 构造保存路径
    save_path = download_dir + task.name
    # 判断保存路径是否为空文件夹
    print(save_path)
    if os.path.isdir(save_path) and not os.listdir(save_path):
        i += 1
        message = f"文件夹 {save_path} 为空，将删除任务：{task.name}"
        logging.info(message)
        print(message)
        qbt_client.torrents_delete(torrent_hashes=task.hash, delete_files=True)
if i > 0:
    logging.info(f"总计删除{i}个任务")
print(f"总计删除{i}个任务")
