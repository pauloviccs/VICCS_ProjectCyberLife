# Synchronizes _shared/ls_shared.lua to all ls_* resources in lifesim
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$lifesimRoot = Split-Path -Parent $scriptDir
$sharedSource = Join-Path $lifesimRoot "_shared\ls_shared.lua"

if (-not (Test-Path $sharedSource)) {
    Write-Error "Arquivo fonte não encontrado: $sharedSource"
}

Write-Host "Sincronizando ls_shared.lua a partir de $sharedSource ..." -ForegroundColor Cyan

$resources = Get-ChildItem -Path $lifesimRoot -Directory | Where-Object { $_.Name -like "ls_*" }

foreach ($res in $resources) {
    $targetDir = Join-Path $res.FullName "shared"
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }
    $targetFile = Join-Path $targetDir "ls_shared.lua"
    Copy-Item -Path $sharedSource -Destination $targetFile -Force
    Write-Host " -> Copiado para: $($res.Name)/shared/ls_shared.lua" -ForegroundColor Green
}

Write-Host "Sincronização concluída com sucesso!" -ForegroundColor Green
