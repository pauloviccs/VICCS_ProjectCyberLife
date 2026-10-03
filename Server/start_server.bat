@echo off
title OPEN//77 - VICCS Cyberpunk Life-Sim RP Server
echo ========================================================
echo   OPEN//77: VICCS Cyberpunk Dedicated Server
echo   Versao: 2.31.21+op77.121 (win-x64)
echo   Gamemode: Life-Sim RP (Night City)
echo ========================================================
echo.

Open77.Server.exe --config server.jsonc --no-setup

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo O servidor encerrou com erro: %ERRORLEVEL%
    pause
)
