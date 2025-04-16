	#로그 생성 및 관리(create log system)
        exec > >(tee "/mnt/c/Users/akasa/Desktop/Proj/logs/react_$(date +%m%d_%H%M).log") 2>&1

	echo "🔍 의존성 체크 시작... (Dependency Check Start)"
	MISSING=0
	REQUIRED_CMDS=(node npx npm)

	for cmd in "${REQUIRED_CMDS[@]}"; do
  		if command -v "$cmd" &>/dev/null; then
    			echo "[Success] ✅ '$cmd' 명령어가 설치되어 있음 (Installed)"
  		else
    			echo "[Error] ❌ '$cmd' 명령어가 설치되어 있지 않음 - 설치 후 다시 실행하세요 (Not Installed - Please install '$cmd' and re-run)"
  		        MISSING=1
		fi
	done

	if [ "$MISSING" -eq 1 ]; then
  		echo "⛔ 필수 의존성이 누락되어 종료합니다. (Aborted due to missing dependencies.)"
                read -rp "👉 Enter 키를 눌러 종료하세요 (Press Enter to exit) " dummy
		exit 1		
	fi

	echo "✅ 의존성 체크 완료! (Dependency Check Complete)"

	echo "  React 프로젝트 생성 중..."
        npm create vite@latest . -- --template react

	echo "📄 requirements.txt 생성 중..."
cat <<EOF > requirements.txt
# dependencies
react
react-dom
react-router-dom
@tanstack/react-query
axios

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
	done < requirements-frontend.txt

        echo "📁 사용자 정의 폴더 생성 중..."
        mkdir -p src/{components,common,pages,routes,styles/scss,utils,hooks,api}
        mkdir -p public/{images,icons,fonts}               
                echo "📄 Tailwind 스타일 파일 작성 중..."
     	mkdir -p .vscode  # ⬅️ vscode 파일 생성
     
        # VSCode 설정 (Git Bash + venv 자동 진입)
        cat <<EOF > .vscode/settings.json
{
  "terminal.integrated.defaultProfile.windows": "Command Prompt",
  "python.pythonPath": ".venv\\Scripts\\python.exe"
}
EOF
        cat <<EOF > src/styles/tailwind.css
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

        echo "📄 Reset 스타일 작성 중..."
        cat <<EOF > src/styles/reset.css
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}
EOF

        echo "📄 SCSS 베이스 스타일 작성 중..."
        cat <<EOF > src/styles/scss/_variables.scss
$primary-color: #3490dc;
$font-stack: 'Segoe UI', sans-serif;
EOF

        cat <<EOF > src/styles/scss/_animations.scss
@keyframes pulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.05); }
        100% { transform: scale(1); }
}

.animated-button {
  animation: pulse 1.5s infinite;
}
EOF

        cat <<EOF > src/styles/scss/base.scss
@import 'variables';
@import 'animations';
EOF

        cat <<EOF > src/styles/index.css
@import './reset.css';
@import './tailwind.css';
@import './scss/base.scss';
EOF

        echo "📄 App.jsx 생성 중..."
        cat <<EOF > src/App.jsx
import React from "react";

function App() {
  return (
    <div className="App animated-button">
      <h1>🚀 \$PROJECT 프론트엔드 시작!</h1>
      <p>SCSS + Tailwind 혼합 전략으로 구성되어 있습니다.</p>
    </div>
  );
}

export default App;
EOF

        echo "📄 index.jsx 생성 중..."
        cat <<EOF > src/index.jsx
import React from "react";
import ReactDOM from "react-dom/client";
import AppRoutes from "./routes/routes";
import "./styles/index.css";
import { QueryClientProvider } from "@tanstack/react-query";
import { queryClient } from "./common/queryClient";

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <AppRoutes />
    </QueryClientProvider>
  </React.StrictMode>
);
EOF

        echo "📄 queryClient.js 생성 중..."
        cat <<EOF > src/common/queryClient.js
import { QueryClient } from "@tanstack/react-query";

export const queryClient = new QueryClient();
EOF

        echo "📄 axiosInstance.js 생성 중..."
        cat <<EOF > src/api/axiosInstance.js
import axios from "axios";

const axiosInstance = axios.create({
  baseURL: process.env.VITE_API_URL || "http://localhost:3000",
  timeout: 5000,
  headers: {
    "Content-Type": "application/json",
  },
});

axiosInstance.interceptors.request.use((config) => {
  const token = localStorage.getItem("accessToken");
  if (token) config.headers.Authorization = `Bearer \${token}`;
  return config;
});
axiosInstance.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error("API Error:", error);
    return Promise.reject(error);
  }
);

export default axiosInstance;
EOF

        echo "📄 .env 파일 생성 중..."
        cat <<EOF > .env
VITE_API_URL=http://localhost:3000
REACT_APP_VERSION=1.0.0
EOF

        echo "📄 .gitignore 파일 생성 중..."
        cat <<EOF > .gitignore
/node_modules
.env
/build
.DS_Store
*.log
.vscode
EOF

