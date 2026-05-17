$ErrorActionPreference = "Stop"

$projectPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$godotExe = Join-Path $projectPath "..\Tools\Godot\Godot_v4.6.2-stable_win64.exe"
$godotExe = [System.IO.Path]::GetFullPath($godotExe)

if (-not (Test-Path -LiteralPath $godotExe)) {
    throw "Godot executable not found: $godotExe"
}

& $godotExe --path $projectPath

