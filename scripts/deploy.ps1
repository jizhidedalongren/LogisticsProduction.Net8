# 物流生产 API 部署脚本 (.NET 8)
# 用法: .\scripts\deploy.ps1 -Environment "Production" -Version "1.0.0"

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Development", "Staging", "Production")]
    [string]$Environment = "Production",
    
    [Parameter(Mandatory=$false)]
    [string]$Version = "1.0.0",
    
    [string]$DeployPath = "F:\LogisticsProductionNet8",
    
    [string]$SiteName = "LogisticsProduction.API",
    
    [switch]$SkipBackup = $false,
    
    [switch]$SkipBuild = $false,
    
    [switch]$SkipIIS = $false
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "物流生产 API 部署脚本 (.NET 8)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "环境: $Environment" -ForegroundColor Yellow
Write-Host "版本: $Version" -ForegroundColor Yellow
Write-Host "部署路径: $DeployPath" -ForegroundColor Yellow
Write-Host "IIS 站点: $SiteName" -ForegroundColor Yellow
Write-Host ""

# 配置
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$publishPath = ".\publish"
$backupPath = "$DeployPath.backup.$timestamp"

# 步骤 1: 清理旧的发布文件
Write-Host "[1/7] 清理旧的发布文件..." -ForegroundColor Green
if (Test-Path $publishPath) {
    Remove-Item -Path $publishPath -Recurse -Force
    Write-Host "  清理完成" -ForegroundColor Gray
}

# 步骤 2: 发布项目
if (-not $SkipBuild) {
    Write-Host "[2/7] 发布项目..." -ForegroundColor Green
    
    # 还原依赖
    Write-Host "  还原 NuGet 包..." -ForegroundColor Gray
    dotnet restore
    
    if ($LASTEXITCODE -ne 0) {
        throw "NuGet 还原失败"
    }
    
    # 发布项目
    Write-Host "  发布项目 (Release)..." -ForegroundColor Gray
    dotnet publish -c Release -o $publishPath --no-restore
    
    if ($LASTEXITCODE -ne 0) {
        throw "项目发布失败"
    }
    
    Write-Host "  发布完成" -ForegroundColor Gray
} else {
    Write-Host "[2/7] 跳过编译" -ForegroundColor Yellow
}

# 步骤 3: 更新配置文件
Write-Host "[3/7] 更新配置文件..." -ForegroundColor Green

# 复制环境特定的配置文件
if (Test-Path ".\appsettings.$Environment.json") {
    Copy-Item -Path ".\appsettings.$Environment.json" -Destination "$publishPath\appsettings.$Environment.json" -Force
    Write-Host "  已复制 appsettings.$Environment.json" -ForegroundColor Gray
}

# 更新 appsettings.json 中的版本信息
$appsettingsPath = "$publishPath\appsettings.json"
if (Test-Path $appsettingsPath) {
    $appsettings = Get-Content $appsettingsPath -Raw | ConvertFrom-Json
    
    # 添加版本信息
    if (-not $appsettings.PSObject.Properties["AppInfo"]) {
        $appsettings | Add-Member -MemberType NoteProperty -Name "AppInfo" -Value @{}
    }
    $appsettings.AppInfo = @{
        Version = $Version
        Environment = $Environment
        DeployTime = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    }
    
    $appsettings | ConvertTo-Json -Depth 10 | Set-Content $appsettingsPath -Encoding UTF8
    Write-Host "  配置文件更新完成" -ForegroundColor Gray
}

# 步骤 4: 停止 IIS 站点
if (-not $SkipIIS) {
    Write-Host "[4/7] 停止 IIS 站点..." -ForegroundColor Green
    try {
        Import-Module WebAdministration -ErrorAction SilentlyContinue
        
        if (Test-Path "IIS:\Sites\$SiteName") {
            Stop-WebSite -Name $SiteName -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 3
            Write-Host "  站点已停止" -ForegroundColor Gray
        } else {
            Write-Host "  站点不存在，跳过停止步骤" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  警告: 无法停止站点" -ForegroundColor Yellow
    }
} else {
    Write-Host "[4/7] 跳过 IIS 操作" -ForegroundColor Yellow
}

# 步骤 5: 备份现有部署
if (-not $SkipBackup -and (Test-Path $DeployPath)) {
    Write-Host "[5/7] 备份现有部署..." -ForegroundColor Green
    
    Copy-Item -Path $DeployPath -Destination $backupPath -Recurse -Force
    Write-Host "  备份完成: $backupPath" -ForegroundColor Gray
    
    # 清理旧备份（保留最近 5 个）
    $parentPath = Split-Path $DeployPath -Parent
    $backupPattern = "$(Split-Path $DeployPath -Leaf).backup.*"
    Get-ChildItem -Path $parentPath -Filter $backupPattern | 
        Sort-Object CreationTime -Descending | 
        Select-Object -Skip 5 | 
        Remove-Item -Recurse -Force
} else {
    Write-Host "[5/7] 跳过备份" -ForegroundColor Yellow
}

# 步骤 6: 部署文件
Write-Host "[6/7] 部署文件..." -ForegroundColor Green

if (!(Test-Path $DeployPath)) {
    New-Item -ItemType Directory -Path $DeployPath -Force | Out-Null
}

# 复制文件
Copy-Item -Path "$publishPath\*" -Destination $DeployPath -Recurse -Force
Write-Host "  文件部署完成" -ForegroundColor Gray

# 步骤 7: 启动 IIS 站点
if (-not $SkipIIS) {
    Write-Host "[7/7] 启动 IIS 站点..." -ForegroundColor Green
    try {
        if (Test-Path "IIS:\Sites\$SiteName") {
            Start-WebSite -Name $SiteName
            Start-Sleep -Seconds 2
            Write-Host "  站点已启动" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  警告: 无法启动站点" -ForegroundColor Yellow
    }
} else {
    Write-Host "[7/7] 跳过 IIS 操作" -ForegroundColor Yellow
}

# 生成部署报告
$reportPath = "$DeployPath\deploy_report_$timestamp.txt"
$report = @"
========================================
部署报告
========================================
部署时间: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
环境: $Environment
版本: $Version
部署路径: $DeployPath
备份路径: $backupPath
IIS 站点: $SiteName

部署文件清单:
$(Get-ChildItem $DeployPath -File | Select-Object -First 20 | Format-Table Name, Length, LastWriteTime | Out-String)

========================================
"@

Set-Content -Path $reportPath -Value $report -Encoding UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "部署完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "部署信息：" -ForegroundColor Yellow
Write-Host "  环境: $Environment" -ForegroundColor White
Write-Host "  版本: $Version" -ForegroundColor White
Write-Host "  路径: $DeployPath" -ForegroundColor White
Write-Host "  备份: $backupPath" -ForegroundColor White
Write-Host "  报告: $reportPath" -ForegroundColor White
Write-Host ""
Write-Host "下一步操作：" -ForegroundColor Yellow
Write-Host "1. 验证应用程序是否正常运行" -ForegroundColor White
Write-Host "2. 访问 Swagger: http://localhost:8008/swagger" -ForegroundColor White
Write-Host "3. 检查日志文件是否有错误" -ForegroundColor White
Write-Host "4. 运行冒烟测试" -ForegroundColor White
Write-Host ""

# 如果部署失败，提供回滚命令
if (Test-Path $backupPath) {
    Write-Host "如需回滚，运行以下命令：" -ForegroundColor Cyan
    Write-Host "  Copy-Item -Path '$backupPath\*' -Destination '$DeployPath' -Recurse -Force" -ForegroundColor Gray
    Write-Host ""
}
