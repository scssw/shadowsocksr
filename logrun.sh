#!/bin/bash
cd `dirname $0`
if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 not found"
    exit 1
fi

eval $(ps -ef | grep "[0-9] python3 server\\.py m" | awk '{print "kill "$2}')
ulimit -n 512000

# 优化内存分配，避免多线程 arena 内存泄漏与碎片化
for jepath in /usr/lib/aarch64-linux-gnu/libjemalloc.so.2 /usr/lib/x86_64-linux-gnu/libjemalloc.so.2 /usr/lib64/libjemalloc.so.2 /usr/lib/libjemalloc.so.2 /usr/lib/aarch64-linux-gnu/libjemalloc.so /usr/lib/x86_64-linux-gnu/libjemalloc.so /usr/lib64/libjemalloc.so /usr/local/lib/libjemalloc.so.2; do
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

# 验证预加载是否兼容，若不兼容（如 ARM 平台特定内核）则自动回退，防止进程闪退
if [ -n "$LD_PRELOAD" ]; then
    if ! python3 -c "pass" >/dev/null 2>&1; then
        unset LD_PRELOAD
        unset MALLOC_CONF
    fi
fi
export MALLOC_ARENA_MAX=2
# 限制日志体积：超过 3MB 自动截取最后 2000 行，防止日志无休止膨胀导致磁盘 I/O 阻塞
if [ -f "ssserver.log" ]; then
    log_size=$(stat -c%s "ssserver.log" 2>/dev/null || stat -f%z "ssserver.log" 2>/dev/null || echo 0)
    if [ "$log_size" -gt 3145728 ]; then
        tail -n 2000 ssserver.log > ssserver.log.tmp 2>/dev/null && mv -f ssserver.log.tmp ssserver.log
    fi
fi

if [ ! -f "userapiconfig.py" ] && [ -f "apiconfig.py" ]; then
    cp -f apiconfig.py userapiconfig.py
fi

if [ -f "user-config.json" ] && [ -f "config.json" ]; then
    if ! python3 -c "import json; json.loads(open('user-config.json').read())" >/dev/null 2>&1; then
        rm -f user-config.json
    fi
fi

nohup python3 server.py m >> ssserver.log 2>&1 &
