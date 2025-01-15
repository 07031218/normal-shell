#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import subprocess
from typing import Optional, Tuple

# ANSI 颜色代码
class Colors:
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    RED = '\033[0;31m'
    NC = '\033[0m'  # No Color

def print_colored(text: str, color: str):
    """打印彩色文本"""
    print(f"{color}{text}{Colors.NC}")

def install_pymysql():
    """安装 PyMySQL 模块"""
    print_colored("\n正在安装 PyMySQL 模块...", Colors.YELLOW)
    try:
        # 尝试使用 python3 安装
        try:
            subprocess.check_call(["python3", "-m", "pip", "install", "--user", "pymysql"])
            print_colored("PyMySQL 安装成功！", Colors.GREEN)
            
            # 重新导入
            global pymysql
            import pymysql
            return True
        except subprocess.CalledProcessError:
            # 如果用户级安装失败，尝试使用 sudo
            print_colored("尝试使用 sudo 安装...", Colors.YELLOW)
            try:
                subprocess.check_call(["sudo", "python3", "-m", "pip", "install", "pymysql"])
                print_colored("PyMySQL 安装成功！", Colors.GREEN)
                
                # 重新导入
                global pymysql
                import pymysql
                return True
            except subprocess.CalledProcessError as e:
                print_colored(f"安装失败: {e}", Colors.RED)
                print_colored("\n请手动尝试以下命令：", Colors.YELLOW)
                print_colored("1. python3 -m pip install --user pymysql", Colors.GREEN)
                print_colored("2. sudo python3 -m pip install pymysql", Colors.GREEN)
                return False
                
    except Exception as e:
        print_colored(f"安装过程出错: {e}", Colors.RED)
        return False

# 检查并安装 PyMySQL
try:
    import pymysql
except ImportError:
    print_colored("检测到未安装 PyMySQL 模块", Colors.YELLOW)
    if not install_pymysql():
        sys.exit(1)

# 数据库配置
DB_CONFIG = {
    'host': '',
    'user': '',
    'password': '',
    'db': '',
    'charset': 'utf8mb4'
}

# 证书目录
CERT_DIR = "/certs"

def check_cert_dir_permissions() -> bool:
    """检查证书目录权限"""
    try:
        if not os.path.exists(CERT_DIR):
            os.makedirs(CERT_DIR, mode=0o755)
        elif not os.access(CERT_DIR, os.W_OK):
            print_colored(f"错误：无权限写入证书目录 {CERT_DIR}", Colors.RED)
            return False
        return True
    except Exception as e:
        print_colored(f"检查证书目录权限时出错: {e}", Colors.RED)
        return False

def restart_nginx() -> bool:
    """重启 nginx 服务"""
    try:
        subprocess.check_call(["service", "nginx", "restart"])
        print_colored("nginx 服务重启完成", Colors.GREEN)
        return True
    except subprocess.CalledProcessError as e:
        print_colored(f"nginx 重启失败: {e}", Colors.RED)
        return False
    except Exception as e:
        print_colored(f"重启 nginx 时发生错误: {e}", Colors.RED)
        return False

def clear_screen():
    """清屏"""
    os.system('cls' if os.name == 'nt' else 'clear')

def test_db_connection() -> bool:
    """测试数据库连接"""
    try:
        conn = pymysql.connect(**DB_CONFIG)
        conn.close()
        return True
    except pymysql.Error as e:
        print_colored(f"数据库连接错误: {e}", Colors.RED)
        print_colored("\n请检查以下内容：", Colors.YELLOW)
        print("1. 数据库连接信息是否正确")
        print("2. 数据库服务是否运行")
        print("3. 防火墙是否允许连接")
        return False

def get_certificate(domain: str) -> Optional[Tuple[str, str]]:
    """查询域名证书信息"""
    try:
        conn = pymysql.connect(**DB_CONFIG)
        try:
            with conn.cursor() as cursor:
                sql = """
                    SELECT o.fullchain, o.privatekey 
                    FROM dnsmgr_cert_order o 
                    INNER JOIN dnsmgr_cert_domain d ON o.id = d.id 
                    WHERE d.domain = %s
                """
                cursor.execute(sql, (domain,))
                result = cursor.fetchone()
                return result if result else None
        finally:
            conn.close()
    except pymysql.Error as e:
        print_colored(f"数据库错误: {e}", Colors.RED)
        return None

def save_certificate(domain: str, cert_data: Tuple[str, str]) -> bool:
    """保存证书到文件"""
    try:
        domain_cert_dir = f"{CERT_DIR}/{domain}/certificate"
        os.makedirs(domain_cert_dir, mode=0o755, exist_ok=True)
        
        fullchain, privatekey = cert_data
        
        # 保存完整证书链
        with open(f"{domain_cert_dir}/chained.pem", "w") as f:
            f.write(fullchain)
        
        # 保存私钥
        with open(f"{domain_cert_dir}/domain.key", "w") as f:
            f.write(privatekey)
            
        # 设置适当的文件权限
        os.chmod(f"{domain_cert_dir}/chained.pem", 0o644)
        os.chmod(f"{domain_cert_dir}/domain.key", 0o600)
            
        return True
    except IOError as e:
        print_colored(f"保存证书文件时出错: {e}", Colors.RED)
        return False
    except Exception as e:
        print_colored(f"处理证书文件时出错: {e}", Colors.RED)
        return False

def process_domain(domain: str) -> Optional[str]:
    """处理域名，获取第一个点后面的内容"""
    try:
        # 用点分割域名
        parts = domain.split('.')
        if len(parts) < 2:
            print_colored("错误：输入的不是有效的域名格式", Colors.RED)
            return None
        # 返回第一个点后面的所有内容
        return '.'.join(parts[1:])
    except Exception as e:
        print_colored(f"域名处理错误: {e}", Colors.RED)
        return None

def main():
    """主函数"""
    try:
        # 检查证书目录权限
        if not check_cert_dir_permissions():
            input("\n按回车键退出...")
            return

        # 测试数据库连接
        if not test_db_connection():
            input("\n按回车键退出...")
            return

        while True:
            clear_screen()
            print_colored("域名证书查询工具", Colors.GREEN)
            print("------------------------")
            
            try:
                # 获取用户输入
                print_colored("\n请输入要查询的域名 (输入 'q' 退出):", Colors.YELLOW)
                print_colored("例如: www.example.com 将会查询 *.example.com", Colors.YELLOW)
                domain = input("> ").strip()
                
                if domain.lower() == 'q':
                    print_colored("\n感谢使用，再见！", Colors.GREEN)
                    break
                
                if not domain:
                    print_colored("错误：域名不能为空，请重新输入", Colors.RED)
                    input("\n按回车键继续...")
                    continue

                # 处理域名
                processed_domain = process_domain(domain)
                if not processed_domain:
                    input("\n按回车键继续...")
                    continue
                
                # 添加通配符
                wildcard_domain = f"*.{processed_domain}"
                print_colored(f"\n将查询域名: {wildcard_domain}", Colors.YELLOW)
                print_colored("正在查询数据库...", Colors.YELLOW)
                
                # 查询证书
                cert_data = get_certificate(wildcard_domain)
                if not cert_data:
                    print_colored(f"未找到域名 '{wildcard_domain}' 的证书信息", Colors.RED)
                    input("\n按回车键继续...")
                    continue
                    
                # 保存证书
                if save_certificate(domain, cert_data):
                    print_colored("\n证书已成功保存：", Colors.GREEN)
                    print_colored(f"完整证书链: {CERT_DIR}/{domain}/certificate/chained.pem", Colors.YELLOW)
                    print_colored(f"私钥: {CERT_DIR}/{domain}/certificate/domain.key", Colors.YELLOW)
                    
                    # 重启 nginx
                    if not restart_nginx():
                        print_colored("请手动重启 nginx 服务", Colors.YELLOW)
                
                # 询问是否继续
                print_colored("\n是否继续查询其他域名？(y/n)", Colors.YELLOW)
                if input("> ").lower() != 'y':
                    print_colored("\n感谢使用，再见！", Colors.GREEN)
                    break

            except KeyboardInterrupt:
                print_colored("\n\n程序被中断，正在退出...", Colors.YELLOW)
                break
                
    except KeyboardInterrupt:
        print_colored("\n\n程序被中断，正在退出...", Colors.YELLOW)
    except Exception as e:
        print_colored(f"\n发生错误: {e}", Colors.RED)
    finally:
        print_colored("\n感谢使用，再见！", Colors.GREEN)

if __name__ == "__main__":
    main()
