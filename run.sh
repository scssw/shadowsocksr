#!/bin/bash
cd `dirname $0`
if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 not found"
    exit 1
fi

eval $(ps -ef | grep "[0-9] python3 server\\.py m" | awk '{print "kill "$2}')
ulimit -n 512000

# 优化内存分配，避免多线程 arena 内存泄漏与碎片化
for jepath in /usr/lib/x86_64-linux-gnu/libjemalloc.so.2 /usr/lib64/libjemalloc.so.2 /usr/lib/libjemalloc.so.2 /usr/lib/x86_64-linux-gnu/libjemalloc.so /usr/lib64/libjemalloc.so /usr/local/lib/libjemalloc.so.2; do
    if [ -f "$jepath" ]; then
        export LD_PRELOAD="$jepath"
        export MALLOC_CONF="background_thread:true,dirty_decay_ms:10000,muzzy_decay_ms:10000"
        break
    fi
done
if [ -z "$LD_PRELOAD" ]; then
    JE_LIB=$(ldconfig -p 2>/dev/null | grep -E 'libjemalloc\.so' | awk 'NR==1 {print $NF}')
    if [ -n "$JE_LIB" ] && [ -f "$JE_LIB" ]; then
        export LD_PRELOAD="$JE_LIB"
        export MALLOC_CONF="background_thread:true,dirty_decay_ms:10000,muzzy_decay_ms:10000"
    fi
fi
export MALLOC_ARENA_MAX=2
if [ ! -f "userapiconfig.py" ] && [ -f "apiconfig.py" ]; then
    cp -f apiconfig.py userapiconfig.py
fi

nohup python3 server.py m >> /dev/null 2>&1 &
