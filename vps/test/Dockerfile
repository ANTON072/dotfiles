# さくらVPS Ubuntu環境を再現
FROM ubuntu:22.04

# 環境変数設定（対話的プロンプトを無効化）
ENV DEBIAN_FRONTEND=noninteractive

# 基本パッケージのインストール
RUN apt-get update && apt-get install -y \
    sudo \
    systemd \
    systemd-sysv \
    curl \
    wget \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# テスト用ユーザー作成（さくらVPSのubuntuユーザーを模倣）
RUN useradd -m -s /bin/bash ubuntu && \
    echo 'ubuntu:ubuntu' | chpasswd && \
    usermod -aG sudo ubuntu && \
    echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# 作業ディレクトリ
WORKDIR /home/ubuntu

# スクリプトをコピー（ビルド時）
COPY ../setup.sh /home/ubuntu/setup.sh
RUN chmod +x /home/ubuntu/setup.sh

# デフォルトユーザー
USER ubuntu

# エントリーポイント
CMD ["/bin/bash"]
