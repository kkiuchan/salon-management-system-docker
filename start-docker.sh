#!/bin/bash

echo "美容室管理システム - Docker版を起動します..."

# ホストマシンのIPアドレスを自動検出
echo "ホストIPアドレスを検出中..."
HOST_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')

if [ -z "$HOST_IP" ]; then
    # macOSの場合の代替方法
    HOST_IP=$(ifconfig en0 | grep "inet " | awk '{print $2}' 2>/dev/null)
fi

if [ -z "$HOST_IP" ]; then
    # Wi-Fiインターフェースを試行
    HOST_IP=$(ifconfig en1 | grep "inet " | awk '{print $2}' 2>/dev/null)
fi

if [ -n "$HOST_IP" ]; then
    echo "検出されたホストIP: $HOST_IP"
    export HOST_IP
else
    echo "ホストIPの自動検出に失敗しました。自動検出を使用します。"
    export HOST_IP="auto"
fi

# Docker Composeが利用可能かチェック
if command -v docker-compose &> /dev/null; then
    echo "Docker Composeを使用して起動します..."
    docker-compose up -d
elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
    echo "Docker Compose V2を使用して起動します..."
    docker compose up -d
else
    echo "エラー: Docker Composeが見つかりません"
    echo "Dockerをインストールしてください: https://docs.docker.com/get-docker/"
    exit 1
fi

echo ""
echo "✅ 起動完了!"
echo "📱 ローカルアクセス: http://localhost:3000"
if [ "$HOST_IP" != "auto" ]; then
    echo "🌐 ネットワークアクセス: http://$HOST_IP:3000"
fi
echo "📝 ログ確認: docker-compose logs -f salon-management"
echo "⏹️  停止方法: ./stop-docker.sh" 