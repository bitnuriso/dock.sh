        #!/bin/bash
	set -eu

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


	source ~/scripts/.dockenv
        TARGET_PATH="$1"

	# 인자가 없으면 스크립트 즉시 중단
	if [ -z "$TARGET_PATH" ]; then
  		log "❌" "[r.sh] 치명적 오류: 작업 디렉터리가 인자로 전달되지 않았습니다." >&2
  		exit 1
	fi

        #로그 생성 및 관리(create log system)
        exec > >(tee "${BASE_PATH}/logs/$(date +%m%d_%H%M)_react.log") 2>&1
        
        check_dependencies "node" "npx" "npm" 

	# Vite 템플릿 생성 (중요!)
	# create-vite는 지정한 디렉터리에 프로젝트를 생성하므로, cd 없이 경로만 지정합니다.
	log "INFO" "⚙️ " "Vite 기반 React 템플릿 생성 중 in ${TARGET_PATH}"
	# Vite는 비어있지 않은 디렉터리에 설치 시 확인을 요구하므로,
	# cd 후 '.'에 설치하는 것이 더 안정적입니다. 서브셸에서 안전하게 실행합니다.
	(
  		cd "$TARGET_PATH" || exit 1
  		npm create vite@latest . -- --template react --yes
	)
	if [ $? -ne 0 ]; then
  		log "INFO" "❌" "Vite 템플릿 생성 실패. 이후 작업을 중단합니다."
  		exit 1
	fi

	# 기존 index.html → public으로 이동
	log "INFO" "📁" "폴더 구조 생성 중..."
	make_directory_structure "public"
	mv index.html public/index.html 2>/dev/null

        #템플릿 파일 생성
        create_files_from_template "$DEFINITION_FILE" || {
           log "ERROR" "❌" "템플릿 파일 생성 중 오류가 발생했습니다."
           exit 1
        }
	echo "test..."
