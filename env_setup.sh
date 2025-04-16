    echo "📄 setup_env.bat 생성 중..."
    cat <<EOF | iconv -f UTF-8 -t UTF-8 -c > setup_env.bat
@echo off
setlocal ENABLEDELAYEDEXPANSION
chcp 65001 >nul
for %%i in ("%cd%") do set "FULL_FOLDER=%%~nxi"
set "PROJECT=%FULL_FOLDER:_front=%"
set "PROJECT=%PROJECT:_backend=%"
set BACK_FOLDER=%PROJECT%_backend
set FRONT_FOLDER=%PROJECT%_front

echo [*] [%PROJECT%] virtual environment setup starting...

cd /d %%~dp0

if exist requirements.txt (
    for %%i in ("%cd%") do (
        set CURRENT_FOLDER=%%~nxi
    )

    echo [Debug] CURRENT_FOLDER = !CURRENT_FOLDER!

    if "!CURRENT_FOLDER!"=="%BACK_FOLDER%" (
        echo [Backend] Detected backend project.
        echo [Installing] Python requirements...

        python -m venv .venv
        if exist .venv\Scripts\activate (
            call .venv\Scripts\activate
            pip install -r requirements.txt
        ) else (
            echo [Warning!] .venv exists but activate script not found.
        )
	) else if "!CURRENT_FOLDER!"=="%FRONT_FOLDER%" (
        echo [Frontend] Detected frontend project.

        call :check_npm
        if "!NPM_FOUND!"=="0" (
            echo [Error!] npm not found in PATH. Please install Node.js and restart the terminal.
        ) else (
            echo [Installing] Node packages...

            rem requirements.txt is used for Node.js packages
            if exist requirements.txt (
                for /f "delims=" %%i in (requirements.txt) do (
                    echo Installing: %%i
                    npm install %%i
                )
            ) else (
                echo [Warning!] requirements.txt not found in the frontend directory.
            )
        )
    )

    ) else (
        echo [Error!] Unknown project type: !CURRENT_FOLDER!
    )
) else (
    echo [Warning!] requirements.txt not found. Skipping installation.
)

echo [Done] [%PROJECT%] setup complete!
pause
goto :eof

:check_npm
where npm >nul 2>nul
if errorlevel 1 (
    set NPM_FOUND=0
) else (
    set NPM_FOUND=1
)
goto :eof

EOF

echo ""
echo "📄 setup_env.bat 인코딩 확인 중..."
ENCODING=$(file -i setup_env.bat | awk -F "=" '{print $2}')

echo "🔍 인코딩 결과: $ENCODING"

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
echo "👉 Windows에서 setup_env.bat을 한 번만 실행해주세요."
echo "📂 경로: $(pwd)/setup_env.bat"

# Notion 앱 실행 (링크 없이 그냥 앱만 띄움)
#echo "📝 Notion 실행 중..."
#cmd.exe /c start "" "C:\\Users\\akasa\\AppData\\Local\\Programs\\Notion\\Notion.exe"

echo "🚀 $PROJECT 초기화 완료: $TARGET_PATH"

