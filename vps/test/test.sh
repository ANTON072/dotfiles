#!/bin/bash

# テスト実行スクリプト
# 使い方: cd test && bash test.sh

set -e

# 色付き出力
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}===========================================
    さくらVPS Setup Script テスト環境
===========================================${NC}"

# コマンドの説明
show_help() {
  echo -e "${GREEN}使用可能なコマンド:${NC}"
  echo "  ./test.sh build   - Dockerイメージをビルド"
  echo "  ./test.sh run     - コンテナを起動して接続"
  echo "  ./test.sh exec    - 実行中のコンテナに接続"
  echo "  ./test.sh test    - 自動テストを実行"
  echo "  ./test.sh clean   - コンテナとイメージを削除"
  echo "  ./test.sh help    - このヘルプを表示"
}

# Dockerイメージのビルド
build_image() {
  echo -e "${YELLOW}Dockerイメージをビルドしています...${NC}"
  docker-compose build
  echo -e "${GREEN}✓ ビルド完了${NC}"
}

# コンテナの起動と接続
run_container() {
  echo -e "${YELLOW}コンテナを起動しています...${NC}"
  
  # 既存のコンテナがあれば停止
  docker-compose down 2>/dev/null || true
  
  # コンテナを起動
  docker-compose up -d
  
  echo -e "${GREEN}✓ コンテナが起動しました${NC}"
  echo -e "${BLUE}コンテナに接続しています...${NC}"
  
  # ubuntuユーザーとして接続
  docker exec -it -u ubuntu sakura-vps-ubuntu /bin/bash
}

# 実行中のコンテナに接続
exec_container() {
  if docker ps | grep -q sakura-vps-ubuntu; then
    echo -e "${BLUE}コンテナに接続しています...${NC}"
    docker exec -it -u ubuntu sakura-vps-ubuntu /bin/bash
  else
    echo -e "${RED}コンテナが起動していません${NC}"
    echo -e "${YELLOW}先に './test.sh run' を実行してください${NC}"
    exit 1
  fi
}

# 自動テストの実行
run_test() {
  echo -e "${YELLOW}自動テストを開始します...${NC}"
  
  # コンテナを起動
  docker-compose up -d
  
  # テストコマンドを実行（非対話モード）
  docker exec -u ubuntu sakura-vps-ubuntu /bin/bash -c "
    echo '=== システム情報 ==='
    cat /etc/os-release | grep -E 'NAME|VERSION'
    echo ''
    echo '=== setup.sh の存在確認 ==='
    ls -la /home/ubuntu/setup.sh
    echo ''
    echo '=== スクリプトの構文チェック ==='
    bash -n /home/ubuntu/setup.sh && echo '✓ 構文エラーなし'
    echo ''
    echo '=== ドライラン実行 ==='
    echo 'スクリプトを手動で実行してください: sudo bash /home/ubuntu/setup.sh'
  "
  
  echo -e "${GREEN}✓ 自動テスト完了${NC}"
  echo -e "${YELLOW}対話的にテストする場合: ./test.sh exec${NC}"
}

# クリーンアップ
clean_up() {
  echo -e "${YELLOW}クリーンアップを実行しています...${NC}"
  docker-compose down
  docker rmi sakura-vps-test:latest 2>/dev/null || true
  echo -e "${GREEN}✓ クリーンアップ完了${NC}"
}

# メイン処理
case ${1:-help} in
  build)
    build_image
    ;;
  run)
    build_image
    run_container
    ;;
  exec)
    exec_container
    ;;
  test)
    build_image
    run_test
    ;;
  clean)
    clean_up
    ;;
  help|*)
    show_help
    ;;
esac
