#!/bin/bash
if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 not found"
    exit 1
fi

pkill -f "server\.py m" 2>/dev/null || eval $(ps -ef | grep "[0-9] .*python.*server\.py m" | awk '{print "kill "$2}')
sleep 0.5
