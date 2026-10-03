@echo off
title OPEN//77 - Validacao de Configuracao
echo ========================================================
echo   Validando server.jsonc do OPEN//77 Server...
echo ========================================================
echo.

Open77.Server.exe --config server.jsonc --check-config

echo.
pause
