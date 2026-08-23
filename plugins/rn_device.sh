#!/bin/bash

source ~/scripts/.dockenv

# === OS 감지 : WSL이면 Windows, 아니면 macOS/Linux ===
if grep -qi microsoft /proc/version; then
  echo "[INFO] Windows 환경 감지 → creating rna.bat"

  cat <<EOF > rna.txt
@echo off
setlocal

:: [ 설정: 기본값 및 경로 : setting default value and path ]
set AVD_NAME=$AVD_NAME
if not "%~1"=="" (
    set AVD_NAME=%~1
)

:: 현재 경로를 PWD 변수에 저장 : Save current directory to PWD variable
set "PWD=%cd%"

:: 디버깅용 출력 : For debugging purpose
echo [INFO] Current directory (PWD) is: %PWD%

:: [ 환경 변수 설정 : load env value and setting ] 
set "JAVA_HOME=$JAVA_HOME"
set "ANDROID_HOME=$ANDROID_HOME"
set PATH=%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\emulator;%JAVA_HOME%\bin

echo [JAVA] JAVA_HOME set to %JAVA_HOME%
echo [AVD] Launching: %AVD_NAME%

:: [ Metro 포트 점거 확인 : Check if Metro port 8081 is in use  ] 
netstat -ano | findstr :8081 >nul
if not errorlevel 1 (
    echo [WARN] 8081 port is already used. delete node.exe task...
    taskkill /f /im node.exe >nul 2>&1
    timeout /t 2 >nul
)

:: [ 변수 확장 가능하게 함 : Enable delayed variable expansion ] 
setlocal ENABLEDELAYEDEXPANSION
set DEVICE_TO_USE=

for /f "tokens=1" %%i in ('adb devices ^| findstr /i /v "List"') do (
    echo [ADB] Found device: %%i
    echo %%i | findstr /i "emulator" >nul
    if errorlevel 1 (
        set "DEVICE_TO_USE=%%i"
    )
)

if defined DEVICE_TO_USE (
    echo [REAL] Real device detected: !DEVICE_TO_USE!
    call adb -s !DEVICE_TO_USE! reverse tcp:8081 tcp:8081
    start "Metro Server" cmd /k "cd /d %PWD% && npx react-native start"
    call npx react-native run-android --device !DEVICE_TO_USE!
    goto :done
)



:: 📦 아무 디바이스도 없으면 AVD 새로 실행 : if no device is detected, run new AVD
echo [AVD] No devices detected. Launching AVD: %AVD_NAME%
start "" emulator -avd %AVD_NAME%
timeout /t 12 >nul

:: ⏎ 새로 뜬 에뮬레이터 adb reverse : new emulator adb reverse
for /f "tokens=1" %%i in ('adb devices ^| findstr emulator') do (
    echo [AVD] Reverse setting: %%i
    adb -s %%i reverse tcp:8081 tcp:8081

    REM  [ Metro 실행 (백그라운드) : run Metro in background ] 
    start "Metro Server" cmd /k "cd /d %PWD% && npx react-native start"

    REM  [ 앱 실행 : run app ] 
    npx react-native run-android
)

:: [ 스크립트 종료됨 : Script complete, Cleanup and exit ] 

:done
endlocal
exit /b 0

EOF

else
  echo "[INFO] Linux or macOS 환경 감지 → creating rna.sh"

  cat <<EOF > rna.sh
#!/bin/bash
set -e

# [ 설정: 기본값 및 경로 : setting default value and path ]
AVD_NAME=$AVD_NAME
if [ -n "$1" ]; then
    AVD_NAME="$1"
fi

# 현재 경로를 PWD 변수에 저장 : Save current directory to PWD variable
PWD=$(pwd)

# 디버깅용 출력 : For debugging purpose
echo "[INFO] Current directory (PWD) is: $PWD"

# [ 환경 변수 설정 : load env value and setting ] 
JAVA_HOME=$JAVA_HOME
ANDROID_HOME=$ANDROID_HOME
PATH="$PATH:$ANDROID_PLATFORM_HOME/platform-tools:$ANDROID_HOME/emulator:$JAVA_HOME/bin"

echo "[JAVA] JAVA_HOME set to $JAVA_HOME"
echo "[AVD] Launching: $AVD_NAME"

# [ Metro 포트 점거 확인 : Check if Metro port 8081 is in use  ] 
if lsof -i :8081 | grep LISTEN > /dev/null; then
    echo "[WARN] 8081 port is already used. delete node.exe task..."
    pkill -f "node.*8081" > /dev/null 2>&1
    sleep 2
fi

# [ 변수 확장 가능하게 함 : Enable delayed variable expansion ] 
DEVICE_TO_USE=""

while read -r line; do
    device_id=$(echo "$line" | awk '{print $1}')
    echo "[ADB] Found device: $device_id"
    echo "$device_id" | grep -i "emulator" > /dev/null
    if [ $? -ne 0 ]; then
        DEVICE_TO_USE="$device_id"
    fi
done < <(adb devices | grep -i -v "List")

if [ -n "$DEVICE_TO_USE" ]; then
    echo "[REAL] Real device detected: $DEVICE_TO_USE"
    adb -s "$DEVICE_TO_USE" reverse tcp:8081 tcp:8081
    (cd "$PWD" && npx react-native start) &
    npx react-native run-android --deviceId "$DEVICE_TO_USE"
    exit 0
fi

# 📦 아무 디바이스도 없으면 AVD 새로 실행 : if no device is detected, run new AVD
echo "[AVD] No devices detected. Launching AVD: $AVD_NAME"
nohup emulator -avd "$AVD_NAME" > /dev/null 2>&1 &
sleep 12

# ⏎ 새로 뜬 에뮬레이터 adb reverse : new emulator adb reverse
while read -r emulator_id; do
    echo "[AVD] Reverse setting: $emulator_id"
    adb -s "$emulator_id" reverse tcp:8081 tcp:8081

    # Metro 실행 (백그라운드) : run Metro in background 
    (cd "$PWD" && npx react-native start) &

    # 앱 실행 : run app 
    npx react-native run-android
done < <(adb devices | grep emulator | awk '{print $1}')

# [ 스크립트 종료됨 : Script complete, Cleanup and exit ] 
exit 0

EOF

  chmod +x rna.sh
fi

