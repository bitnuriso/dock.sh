#!/bin/bash

exec > >(tee "/mnt/c/Users/akasa/Desktop/Proj/logs/nextjs_$(date +%m%d_%H%M).log") 2>&1

BASE_PATH="/mnt/c/Users/akasa/Desktop/Proj"
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

echo "🔍 의존성 체크 시작... (Dependency Check Start)"
MISSING=0
REQUIRED_CMDS=(node npx npm)

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
  exit 1
fi

echo "✅ 의존성 체크 완료! (Dependency Check Complete)"

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
rm -rf "$TARGET_DIR"
mv "$TEMP_PATH" "$TARGET_DIR"
cd "$TARGET_DIR" || { echo "❌ TARGET_DIR 이동 실패"; exit 1; }


	echo "📄 requirements.txt 생성 중..."
	cat <<EOF > requirements.txt
# Next.js Template
# dependencies
axios
@tanstack/react-query

# devDependencies
tailwindcss
postcss
autoprefixer
sass
EOF

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

        echo "📁 폴더 구조 생성 중..."
        mkdir -p src/{api,common,components,hooks,styles/scss}
        mkdir -p public/{images,icons,fonts}
	mkdir -p .vscode
        
        #VScode 설정 파일 생성
        # VSCode 설정 (Git Bash + venv 자동 진입)
        cat <<EOF > .vscode/settings.json
{
  "terminal.integrated.defaultProfile.windows": "Command Prompt",
  "python.pythonPath": ".venv\\Scripts\\python.exe"
}
EOF

        echo "📄 Tailwind 설정 파일 생성 중..."
        cat <<EOF > tailwind.config.js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./pages/**/*.{js,ts,jsx,tsx}", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {},
  },
  plugins: [],
};
EOF

        echo "📄 CSS 파일 작성 중..."
        cat <<EOF > src/styles/tailwind.css
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

        cat <<EOF > src/styles/reset.css
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}
EOF

        cat <<EOF > src/styles/index.css
@import './reset.css';
@import './tailwind.css';
@import './scss/custom.scss';
EOF

        echo "📄 SCSS 커스텀 파일 작성 중..."
        cat <<EOF > src/styles/scss/custom.scss
\$primary-color: #007bff;

.text-primary {
  color: \$primary-color;
}
EOF

        echo "📄 axiosInstance.js 생성 중..."
        cat <<EOF > src/api/axiosInstance.js
import axios from 'axios';

const axiosInstance = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000',
  timeout: 5000,
  headers: { 'Content-Type': 'application/json' },
});

export default axiosInstance;
EOF

        echo "📄 queryClient.js 생성 중..."
        cat <<EOF > src/common/queryClient.js
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient();
EOF

        echo "📄 useExample.js 생성 중..."
        cat <<EOF > src/hooks/useExample.js
import { useQuery } from '@tanstack/react-query';
import axiosInstance from '../api/axiosInstance';

const fetchExample = async () => {
  const res = await axiosInstance.get('/example');
  return res.data;
};

export const useExample = () => useQuery({ queryKey: ['example'], queryFn: fetchExample });
EOF

        echo "📄 index.jsx 생성 중..."
        mkdir -p pages
        cat <<EOF > pages/index.jsx
import React from 'react';
import { QueryClientProvider } from '@tanstack/react-query';
import { queryClient } from '../src/common/queryClient';
import '../src/styles/index.css';

const Home = () => {
  return (
    <div className="min-h-screen flex items-center justify-center">
      <h1 className="text-3xl font-bold text-primary">🚀 Hello Next.js + Tailwind + SCSS!</h1>
    </div>
  );
};

const App = () => (
  <QueryClientProvider client={queryClient}>
    <Home />
  </QueryClientProvider>
);

export default App;
EOF

        echo "📄 .env 생성 중..."
        cat <<EOF > .env
NEXT_PUBLIC_API_URL=http://localhost:3000
EOF

        echo "📄 .gitignore 생성 중..."
        cat <<EOF > .gitignore
/node_modules
/.next
.env.local
.DS_Store
*.log
.vscode
EOF
