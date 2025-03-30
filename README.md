# DuckDNS Cert

一个独立的 DuckDNS 容器，用于自动更新 DuckDNS 域名记录并管理 SSL 证书。

## 功能特点

- 自动更新 DuckDNS 域名记录
- 支持 IPv4 和 IPv6
- 集成 Let's Encrypt 证书管理
- 支持 DNS-01 验证
- 自动证书续期
- 支持自定义 IP 地址检测

## 使用方法

1. 创建配置文件：
   ```bash
   mkdir config
   cp config.yaml.example config/config.yaml
   ```

2. 编辑 `config.yaml`：
   - 设置您的 DuckDNS 域名
   - 添加您的 DuckDNS token
   - 如果需要，配置 Let's Encrypt 选项

3. 运行容器：
   ```bash
   docker run -d --name duckdns-cert -v ./config:/data/config -v ~/ssl:/ssl duckdns-cert
   ```

## 配置说明

### 必需配置
- `domains`: DuckDNS 域名列表
- `token`: DuckDNS API token

### 可选配置
- `aliases`: 域名别名列表
- `lets_encrypt`: Let's Encrypt 配置
  - `accept_terms`: 是否接受 Let's Encrypt 条款
  - `algo`: 证书算法 (rsa/prime256v1/secp384r1)
  - `certfile`: 证书文件名
  - `keyfile`: 私钥文件名
- `seconds`: 更新间隔（秒）
- `ipv4`: IPv4 地址或检测 URL
- `ipv6`: IPv6 地址或检测 URL

## 构建镜像

```bash
docker build -t duckdns-cert .
```

## 注意事项

1. 确保配置文件权限正确
2. 确保 SSL 目录有正确的权限
3. 定期备份证书和配置
4. 如果使用 Let's Encrypt，请确保域名解析正确

## 许可证

MIT License 