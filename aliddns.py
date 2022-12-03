#!/usr/bin/python3

import base64
import hmac
import json
import re
import sys
import urllib.request
from urllib.parse import quote
from urllib import error
from _sha1 import sha1
import time
from datetime import datetime,timezone
import sys
import os
import ssl
import argparse
import requests

# author: TreviD
# modify by: 翔翎
# bug修复日期:2022.12.3
# 原脚本bug:查询A记录不存在时因为位标部分代码存在问题导致执行报错
# 错误提示信息如下:
# Traceback (most recent call last):
#   File "/root/aliddns.py", line 323, in <module>
#     recordListInfo = get_record_info(RR, DomainName, Type)
#   File "/root/aliddns.py", line 95, in get_record_info
#     i = json.loads(jsonStr)['DomainRecords']['Record'][0]['Value']

# 使用方法 python3 ./aliddns.py RR DomainName Type
# eg: python3 ./aliddns.py www baidu.com A

aliddnsipv6_ak = "AccessKeyId" # 
aliddnsipv6_sk = "Access Key Secret"

# aliddnsipv6_ttl = "600"

params = {
    'Format': 'JSON',
    'Version': '2015-01-09',
    'AccessKeyId': aliddnsipv6_ak,
    'Signature': '',
    'SignatureMethod': 'HMAC-SHA1',
    'SignatureNonce': '',
    'SignatureVersion': '',
    'Timestamp': ''
}


def getSignature(params):
    list = []
    for key in params:
        # print(key)
        list.append(percentEncode(key) + "=" + percentEncode(str(params[key])))
    list.sort()
    CanonicalizedQueryString = '&'.join(list)
    # print("strlist:" + CanonicalizedQueryString)
    StringToSign = 'GET' + '&' + percentEncode("/") + "&" + percentEncode(CanonicalizedQueryString)
    # print("StringToSign:" + StringToSign)
    h = hmac.new(bytes(aliddnsipv6_sk + "&", encoding="utf8"),
                 bytes(StringToSign, encoding="utf8"), sha1)
    signature = base64.encodebytes(h.digest()).strip()
    signature = str(signature, encoding="utf8")
    # print(signature)
    return signature


def get_record_info(SubDomain, DomainName, Type):
    params = {
        'Format': 'JSON',
        'Version': '2015-01-09',
        'AccessKeyId': aliddnsipv6_ak,
        'SignatureMethod': 'HMAC-SHA1',
        'SignatureNonce': '',
        'SignatureVersion': '1.0',
        'Timestamp': '',
        'Action': 'DescribeSubDomainRecords'
    }
    params['DomainName'] = DomainName
    params['SubDomain'] = SubDomain + "." + DomainName
    params['Type'] = Type
    timestamp = time.time()
    # formatTime = time.strftime(
    # "%Y-%m-%dT%H:%M:%SZ", time.localtime(time.time() - 8 * 60 * 60))
    utc_dt = datetime.utcnow().replace(tzinfo=timezone.utc)
    formatTime=utc_dt.strftime("%Y-%m-%dT%H:%M:%SZ")
    params['Timestamp'] = formatTime
    params['SignatureNonce'] = timestamp

    Signature = getSignature(params)
    params['Signature'] = Signature
    list = []
    for key in params:
        list.append(percentEncode(key) + "=" + percentEncode(str(params[key])))
    list.sort()
    paramStr = "&".join(list)
    url = "https://alidns.aliyuncs.com/?" + paramStr
    # print("url:" + url)
    try:
        print("查询域名信息：" + SubDomain + "." + DomainName + "的" + Type + "记录")
        context = ssl._create_unverified_context()
        jsonStr = urllib.request.urlopen(
            url, context=context).read().decode("utf8")
        if str(json.loads(jsonStr)['DomainRecords']['Record']) != "[]":
            i = json.loads(jsonStr)['DomainRecords']['Record'][0]['Value']
            print("查询历史A记录结束，指向：" + i)
        else:
            i = str(json.loads(jsonStr)['DomainRecords']['Record'])
        return json.loads(jsonStr)
    except error.HTTPError as e:
        print(e)
        print("查询域名信息失败：" + e.read().decode("utf8"))


def add_domain_record(DomainName, RR, Type, Value):
    print("start add domain record")
    params = {
        'Format': 'JSON',
        'Version': '2015-01-09',
        'AccessKeyId': aliddnsipv6_ak,
        'SignatureMethod': 'HMAC-SHA1',
        'SignatureNonce': '',
        'SignatureVersion': '1.0',
        'Timestamp': '',
        'Action': 'AddDomainRecord'
    }
    params['DomainName'] = DomainName
    params['RR'] = RR
    params['Type'] = Type
    params['Value'] = Value

    timestamp = time.time()
    # formatTime = time.strftime(
    # "%Y-%m-%dT%H:%M:%SZ", time.localtime(time.time() - 8 * 60 * 60))
    utc_dt = datetime.utcnow().replace(tzinfo=timezone.utc)
    formatTime=utc_dt.strftime("%Y-%m-%dT%H:%M:%SZ")
    # formatTime = formatTime.replace(":", "%3A")
    params['Timestamp'] = formatTime
    params['SignatureNonce'] = timestamp

    Signature = getSignature(params)
    params['Signature'] = Signature
    list = []
    for key in params:
        list.append(percentEncode(key) + "=" + percentEncode(str(params[key])))
    list.sort()
    paramStr = "&".join(list)
    url = "https://alidns.aliyuncs.com/?" + paramStr
    # print("url:" + url)
    try:
        print("添加 " + RR + " " + DomainName + " " + Type + " " + Value)
        context = ssl._create_unverified_context()
        jsonStr = urllib.request.urlopen(
            url, context=context).read().decode("utf8")
        print("添加成功")
        return json.loads(jsonStr)
    except error.HTTPError as e:
        print(e)
        print("添加失败：" + e.read().decode("utf8"))


def update_domain_record(RecordId, RR, Value, Type):
    print("start update domain record")
    params = {
        'Format': 'JSON',
        'Version': '2015-01-09',
        'AccessKeyId': aliddnsipv6_ak,
        'SignatureMethod': 'HMAC-SHA1',
        'SignatureNonce': '',
        'SignatureVersion': '1.0',
        'Timestamp': '',
        'Action': 'UpdateDomainRecord'
    }
    params['RecordId'] = RecordId
    params['RR'] = RR
    params['Type'] = Type
    params['Value'] = Value

    timestamp = time.time()
    # formatTime = time.strftime(
    # "%Y-%m-%dT%H:%M:%SZ", time.localtime(time.time() - 8 * 60 * 60))
    utc_dt = datetime.utcnow().replace(tzinfo=timezone.utc)
    formatTime=utc_dt.strftime("%Y-%m-%dT%H:%M:%SZ")
    params['Timestamp'] = formatTime
    params['SignatureNonce'] = timestamp

    Signature = getSignature(params)
    params['Signature'] = Signature
    list = []
    for key in params:
        list.append(percentEncode(key) + "=" + percentEncode(str(params[key])))
    list.sort()
    paramStr = "&".join(list)
    url = "https://alidns.aliyuncs.com/?" + paramStr
    # print("url:" + url)
    try:
        print("更新 " + RR + " " + " " + Type + " " + Value)
        context = ssl._create_unverified_context()
        jsonStr = urllib.request.urlopen(
            url, context=context).read().decode("utf8")
        print("更新成功")
        return json.loads(jsonStr)
    except error.HTTPError as e:
        print(e)
        print("更新失败：" + e.read().decode("utf8"))


def percentEncode(str):
    res = quote(str, 'utf8')
    res = res.replace('+', '%20')
    res = res.replace('*', '%2A')
    res = res.replace('%7E', '~')
    return res


def get_Local_ipv6_address_win():
    """
        Get local ipv6
    """
    # pageURL = 'https://ip.zxinc.org/ipquery/'
    # pageURL = 'https://ip.sb/'
    pageURL = 'https://api-ipv6.ip.sb/ip'
    content = urllib.request.urlopen(pageURL).read()
    webContent = content.decode("utf8")

    print(webContent)
    ipv6_pattern = '(([a-f0-9]{1,4}:){7}[a-f0-9]{1,4})'

    m = re.search(ipv6_pattern, webContent)

    if m is not None:
        return m.group()
    else:
        return None


def get_Local_ipv6_address_win2():
    """
        Get local ipv6
    """
    # pageURL = 'https://ip.zxinc.org/ipquery/'
    linelist = os.popen(''' ipconfig ''').readlines()
    webContent = ""
    for item in linelist:
        webContent += item

    print(linelist)
    ipv6_pattern = '(([a-f0-9]{1,4}:){7}[a-f0-9]{1,4})'

    m = re.search(ipv6_pattern, webContent)

    if m is not None:
        return m.group()
    else:
        return None


def get_Local_ipv6_address_linux():
    """
        Get local ipv6
    """
    # pageURL = 'https://ip.zxinc.org/ipquery/'
    # pageURL = 'https://ip.sb/'
    linelist = os.popen(
        ''' ip addr show eth0 | grep "inet6.*global" | awk \'{print $2}\' | awk -F"/" \'{print $1}\' ''').readlines()  # 这个返回值是一个list
    if linelist:
        content = linelist[0].strip()
    else:
        return None
    ipv6_pattern = '(([a-f0-9]{1,4}:){7}[a-f0-9]{1,4})'

    m = re.search(ipv6_pattern, content)

    if m is not None:
        return m.group()
    else:
        return None


def get_ipv4_net():
    context = ssl._create_unverified_context()
    res = urllib.request.urlopen("https://api-ipv4.ip.sb/jsonip", context=context)
    return json.loads(res.read().decode('utf8'))['ip']


def get_local_ipv6():
    sysPlatform = sys.platform
    ipv6Addr = ""
    ipv6Addr = get_Local_ipv6_address_win()
    
    if ipv6Addr == None:
        if sysPlatform == "linux":
            ipv6Addr = get_Local_ipv6_address_linux()
            print()
        elif sysPlatform == "win32":
            ipv6Addr = get_Local_ipv6_address_win2()
        else:
            ipv6Addr = get_Local_ipv6_address_win()
    return ipv6Addr


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.description = '阿里云云解析工具'
    # parser.add_argument("key", help="从https://ak-console.aliyun.com/#/accesskey得到的AccessKeyId", type=str)
    # parser.add_argument("secret", help="从https://ak-console.aliyun.com/#/accesskey得到的AccessKeySecret", type=str)
    parser.add_argument("RR", help="RR例子：@, *, www, ...", type=str)
    parser.add_argument("DomainName", help="domain例子: aliyun.com, baidu.com, google.com, ...", type=str)
    parser.add_argument("Type", help="类型(A/AAAA)", type=str)
    parser.add_argument("--value", help="[value]", type=str)
    args = parser.parse_args()
    Type = ""
    ip = args.value
    if not ip:
        if args.Type.lower() == "a":
            ip = get_ipv4_net()
            Type = "A"
        elif args.Type.lower() == "aaaa":
            ip = get_local_ipv6()
            Type = "AAAA"
        else:
            print("参数不正确，例：python3 ./aliddns.py www baidu.com A")
            exit()
    else:
        Type = args.Type.upper()

    RR = args.RR
    DomainName = args.DomainName

    print("开始处理: RR:" + RR + " DomainName:" + DomainName)
    print("本机当前IP: " + ip)

    # client = AcsClient(args.key, args.secret, 'cn-hangzhou')
    recordListInfo = get_record_info(RR, DomainName, Type)

    if recordListInfo['TotalCount'] == 0:
        print("记录不存在，添加记录")
        add_domain_record(DomainName, RR, Type, ip)
    else:
        records = recordListInfo["DomainRecords"]["Record"]
        hasFind = "false"
        for record in records:
            if record['RR'] == RR and record['DomainName'] == DomainName and record['Type'] == Type:
                hasFind = "true"
                if record['Value'] == ip:
                    print("当前IP与历史A记录一致，无需更新")
                else:
                    print("更新域名")
                    response = requests.get(f'https://api.telegram.org/bot1822948434:AAEz9BJWMxaah6Zk79sc3XOT8L5HFu-YlLM/sendMessage?chat_id=459180203&text=发现jp.xun-da.com被墙，已为jp.xun-da.com更换新的IP地址，新的IP地址为:{ip}')
                    update_domain_record(record['RecordId'], RR, ip, Type)

        if not hasFind:
            print("记录不存在，添加记录")
            add_domain_record(DomainName, RR, Type, ip)
