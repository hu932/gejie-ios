# 格界 - Docker 一键编译脚本
# 运行前确保已安装 Docker Desktop: https://www.docker.com/products/docker-desktop/

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  格界 deb 编译工具" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Docker
Write-Host "[1/4] 检查 Docker 环境..." -ForegroundColor Yellow
$dockerVersion = docker --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] Docker 未安装！" -ForegroundColor Red
    Write-Host ""
    Write-Host "请先安装 Docker Desktop:" -ForegroundColor White
    Write-Host "  https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "安装完成后重新运行此脚本。" -ForegroundColor White
    Read-Host "按回车退出"
    exit 1
}
Write-Host "  ✓ $dockerVersion" -ForegroundColor Green

# 检查 Docker 是否运行
Write-Host "[2/4] 检查 Docker 服务..." -ForegroundColor Yellow
docker info 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] Docker Desktop 未运行，请先启动它！" -ForegroundColor Red
    Read-Host "按回车退出"
    exit 1
}
Write-Host "  ✓ Docker 服务正常" -ForegroundColor Green

# 获取项目路径
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = $scriptDir.Replace('\', '/')
# 转为 Docker 可用路径（Windows 路径转换）
$dockerPath = $projectDir -replace '^([A-Z]):', { '//' + $_.Groups[1].Value.ToLower() }

Write-Host "[3/4] 拉取 Theos 编译环境..." -ForegroundColor Yellow
Write-Host "  (首次运行需要下载镜像，约 1-2 GB，请耐心等待)" -ForegroundColor Gray
docker pull ghcr.io/nickchan929/theos-buildenv:latest
if ($LASTEXITCODE -ne 0) {
    Write-Host "  尝试备用镜像..." -ForegroundColor Yellow
    docker pull alfiecg/theos-base:latest 2>&1
    $useAlt = $true
}

Write-Host ""
Write-Host "[4/4] 开始编译格界..." -ForegroundColor Yellow
Write-Host "  项目路径: $scriptDir" -ForegroundColor Gray
Write-Host ""

# 编译
if ($useAlt) {
    docker run --rm `
        -v "${scriptDir}:/work" `
        -w /work `
        alfiecg/theos-base:latest `
        bash -c "export THEOS=/opt/theos; make package FINALPACKAGE=1 2>&1"
} else {
    docker run --rm `
        -v "${scriptDir}:/work" `
        -w /work `
        ghcr.io/nickchan929/theos-buildenv:latest `
        bash -c "export THEOS=/opt/theos; make package FINALPACKAGE=1 2>&1"
}

Write-Host ""
if ($LASTEXITCODE -eq 0) {
    $debFile = Get-ChildItem -Path "$scriptDir\packages" -Filter "*.deb" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($debFile) {
        Write-Host "=====================================" -ForegroundColor Green
        Write-Host "  编译成功！" -ForegroundColor Green
        Write-Host "=====================================" -ForegroundColor Green
        Write-Host "  deb 文件: $($debFile.FullName)" -ForegroundColor Cyan
        Write-Host "  文件大小: $([math]::Round($debFile.Length/1KB, 1)) KB" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "安装到越狱手机：" -ForegroundColor Yellow
        Write-Host "  1. 用 Filza 或 iFile 把 deb 传到手机" -ForegroundColor White
        Write-Host "  2. 点击 deb 文件安装" -ForegroundColor White
        Write-Host "  3. 或用 SSH: scp $($debFile.Name) root@手机IP:/var/root/" -ForegroundColor White
    } else {
        Write-Host "编译完成，但未找到 deb 文件，请检查 packages/ 目录。" -ForegroundColor Yellow
    }
} else {
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host "  编译失败！请查看上方错误信息。" -ForegroundColor Red
    Write-Host "=====================================" -ForegroundColor Red
}

Write-Host ""
Read-Host "按回车退出"
