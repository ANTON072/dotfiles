#!/bin/bash

# さくらVPS Ubuntu セットアップスクリプト（セキュリティ強化版）
# 実行方法: bash setup.sh

set -e  # エラーが発生したら即座に終了

# 色付き出力の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 設定変数
NEW_USER=""
NEW_USER_PASSWORD=""
SSH_PORT="22"  # デフォルトは22、変更推奨
ENABLE_JAPANESE="yes"  # 日本語環境を有効にするか

# ログ出力関数
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

log_prompt() {
  echo -e "${BLUE}[INPUT]${NC} $1"
}

# ルート権限チェック
check_root() {
  if [[ $EUID -eq 0 ]]; then
    log_warn "rootユーザーで実行されています"
    log_info "さくらVPSのUbuntuはubuntuユーザーで実行することを推奨します"
    log_info "使用方法: sudo bash setup.sh"
    read -p "このまま続行しますか？ (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi
}

# システムの更新
update_system() {
  log_info "システムパッケージを更新しています..."
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get autoremove -y
  sudo apt-get autoclean
  log_info "システムパッケージの更新が完了しました"
}

# 基本的なツールのインストール
install_basic_tools() {
  log_info "基本的なツールをインストールしています..."
  
  # 必要な基本パッケージ
  PACKAGES=(
    "curl"
    "wget"
    "git"
    "build-essential"
    "software-properties-common"
    "apt-transport-https"
    "ca-certificates"
    "gnupg"
    "lsb-release"
    "net-tools"
    "htop"
    "unzip"
  )
  
  for package in "${PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $package "; then
      log_warn "$package は既にインストールされています"
    else
      log_info "$package をインストールしています..."
      sudo apt-get install -y "$package"
    fi
  done
}

# Vimのインストールとデフォルトエディタ設定
install_and_configure_vim() {
  if command -v vim &> /dev/null; then
    log_warn "Vim は既にインストールされています"
  else
    log_info "Vim をインストールしています..."
    sudo apt-get install -y vim
  fi
  
  # デフォルトエディタをvimに変更
  log_info "デフォルトエディタをVimに設定しています..."
  sudo update-alternatives --set editor /usr/bin/vim.basic 2>/dev/null || {
    log_warn "デフォルトエディタの自動設定に失敗しました"
    log_info "手動で設定してください: sudo update-alternatives --config editor"
  }
  
  # 基本的な.vimrcの作成（現在のユーザー用）
  if [ ! -f ~/.vimrc ]; then
    cat > ~/.vimrc << 'EOF'
set number              " 行番号
set expandtab           " タブを空白に
set tabstop=2          
set shiftwidth=2        
set autoindent          " 自動インデント
set ignorecase          " 検索で大小文字無視
set smartcase           
set hlsearch            " 検索ハイライト
syntax enable           " シンタックスハイライト
inoremap jj <Esc>      " jjでESC
EOF
    log_info "基本的な.vimrcを作成しました"
  fi
}

# tmuxのインストール
install_tmux() {
  if command -v tmux &> /dev/null; then
    log_warn "tmux は既にインストールされています"
  else
    log_info "tmux をインストールしています..."
    sudo apt-get install -y tmux
    
    # 基本的な.tmux.confの作成
    if [ ! -f ~/.tmux.conf ]; then
      cat > ~/.tmux.conf << 'EOF'
# プレフィックスキーの設定
unbind C-b
set -g prefix C-g
bind C-g send-prefix

# インデックスとウィンドウの基本設定
set -g base-index 1
setw -g pane-base-index 1
set-option -g renumber-windows on

# ペインのボーダー設定
set -g pane-border-style fg=colour238
set -g pane-active-border-style fg=colour119

# ペイン分割のキーバインド（ディレクトリを引き継ぐ）
bind \\ split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Vimライクなコピーモード設定
set -g mode-keys vi
bind-key -T copy-mode-vi 'v' send -X begin-selection
bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle

# ペインサイズ変更のキーバインド（Vimライク）
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# レスポンス改善
set -s escape-time 0

# マウス関連の設定
set-option -g mouse on

# マウスホイールでスクロール
bind-key -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'select-pane -t=; copy-mode -e; send-keys -M'"
bind-key -n WheelDownPane select-pane -t= \; send-keys -M

# コピーモードの設定
setw -g mode-keys vi

# マウスドラッグを終了してもコピーモードを維持する
unbind -T copy-mode-vi MouseDragEnd1Pane
EOF
      log_info "基本的な.tmux.confを作成しました"
    fi
  fi
}

# Dockerのインストール
install_docker() {
  if command -v docker &> /dev/null; then
    log_warn "Docker は既にインストールされています"
    docker --version
  else
    log_info "Docker をインストールしています..."
    
    # Dockerの公式GPGキーを追加
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Dockerリポジトリを追加
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Dockerをインストール
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    
    # Dockerサービスを有効化
    sudo systemctl enable docker
    sudo systemctl start docker
    
    # 現在のユーザーをdockerグループに追加
    sudo usermod -aG docker $USER
    
    log_info "Docker のインストールが完了しました"
    log_warn "Dockerグループへの追加を反映するには、一度ログアウトして再ログインしてください"
    docker --version
  fi
}

# Docker Composeのインストール
install_docker_compose() {
  if command -v docker-compose &> /dev/null || docker compose version &> /dev/null 2>&1; then
    log_warn "Docker Compose は既にインストールされています"
    docker compose version 2>/dev/null || docker-compose --version
  else
    log_info "Docker Compose をインストールしています..."
    
    # Docker Compose v2 (Docker CLIプラグイン)をインストール
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
    
    log_info "Docker Compose のインストールが完了しました"
    docker compose version
  fi
}

# ロケールと日本語環境の設定
setup_locale() {
  if [[ "$ENABLE_JAPANESE" == "yes" ]]; then
    log_info "日本語環境を設定しています..."
    
    # 現在のロケールを確認
    current_locale=$(localectl status | grep "System Locale" | cut -d'=' -f2)
    log_info "現在のロケール: $current_locale"
    
    # 日本語パッケージのインストール
    if ! dpkg -l | grep -q "language-pack-ja"; then
      log_info "日本語パッケージをインストールしています..."
      sudo apt-get install -y language-pack-ja
    fi
    
    # ロケールを日本語に設定
    log_info "ロケールを ja_JP.UTF-8 に設定しています..."
    sudo localectl set-locale LANG=ja_JP.UTF-8
    
    log_info "日本語環境の設定が完了しました"
  fi
}

# タイムゾーンの設定
setup_timezone() {
  log_info "タイムゾーンを Asia/Tokyo に設定しています..."
  sudo timedatectl set-timezone Asia/Tokyo
  log_info "現在の時刻: $(date)"
}

# 一般ユーザーの作成
create_user() {
  log_prompt "新しいユーザーを作成しますか？ (y/N): "
  read -n 1 -r
  echo
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_prompt "作成するユーザー名を入力してください: "
    read NEW_USER
    
    if id "$NEW_USER" &>/dev/null; then
      log_warn "ユーザー $NEW_USER は既に存在します"
      return
    fi
    
    log_info "ユーザー $NEW_USER を作成しています..."
    sudo adduser "$NEW_USER"
    
    # sudo権限を付与
    log_info "$NEW_USER にsudo権限を付与しています..."
    sudo gpasswd -a "$NEW_USER" sudo
    
    # Dockerグループに追加
    if getent group docker > /dev/null 2>&1; then
      sudo usermod -aG docker "$NEW_USER"
      log_info "$NEW_USER をdockerグループに追加しました"
    fi
    
    # 新しいユーザー用の.vimrcと.tmux.confをコピー
    if [ -f ~/.vimrc ]; then
      sudo cp ~/.vimrc /home/$NEW_USER/.vimrc
      sudo chown $NEW_USER:$NEW_USER /home/$NEW_USER/.vimrc
    fi
    
    if [ -f ~/.tmux.conf ]; then
      sudo cp ~/.tmux.conf /home/$NEW_USER/.tmux.conf
      sudo chown $NEW_USER:$NEW_USER /home/$NEW_USER/.tmux.conf
    fi
    
    log_info "ユーザー $NEW_USER の作成が完了しました"
  fi
}

# SSH鍵の生成と設定
setup_ssh_keys() {
  log_prompt "SSH鍵認証を設定しますか？ (y/N): "
  read -n 1 -r
  echo
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    TARGET_USER=${NEW_USER:-$USER}
    TARGET_HOME=$(eval echo ~$TARGET_USER)
    
    log_info "ユーザー $TARGET_USER 用のSSH鍵を設定しています..."
    
    # .sshディレクトリの作成
    if [ "$TARGET_USER" = "$USER" ]; then
      mkdir -p ~/.ssh
      chmod 700 ~/.ssh
    else
      sudo -u $TARGET_USER mkdir -p $TARGET_HOME/.ssh
      sudo chmod 700 $TARGET_HOME/.ssh
    fi
    
    log_prompt "SSH鍵を生成しますか？ それとも既存の公開鍵を使用しますか？ (g:生成/e:既存): "
    read -n 1 -r KEY_OPTION
    echo
    
    if [[ $KEY_OPTION == "g" ]]; then
      # 新しい鍵を生成
      log_info "SSH鍵を生成しています..."
      ssh-keygen -t rsa -b 4096 -f /tmp/id_rsa_$TARGET_USER -N ""
      
      # 公開鍵をauthorized_keysに追加
      if [ "$TARGET_USER" = "$USER" ]; then
        cat /tmp/id_rsa_$TARGET_USER.pub >> ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
      else
        sudo sh -c "cat /tmp/id_rsa_$TARGET_USER.pub >> $TARGET_HOME/.ssh/authorized_keys"
        sudo chmod 600 $TARGET_HOME/.ssh/authorized_keys
        sudo chown $TARGET_USER:$TARGET_USER $TARGET_HOME/.ssh/authorized_keys
      fi
      
      log_warn "========================================="
      log_warn "重要: 以下の秘密鍵を安全な場所に保存してください"
      log_warn "========================================="
      cat /tmp/id_rsa_$TARGET_USER
      log_warn "========================================="
      log_warn "この秘密鍵は画面を閉じると失われます！"
      log_warn "========================================="
      
      # 一時ファイルを削除
      rm -f /tmp/id_rsa_$TARGET_USER /tmp/id_rsa_$TARGET_USER.pub
      
    elif [[ $KEY_OPTION == "e" ]]; then
      # 既存の公開鍵を使用
      log_prompt "公開鍵を貼り付けてください (ssh-rsa で始まる1行): "
      read PUBLIC_KEY
      
      if [ "$TARGET_USER" = "$USER" ]; then
        echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
      else
        echo "$PUBLIC_KEY" | sudo tee -a $TARGET_HOME/.ssh/authorized_keys > /dev/null
        sudo chmod 600 $TARGET_HOME/.ssh/authorized_keys
        sudo chown $TARGET_USER:$TARGET_USER $TARGET_HOME/.ssh/authorized_keys
      fi
      
      log_info "公開鍵を追加しました"
    fi
  fi
}

# SSHセキュリティ設定
configure_ssh_security() {
  log_info "SSHセキュリティ設定を強化しています..."
  
  # sshd_configのバックアップ
  sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d)
  
  # Rootログインの禁止
  log_prompt "Rootログインを禁止しますか？ (推奨) (y/N): "
  read -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    log_info "Rootログインを禁止しました"
  fi
  
  # パスワード認証の禁止（SSH鍵認証が設定されている場合のみ）
  if [ -f ~/.ssh/authorized_keys ] || [ -f /home/$NEW_USER/.ssh/authorized_keys ]; then
    log_prompt "パスワード認証を禁止しますか？ (SSH鍵設定済みの場合推奨) (y/N): "
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
      log_info "パスワード認証を禁止しました"
    fi
  else
    log_warn "SSH鍵が設定されていないため、パスワード認証の禁止はスキップします"
  fi
  
  # SSHポートの変更
  log_prompt "SSHポートを変更しますか？ (現在: 22) (y/N): "
  read -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_prompt "新しいポート番号を入力してください (1024-65535): "
    read SSH_PORT
    
    if [[ $SSH_PORT -ge 1024 && $SSH_PORT -le 65535 ]]; then
      sudo sed -i "s/^#*Port .*/Port $SSH_PORT/" /etc/ssh/sshd_config
      log_info "SSHポートを $SSH_PORT に変更しました"
      log_warn "さくらVPSのパケットフィルターで ポート $SSH_PORT を許可してください！"
    else
      log_error "無効なポート番号です。変更をスキップします"
    fi
  fi
  
  # SSH設定の再起動
  log_info "SSH設定を反映しています..."
  sudo systemctl restart ssh
  log_info "SSH設定の強化が完了しました"
}

# ファイアウォールの設定
setup_firewall() {
  log_info "ファイアウォール設定を確認しています..."
  
  # UFWが有効な場合は無効化（さくらVPSのパケットフィルターを使用するため）
  if command -v ufw &> /dev/null; then
    if sudo ufw status | grep -q "Status: active"; then
      log_warn "UFWが有効になっています。さくらVPSのパケットフィルターを使用するため無効化します"
      sudo ufw disable
    else
      log_info "UFWは無効になっています（さくらVPSのパケットフィルター推奨）"
    fi
  fi
  
  log_info "========================================="
  log_info "重要: さくらVPSのコントロールパネルで以下を設定してください"
  log_info "========================================="
  log_info "パケットフィルター設定:"
  log_info "  - SSH (ポート $SSH_PORT): 許可 [必須]"
  log_info "  - HTTP (80番ポート): Webサービス利用時に許可"
  log_info "  - HTTPS (443番ポート): SSL利用時に許可"
  log_info "  - その他必要なポートを適宜追加"
  log_info "========================================="
}

# スワップファイルの作成
setup_swap() {
  log_prompt "スワップファイル(2GB)を作成しますか？ (メモリが少ない場合推奨) (y/N): "
  read -n 1 -r
  echo
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f /swapfile ]; then
      log_warn "スワップファイルは既に存在します"
    else
      log_info "スワップファイルを作成しています（2GB）..."
      sudo fallocate -l 2G /swapfile
      sudo chmod 600 /swapfile
      sudo mkswap /swapfile
      sudo swapon /swapfile
      echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
      log_info "スワップファイルの作成が完了しました"
    fi
  fi
}

# 最終確認と情報表示
show_summary() {
  echo ""
  log_info "========================================="
  log_info "セットアップが完了しました！"
  log_info "========================================="
  echo ""
  log_info "システム設定:"
  echo "  - タイムゾーン: Asia/Tokyo"
  if [[ "$ENABLE_JAPANESE" == "yes" ]]; then
    echo "  - ロケール: ja_JP.UTF-8"
  fi
  echo "  - デフォルトエディタ: Vim"
  echo ""
  
  log_info "インストール済みソフトウェア:"
  echo "  - Vim: $(vim --version | head -1)"
  echo "  - tmux: $(tmux -V)"
  echo "  - Docker: $(docker --version)"
  echo "  - Docker Compose: $(docker compose version 2>/dev/null || echo 'v2 plugin')"
  echo ""
  
  if [ ! -z "$NEW_USER" ]; then
    log_info "作成したユーザー:"
    echo "  - ユーザー名: $NEW_USER (sudo権限付与済み)"
  fi
  echo ""
  
  log_info "SSHセキュリティ設定:"
  echo "  - SSHポート: $SSH_PORT"
  echo "  - Rootログイン: $(grep "^PermitRootLogin" /etc/ssh/sshd_config | cut -d' ' -f2)"
  echo "  - パスワード認証: $(grep "^PasswordAuthentication" /etc/ssh/sshd_config | cut -d' ' -f2)"
  echo ""
  
  log_warn "重要な次のステップ:"
  echo "  1. さくらVPSコントロールパネルでパケットフィルターを設定"
  if [ "$SSH_PORT" != "22" ]; then
    echo "     特に SSHポート $SSH_PORT の許可を忘れずに！"
  fi
  echo "  2. SSH鍵でのログインを確認してからパスワード認証を無効化"
  echo "  3. 定期的なセキュリティアップデート: sudo apt update && sudo apt upgrade"
  echo ""
  
  if [ ! -z "$NEW_USER" ]; then
    log_info "新しいユーザーでSSH接続する場合:"
    echo "  ssh -i [秘密鍵パス] $NEW_USER@[サーバーIP] -p $SSH_PORT"
  fi
}

# メイン処理
main() {
  log_info "さくらVPS Ubuntu セットアップスクリプトを開始します..."
  echo ""
  
  check_root
  update_system
  install_basic_tools
  install_and_configure_vim
  install_tmux
  install_docker
  install_docker_compose
  setup_locale
  setup_timezone
  create_user
  setup_ssh_keys
  configure_ssh_security
  setup_firewall
  setup_swap
  show_summary
  
  log_info "セットアップスクリプトが正常に完了しました！"
}

# スクリプトの実行
main "$@"
