#!/bin/bash

python -m venv .venv
mkdir -p .vscode

cat <<EOF > .vscode/settings.json
{
  "python.pythonPath": "\${workspaceFolder}/.venv/Scripts/python3.exe",
  "python.terminal.activateEnvironment": true
}
EOF

echo "✅ .venv 생성 + VSCode 연동 완료"

