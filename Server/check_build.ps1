Add-Type -Path "C:\Games\VICCS_CyberpunkServer\Server\Open77.Protocol.dll"
Add-Type -Path "C:\Games\VICCS_CyberpunkServer\Server\Open77.Server.Core.dll"

$proto = [System.Reflection.Assembly]::LoadFrom("C:\Games\VICCS_CyberpunkServer\Server\Open77.Protocol.dll")
$core = [System.Reflection.Assembly]::LoadFrom("C:\Games\VICCS_CyberpunkServer\Server\Open77.Server.Core.dll")

Write-Host "--- PROTOCOL TYPES ---"
$proto.GetTypes() | Where-Object { $_.Name -match "Reject|Hello|Handshake" } | ForEach-Object {
    Write-Host $_.FullName
    $_.GetProperties() | ForEach-Object { Write-Host "   prop: $($_.Name) : $($_.PropertyType)" }
}

Write-Host "--- CORE TYPES ---"
$core.GetTypes() | Where-Object { $_.Name -match "Handshake|Admission|Connection" } | ForEach-Object {
    Write-Host $_.FullName
}
