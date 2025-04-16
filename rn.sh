#!/bin/bash

exec > >(tee "/mnt/c/Users/akasa/Desktop/Proj/logs/rn_$(date +%m%d_%H%M).log") 2>&1

PROJECT="$1"
APP_NAME="${PROJECT}_front"
TARGET_PATH="/mnt/c/Users/akasa/Desktop/Proj/$PROJECT"
INIT_PATH="$TARGET_PATH/$APP_NAME"
#TEMP_PATH="$TARGET_PATH/temp_rn"

echo "[DEBUG] rn.sh 안에서 PROJECT = $PROJECT"
echo "[DEBUG] APP_NAME = $APP_NAME"
echo "[DEBUG] INIT_PATH = $INIT_PATH"

if [ -z "$PROJECT" ]; then
  echo "❌ 프로젝트 이름이 전달되지 않았습니다."
  exit 1
fi

# 기존 폴더가 존재하되 비어있지 않으면 중단
if [ -d "$INIT_PATH" ] && [ "$(ls -A "$INIT_PATH")" ]; then
  echo "  기존 폴더 $INIT_PATH 가 비어있지 않습니다. 삭제 후 다시 시도해 주세요."
  read -rp "👉 Enter 키를 눌러 종료하세요 (Press Enter to exit) " dummy
  exit 1
fi

mkdir -p "$APP_NAME"
echo "$APP_NAME 폴더 생성 완료 : PATH = $INIT_PATH"
cd $INIT_PATH
echo "$APP_NAME 폴더로 이동..."

echo "🔍 의존성 체크 시작... (Dependency Check Start)"

REQUIRED_CMDS=(node npm npx)
MISSING=0
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

echo "📄 requirements.txt 생성 중..."
cat <<EOF > requirements.txt
# dependencies
axios
@tanstack/react-query
@react-navigation/native
@react-navigation/native-stack
react-native-screens
react-native-safe-area-context
react-native-gesture-handler
react-native-reanimated
nativewind

# devDependencies
react-native-sass-transformer
tailwindcss
EOF

        echo "📦 패키지 설치 중..."
        while IFS= read -r pkg; do
                if [[ "$pkg" == \#* || -z "$pkg" ]]; then
                        continue
                elif grep -q "$pkg" <<< "react-native-sass-transformer tailwindcss"; then
                        npm install -D "$pkg"
                else
                        npm install "$pkg"
                fi
        done < requirements.txt

        echo "📄 tailwind.config.js 설정 중..."
        cat <<EOF > tailwind.config.js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./App.{js,jsx,ts,tsx}", "./src/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {},
  },
  plugins: [],
};
EOF

        echo "📄 babel.config.js 생성 중..."
        cat <<EOF > babel.config.js
module.exports = {
  presets: ['module:metro-react-native-babel-preset'],
  plugins: ['nativewind/babel'],
};
EOF

        echo "📄 metro.config.js 생성 중 (SCSS 지원용)..."
        cat <<EOF > metro.config.js
const { getDefaultConfig } = require('expo/metro-config');
const defaultConfig = getDefaultConfig(__dirname);

module.exports = {
  ...defaultConfig,
  transformer: {
    babelTransformerPath: require.resolve('react-native-sass-transformer'),
  },
  resolver: {
    sourceExts: ['js', 'jsx', 'scss'],
  },
};
EOF

        echo "📁 폴더 구조 생성 중..."
        mkdir -p src/{api,common,components,hooks,navigations,screens,styles/scss}
	mkdir -p .vscode
        #VScode 설정 파일 생성
        # VSCode 설정 (Git Bash + venv 자동 진입)
        cat <<EOF > .vscode/settings.json
{
  "terminal.integrated.defaultProfile.windows": "Command Prompt",
  "python.pythonPath": ".venv\\Scripts\\python.exe"
}
EOF
        echo "📄 axiosInstance.js 생성 중..."
        cat <<EOF > src/api/axiosInstance.js
import axios from 'axios';

const axiosInstance = axios.create({
  baseURL: 'http://localhost:3000',
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

        echo "📄 AppNavigator.js 생성 중..."
        cat <<EOF > src/navigations/AppNavigator.js
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import HomeScreen from '../screens/HomeScreen';

const Stack = createNativeStackNavigator();

const AppNavigator = () => (
  <NavigationContainer>
    <Stack.Navigator>
      <Stack.Screen name="Home" component={HomeScreen} />
    </Stack.Navigator>
  </NavigationContainer>
);

export default AppNavigator;
EOF

        echo "📄 HomeScreen.js 생성 중..."
        cat <<EOF > src/screens/HomeScreen.js
import React from 'react';
import { View, Text } from 'react-native';
import '../styles/scss/custom.scss';

const HomeScreen = () => (
  <View className="flex-1 justify-center items-center bg-white">
    <Text className="text-blue-500 text-xl font-bold">🏠 Hello NativeWind + SCSS!</Text>
  </View>
);

export default HomeScreen;
EOF

        echo "📄 theme.js 생성 중..."
        cat <<EOF > src/styles/theme.js
export const colors = {
  primary: '#007bff',
  secondary: '#6c757d',
  background: '#f8f9fa',
  text: '#212529',
};
EOF

        echo "📄 custom.scss 생성 중..."
        cat <<EOF > src/styles/scss/custom.scss
// SCSS 예시
\$primary-color: #007bff;

.text-primary {
  color: \$primary-color;
}
EOF

        echo "📄 App.js 수정 중..."
        cat <<EOF > src/App.js
import React from 'react';
import { QueryClientProvider } from '@tanstack/react-query';
import { queryClient } from './common/queryClient';
import AppNavigator from './navigations/AppNavigator';

const App = () => (
  <QueryClientProvider client={queryClient}>
    <AppNavigator />
  </QueryClientProvider>
);

export default App;
EOF

        echo "📄 .env 파일 생성 중..."
        cat <<EOF > .env
API_URL=http://localhost:3000
EOF

        echo "📄 .gitignore 파일 생성 중..."
        cat <<EOF > .gitignore
/node_modules
.env
/android/app/build
/ios/build
.DS_Store
*.log
.vscode
EOF

echo "✅ React Native 프로젝트 초기화 완료!"

echo "📦 React Native 프로젝트 임시 생성 중..."
npx @react-native-community/cli init "$PROJECT"
RC=$?

if [ $RC -ne 0 ]; then
  echo "❌ react-native init 실패 (에러 코드: $RC)"
  rm -rf "$INIT_PATH"
  read -rp "👉 Enter 키를 눌러 종료하세요 (Press Enter to exit) " dummy
  exit 1
fi

#echo "📁 구조 정리 중..."
#mkdir -p "$INIT_PATH"
#mv "$TEMP_PATH"/* "$TEMP_PATH"/.* "$INIT_PATH" 2>/dev/null
#rm -rf "$TEMP_PATH"

