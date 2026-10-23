#!/bin/bash
cd "$(dirname "$0")"

if ! ps -ef | grep -v grep | grep -q "server.py"; then
    echo -e "\033[31m[警告] ShadowsocksR 进程未在运行！\033[0m"
    echo -e "\033[33m以下为最近 50 行历史日志（含可能的报错信息）：\033[0m"
    echo "=================================================="
    if [ -f "ssserver.log" ]; then
        tail -n 50 ssserver.log
    else
        echo "日志文件 ssserver.log 不存在"
    fi
    echo "=================================================="
    echo "按回车键返回上级菜单..."
    read -r
    exit 0
fi

echo -e "\033[32m正在实时查看日志 (按 Ctrl+C 返回菜单)...\033[0m"
echo "=================================================="
if [ -f "ssserver.log" ]; then
    tail -n 30 -f ssserver.log
else
    echo "日志文件 ssserver.log 不存在"
fi
