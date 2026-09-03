# OS 감지
if grep -qi microsoft /proc/version; then
  DETECTED_OS="windows"
   echo "📄 setup_env.bat 생성 중..."
    cat <<EOF | iconv -f UTF-8 -t UTF-8 -c > setup_env.txt
@echo off
setlocal ENABLEDELAYEDEXPANSION
chcp 65001 >nul

cd /d %%~dp0

for %%i in ("%%cd%%") do set "FULL_FOLDER=%%~ni"
set "PROJECT=%%FULL_FOLDER:_front=%%"
set "PROJECT=%%PROJECT:_backend=%%"
set BACK_FOLDER=%%PROJECT%%_backend
set FRONT_FOLDER=%%PROJECT%%_front

echo [pwd] %%cd%%
echo [*] [%%PROJECT%%] setup starting...

:: venv 폴더가 있으면 Python 프로젝트로 판단 (If a venv folder exists, consider it a Python project)
if exist venv (
    echo [Python] Detected Python project.
    call :install_python
) else if exist package.json (
    echo [Node.js] Detected Node.js project.
    call :install_node
) else (
    echo [Error!] Unknown project type: No venv or package.json found.
)

echo [✔] Setup complete.
pause
exit /b

:install_python
echo [Python] Installing Python packages...

:: 가상 환경이 없다면 생성 (If virtual environment doesn't exist, create one)
if not exist .venv (
    python -m venv .venv
)

:: 가상 환경 활성화 후 패키지 설치 (Activate virtual environment and install packages)
if exist .venv\Scripts\activate (
    call .venv\Scripts\activate
    if exist requirements.txt (
        pip install -r requirements.txt
    ) else (
        echo [Warning!] requirements.txt not found. Skipping Python package installation.
    )
) else (
    echo [Warning!] .venv exists but activate script not found.
)

exit /b

:install_node
echo [Node.js] Installing Node packages...

:: Node.js 패키지 설치 (Install Node.js packages)
if exist requirements.txt (
    for /f "delims=" %%i in (requirements.txt) do (
        set "LINE=%%i"
        
        :: 주석 (#) 라인 건너뛰기 (Skip comment lines)
        echo !LINE! | findstr /r "^#" >nul
        if !errorlevel! == 0 (
            rem skip
        ) else (
            echo Installing: %%i
            npm install %%i
        )
    )
) else (
    echo [Warning!] requirements.txt not found in the frontend directory.
)

exit /b
EOF
else
  case "$(uname -s)" in
    Darwin* | Linux*) DETECTED_OS="macos or linux" 
	echo "📄 setup_env.sh 생성 중..."
cat <<'EOF' > setup_env.sh
#!/bin/bash

# 현재 폴더 경로 (Set the current folder path)
cd "$(dirname "$0")"

# 루트 폴더 이름 인식 (Detect the root folder name)
FULL_FOLDER=$(basename "$PWD")
PROJECT="${FULL_FOLDER//_front/}"
PROJECT="${PROJECT//_backend/}"
BACK_FOLDER="${PROJECT}_backend"
FRONT_FOLDER="${PROJECT}_front"

echo "[pwd] $PWD"
echo "[*] [$PROJECT] setup starting..."

# venv 폴더가 있으면 Python 프로젝트로 판단 (If a venv folder exists, consider it a Python project)
if [ -d "venv" ]; then
    echo "[Python] Detected Python project."
    install_python
elif [ -f "package.json" ]; then
    echo "[Node.js] Detected Node.js project."
    install_node
else
    echo "[Error!] Unknown project type: No venv or package.json found."
fi

echo "[✔] Setup complete."

# Python 패키지 설치 (Install Python packages)
install_python() {
    echo "[Python] Installing Python packages..."
    
    # 가상 환경이 없다면 생성 (If virtual environment doesn't exist, create one)
    if [ ! -d ".venv" ]; then
        python -m venv .venv
    fi

    # 가상 환경 활성화 후 패키지 설치 (Activate virtual environment and install packages)
    if [ -f ".venv/bin/activate" ]; then
        source .venv/bin/activate
        if [ -f "requirements.txt" ]; then
            pip install -r requirements.txt
        else
            echo "[Warning!] requirements.txt not found. Skipping Python package installation."
        fi
    else
        echo "[Warning!] .venv exists but activate script not found."
    fi
}

# Node.js 패키지 설치 (Install Node.js packages)
install_node() {
    echo "[Node.js] Installing Node packages..."

    # Node.js 패키지 설치 (Install Node.js packages)
    if [ -f "requirements.txt" ]; then
        while IFS= read -r LINE; do
            # 주석 (#) 라인 건너뛰기 (Skip comment lines)
            if [[ "$LINE" =~ ^# ]]; then
                continue
            fi
            echo "Installing: $LINE"
            npm install "$LINE"
        done < requirements.txt
    else
        echo "[Warning!] requirements.txt not found in the frontend directory."
    fi
}
EOF
	    ;;
    *)       DETECTED_OS="unknown" ;;
  esac
fi


echo ""
#echo "📄 setup_env.bat 인코딩 확인 중..."
#ENCODING=$(file -i setup_env.bat | awk -F "=" '{print $2}')

#echo "🔍 인코딩 결과: $ENCODING"

#if [[ "$ENCODING" == "utf-8" ]]; then
 # echo "✅ UTF-8 (BOM 없음) 인코딩입니다. 문제 없습니다."
#else
 # echo "⚠️ 경고: UTF-8이 아닌 인코딩입니다. Windows에서 실행 시 깨질 수 있습니다."
 # echo "👉 iconv로 변환하려면 다음 명령어를 사용하세요:"
  #echo "   iconv -f UTF-8 -t UTF-8 -c setup_env.bat -o fixed_setup_env.bat"
#fi

# 가상환경 접속 및 VSCode 자동 실행
# Windows 가상환경 activate
echo "✅ 템플릿 구조 생성 완료!"
echo "  가상환경은 아직 설정되지 않았습니다."
echo "👉 setup_env.txt를 bat으로 바꾸어 Windows에서 setup_env.bat을 한 번만 실행해주세요."
echo "📂 경로: $(pwd)/setup_env.txt"

# Notion 앱 실행 (링크 없이 그냥 앱만 띄움)
#echo "📝 Notion 실행 중..."
#cmd.exe /c start "" "C:\\Users\\akasa\\AppData\\Local\\Programs\\Notion\\Notion.exe"

echo "🚀 $PROJECT 초기화 완료: $TARGET_PATH"

