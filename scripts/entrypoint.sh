#!/bin/sh
set -e

# 检查配置文件是否存在
if [ ! -f /data/config/config.yaml ]; then
    echo "Error: /data/config/config.yaml not found!"
    exit 1
fi

# 读取配置
TOKEN=$(yq e '.token' /data/config/config.yaml)
DOMAINS=$(yq e '.domains[]' /data/config/config.yaml | tr '\n' ',' | sed 's/,$//')
WAIT_TIME=$(yq e '.seconds' /data/config/config.yaml)
LE_ACCEPT_TERMS=$(yq e '.lets_encrypt.accept_terms' /data/config/config.yaml)
LE_ALGO=$(yq e '.lets_encrypt.algo' /data/config/config.yaml)
LE_CERTFILE=$(yq e '.lets_encrypt.certfile' /data/config/config.yaml)
LE_KEYFILE=$(yq e '.lets_encrypt.keyfile' /data/config/config.yaml)
IPV4=$(yq e '.ipv4 // ""' /data/config/config.yaml)
IPV6=$(yq e '.ipv6 // ""' /data/config/config.yaml)

# Let's Encrypt 初始化
if [ "$LE_ACCEPT_TERMS" = "true" ]; then
    # 清理可能的旧锁文件
    if [ -e "${WORK_DIR}/lock" ]; then
        rm -f "${WORK_DIR}/lock"
        echo "Reset dehydrated lock file"
    fi

    # 生成新证书
    if [ ! -d "${CERT_DIR}/live" ]; then
        touch "${WORK_DIR}/config"
        dehydrated --register --accept-terms --config "${WORK_DIR}/config"
    fi
fi

# 主循环
while true; do
    # 更新 IP 地址
    if [ -n "$IPV4" ]; then
        if [[ $IPV4 != *:/* ]]; then
            ipv4=$IPV4
        else
            ipv4=$(curl -s -m 10 "$IPV4")
        fi
    fi

    if [ -n "$IPV6" ]; then
        if [[ $IPV6 != *:/* ]]; then
            ipv6=$IPV6
        else
            ipv6=$(curl -s -m 10 "$IPV6")
        fi
    fi

    # 更新 DuckDNS
    if [ -n "$ipv6" ] && [[ $ipv6 == *:* ]]; then
        curl -s "https://www.duckdns.org/update?domains=${DOMAINS}&token=${TOKEN}&ipv6=${ipv6}&verbose=true"
    fi

    if [ -n "$ipv4" ] && [[ $ipv4 == *.* ]]; then
        curl -s "https://www.duckdns.org/update?domains=${DOMAINS}&token=${TOKEN}&ip=${ipv4}&verbose=true"
    fi

    # 更新 Let's Encrypt 证书
    if [ "$LE_ACCEPT_TERMS" = "true" ]; then
        dehydrated --cron --algo "${LE_ALGO}" --hook /usr/local/bin/hooks.sh --challenge dns-01 --domain "${DOMAINS}" --out "${CERT_DIR}" --config "${WORK_DIR}/config"
    fi

    sleep "${WAIT_TIME}"
done 