#!/bin/bash

# 📍 스크립트가 있는 디렉토리 기준 경로 설정
# Set path based on current script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME=$(basename "$0" .sh)
TIME_STAMP=$(date +%m%d_%H%M)

# 📂 로그 디렉토리 설정: logs/script_name/yyyyMMDD_HHMM.log
# Set log directory structure: logs/script_name/time.log
LOG_BASE="$SCRIPT_DIR/logs"
LOG_DIR="$LOG_BASE/$SCRIPT_NAME"
LOG_FILE="$LOG_DIR/$TIME_STAMP.log"

# ✅ logs 디렉토리가 없으면 생성
# Create logs/ if it doesn't exist
if [ ! -d "$LOG_BASE" ]; then
  mkdir "$LOG_BASE"
fi

# ✅ logs/스크립트명 디렉토리가 없으면 생성
# Create logs/script_name/ if it doesn't exist
if [ ! -d "$LOG_DIR" ]; then
  mkdir "$LOG_DIR"
fi

# 📦 로그 저장 시작 (표준 출력 + 에러 포함)
# Start log output (including stdout + stderr)
exec > >(tee -a "$LOG_FILE") 2>&1

