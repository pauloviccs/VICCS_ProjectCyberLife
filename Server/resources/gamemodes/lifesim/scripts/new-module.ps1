param(
    [Parameter(Mandatory=$true)]
    [string]$ModuleName
)

$ErrorActionPreference = "Stop"

if (-not ($ModuleName -like "ls_*")) {
    $ModuleName = "ls_$ModuleName"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$lifesimRoot = Split-Path -Parent $scriptDir
$modulePath = Join-Path $lifesimRoot $ModuleName

if (Test-Path $modulePath) {
    Write-Error "O módulo '$ModuleName' já existe em $modulePath"
}

Write-Host "Criando scaffolding para o módulo '$ModuleName'..." -ForegroundColor Cyan

# Criação de diretórios
New-Item -ItemType Directory -Path (Join-Path $modulePath "shared") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modulePath "server") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modulePath "client") -Force | Out-Null

# Copiar ls_shared.lua
$sharedSource = Join-Path $lifesimRoot "_shared\ls_shared.lua"
if (Test-Path $sharedSource) {
    Copy-Item -Path $sharedSource -Destination (Join-Path $modulePath "shared\ls_shared.lua") -Force
}

# Manifesto open77.lua
$manifestContent = @"
---@diagnostic disable: undefined-global
resource "$ModuleName"
version "0.1.0"
open77_version ">=0.0.1"
auto_start(true)
reload_policy "local"

dependency "ls_core >=0.1.0"
dependency "ls_data >=0.1.0"

shared_script "shared/ls_shared.lua"
shared_script "shared/config.lua"
server_script "server/main.lua"
client_script "client/main.lua"

permissions {
    "network.events",
    "state.write"
}
"@
Set-Content -Path (Join-Path $modulePath "open77.lua") -Value $manifestContent -Encoding UTF8

# config.lua
$configContent = @"
Config = Config or {}
Config.Enabled = true
"@
Set-Content -Path (Join-Path $modulePath "shared\config.lua") -Value $configContent -Encoding UTF8

# server/main.lua
$serverMainContent = @"
local Module = {
    name = "$ModuleName",
    version = "0.1.0"
}

AddEventHandler("onResourceStart", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    
    -- Registrar no Core
    exports.ls_core:registerModule({
        version = Module.version,
        requires = { "ls_core", "ls_data" },
        provides = { exports = {} },
        emits = {},
        listens = { "ls:core:ready", "ls:core:playerLoaded" },
        stateKeys = {},
        tables = {}
    })
    
    Open77.log.info(("[$ModuleName] Inicializado com sucesso (v%s)"):format(Module.version))
end)
"@
Set-Content -Path (Join-Path $modulePath "server\main.lua") -Value $serverMainContent -Encoding UTF8

# client/main.lua
$clientMainContent = @"
AddEventHandler("onClientResourceStart", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    Open77.log.info("[$ModuleName] Cliente ativo.")
end)
"@
Set-Content -Path (Join-Path $modulePath "client\main.lua") -Value $clientMainContent -Encoding UTF8

Write-Host "Módulo '$ModuleName' criado com sucesso!" -ForegroundColor Green
