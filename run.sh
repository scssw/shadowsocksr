#!/bin/bash
cd `dirname $0`
# 优先尝试python3，如果不存在则使用python2
if command -v python3 >/dev/null 2>&1; then
    python_ver="python3"
elif command -v python2 >/dev/null 2>&1; then
    python_ver="python2"
else
    echo "Error: Neither python2 nor python3 found"
    exit 1
fi

eval $(ps -ef | grep "[0-9] ${python_ver} server\\.py m" | awk '{print "kill "$2}')
ulimit -n 512000
nohup ${python_ver} server.py m>> /dev/null 2>&1 &

