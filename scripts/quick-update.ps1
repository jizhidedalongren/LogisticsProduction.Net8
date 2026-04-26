# 快速更新本地测试环境
# 用法: .\scripts\quick-update.ps1
# 注意: 需要管理员权限

param(
    [string]$DeployPath = "F:\LogisticsProductionNet8",
    [string]$SiteName = "LogisticsProduction.API",
    [string]$AppPoolName = "LogisticsProductionNet8"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "快速更新本地测试环境" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查管理员权限
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "错误：请以管理员身份运行！" -ForegroundColor Red
    Write-Host "右键 PowerShell → 以管理员身份运行" -ForegroundColor Yellow
    exit 1
}

try {
    # 1. 发布项目
    Write-Host "[1/5] 发布项目..." -ForegroundColor Green
    dotnet publish -c Release -o ./publish
    
    if ($LASTEXITCODE -ne 0) {
        throw "项目发布失败"
    }
    Write-Host "  ✓ 发布完成" -ForegroundColor Gray

    # 2. 停止网站
    Write-Host "[2/5] 停止网站..." -ForegroundColor Green
    Import-Module WebAdministration -ErrorAction Stop
    
    if (Test-Path "IIS:\Sites\$SiteName") {
        Stop-Website -Name $SiteName -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3
        Write-Host "  ✓ 网站已停止" -ForegroundColor Gray
    } else {
        Write-Host "  ! 网站不存在，跳过停止步骤" -ForegroundColor Yellow
    }

    # 3. 备份配置文件
    Write-Host "[3/5] 备份配置..." -ForegroundColor Green
    $configFile = "$DeployPath\appsettings.Production.json"
    $configBackup = "$DeployPath\appsettings.Production.json.backup"
    
    if (Test-Path $configFile) {
        Copy-Item $configFile -Destination $configBackup -Force
        Write-Host "  ✓ 配置已备份" -ForegroundColor Gray
    } else {
        Write-Host "  ! 未找到生产配置文件" -ForegroundColor Yellow
    }

    # 4. 复制文件
    Write-Host "[4/5] 复制文件..." -ForegroundColor Green
    
    if (!(Test-Path $DeployPath)) {
        New-Item -ItemType Directory -Path $DeployPath -Force | Out-Null
    }
    
    Copy-Item -Path ".\publish\*" -Destination $DeployPath -Recurse -Force
    Write-Host "  ✓ 文件复制完成" -ForegroundColor Gray

    # 恢复配置文件
    if (Test-Path $configBackup) {
        Copy-Item $configBackup -Destination $configFile -Force
        Remove-Item $configBackup -Force
        Write-Host "  ✓ 配置已恢复" -ForegroundColor Gray
    }

    # 5. 启动网站
    Write-Host "[5/5] 启动网站..." -ForegroundColor Green
    
    if (Test-Path "IIS:\Sites\$SiteName") {
        Start-Website -Name $SiteName
        Start-Sleep -Seconds 3
        
        $site = Get-Website -Name $SiteName
        if ($site.State -eq "Started") {
            Write-Host "  ✓ 网站运行中" -ForegroundColor Green
        } else {
            Write-Host "  ! 网站状态: $($site.State)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ! 网站不存在，请先运行首次安装" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "更新完成！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "验证部署：" -ForegroundColor Yellow
    Write-Host "  访问 Swagger: http://localhost:8008/swagger" -ForegroundColor White
    Write-Host "  查看日志: Get-Content '$DeployPath\Logs\*.log' -Tail 50" -ForegroundColor White
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "更新失败！" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "错误信息: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    
    # 尝试恢复配置
    if (Test-Path $configBackup) {
        Copy-Item $configBackup -Destination $configFile -Force
        Remove-Item $configBackup -Force
        Write-Host "配置文件已恢复" -ForegroundColor Yellow
    }
    
    # 尝试启动网站
    if (Test-Path "IIS:\Sites\$SiteName") {
        Start-Website -Name $SiteName -ErrorAction SilentlyContinue
    }
    
    exit 1
}
