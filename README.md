# CafeAuto — Public Release Repository

CafeAuto(네이버 카페 1·2단계 통합 자동화)의 **공개 릴리스 자산 전용 저장소**입니다.
소스 코드는 포함하지 않습니다.

## 초기 설치 (압축 해제 불필요)

- [install_latest.bat](https://github.com/namtsby/navercafe-auto-releases-08/releases/latest/download/install_latest.bat) 다운로드 후 실행
- 최신 zip을 자동 다운로드 → sha256 검증 → `%LOCALAPPDATA%\CafeAuto\app` 설치 → 실행
- 이후 업데이트는 앱이 자동으로 처리

## 다운로드

- 최신 릴리스: https://github.com/namtsby/navercafe-auto-releases-08/releases/latest
- 앱 zip: `CafeAuto_vX.Y.Z_win64.zip`
- 무결성: `CafeAuto_vX.Y.Z_win64.zip.sha256`
- 자동 업데이트 메타데이터: `update.json`

## 자동 업데이트 구조

1. 고객 PC의 `CafeAuto.exe`가 시작 시 `update.repo=namtsby/navercafe-auto-releases-08`를
   GitHub Releases API로 조회합니다. (공개 저장소, 익명, 토큰 불필요)
2. 새 버전이면 `update.json`의 `version`과 앱 버전을 비교합니다.
3. `asset.url` zip을 다운로드하고 `asset.sha256`을 검증합니다.
4. `staging`에 압축을 풀고, 앱 종료 후 헬퍼가 `app → app.old`, `app.new → app`로 교체합니다.
5. 새 exe가 실행됩니다. 교체 실패 시 `app.old`로 롤백합니다.

## 릴리스 방법

```powershell
# 소스 저장소에서 버전 증가 후
git tag v1.0.2
git push origin main --tags

# 또는 수동
powershell -ExecutionPolicy Bypass -File build\build.ps1 -Repo "namtsby/navercafe-auto-releases-08"
gh release create v1.0.2 dist\CafeAuto_v1.0.2_win64.zip `
  dist\CafeAuto_v1.0.2_win64.zip.sha256 dist\update.json `
  --repo namtsby/navercafe-auto-releases-08 `
  --title "CafeAuto v1.0.2" --notes "..."
```

## 주의

- 이 저장소에는 고객 계정·비밀번호·프로필·results 엑셀을 올리지 마세요.
- 앱 exe에는 GitHub 토큰/API 키가 포함되지 않습니다.
- `update.json`의 `asset.url`은 해당 릴리스의 zip 자산을 가리켜야 합니다.


