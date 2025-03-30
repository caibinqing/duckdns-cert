FROM alpine:3.20

# 安装必要的包
RUN apk add --no-cache \
    openssl \
    curl \
    yq \
    bash

# 安装 dehydrated
ARG DEHYDRATED_VERSION=0.7.1
RUN curl -s -o /usr/bin/dehydrated \
    "https://raw.githubusercontent.com/dehydrated-io/dehydrated/v${DEHYDRATED_VERSION}/dehydrated" \
    && chmod a+x /usr/bin/dehydrated

# 创建必要的目录
RUN mkdir -p /data/letsencrypt /data/workdir /ssl

# 复制脚本
COPY scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# 设置环境变量
ENV CERT_DIR=/data/letsencrypt \
    WORK_DIR=/data/workdir \
    SSL_DIR=/ssl

# 设置入口点
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
