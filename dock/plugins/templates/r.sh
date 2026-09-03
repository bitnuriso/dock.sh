## VScode 설정 파일
📄 VSCode 설정 파일 생성 중...
.vscode/settings.json
{
  "terminal.integrated.defaultProfile.windows": "Command Prompt",
  "python.pythonPath": ".venv\\Scripts\\python.exe"
}
---EOF---

## Tailwind CSS
📄 Tailwind 스타일 파일 작성 중...
src/styles/tailwind.css
@tailwind base;
@tailwind components;
@tailwind utilities;
---EOF---

## Reset CSS
📄 Reset 스타일 작성 중...
src/styles/reset.css
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}
---EOF---

## SCSS 변수 파일
📄 SCSS 베이스 스타일 작성 중...
src/styles/scss/_variables.scss
$primary-color: #3490dc;
$font-stack: 'Segoe UI', sans-serif;
---EOF---

## SCSS 애니메이션
📄 SCSS 애니메이션 작성 중...
src/styles/scss/_animations.scss
@keyframes pulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.05); }
  100% { transform: scale(1); }
}

.animated-button {
  animation: pulse 1.5s infinite;
}
---EOF---

## SCSS base.scss
📄 SCSS base.scss 작성 중...
src/styles/scss/base.scss
@import 'variables';
@import 'animations';
---EOF---

## Index CSS
📄 Index CSS 작성 중...
src/styles/index.css
@import './reset.css';
@import './tailwind.css';
@import './scss/base.scss';
---EOF---

## App.jsx
📄 App.jsx 생성 중...
src/App.jsx
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
---EOF---

## index.jsx
📄 index.jsx 생성 중...
src/index.jsx
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
---EOF---

## queryClient.js
📄 queryClient.js 생성 중...
src/common/queryClient.js
import { QueryClient } from "@tanstack/react-query";

export const queryClient = new QueryClient();
---EOF---

## axiosInstance.js
📄 axiosInstance.js 생성 중...
src/api/axiosInstance.js
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
---EOF---

## .env 파일
📄 .env 파일 생성 중...
.env
VITE_API_URL=http://localhost:3000
REACT_APP_VERSION=1.0.0
---EOF---

## .gitignore 파일
📄 .gitignore 생성 중...
.gitignore
/node_modules
.env
/build
.DS_Store
*.log
.vscode
---EOF---

