#!/bin/sh
set -e

CONFIG_PATH=/data/config/config.yaml

# 读取配置
TOKEN=$(yq e '.token' $CONFIG_PATH)
SYS_CERTFILE=$(yq e '.lets_encrypt.certfile' $CONFIG_PATH)
SYS_KEYFILE=$(yq e '.lets_encrypt.keyfile' $CONFIG_PATH)

deploy_challenge() {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"
    
    # 通过 DuckDNS API 添加 TXT 记录
    curl -s "https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&txt=$TOKEN_VALUE"
}

clean_challenge() {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"
    
    # 清理验证用的 TXT 记录
    curl -s "https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&txt=removed&clear=true"
}

deploy_cert() {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}" TIMESTAMP="${6}"
    
    # 复制证书到指定位置
    cp -f "$FULLCHAINFILE" "/ssl/$SYS_CERTFILE"
    cp -f "$KEYFILE" "/ssl/$SYS_KEYFILE"
}

HANDLER="$1"; shift
if [ "${HANDLER}" = "deploy_challenge" ] || [ "${HANDLER}" = "clean_challenge" ] || [ "${HANDLER}" = "deploy_cert" ]; then
    "$HANDLER" "$@"
fi 