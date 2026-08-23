#!/bin/bash
PROJECT="${PROJECT-myproject}"
BASE_PATH=$(cat ~/scripts/base_path.txt)
exec > >(tee "${BASE_PATH}/logs/${PROJECT}_fastapi_$(date +%m%d_%H%M).log") 2>&1

# 테스트용 변수
APP_NAME="${PROJECT}_backend"
TARGET_PATH="$BASE_PATH/$PROJECT/$APP_NAME"

echo "[DEBUG] TARGET_PATH: $TARGET_PATH"

# 폴더 생성
if [ ! -d "$TARGET_PATH" ]; then
  echo "[DEBUG] 생성할 폴더가 존재하지 않습니다. 생성 시도"
  mkdir -p "$TARGET_PATH"
else
  echo "[DEBUG] 폴더 이미 존재함"
fi

# 존재 여부 확인
if [ -d "$TARGET_PATH" ]; then
  echo "[DEBUG] 폴더 생성 성공, 진입 시도"
  cd "$TARGET_PATH" || { echo "❌ cd 실패"; exit 1; }
  echo "[DEBUG] 현재 디렉토리: $(pwd)"
else
  echo "❌ 폴더가 여전히 없음: $TARGET_PATH"
  read -rp "👉 Enter 키를 눌러 종료하세요 (Press Enter to exit) " dummy
  exit 1
fi

echo "🔍 의존성 체크 시작... (Dependency Check Start)"

MISSING=0
REQUIRED_CMDS=(python3 pip)

for cmd in "${REQUIRED_CMDS[@]}"; do
  if command -v "$cmd" &>/dev/null; then
    echo "[Success] ✅ '$cmd' 명령어가 설치되어 있음 (Installed)"
  else
    echo "[Error] ❌ '$cmd' 명령어가 설치되어 있지 않음 - 설치 후 다시 실행하세요 (Not Installed - Please install '$cmd' and re-run)"
    MISSING=1
  fi
done

# venv 모듈 존재 여부 확인
python3 -m venv --help &>/dev/null
if [ $? -eq 0 ]; then
  echo "[Success]✅ venv 모듈: 사용 가능 (venv module available)"
else
  echo "[Error]❌ venv 모듈: 누락됨 (venv module missing - install python3-venv)"
  MISSING=1
fi

# ❗ 하나라도 빠졌으면 종료
if [ "$MISSING" -eq 1 ]; then
  echo "⛔ 필수 의존성이 누락되어 종료합니다. (Aborted due to missing dependencies.)"
  read -rp "👉 Enter 키를 눌러 종료하세요 (Press Enter to exit) " dummy
  exit 1
fi

echo "[Success]✅ 의존성 체크 완료! (Dependency Check Complete)"


echo "⚙️ FastAPI 프로젝트 초기화 중..."

    # 이렇게 echo 여러 줄로
    cat <<EOF > requirements.txt
fastapi
uvicorn[standard]
sqlalchemy
pydantic
python-dotenv
EOF

    #pip install -r requirements.txt

    echo "📁 디렉터리 구조 생성 중..."
    mkdir -p app/{routes,setting,repository,models,schemas,services,db,utils,static}
    mkdir -p .vscode

    #VScode 설정 파일 생성
    # VSCode 설정 (Git Bash + venv 자동 진입)
    cat <<EOF > .vscode/settings.json
{
  "terminal.integrated.defaultProfile.windows": "Command Prompt",
  "python.pythonPath": ".venv\\Scripts\\python.exe"
}
EOF

    echo "📄 main.py 생성 중..."
    cat <<EOF > app/main.py
from fastapi import FastAPI
from app.routes import sample

app = FastAPI()
app.include_router(sample.router)
EOF

    # 기본 설정 파일
    cat <<EOF > app/setting/config.py
from dotenv import load_dotenv
import os

load_dotenv()

API_NAME = os.getenv("API_NAME", "FastAPI")
API_HOST = os.getenv("API_HOST", "0.0.0.0")
API_PORT = int(os.getenv("API_PORT", 8000))

DB_URL = os.getenv("DB_URL")
REDIS_URL = os.getenv("REDIS_URL")

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 60))

EMAIL_FROM = os.getenv("EMAIL_FROM")
EMAIL_NAME = os.getenv("EMAIL_NAME")

UPLOAD_PATH = os.getenv("UPLOAD_PATH", "./static/uploads")

ENV = os.getenv("ENV", "development")
DEBUG = os.getenv("DEBUG", "False").lower() == "true"
EOF


    echo "📄 sample router 생성 중..."
    cat <<EOF > app/routes/sample.py
from fastapi import APIRouter

router = APIRouter()

@router.get("/ping")
def ping():
    return {"message": "pong"}
EOF


    echo "📄 sample service 생성 중..."
    cat <<EOF > app/services/sample.py
EOF
    echo "📄 sample service 생성 중..."
    cat <<EOF > app/services/sample.py
def get_sample_data():
    return {"data": "This is from service"}
EOF

    echo "📄 sample util 생성 중..."
    cat <<EOF > app/utils/date.py
from datetime import datetime

def current_time():
    return datetime.utcnow().isoformat()
EOF

    echo "📄 .env 파일 생성 중..."
    cat <<EOF > .env
API_NAME=MyProjectAPI
API_HOST=0.0.0.0
API_PORT=8000
DB_URL=mysql+pymysql://user:password@localhost:3306/mydb
REDIS_URL=redis://localhost:6379/0
SECRET_KEY=super-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
EMAIL_FROM=noreply@example.com
EMAIL_NAME=My API Service
UPLOAD_PATH=./static/uploads
ENV=development
DEBUG=True
EOF

    echo "📄 .gitignore 생성 중..."
    cat <<EOF > .gitignore
__pycache__/
*.pyc
.venv/
.env
.DS_Store
*.log
EOF
