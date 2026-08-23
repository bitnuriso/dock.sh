set -euo pipefail
# common.sh

# 순수 Bash 파싱 및 파일 생성 함수
function create_files_from_template() {
  set -u
  local template_file="${1:-}"

  if [[ -z "$template_file" || ! -s "$template_file" ]]; then
    echo "❌ 템플릿 파일이 없거나 비어있습니다: $template_file"
    return 1
  fi

  local file_content=""
  file_content=$(<"$template_file") || { echo "❌ 템플릿 파일 읽기 실패"; return 1; }
  file_content=${file_content//$'\r'/}

  # 주석 제거
  local cleaned_content=""
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ ! "$line" =~ ^[[:space:]]*# ]]; then
      cleaned_content+="$line"$'\n'
    fi
  done <<< "$file_content"

  file_content="$cleaned_content"

  while [[ -n "$file_content" ]]; do
    local record="${file_content%%---EOF---*}"
    file_content="${file_content#*---EOF---}"

    # 공백/빈줄 제거
    record=$(echo "$record" | sed '/^[[:space:]]*$/d')

    if [[ -z "$record" ]]; then
      continue
    fi

    IFS=$'\n' read -r -d '' -a lines <<< "$record"$'\0' || true

    # 검증: 배열 요소 없으면 건너뜀
    if [ -z "${lines+x}" ]; then
      echo "❌ 배열이 선언되지 않음"
      continue
    fi

    if (( ${#lines[@]} < 3 )); then
      echo "❌ 레코드 형식 문제: 최소 3줄 필요"
    continue
    fi

    local title="${lines[0]:-}"
    local target_path="${lines[1]:-}"
    local content=$(printf "%s\n" "${lines[@]:2}")

    echo "$title"

    local dir_path
    dir_path=$(dirname -- "$target_path")
    if [[ "$dir_path" != "." && ! -d "$dir_path" ]]; then
      mkdir -p "$dir_path" || { echo "❌ 디렉토리 생성 실패: $dir_path"; return 1; }
      echo "📁 디렉토리 생성: $dir_path"
    fi

    printf "%s" "$content" > "$target_path" || { echo "❌ 파일 생성 실패: $target_path"; return 1; }

    echo "✅ 완료: $target_path"
    echo "----------------------------------------"
  done

  echo "🎉 모든 설정 파일 생성이 완료되었습니다."
  set +u
}


#폴더 구조 생성 함수
function make_directory_structure() {
    # 인자로 받은 모든 경로에 대해 mkdir -p 실행
    for path in "$@"; do
        mkdir -p "$path"
    done
}


# 로그 출력 함수
# common.sh
function log() {
  # 인자 개수에 따른 분기 처리
  if [ $# -eq 0 ]; then
    echo "[$(date +'%H:%M:%S')] [INFO] ℹ️ (no message)"
    return
  fi

  local level icon message

  level="${1:-INFO}"          # 기본값 INFO
  icon="${2:-}"              # 기본 아이콘 없음 허용
  message="${3:-}"           # 메시지도 옵션 처리

  # 인자 개수에 따라 출력 형식 분기
  if [ $# -eq 1 ]; then
    echo "[$(date +'%H:%M:%S')] $level"
  elif [ $# -eq 2 ]; then
    echo "[$(date +'%H:%M:%S')] $level  $icon"
  else
    echo "[$(date +'%H:%M:%S')] [$level] $icon $message"
  fi
}


# 의존성 체크 함수
function check_dependencies() { 

log "INFO" "🔍" "의존성 체크 시작... (Dependency Check Start)"
local MISSING=0
local REQUIRED_CMDS=("$@")

for cmd in "${REQUIRED_CMDS[@]}"; do
  if command -v "$cmd" &>/dev/null; then
    echo "[Success] ✅ '$cmd' 명령어가 설치되어 있음 (Installed)"
  else
    echo "[Error] ❌ '$cmd' 명령어가 설치되어 있지 않음"
    MISSING=1
  fi
done

if [ "$MISSING" -eq 1 ]; then
  echo "⛔ 필수 의존성 누락으로 종료합니다."
  read -rp "👉 Enter 키를 눌러 종료하세요 (Press Enter to exit) " dummy
  return 1
fi

echo "✅ 의존성 체크 완료! (Dependency Check Complete)"
echo "🔍 의존성 체크 시작... (Dependency Check Start)"

MISSING=0
REQUIRED_CMDS=("$@")

for cmd in "${REQUIRED_CMDS[@]}"; do
  if command -v "$cmd" &>/dev/null; then
    echo "[Success] ✅ '$cmd' 명령어가 설치되어 있음 (Installed)"
  else
    echo "[Error] ❌ '$cmd' 명령어가 설치되어 있지 않음"
    MISSING=1
  fi
done

if [ "$MISSING" -eq 1 ]; then
  echo "⛔ 필수 의존성 누락으로 종료합니다."
  read -rp "👉 Enter 키를 눌러 종료하세요 (Press Enter to exit) " dummy
  return 1
fi

echo "✅ 의존성 체크 완료! (Dependency Check Complete)"
}
   
