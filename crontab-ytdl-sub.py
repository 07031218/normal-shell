# 请预先安装如下依赖
# pip3 install mysql-connector-python
import mysql.connector
import os

# 连接 MySQL 数据库
db = mysql.connector.connect(
    host="",
    user="",
    password="",
    database=""
)
# 创建游标对象
cursor = db.cursor()

# 查询数据库
query = "SELECT chinesename, name, url, timerange FROM list"
cursor.execute(query)
results = cursor.fetchall()
# 定义新的配置文件名格式
# 循环遍历结果，执行任务
for chinesename, name, url, timerange in results:
    config_file_name = f"subscriptions-{name}.yaml"
    if timerange == "1years":
        os.system(f"cp subscriptions-clasic.yaml {config_file_name}")
        os.system(f'sed -i "s/laogao/{name}/" {config_file_name}')
        os.system(f'sed -i "s/老高與小茉/{chinesename}/" {config_file_name}')
        os.system(f'sed -i "s/1weeks/1years/" {config_file_name}')
        os.system(f'sed -i "s%https://www.youtube.com/@laogao/videos%{url}%" {config_file_name}')
        os.system(f"ytdl-sub --config=/config/config-1years.yaml sub /config/{config_file_name}")
        os.system(f"rm {config_file_name}")
        query1 = "UPDATE `ytdl-sub`.`list` SET `timerange` = '1weeks' WHERE `name` = '%s'"%(name,)
        try:
            db.ping(reconnect=True)
            cursor.execute(query1)
            db.commit()
        except Exception as e:
            print(e)
    else:
        os.system(f"cp subscriptions-clasic.yaml {config_file_name}")
        os.system(f'sed -i "s/laogao/{name}/" {config_file_name}')
        os.system(f'sed -i "s/老高與小茉/{chinesename}/" {config_file_name}')
        os.system(f'sed -i "s%https://www.youtube.com/@laogao/videos%{url}%" {config_file_name}')
        os.system(f"ytdl-sub --config=/config/config-dianxixiaoge.yaml sub /config/{config_file_name}")
        os.system(f"rm {config_file_name}")

# 关闭游标和数据库连接
cursor.close()
db.close()
os.system(f"gclone copy /tv_shows/ SA:影视剧/油管专辑 --drive-server-side-across-configs --transfers=8 -P")
os.system(f"cd /tv_shows && rm ./* -rf")
