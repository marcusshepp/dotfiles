# WezTerm Configuration Setup Script
# Run this script as Administrator

$configPath = "$env:USERPROFILE\.wezterm.lua"
$dotfilesPath = "$env:USERPROFILE\p\dotfiles\.wezterm.lua"

# Remove existing config if it exists
if (Test-Path $configPath) {
    Write-Host "Backing up existing config to .wezterm.lua.backup"
    Copy-Item $configPath "$configPath.backup" -Force
    Remove-Item $configPath -Force
}

# Create symbolic link
Write-Host "Creating symlink from $configPath to $dotfilesPath"
New-Item -ItemType SymbolicLink -Path $configPath -Target $dotfilesPath -Force

Write-Host "WezTerm configuration setup complete!"
Write-Host "Config is now linked to: $dotfilesPath"
