#!/bin/bash

# .dockenv 실행
source ~/scripts/.dockenv

exec > >(tee "/mnt/c/Users/akasa/Desktop/Proj/logs/d_$(date +%m%d_%H%M).log") 2>&1

echo "[DEBUG] 인자 확인 -> PROJECT: $1 / TYPE: $2 / FRAMEWORK: $3"
PROJECT=$1
TYPE=$2
FRAMEWORK=$3
echo "[DEBUG] 변수 확인 -> PROJECT: $PROJECT / TYPE: $TYPE / FRAMEWORK: $FRAMEWORK"

# BASE_PATH="/mnt/c/Users/akasa/Desktop/Proj"

# base_path.txt가 존재하지 않으면 생성하고, 존재하면 덮어쓰기
if [ ! -f base_path.txt ]; then
  echo "[Info] base_path.txt 파일이 없습니다. 새로 생성합니다."
  source ~/scripts/.dockenv
else
  # 파일이 존재하면, 기존 내용을 읽어옴
  OLD_BASE_PATH=$BASE_PATH
  source ~/scripts/.dockenv
  if [ "$OLD_BASE_PATH" != "$BASE_PATH" ]; then
    echo "[Info] base_path가 변경되었습니다. base_path.txt를 업데이트합니다."
    fi
fi 

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINS_DIR="${SCRIPT_DIR}/plugins"
export PROJECT TYPE FRAMEWORK

if [ -z "$PROJECT" ]; then
  echo "❗ 사용법: d [프로젝트명] [f/b] [r/rn/n/f]"
  read -p "D)Command is not matched. Please type again."
fi

# default type 처리
if [ -z "$TYPE" ]; then
  TYPE="all"
fi

TARGET_PATH="$BASE_PATH/$PROJECT"

# 폴더 존재 여부 확인
if [ ! -d "$TARGET_PATH" ]; then
  mkdir -p "$TARGET_PATH"
  echo "D)$TARGET_PATH 폴더 생성 완료!"
  cd "$TARGET_PATH" || exit 1
  echo "D)$TARGET_PATH 폴더로 이동함"
fi

FRONT_DIR="$TARGET_PATH/${PROJECT}_front"
BACK_DIR="$TARGET_PATH/${PROJECT}_backend"

# TYPE에 따라 각각 독립적으로 생성 여부 판단
if [ "$TYPE" = "f" ]; then
  if [ -d "$FRONT_DIR" ]; then
    echo "📂 이미 front 디렉토리가 존재합니다. 이동합니다."
    cd "$FRONT_DIR" || { read -p "D)Failed to open directory. Press Enter to exit..."; exit 1; }
  else
    echo "🆕 front 디렉토리 생성을 시작합니다."
    mkdir -p "$FRONT_DIR"
    cd "$FRONT_DIR" || { read -p "D)Failed to make directory. Press Enter to exit..."; exit 1; }
    case "$FRAMEWORK" in
      r)
	      bash "$PLUGINS_DIR/r.sh" "$(pwd)"
        if [ $? -ne 0 ]; then
          echo "❌ Frontend 세팅 중 오류 발생. 이후 작업을 중단합니다."
	  read -p "D)some error is occured in frontend setting. Press Enter to exit..."
	  exit 1
        fi
        ;;
      rn)
        bash "$PLUGINS_DIR/rn.sh" "$PROJECT"
        if [ $? -ne 0 ]; then
          echo "❌ Frontend 세팅 중 오류 발생. 이후 작업을 중단합니다."
          read -p "some error is occured in frontend setting. Press Enter to exit..."
	  exit 1
        fi
        ;;
      n)
        bash "$PLUGINS_DIR/n.sh" "$PROJECT"
        if [ $? -ne 0 ]; then
          echo "❌ Frontend 세팅 중 오류 발생. 이후 작업을 중단합니다."
          read -p "some error is occured in frontend setting. Press Enter to exit..."
	  exit 1
        fi
        ;;
      *)
        echo "❗ 지원하지 않는 프론트 프레임워크: $FRAMEWORK"
        read -p "some error is occured in frontend setting. Press Enter to exit..."
	exit 1
        ;;
    esac
    # 새로운 디렉토리가 생성된 경우에만 env_setup.sh 실행
    source "$SCRIPT_DIR/env_setup.sh"
  fi

elif [ "$TYPE" = "b" ]; then
  if [ -d "$BACK_DIR" ]; then
    echo "📂 이미 backend 디렉토리가 존재합니다. 이동합니다."
    cd "$BACK_DIR" || exit 1
  else
    echo "🆕 backend 디렉토리를 생성하고 세팅합니다."
    mkdir -p "$BACK_DIR"
    cd "$BACK_DIR" || exit 1
    case "$FRAMEWORK" in
      f)
        bash "$PLUGINS_DIR/f.sh"
        if [ $? -ne 0 ]; then
          echo "❌ Backend 세팅 중 오류 발생. 이후 작업을 중단합니다."
          exit 1
        fi
        ;;
      *)
        echo "❗ 지원하지 않는 백엔드 프레임워크: $FRAMEWORK"
        exit 1
        ;;
    esac
    # 새로운 디렉토리가 생성된 경우에만 env_setup.sh 실행
    source "$SCRIPT_DIR/env_setup.sh"
  fi
else
  echo "❗ TYPE은 f(front) 또는 b(back) 중 하나여야 합니다."
  exit 1
fi

# Docker compose 실행
if [ -f "docker-compose.yml" ]; then
  docker compose up -d
fi

if [ $NOTION_USE = "YES" ]; then
# Notion 앱 실행 (링크 없이 그냥 앱만 띄움)
echo "📝 Notion 실행 중..."
cmd.exe /c start "" "$NOTION_PATH"
fi

# 가상환경 접속 및 VSCode 자동 실행
# Windows 가상환경 activate
echo "Vscode에 접속합니다.(Open Vscode)"

# 경로 변환
#WIN_TARGET_PATH_F=$(wslpath -w "$TARGET_PATH/${PROJECT}_front")
if command -v wslpath >/dev/null 2>&1; then
  # WSL 환경
  CODE_TARGET_PATH_F=$(wslpath -w "$TARGET_PATH/${PROJECT}_front")
  CODE_TARGET_PATH_B=$(wslpath -w "$TARGET_PATH/${PROJECT}_backend")
else
  # Linux/macOS 환경
  CODE_TARGET_PATH_F="$TARGET_PATH/${PROJECT}_front"
  CODE_TARGET_PATH_B="$TARGET_PATH/${PROJECT}_backend"
fi

#WIN_TARGET_PATH_B=$(wslpath -w "$TARGET_PATH/${PROJECT}_backend")
#WIN_TARGET_PATH_ROOT=$(wslpath -w "$TARGET_PATH")

# VSCode 실행 경로
#VSCODE_PATH="C:\\Users\\akasa\\AppData\\Local\\Programs\\Microsoft VS Code\\Code.exe"

# OS 분기
if grep -qi microsoft /proc/version; then
  echo "🪟 Windows 환경 감지됨"
  # 예: TYPE별 VSCode 실행
  if [ "$TYPE" = "f" ]; then
    cmd.exe /c start "" "$VSCODE_PATH" "$CODE_TARGET_PATH_F/"
    echo "🚀 $PROJECT 초기화 완료: $TARGET_PATH/${PROJECT}_front"
  elif [ "$TYPE" = "b" ]; then
    cmd.exe /c start "" "$VSCODE_PATH" "$CODE_TARGET_PATH_B/"
    echo "🚀 $PROJECT 초기화 완료: $TARGET_PATH/${PROJECT}_backend"
  else
    cmd.exe /c start "" "$VSCODE_PATH" "$CODE_TARGET_PATH_ROOT/"
  fi
else
  echo "🐧 리눅스 or 🍎 macOS 환경 감지됨"
  # 예: code 커맨드 이용
  if [ "$TYPE" = "f" ]; then
    code "$CODE_TARGET_PATH_F/"
    echo "🚀 $PROJECT 초기화 완료: $TARGET_PATH/${PROJECT}_front"
  elif [ "$TYPE" = "b" ]; then
    code "$CODE_TARGET_PATH_B/"
    echo "🚀 $PROJECT 초기화 완료: $TARGET_PATH/${PROJECT}_backend"
  else
    code "$CODE_TARGET_PATH_ROOT/"
  fi
fi


