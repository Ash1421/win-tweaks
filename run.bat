@echo off
title Ash's Windows Tweaks Manager

:: Try to run as Administrator.
:: If elevation is not available (e.g. school), falls back to running as current user.
net session >nul 2>&1
if %errorLevel% == 0 (
    :: Already admin — run directly
    powershell -ExecutionPolicy Bypass -File "%~dp0tweaks.ps1"
) else (
    :: Not admin — attempt UAC elevation, fall back silently if denied
    powershell -Command "try { Start-Process -FilePath '%~f0' -Verb RunAs -ErrorAction Stop } catch { }" >nul 2>&1
    if %errorLevel% neq 0 (
        :: Elevation failed or was denied — run as current user anyway
        powershell -ExecutionPolicy Bypass -File "%~dp0tweaks.ps1"
    )
)
