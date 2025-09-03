# Nginx Reverse Proxy with SSL/TLS Support

このディレクトリには、複数の Web アプリケーションを単一のサーバーでホストするためのリバースプロキシ設定が含まれています。

## 概要

`docker-compose.yml` は以下の 2 つのサービスを定義しています：

1. **nginx-proxy**: 自動的に Docker コンテナを検出し、リバースプロキシとして機能
2. **letsencrypt**: Let's Encrypt を使用して SSL/TLS 証明書を自動取得・更新

## 主な機能

- **自動リバースプロキシ**: 環境変数 `VIRTUAL_HOST` を持つコンテナを自動的に検出
- **SSL/TLS 自動化**: Let's Encrypt による証明書の自動取得と更新
- **HTTP/HTTPS 対応**: ポート 80（HTTP）と 443（HTTPS）でリクエストを受付

## ディレクトリ構造

```text
proxy/
├── docker-compose.yml
├── certs/          # SSL/TLS証明書
├── vhost/          # バーチャルホスト設定
├── html/           # Let's Encrypt認証用
└── acme/           # ACME設定
```

## 使用方法

1. **ネットワークの作成**（初回のみ）:

   ```bash
   docker network create proxy-network
   ```

2. **プロキシの起動**:

   ```bash
   docker-compose up -d
   ```

3. **他のアプリケーションとの連携**:
   アプリケーションの docker-compose.yml に以下を追加:

   ```yaml
   services:
     app:
       environment:
         - VIRTUAL_HOST=example.com
         - LETSENCRYPT_HOST=example.com
       networks:
         - proxy-network

   networks:
     proxy-network:
       external: true
   ```

## 設定項目

- **DEFAULT_EMAIL**: Let's Encrypt 証明書のメール通知先（現在: ougi@strobe-scop.net）
- **ポート**: 80 番（HTTP）、443 番（HTTPS）

## 注意事項

- Docker ソケット（`/var/run/docker.sock`）への読み取り専用アクセスが必要
- 証明書の自動更新のため、コンテナは常時起動（`restart: always`）
- すべての関連コンテナは同じ `proxy-network` に接続する必要がある
