@echo off
chcp 65001 >nul
title Sistema de Oficios - SCFC

echo.
echo ========================================
echo    SISTEMA DE OFICIOS - SCFC
echo ========================================
echo.
echo Iniciando servidor local...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0server.ps1"

pause
