# ⚓ Dock.sh

**매번 반복되던 셋업, 이제 한 줄로 정박하세요.**

> One command. One workspace. Ready to code.

FastAPI, React, React Native, Next.js, Express, NestJS, Flutter 등 여러 개발 스택의 **프로젝트 생성부터 초기 환경 구성, 실행 준비까지 자동화하는 CLI 도구**입니다.

새 프로젝트를 시작할 때마다 반복되던 폴더 생성, 기본 구조 구성, 의존성 준비, 편집기 실행을 줄이고 곧바로 개발을 시작하는 것을 목표로 합니다.

---

## ✨ Overview

```bash
d [project_name] [f/b] [framework]
```

예:

```bash
d real f r
d myai b f
```

Dock.sh는 명령 한 줄로 프로젝트 종류에 맞는 기본 구조와 실행 환경을 준비합니다.

이미 동일한 프로젝트가 존재하면 새로 생성하거나 덮어쓰지 않고 기존 프로젝트를 그대로 엽니다.

---

## 🧰 Supported Stacks

| Code | Stack        |
| ---- | ------------ |
| `f`  | FastAPI      |
| `r`  | React        |
| `rn` | React Native |
| `n`  | Next.js      |
| `ne` | Express      |
| `nn` | NestJS       |
| `fl` | Flutter      |

---

## ⚙️ What Dock.sh Does

* 프로젝트 폴더 자동 생성
* Frontend / Backend 구조 분리
* 프레임워크별 기본 디렉터리 구성
* 기존 프로젝트 감지 및 재생성 방지
* VS Code 자동 실행
* 개발 환경 및 의존성 초기화
* 작업 로그 저장
* React Native 실기기 / Emulator 실행 보조

> 필요한 것만 빠르게 만들어주고,
> 이미 있는 것은 건드리지 않습니다.

---

## 🚀 Development Flow

```text
명령 입력
   ↓
프로젝트 종류 판별
   ↓
폴더 및 기본 구조 생성
   ↓
환경 / 의존성 초기화
   ↓
실행 대상 확인
   ↓
VS Code 실행
   ↓
개발 시작
```

React Native 프로젝트에서는 연결된 실기기를 확인합니다.

실기기가 연결되어 있으면 해당 기기를 실행 대상으로 사용하고, 연결된 기기가 없으면 Emulator를 이용할 수 있도록 실행 흐름을 구성합니다.

---

## 🧭 Dock.sh Architecture

Dock.sh는 모든 프레임워크의 초기화 로직을 하나의 거대한 스크립트에 넣지 않습니다.

스택별 초기화 로직과 생성 템플릿을 분리해, 각 프레임워크가 자신의 설정을 독립적으로 관리하도록 구성했습니다.

```text
dock/
├── d.sh                     # Main CLI entry point
│
├── plugins/                 # Stack initialization plugins
│   ├── templates/           # Generated project structure templates
│   │   ├── react.sh
│   │   ├── nextjs.sh
│   │   ├── react_native.sh
│   │   ├── flutter.sh
│   │   ├── fastapi.sh
│   │   ├── nestjs.sh
│   │   ├── express.sh
│   │   └── ...
│   │
│   ├── react.sh
│   ├── nextjs.sh
│   ├── react_native.sh
│   ├── flutter.sh
│   ├── fastapi.sh
│   ├── nestjs.sh
│   ├── express.sh
│   └── ...
│
├── .env/
│   ├── .dockenv
│   ├── .dockenv.path
│   ├── env_setup.sh
│   ├── init_venvs.sh
│   ├── rn_device.sh
│   └── path_collection.txt
│
├── scripts/
│   ├── orca.sh
│   ├── translate.sh
│   └── intro.sh
│
├── logs/
│   └── manage_logs.txt
│
└── README.md
```

이 구조를 통해 새로운 스택을 추가할 때 전체 CLI를 다시 수정하기보다 plugin과 template을 확장하는 방향을 지향합니다.

---

## 🗂️ Generated Project Structures

Dock.sh는 단순히 빈 프로젝트를 생성하는 데서 끝나지 않습니다.

API, 공통 설정, 컴포넌트, 라우팅, 스타일, 환경변수 등 개발을 시작할 때 반복적으로 만들던 기본 골격까지 함께 구성합니다.

### ⚛️ React

<details>
<summary><strong>React 기본 구조 보기</strong></summary>

<br>

```text
.vscode/
└── settings.json

public/
├── images/
├── icons/
├── fonts/
├── favicon.ico
├── index.html
└── manifest.json

src/
├── api/
├── common/
├── components/
├── hooks/
├── pages/
├── routes/
├── styles/
│   ├── index.css
│   ├── tailwind.css
│   ├── reset.css
│   └── scss/
│       ├── _variables.scss
│       ├── _animations.scss
│       └── base.scss
├── App.jsx
└── index.jsx
```

`public` 내부 리소스는 `/images/example.jpg`와 같은 절대 경로를 기준으로 접근합니다.

</details>

---

### 📱 React Native

<details>
<summary><strong>React Native 기본 구조 보기</strong></summary>

<br>

```text
myproject/
└── myproject_front/
    ├── .vscode/
    │   └── settings.json
    │
    ├── myproject/
    │   ├── android/
    │   └── ios/
    │
    ├── src/
    │   ├── api/
    │   ├── common/
    │   ├── components/
    │   ├── hooks/
    │   ├── navigations/
    │   ├── screens/
    │   └── styles/
    │       ├── scss/
    │       │   └── custom.scss
    │       └── theme.js
    │
    ├── .env
    ├── .gitignore
    ├── babel.config.js
    ├── metro.config.js
    ├── package.json
    ├── package-lock.json
    ├── requirements.txt
    ├── tailwind.config.js
    └── setup_env.(bat|sh)
```

React Native에서는 프로젝트 생성뿐 아니라 연결된 실기기를 확인해 실행 환경을 선택하는 과정도 자동화 대상으로 포함합니다.

</details>

---

### 🚀 Next.js

<details>
<summary><strong>Next.js 기본 구조 보기</strong></summary>

<br>

```text
myproject/
└── myproject_front/
    ├── .vscode/
    │   └── settings.json
    │
    ├── public/
    │   ├── fonts/
    │   ├── icons/
    │   └── images/
    │
    ├── src/
    │   ├── api/
    │   │   └── axiosInstance.js
    │   ├── app/
    │   │   ├── favicon.ico
    │   │   ├── globals.css
    │   │   ├── layout.js
    │   │   ├── page.js
    │   │   └── page.module.css
    │   ├── common/
    │   │   └── queryClient.js
    │   ├── components/
    │   └── hooks/
    │
    ├── styles/
    │   └── scss/
    │       ├── index.css
    │       ├── reset.css
    │       └── tailwind.css
    │
    ├── .env
    ├── .gitignore
    ├── eslint.config.mjs
    ├── jsconfig.json
    ├── next.config.mjs
    ├── package.json
    ├── package-lock.json
    ├── requirements.txt
    ├── setup_env.bat
    └── tailwind.config.js
```

</details>

---

### ⚡ FastAPI

<details>
<summary><strong>FastAPI 기본 구조 보기</strong></summary>

<br>

```text
myproject/
└── myproject_backend/
    ├── .venv/
    │
    ├── .vscode/
    │   └── settings.json
    │
    ├── app/
    │   ├── db/
    │   ├── models/
    │   ├── repository/
    │   ├── routes/
    │   ├── schemas/
    │   ├── services/
    │   ├── setting/
    │   ├── static/
    │   ├── utils/
    │   └── main.py
    │
    ├── .env
    ├── .gitignore
    ├── requirements.txt
    └── setup_env.bat
```

FastAPI 프로젝트에서는 DB, ORM Model, Repository, Route, Schema, Service 등을 기본적으로 분리해 곧바로 기능 구현을 시작할 수 있는 골격을 생성합니다.

</details>

---

## 🪟 Environment

현재 Dock.sh는 **Windows 11 + WSL2** 환경을 중심으로 개발하고 테스트했습니다.

주요 사용 환경은 다음과 같습니다.

* Ubuntu on WSL2
* Windows 파일 시스템
* VS Code
* Python / Node 기반 개발 환경
* React Native Android 개발

Windows와 WSL을 함께 사용하는 환경 특성상 파일 시스템 동기화나 프로세스 실행이 지연되는 경우가 있어, 해당 부분도 자동화 및 안정화 대상으로 다루고 있습니다.

---

## 🚧 Status

현재 주요 자동화 기능은 구현되어 있으며 실제 개인 개발 환경에서 사용하고 있습니다.

프로젝트 생성, 기본 구조 구성, 개발 환경 초기화, VS Code 실행 등 핵심 흐름은 정상 동작합니다.

다만 초기 개발 과정에서 빠르게 기능을 추가한 만큼 일부 스크립트에는 정리할 부분이 남아 있습니다.

다음 단계에서는 새로운 프레임워크 추가보다 다음 영역을 우선적으로 정리할 예정입니다.

* OS별 환경 설정 스크립트 정리
* 로그 디렉터리 자동 생성
* Windows / WSL 경로 처리 안정화
* React Native 프로젝트 초기화 흐름 개선
* 설치 및 Quick Start 단순화
* 공통 설정과 plugin 구조 리팩터링

---

## ⚠️ Known Issues

<details>
<summary><strong>현재 알려진 환경별 이슈 보기</strong></summary>

<br>

### 로그 디렉터리

일부 환경에서는 최초 실행 전 `logs/` 디렉터리가 필요할 수 있습니다.

향후 자동 생성하도록 수정할 예정입니다.

### React Native 초기화

React Native 프로젝트 생성 과정에서 추가 빈 디렉터리가 만들어지는 경우가 있습니다.

현재는 생성 후 정리하는 방식으로 사용하며, 초기화 스크립트 개선을 예정하고 있습니다.

### Windows + WSL2

다음과 같은 현상이 간헐적으로 발생할 수 있습니다.

* 생성한 디렉터리가 즉시 보이지 않음
* VS Code 실행 지연
* `npm create` 진행이 멈춘 것처럼 보임

WSL 파일 시스템과 Windows 측 I/O 동기화에 영향을 받을 수 있으며, 필요할 경우 WSL 재시작으로 해결됩니다.

```bash
wsl --shutdown
```

</details>

---

## 🧩 Design Principles

### 1. 반복 작업은 한 번만 정의합니다.

프레임워크마다 되풀이하던 초기 설정을 template과 plugin으로 묶어 다시 입력하지 않도록 합니다.

### 2. 이미 있는 프로젝트는 건드리지 않습니다.

기존 프로젝트가 존재하면 다시 생성하거나 덮어쓰지 않고 그대로 엽니다.

### 3. 생성보다 개발 시작이 목적입니다.

Dock.sh의 목표는 파일 몇 개를 만들어주는 것이 아니라, 실제 개발을 시작할 수 있는 상태까지 준비하는 것입니다.

> 프로젝트는 만들고,
> 편집기는 열고,
> 개발 시작 버튼은 눌러드립니다.

---

<details>
<summary><strong>📜 옛 기록에 Dock이라 하는 부두가 전해집니다...</strong></summary>

<br>

옛 기록에 이르기를, 빛누리소는 본디 햇살 아래 드러눕기를 즐겼다.

사람들이 묻기를,

> "새 일을 벌일 때마다 같은 터전을 세우고, 같은 물건을 갖추며, 같은 문을 여는 일이 번거롭지 않소?"

하니 빛누리소가 답하였다.

> **"그리 번거롭다면, 한 줄로 부르면 될 일이오."**

이에 여러 일을 시작할 적 필요한 터전과 연장을 미리 갖추는 작은 부두를 세웠으니, 후세 사람들이 이를 **Dock.sh**라 불렀다.

Dock이라 함은 배가 잠시 머물러 다음 항해를 준비하는 부두를 이르는 것이다.

이 부두에는 FastAPI와 React와 React Native, Next.js를 비롯한 여러 배가 닻을 내렸으며, 일이 정해지면 저마다 필요한 틀과 물건을 갖추어 제 자리로 들어갔다 한다.

누리소가 이를 보고 말하기를,

> **"같은 일을 두 번 하는 것보다는, 한 번 귀찮은 편이 낫지 않은가."**

하였다.

</details>
