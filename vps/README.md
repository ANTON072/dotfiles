# さくら VPS Ubuntu セットアップスクリプト

さくら VPS の Ubuntu 環境を一括でセキュリティ設定とともにセットアップするためのスクリプト集です。

## 概要

`setup.sh`は、さくら VPS で Ubuntu サーバーを初期設定する際に必要な作業を自動化します。セキュリティ強化、開発環境構築、基本的なツールのインストールを対話的に実行できます。

## 機能

### 🔐 セキュリティ設定

- **SSH セキュリティ強化**
  - SSH 鍵認証の設定（新規生成または既存鍵の利用）
  - Root ログインの禁止
  - パスワード認証の無効化
  - SSH ポート番号の変更
- **ファイアウォール設定**
  - UFW の適切な設定（さくら VPS パケットフィルター推奨）
  - 必要ポートの案内表示

### 👤 ユーザー管理

- **一般ユーザーの作成**
  - sudo 権限の付与
  - Docker グループへの追加
  - 設定ファイルの自動コピー

### 🛠️ 開発環境構築

- **エディタ・ツール**
  - Vim のインストールと基本設定（.vimrc 作成）
  - tmux のインストールと設定（.tmux.conf 作成）
  - 基本的な開発ツール一式
- **コンテナ環境**
  - Docker CE のインストール
  - Docker Compose のインストール
  - ユーザーの Docker グループ追加

### 🌏 システム設定

- **ロケール・タイムゾーン**
  - 日本語環境の設定（オプション）
  - タイムゾーンを Asia/Tokyo に設定
- **システム最適化**
  - パッケージの更新
  - スワップファイルの作成（2GB）

## 使用方法

### 前提条件

- さくら VPS Ubuntu 環境
- sudo 権限を持つユーザーでの実行

### 実行手順

1. **スクリプトのダウンロード**

   ```bash
   wget https://your-repo/setup.sh
   chmod +x setup.sh
   ```

2. **実行**

   ```bash
   bash setup.sh
   ```

3. **対話的設定**
   スクリプト実行中に以下の項目について選択を求められます：
   - 新しいユーザーの作成
   - SSH 鍵認証の設定
   - SSH セキュリティ設定の強化
   - スワップファイルの作成

## 設定内容

### インストールされるパッケージ

```
curl, wget, git, build-essential, software-properties-common,
apt-transport-https, ca-certificates, gnupg, lsb-release,
net-tools, htop, unzip, vim, tmux, docker-ce, docker-ce-cli,
containerd.io, docker-compose-plugin, language-pack-ja
```

### 作成される設定ファイル

#### .vimrc

- 行番号表示
- タブの空白変換（2 スペース）
- 自動インデント
- 検索設定（大小文字無視、ハイライト）
- jj で ESC キー

#### .tmux.conf

- プレフィックスキー: Ctrl+g
- Vim ライクなキーバインド
- ペイン分割: `\` (水平), `-` (垂直)
- マウス操作サポート
- コピーモード設定

## セキュリティ設定詳細

### SSH 設定の変更点

```bash
# /etc/ssh/sshd_config の主な変更
PermitRootLogin no              # Root ログイン禁止
PasswordAuthentication no       # パスワード認証無効化（鍵設定時）
Port [指定ポート]               # デフォルト22番から変更
```

### 重要な注意事項

⚠️ **設定変更前の確認事項**

1. SSH 鍵認証が正しく設定されていることを確認
2. さくら VPS パケットフィルターで新しい SSH ポートを許可
3. 設定変更後の接続テストを必ず実施

⚠️ **設定完了後の必須作業**

1. **パケットフィルター設定**（さくら VPS コントロールパネル）
   - SSH ポート（変更した場合）: 許可
   - HTTP (80): Web サービス利用時
   - HTTPS (443): SSL 利用時
2. **セキュリティアップデート**

```bash
sudo apt update && sudo apt upgrade
```

## トラブルシューティング

### SSH 接続できない場合

1. パケットフィルターで SSH ポートが許可されているか確認
2. SSH 鍵のパーミッションを確認: `chmod 600 ~/.ssh/id_rsa`
3. SSH 設定ファイルのバックアップから復元: `/etc/ssh/sshd_config.backup.[日付]`

### Docker 権限エラー

```bash
# Docker グループ追加の反映のため再ログイン
exit
ssh [user]@[server]
```

### スワップファイルの確認

```bash
sudo swapon --show
free -h
```

## 設定後の推奨作業

1. **定期的なセキュリティ更新**

```bash
sudo apt update && sudo apt upgrade
```

2. **ログ監視の設定**

```bash
sudo tail -f /var/log/auth.log
```

3. **SSH 接続の確認**

```sh
ssh -i [秘密鍵] [ユーザー名]@[サーバーIP] -p [ポート番号]
```

## 🧪 ローカル環境でのテスト（Docker Compose）

本番環境で実行する前に、Docker を使ってローカルでテストすることができます。

```sh
cd test
chmod +x test.sh  # 実行権限を付与

# コンテナを起動してすぐに接続
./test.sh run

# コンテナ内でスクリプトを実行
sudo bash /home/ubuntu/setup.sh
```

### 📝 利用可能なコマンド

| コマンド          | 説明                               |
| ----------------- | ---------------------------------- |
| `./test.sh build` | Docker イメージをビルド            |
| `./test.sh run`   | コンテナを起動して接続             |
| `./test.sh exec`  | 実行中のコンテナに再接続           |
| `./test.sh test`  | 自動テスト（構文チェック等）を実行 |
| `./test.sh clean` | コンテナとイメージを削除           |
| `./test.sh help`  | ヘルプを表示                       |
