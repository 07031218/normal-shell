#!/bin/bash
# 脚本适配Emby 4.8.0.37版本，如果非该版本，请自行抓取刷新媒体库时获取到的curl指令进行替换。
# set -x
declare -A items=(
	["oumeiju"]="欧美剧,687156" # []里填写媒体分类的字母代号(可自定义)，欧美剧为媒体库名称，687156为该媒体库emby对应的parentId,
	["guochanju"]="国产剧,682089" # 同上
	["rihanju"]="日韩剧,720395" # 同上
)
rcloneconfig="" # 填写GD网盘的rclone配置名称
gddir="" # 填写GD盘媒体目录名称，最后不带/
apikey="" # 填写EMBY的APIKEY
embyurl="http://ip:8096" # 填写EMBY的网址，最后不加/
bot_token="" # 填写telegram bot的Token
chat_id="" # 填写接收机器人消息的群组或者用户的TG_ID
Device_Id="" # 此处填写刷新媒体库时抓取到的curl指令中的Device-Id的对应编号
for key in "${!items[@]}"
do
	value="${items[$key]}"
	name="${value%,*}"
	id="${value#*,}"
	fullurl="${embyurl}/emby/Items/${id}"'/Refresh?Recursive=true&ImageRefreshMode=Default&MetadataRefreshMode=Default&ReplaceAllImages=false&ReplaceAllMetadata=false&X-Emby-Client=Emby%20Web&X-Emby-Device-Name=Microsoft%20Edge%20macOS&X-Emby-Device-Id='"${Device_Id}"'&X-Emby-Client-Version=4.8.0.37&X-Emby-Token='"${apikey}"
	fullurl1="${embyurl}/emby/Items/${id}"'/Refresh?Recursive=true&ImageRefreshMode=FullRefresh&MetadataRefreshMode=FullRefresh&ReplaceAllImages=false&ReplaceAllMetadata=false&X-Emby-Client=Emby%20Web&X-Emby-Device-Name=Microsoft%20Edge%20macOS&X-Emby-Device-Id='"${Device_Id}"'&X-Emby-Client-Version=4.8.0.37&X-Emby-Token='"${apikey}"
	if [[ ! -f /root/.${key}.txt ]]; then
	rclone size ${rcloneconfig}:${gddir}/${name}|sed -n "2p"|awk -F "(" '{print $2}'|awk '{print $1}' > /root/.${key}.txt
	fi
	if [[ `rclone size ${rcloneconfig}:${gddir}/${name}|sed -n "2p"|awk -F "(" '{print $2}'|awk '{print $1}'` != `cat /root/.${key}.txt` ]]; then
	rclone size ${rcloneconfig}:${gddir}/${name}|sed -n "2p"|awk -F "(" '{print $2}'|awk '{print $1}' > /root/."${key}".txt
	curl ${fullurl} \
	-X 'POST' \
	-H 'Connection: keep-alive' \
	-H 'Content-Length: 0' \
	-H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="98", "Microsoft Edge";v="98"' \
	-H 'DNT: 1' \
	-H 'sec-ch-ua-mobile: ?0' \
	-H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.80 Safari/537.36 Edg/98.0.1108.43' \
	-H 'sec-ch-ua-platform: "macOS"' \
	-H 'Accept: */*' \ 
	-H 'Origin: '"${embyurl}" \
	-H 'Sec-Fetch-Site: same-origin' \
	-H 'Sec-Fetch-Mode: cors' \
	-H 'Sec-Fetch-Dest: empty' \
	-H 'Referer: '"${embyurl}"'/web/index.html' \
	-H 'Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6' \
	-H 'Cookie: _ga=GA1.1.1511214678.1654738055; _ga_P1E9Z5LRRK=GS1.1.1684834693.201.0.1684834693.0.0.0' \
	--compressed # 38、42行要保留格式不变
	sleep 20
	curl ${fullurl1} \
	-X 'POST' \
	-H 'Connection: keep-alive' \
	-H 'Content-Length: 0' \
	-H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="98", "Microsoft Edge";v="98"' \
	-H 'DNT: 1' \
	-H 'sec-ch-ua-mobile: ?0' \
	-H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.80 Safari/537.36 Edg/98.0.1108.43' \
	-H 'sec-ch-ua-platform: "macOS"' \
	-H 'Accept: */*' \
	-H 'Origin: '"${embyurl}" \
	-H 'Sec-Fetch-Site: same-origin' \
	-H 'Sec-Fetch-Mode: cors' \
	-H 'Sec-Fetch-Dest: empty' \
	-H 'Referer: '"${embyurl}"'/web/index.html' \
	-H 'Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6' \
	-H 'Cookie: _ga=GA1.1.1511214678.1654738055; _ga_P1E9Z5LRRK=GS1.1.1684834693.201.0.1684834693.0.0.0' \
	--compressed # 57、61行要保留格式不变
	sleep 1000
	echo "`date +%Y-%m-%d\ %H:%M:%S` ${name}追新刷新媒体库完成。" >> /root/sync-zhuixin.log
	curl "https://api.telegram.org/bot${bot_token}/sendMessage?chat_id=${chat_id}&text=`date +%Y-%m-%d\ %H:%M:%S` ${name}追新刷新媒体库完成。"
	fi
done
