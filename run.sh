#!/bin/bash
cd `dirname $0`
if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 not found"
    exit 1
fi

eval $(ps -ef | grep "[0-9] python3 server\\.py m" | awk '{print "kill "$2}')
ulimit -n 512000

# 优化内存分配，避免多线程 arena 内存泄漏与碎片化
for jepath in /usr/lib/x86_64-linux-gnu/libjemalloc.so.2 /usr/lib64/libjemalloc.so.2 /usr/lib/libjemalloc.so.2 /usr/lib/x86_64-linux-gnu/libjemalloc.so /usr/lib64/libjemalloc.so; do
    if [ -f "$jepath" ]; then
        export LD_PRELOAD="$jepath"
        export MALLOC_CONF="background_thread:true,dirty_decay_ms:10000,muzzy_decay_ms:10000"
        break
    fi
done
export MALLOC_ARENA_MAX=2
nohup python3 server.py m>> /dev/null 2>&1 &
