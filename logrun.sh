#!/bin/bash
cd `dirname $0`
if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 not found"
    exit 1
fi

eval $(ps -ef | grep "[0-9] python3 server\\.py m" | awk '{print "kill "$2}')
ulimit -n 512000
nohup python3 server.py m>> ssserver.log 2>&1 &
