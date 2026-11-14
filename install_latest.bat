@echo off
chcp 65001 >nul
setlocal
title CafeAuto Installer (latest)
echo ============================================================
echo  CafeAuto 최신 버전 자동 설치
echo  - GitHub 최신 릴리스 다운로드
echo  - sha256 검증
echo  - %%LOCALAPPDATA%%\CafeAuto\app 설치
echo ============================================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop'; $u='https://raw.githubusercontent.com/namtsby/navercafe-auto-releases-08/main/install_latest.ps1'; $p=Join-Path $env:TEMP 'cafeauto_install_latest.ps1'; Invoke-WebRequest -Uri $u -OutFile $p -UseBasicParsing; & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $p"
if errorlevel 1 (
    echo.
    echo [ERROR] 설치에 실패했습니다. 인터넷 연결과 GitHub 접근을 확인하세요.
    pause
    exit /b 1
)
echo.
echo 설치가 완료되었습니다.
exit /b 0
