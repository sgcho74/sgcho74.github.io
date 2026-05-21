# push.ps1 — 슬라이드 변경분을 한 번에 커밋·푸시
# 사용법:
#   .\push.ps1                       # 기본 메시지로 커밋
#   .\push.ps1 "톤 다듬기"           # 메시지 직접 지정
#   .\push.ps1 -DryRun               # 무엇이 바뀌는지만 보고 끝
#   .\push.ps1 -NoPush "오타 수정"   # 커밋만, 푸시는 X

param(
    [Parameter(Position = 0)]
    [string]$Message = "Update slides",
    [switch]$DryRun,
    [switch]$NoPush
)

$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

Write-Host "[1/4] 변경 파일 확인" -ForegroundColor Cyan
$changed = git status --porcelain
if (-not $changed) {
    Write-Host "  변경된 파일 없음. 종료." -ForegroundColor Yellow
    exit 0
}
$changed | ForEach-Object { Write-Host "  $_" }

if ($DryRun) {
    Write-Host "`n[DryRun] 여기까지만 — 커밋·푸시 안 함" -ForegroundColor Yellow
    exit 0
}

Write-Host "`n[2/4] 스테이징 (git add -A)" -ForegroundColor Cyan
git add -A

Write-Host "`n[3/4] 커밋: $Message" -ForegroundColor Cyan
git commit -m $Message
if ($LASTEXITCODE -ne 0) {
    Write-Host "  커밋 실패. 위 메시지 확인." -ForegroundColor Red
    exit $LASTEXITCODE
}

if ($NoPush) {
    Write-Host "`n[4/4] -NoPush 옵션 — 푸시 생략" -ForegroundColor Yellow
    exit 0
}

Write-Host "`n[4/4] 푸시 (origin main)" -ForegroundColor Cyan
git push origin main
if ($LASTEXITCODE -ne 0) {
    Write-Host "  푸시 실패. 네트워크/권한 확인." -ForegroundColor Red
    exit $LASTEXITCODE
}

$sha = git rev-parse --short HEAD
Write-Host "`n완료: $sha pushed -> origin/main" -ForegroundColor Green
Write-Host "라이브: https://sgcho74.github.io/" -ForegroundColor Green
