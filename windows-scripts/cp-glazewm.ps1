# Capture live GlazeWM config into the repo (correct dest: windows-conf/glazewm).
$dst = "$HOME\p\dotfiles\windows-conf\glazewm"
if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
Copy-Item "$HOME\.glzr\glazewm" $dst -Recurse -Force
