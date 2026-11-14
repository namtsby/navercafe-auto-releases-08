# CafeAuto 초기 설치/복구 스크립트
# - GitHub 최신 릴리스의 zip을 자동 다운로드/검증/설치합니다.
# - 관리자 권한이 필요 없습니다.
# - 이후 업데이트는 앱의 자동 업데이트가 처리합니다.

$ErrorActionPreference = "Stop"
$repo = "namtsby/navercafe-auto-releases-08"
$api = "https://api.github.com/repos/$repo/releases/latest"
$headers = @{ "User-Agent" = "CafeAuto-Installer"; "Accept" = "application/vnd.github+json" }

Write-Host "CafeAuto 최신 릴리스 확인: $repo"
$release = Invoke-RestMethod -Uri $api -Headers $headers -TimeoutSec 30
$zipAsset = $release.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1
$shaAsset = $release.assets | Where-Object { $_.name -like "*.sha256" } | Select-Object -First 1
if (-not $zipAsset) { throw "릴리스에서 zip 자산을 찾지 못했습니다." }
if (-not $shaAsset) { throw "릴리스에서 sha256 자산을 찾지 못했습니다." }

$temp = Join-Path $env:TEMP ("CafeAutoInstall-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $temp | Out-Null
$zipPath = Join-Path $temp $zipAsset.name
$shaPath = Join-Path $temp $shaAsset.name

Write-Host "다운로드: $($zipAsset.name) ($($zipAsset.size) bytes)"
Invoke-WebRequest -Uri $zipAsset.browser_download_url -OutFile $zipPath -UseBasicParsing
Invoke-WebRequest -Uri $shaAsset.browser_download_url -OutFile $shaPath -UseBasicParsing

$expected = ((Get-Content $shaPath -Raw).Trim() -split "\s+")[0].ToLower()
$actual = (Get-FileHash $zipPath -Algorithm SHA256).Hash.ToLower()
if ($expected -ne $actual) {
    throw "sha256 불일치: expected=$expected actual=$actual"
}
Write-Host "sha256 검증 완료"

Expand-Archive -Path $zipPath -DestinationPath $temp -Force
$source = Join-Path $temp "CafeAuto"
if (-not (Test-Path (Join-Path $source "CafeAuto.exe"))) {
    throw "압축 해제 후 CafeAuto.exe를 찾지 못했습니다."
}

$target = Join-Path $env:LOCALAPPDATA "CafeAuto\app"
taskkill /IM CafeAuto.exe /F 2>$null | Out-Null
if (Test-Path $target) { Remove-Item $target -Recurse -Force }
New-Item -ItemType Directory -Force -Path (Split-Path $target -Parent) | Out-Null
Copy-Item $source $target -Recurse -Force

$ws = New-Object -ComObject WScript.Shell
$shortcut = $ws.CreateShortcut((Join-Path ([Environment]::GetFolderPath("Desktop")) "CafeAuto.lnk"))
$shortcut.TargetPath = Join-Path $target "CafeAuto.exe"
$shortcut.WorkingDirectory = $target
$shortcut.IconLocation = (Join-Path $target "CafeAuto.exe") + ",0"
$shortcut.Save()

Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "설치 완료: $target"
Start-Process (Join-Path $target "CafeAuto.exe")
