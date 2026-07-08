# Capture live VS Code user settings into the repo (correct dest: windows-conf/vscode).
$dst = "$HOME\p\dotfiles\windows-conf\vscode"
New-Item -ItemType Directory -Force -Path $dst | Out-Null
Copy-Item "$HOME\AppData\Roaming\Code\User\settings.json" "$dst\settings.json" -Force
