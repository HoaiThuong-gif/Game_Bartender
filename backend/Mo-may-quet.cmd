@echo off
title MeoMeo - May quet 3D
echo Dang mo may quet. Lan dau co the can cho tai thu vien.
echo Giu cua so nay mo trong khi quet va xu ly mo hinh.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\start-scan-server.ps1"
if errorlevel 1 (
    echo May quet chua khoi dong duoc. Giu lai thong bao loi ben tren de kiem tra.
    pause
)
