import re
import json
import requests
import time

nastool_username = "" # NT用户名
nastool_password = "" # NT账户密码
moviepilot_username = "" # MP用户名
moviepilot_password = "" # MP账户密码

nastool_url = "" # NT的WEB地址
moviepilot_url = "" #MP的API地址
def replace_func(match):
    return str(int(match.group(1)))
def get_nas_tool_token():
    headers1 = {
        'accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
    }

    data1 = {
        'username': nastool_username,
        'password': nastool_password,
    }

    response1 = requests.post(f'{nastool_url}/api/v1/user/login', headers=headers1, data=data1)
    r1 = json.loads(response1.text)
    API_token = r1["data"]["token"]
    return API_token
nas_tool_token = get_nas_tool_token()
#
def get_moviepilot_token():
    headers1 = {
        'accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
    }

    data1 = {
        'username': moviepilot_username,
        'password': moviepilot_password,
    }

    response1 = requests.post(f'{moviepilot_url}/api/v1/login/access-token', headers=headers1, data=data1)
    r1 = json.loads(response1.text)
    API_token = r1['access_token']
    return API_token



headers = {
    'accept': 'application/json',
    'Authorization': nas_tool_token,
    'content-type': 'application/x-www-form-urlencoded',
}

# 电视剧订阅记录迁移逻辑起始处；
response = requests.post(f'{nastool_url}/api/v1/subscribe/tv/list', headers=headers)
r = json.loads(response.text)['data']['result']
# print(r['data']['result'])
i = 0
for key, value in r.items():
    name = f"{value['name']}"
    token = get_moviepilot_token()
    season = re.sub(r'S(\d{2})', replace_func, value['season'])
    headers1 = {
        'accept': 'application/json',
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json',
    }

    json_data1 = {
        "id": 0,
        'name': name,
        'year': value['year'],
        'type': '电视剧',
        'keyword': 'string',
        'tmdbid': value['tmdbid'],
        'bangumiid': 0,
        'season': season,
        'vote': 0,
        'quality': 'WEB-DL',
        'resolution': '4k,1080p',
        'total_episode': 0,
        'start_episode': 0,
        'lack_episode': 0,
        'sites': [
            0,
        ],
        'best_version': 0,
        'current_priority': 0,
        'save_path': '影视剧',
        'search_imdbid': 0,
    }

    response = requests.post(f'{moviepilot_url}/api/v1/subscribe/', headers=headers1, json=json_data1)
    rr = json.loads(response.text)
    i += 1
    with open('error_log.txt', 'a') as logfile:
        if rr['success'] == False:
            logfile.write(f"NO.{i}、电视剧<<{name}>>添加订阅失败，原因:{rr['message']}\n")
        else:
            print(f"NO.{i}、电视剧<<{name}>> 第 {value['season']} 季添加订阅成功")
    time.sleep(1)
# 电视剧订阅记录迁移逻辑结束处；

# 电影订阅记录迁移逻辑起始处；
response = requests.post(f'{nastool_url}/api/v1/subscribe/movie/list', headers=headers)
r = json.loads(response.text)['data']['result']
j = 0
for key, value in r.items():
    name = f"{value['name']}"
    token = get_moviepilot_token()
    headers1 = {
        'accept': 'application/json',
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json',
    }

    json_data1 = {
        "id": 0,
        'name': name,
        'year': value['year'],
        'type': '电影',
        'keyword': 'string',
        'tmdbid': value['tmdbid'],
        'bangumiid': 0,
        'season': 0,
        'vote': 0,
        'quality': 'WEB-DL',
        'resolution': '4k,1080p',
        'total_episode': 0,
        'start_episode': 0,
        'lack_episode': 0,
        'sites': [
            0,
        ],
        'best_version': 0,
        'current_priority': 0,
        'save_path': '电影',
        'search_imdbid': 0,
    }

    response = requests.post(f'{moviepilot_url}/api/v1/subscribe/', headers=headers1, json=json_data1)
    rr = json.loads(response.text)
    j+= 1
    with open('error_log.txt', 'a') as logfile:
        if rr['success'] == False:
            logfile.write(f"NO.{j}、电影<<{name}>>添加订阅失败，原因:{rr['message']}\n")
        else:
            print(f"NO.{j}、电影<<{name}>>添加订阅成功")
    time.sleep(1)

# 电影订阅记录迁移逻辑结束处；
