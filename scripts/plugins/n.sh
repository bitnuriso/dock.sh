#!/bin/bash
BASE_PATH=$(cat ~/scripts/base_path.txt)
# 스크립트가 위치한 디렉토리를 기준으로 TEMPLATE_DIR 설정 (안정성 확보)
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")

#공통 함수 불러오기
source "$SCRIPT_DIR/common.sh"

TEMPLATE_DIR="$SCRIPT_DIR/templates"
#templats의 템플릿을 불러옴
DEFINITION_FILE="$SCRIPT_DIR/templates/$SCRIPT_NAME"
REQUIREMENTS_FILE="$DEFINITION_FILE/requirements.txt"

exec > >(tee "${BASE_PATH}/logs/nextjs_$(date +%m%d_%H%M).log") 2>&1

APP_NAME="${PROJECT}_front"
TARGET_DIR="$BASE_PATH/$PROJECT/$APP_NAME"
TEMP_PATH="$BASE_PATH/$PROJECT/temp_nextjs"

echo "[DEBUG] PROJECT: $PROJECT"
echo "[DEBUG] BASE_PATH: $BASE_PATH"
echo "[DEBUG] TARGET_DIR: $TARGET_DIR"
echo "[DEBUG] TEMP_PATH: $TEMP_PATH"

# 임시 디렉토리 생성
rm -rf "$TEMP_PATH"
mkdir -p "$TEMP_PATH"
mkdir -p "$TARGET_DIR"
cd "$TEMP_PATH" || { echo "❌ TEMP_PATH 이동 실패"; exit 1; }

#의존성 체크
check_dependencies "node" "npx" "npm"

echo "⚙️ Next.js 프로젝트 생성 중..."
npx create-next-app@latest . --javascript --src-dir --no-tailwind --eslint
RC=$?

if [ "$RC" -ne 0 ]; then
  echo "❌ Next.js 생성 실패 (에러 코드: $RC)"
  rm -rf "$TEMP_PATH"
  read -rp "👉 Enter 키를 눌러 종료하세요 (Press Enter to exit) " dummy
  exit 1
fi

# 기존 타겟 디렉토리가 있으면 삭제
#rm -rf "$TARGET_DIR"
#mv "$TEMP_PATH" "$TARGET_DIR"

echo "node_modules를 타겟 디렉토리로 이동 중..."
if [ -d "$TEMP_PATH/node_modules" ]; then
    mv "$TEMP_PATH/node_modules" "$TARGET_DIR/"
    echo "node_modules 이동 완료!"
else
    echo "임시 경로에 node_modules가 없어 이동을 건너뜁니다."
fi

echo "다른 템플릿들을 복사 중..."
cp -r "$TEMP_PATH" "$TARGET_DIR"

echo "프로젝트 파일 복사 완료!"

rm -rf "$TEMP_PATH"
cd "$TARGET_DIR" || { echo "❌ TARGET_DIR 이동 실패"; exit 1; }

if [ -f "$REQUIREMENTS_FILE" ]; then
	echo "📄 requirements.txt 복사 중..."
	cp "$REQUIREMENTS_FILE" .
	echo "📦 패키지 설치 중..."
		while IFS= read -r pkg; do
  			if [[ "$pkg" == \#* || -z "$pkg" ]]; then
    				continue
  			elif grep -q "$pkg" <<< "tailwindcss postcss autoprefixer sass"; then
    				npm install -D "$pkg"
  			else
    				npm install "$pkg"
  			fi
		done < requirements.txt
fi

        log "INFO" "📁" "폴더 구조 생성 중..."
	make_directory_structure \
    "src/api" \
    "src/common" \
    "src/components" \
    "src/hooks" \
    "src/styles/scss" \
    "public/images" \
    "public/icons" \
    "public/fonts" \
    ".vscode"

#템플릿 파일 생성
create_files_from_template "$DEFINITION_FILE"
