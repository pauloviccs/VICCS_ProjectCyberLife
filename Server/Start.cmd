@echo off
cd /d "%~dp0"
Open77.Server.exe %*
if errorlevel 1 pause
