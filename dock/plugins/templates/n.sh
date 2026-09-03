# 각 파일 생성 정보는 TITLE, TARGET_PATH, CONTENT 순서로 정의합니다.
# 각 파일 정보는 ---EOF--- 로 구분합니다.

## VScode 설정 파일
📄 VScode 설정 파일 생성 중...
.vscode/settings.json
{
  "terminal.integrated.defaultProfile.windows": "Command Prompt",
  "python.pythonPath": ".venv\\Scripts\\python.exe"
}
---EOF---

## Tailwind 설정 파일
📄 Tailwind 설정 파일 생성 중...
tailwind.config.js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./pages/**/*.{js,ts,jsx,tsx}", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {},
  },
  plugins: [],
};
---EOF---

## Tailwind CSS
📄 CSS 파일 작성 중... (tailwind.css)
src/styles/tailwind.css
@tailwind base;
@tailwind components;
@tailwind utilities;
---EOF---

## Reset CSS
📄 CSS 파일 작성 중... (reset.css)
src/styles/reset.css
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}
---EOF---

## Index CSS
📄 CSS 파일 작성 중... (index.css)
src/styles/index.css
@import './reset.css';
@import './tailwind.css';
@import './scss/custom.scss';
---EOF---

## SCSS 커스텀 파일
📄 SCSS 커스텀 파일 작성 중...
src/styles/scss/custom.scss
$primary-color: #007bff;

.text-primary {
  color: $primary-color;
}
---EOF---

## Axios 인스턴스
📄 axiosInstance.js 생성 중...
src/api/axiosInstance.js
import axios from 'axios';

const axiosInstance = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000',
  timeout: 5000,
  headers: { 'Content-Type': 'application/json' },
});

export default axiosInstance;
---EOF---

## React Query 클라이언트
📄 queryClient.js 생성 중...
src/common/queryClient.js
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient();
---EOF---

## 커스텀 훅 예제
📄 useExample.js 생성 중...
src/hooks/useExample.js
import { useQuery } from '@tanstack/react-query';
import axiosInstance from '../api/axiosInstance';

const fetchExample = async () => {
  const res = await axiosInstance.get('/example');
  return res.data;
};

export const useExample = () => useQuery({ queryKey: ['example'], queryFn: fetchExample });
---EOF---

## 메인 페이지 (index.jsx)
📄 index.jsx 생성 중...
pages/index.jsx
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
---EOF---

## .env 파일
📄 .env 생성 중...
.env
NEXT_PUBLIC_API_URL=http://localhost:3000
---EOF---

## .gitignore 파일
📄 .gitignore 생성 중...
.gitignore
/node_modules
/.next
.env.local
.DS_Store
*.log
.vscode
---EOF---
