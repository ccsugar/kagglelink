#!/bin/bash

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: ./start_zrok.sh <zrok_token> <reserved_name_or_token>"
    exit 1
fi

ZROK_TOKEN=$1
RESERVED_NAME=$2

cleanup() {
    echo "Disabling zrok environment..."
    zrok disable
    echo "Cleanup complete."
}

trap cleanup EXIT

echo "Starting zrok service..."
if [ -z "$ZROK_TOKEN" ]; then
    echo "Error: ZROK_TOKEN not provided."
    exit 1
fi

echo "Enabling zrok with provided token..."
zrok enable "$ZROK_TOKEN" || {
    echo "Failed to enable zrok with provided token."
    exit 1
}

# 创建 reserved share
if [ -n "$RESERVED_NAME" ]; then
    echo "Reserving share with name/token: $RESERVED_NAME ..."
    zrok reserve private localhost:22 --backend-mode tcpTunnel --unique-name "$RESERVED_NAME" || {
        echo "Failed to reserve share (might already exist). Trying to continue..."
    }
    echo "Starting reserved zrok share in headless mode..."
    zrok share reserved "$RESERVED_NAME" --headless --backend-mode tcpTunnel localhost:22
else
    echo "Starting temporary zrok share in headless mode..."
    zrok share private --headless --backend-mode tcpTunnel localhost:22
fi
