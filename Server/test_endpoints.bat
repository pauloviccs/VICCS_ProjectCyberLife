@echo off
title OPEN//77 - Teste de Endpoints
echo ========================================================
echo   Testando Endpoints Locais do Servidor OPEN//77
echo ========================================================
echo.

echo [1/2] Testando Health Check de Recursos (HTTP 11779)...
curl -s http://127.0.0.1:11779/health
echo.
echo.

echo [2/2] Testando Painel Web Warden (HTTP 11780)...
curl -s -I http://127.0.0.1:11780/
echo.

echo ========================================================
echo   Teste concluido! Se os codigos forem 200 OK, tudo esta 100%%.
echo ========================================================
pause
