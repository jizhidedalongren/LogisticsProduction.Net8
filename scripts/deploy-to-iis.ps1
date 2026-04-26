# IIS 部署脚本 - 在服务器上运行
# 用法: .\scripts\deploy-to-iis.ps1 -FirstInstall  (首次安装)
#       .\scripts\deploy-to-iis.ps1                (更新部署)
#       .\scripts\deploy-to-iis.ps1 -HotUpdate     (热更新)

param(
    [string]$SiteName = "LogisticsProduction.API",
    [string]$AppPoolName = "LogisticsProductionNet8",
    [string]$DeployPath = "F:\IIS\LogisticsProductionNet8",
    [int]$Port = 8008,
    [switch]$FirstInstall = $false,
    [switch]$HotUpdate = $false
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "IIS 部署脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查管理员权限
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "错误：请以管理员身份运行！" -ForegroundColor Red
    exit 1
}

# 导入 IIS 模块
Import-Module WebAdministration -ErrorAction Stop

# 获取项目根目录
$projectRoot = Split-Path $PSScriptRoot -Parent

# 检查 IIS 站点是否存在
$siteExists = Test-Path "IIS:\Sites\$SiteName"
$poolExists = Test-Path "IIS:\AppPools\$AppPoolName"

if ($FirstInstall) {
    # ===== 首次安装 =====
    if ($siteExists) {
        Write-Host "错误：IIS 站点已存在！如需更新，请不要使用 -FirstInstall 参数" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "执行首次安装..." -ForegroundColor Yellow
    Write-Host ""
    
    # 1. 创建应用程序池
    Write-Host "[1/6] 创建应用程序池..." -ForegroundColor Green
    
    if (!$poolExists) {
        New-WebAppPool -Name $AppPoolName
        
        # 配置应用程序池
        Set-ItemProperty "IIS:\AppPools\$AppPoolName" -Name "managedRuntimeVersion" -Value ""
        Set-ItemProperty "IIS:\AppPools\$AppPoolName" -Name "startMode" -Value "AlwaysRunning"
        Set-ItemProperty "IIS:\AppPools\$AppPoolName" -Name "processModel.idleTimeout" -Value "00:00:00"
        Set-ItemProperty "IIS:\AppPools\$AppPoolName" -Name "recycling.periodicRestart.time" -Value "00:00:00"
        
        # 配置快速失败保护
        Set-ItemProperty "IIS:\AppPools\$AppPoolName" -Name "failure.rapidFailProtection" -Value $true
        Set-ItemProperty "IIS:\AppPools\$AppPoolName" -Name "failure.rapidFailProtectionMaxCrashes" -Value 5
        
        Write-Host "  ✓ 应用程序池创建完成" -ForegroundColor Gray
    } else {
        Write-Host "  应用程序池已存在" -ForegroundColor Gray
    }
    
    # 2. 创建部署目录
    Write-Host "[2/6] 创建部署目录..." -ForegroundColor Green
    if (!(Test-Path $DeployPath)) {
        New-Item -ItemType Directory -Path $DeployPath -Force | Out-Null
    }
    
    # 创建日志目录
    $logsPath = Join-Path $DeployPath "logs"
    if (!(Test-Path $logsPath)) {
        New-Item -ItemType Directory -Path $logsPath -Force | Out-Null
    }
    
    Write-Host "  ✓ 目录创建完成" -ForegroundColor Gray
    
    # 3. 设置目录权限
    Write-Host "[3/6] 设置目录权限..." -ForegroundColor Green
    
    icacls $DeployPath /grant "IIS AppPool\${AppPoolName}:(OI)(CI)RX" /T
    icacls $logsPath /grant "IIS AppPool\${AppPoolName}:(OI)(CI)M" /T
    
    Write-Host "  ✓ 权限设置完成" -ForegroundColor Gray
    
    # 4. 复制文件
    Write-Host "[4/6] 复制文件..." -ForegroundColor Green
    Copy-Item -Path "$projectRoot\*" -Destination $DeployPath -Recurse -Force -Exclude "*.ps1","*.md","VERSION.txt","部署说明.txt"
    Write-Host "  ✓ 文件复制完成" -ForegroundColor Gray
    
    # 5. 创建 IIS 网站
    Write-Host "[5/6] 创建 IIS 网站..." -ForegroundColor Green
    
    New-Website -Name $SiteName `
        -PhysicalPath $DeployPath `
        -ApplicationPool $AppPoolName `
        -Port $Port `
        -Force
    
    # 启用预加载
    Set-ItemProperty "IIS:\Sites\$SiteName" -Name "applicationDefaults.preloadEnabled" -Value $true
    
    Write-Host "  ✓ IIS 网站创建完成" -ForegroundColor Gray
    
    # 6. 启动网站
    Write-Host "[6/6] 启动网站..." -ForegroundColor Green
    Start-Website -Name $SiteName
    Start-Sleep -Seconds 3
    
    $site = Get-Website -Name $SiteName
    if ($site.State -eq "Started") {
        Write-Host "  ✓ 网站运行中" -ForegroundColor Green
    } else {
        Write-Host "  ✗ 网站状态: $($site.State)" -ForegroundColor Red
    }
    
} else {
    # ===== 更新部署 =====
    if (!$siteExists) {
        Write-Host "错误：IIS 站点不存在！首次安装请使用 -FirstInstall 参数" -ForegroundColor Red
        exit 1
    }
    
    if ($HotUpdate) {
        Write-Host "执行热更新（app_offline 方法）..." -ForegroundColor Yellow
    } else {
        Write-Host "执行标准更新..." -ForegroundColor Yellow
    }
    Write-Host ""
    
    if ($HotUpdate) {
        # ===== 热更新方案（app_offline.htm）=====
        Write-Host "[1/5] 启用维护模式..." -ForegroundColor Green
        
        # 创建 app_offline.htm（IIS 会自动停止应用）
        $appOfflineContent = @'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>系统维护中</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        h1 { color: #333; }
        p { color: #666; }
    </style>
</head>
<body>
    <h1>系统维护中</h1>
    <p>系统正在更新，预计 10 秒后恢复服务...</p>
    <p>System is updating, will be back in 10 seconds...</p>
</body>
</html>
'@
        $appOfflinePath = Join-Path $DeployPath "app_offline.htm"
        Set-Content -Path $appOfflinePath -Value $appOfflineContent -Encoding UTF8
        
        Write-Host "  ✓ 维护模式已启用" -ForegroundColor Gray
        Start-Sleep -Seconds 2
        
        # 备份
        Write-Host "[2/5] 备份现有文件..." -ForegroundColor Green
        $backupPath = "$DeployPath.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
        
        # 只备份关键文件
        $backupItems = @(
            "appsettings.Production.json",
            "web.config",
            "LogisticsProduction.Net8.dll",
            "LogisticsProduction.Net8.deps.json"
        )
        
        New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
        foreach ($item in $backupItems) {
            $sourcePath = Join-Path $DeployPath $item
            if (Test-Path $sourcePath) {
                Copy-Item -Path $sourcePath -Destination $backupPath -Force
            }
        }
        
        Write-Host "  ✓ 关键文件已备份" -ForegroundColor Gray
        
        # 复制新文件
        Write-Host "[3/5] 复制新文件..." -ForegroundColor Green
        Copy-Item -Path "$projectRoot\*" -Destination $DeployPath -Recurse -Force -Exclude "*.ps1","*.md","VERSION.txt","部署说明.txt","app_offline.htm"
        
        # 保留生产配置
        if (Test-Path "$backupPath\appsettings.Production.json") {
            Copy-Item -Path "$backupPath\appsettings.Production.json" -Destination "$DeployPath\appsettings.Production.json" -Force
        }
        
        Write-Host "  ✓ 文件复制完成" -ForegroundColor Gray
        
        # 等待文件系统同步
        Write-Host "[4/5] 等待文件系统同步..." -ForegroundColor Green
        Start-Sleep -Seconds 2
        
        # 删除 app_offline.htm（IIS 自动启动应用）
        Write-Host "[5/5] 恢复服务..." -ForegroundColor Green
        Remove-Item -Path $appOfflinePath -Force
        
        Write-Host "  ✓ 服务已恢复" -ForegroundColor Gray
        Start-Sleep -Seconds 3
        
    } else {
        # ===== 标准更新方案 =====
        Write-Host "[1/5] 停止网站..." -ForegroundColor Green
        Stop-Website -Name $SiteName
        Start-Sleep -Seconds 2
        Write-Host "  ✓ 网站已停止" -ForegroundColor Gray
        
        # 备份
        Write-Host "[2/5] 备份现有文件..." -ForegroundColor Green
        $backupPath = "$DeployPath.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item -Path $DeployPath -Destination $backupPath -Recurse -Force
        Write-Host "  ✓ 备份完成: $backupPath" -ForegroundColor Gray
        
        # 复制新文件
        Write-Host "[3/5] 复制新文件..." -ForegroundColor Green
        Copy-Item -Path "$projectRoot\*" -Destination $DeployPath -Recurse -Force -Exclude "*.ps1","*.md","VERSION.txt","部署说明.txt"
        
        # 保留生产配置
        if (Test-Path "$backupPath\appsettings.Production.json") {
            Copy-Item -Path "$backupPath\appsettings.Production.json" -Destination "$DeployPath\appsettings.Production.json" -Force
        }
        
        Write-Host "  ✓ 文件复制完成" -ForegroundColor Gray
        
        # 回收应用程序池
        Write-Host "[4/5] 回收应用程序池..." -ForegroundColor Green
        Restart-WebAppPool -Name $AppPoolName
        Start-Sleep -Seconds 2
        Write-Host "  ✓ 应用程序池已回收" -ForegroundColor Gray
        
        # 启动网站
        Write-Host "[5/5] 启动网站..." -ForegroundColor Green
        Start-Website -Name $SiteName
        Start-Sleep -Seconds 3
        
        $site = Get-Website -Name $SiteName
        if ($site.State -eq "Started") {
            Write-Host "  ✓ 网站运行中" -ForegroundColor Green
        } else {
            Write-Host "  ✗ 网站状态: $($site.State)" -ForegroundColor Red
        }
    }
    
    # 清理旧备份（保留最近 3 个）
    $parentPath = Split-Path $DeployPath -Parent
    $backupPattern = "$(Split-Path $DeployPath -Leaf).backup.*"
    Get-ChildItem -Path $parentPath -Filter $backupPattern -Directory | 
        Sort-Object CreationTime -Descending | 
        Select-Object -Skip 3 | 
        ForEach-Object {
            Write-Host "  清理旧备份: $($_.Name)" -ForegroundColor Gray
            Remove-Item -Path $_.FullName -Recurse -Force
        }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "部署完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "验证部署：" -ForegroundColor Yellow
Write-Host "  1. 网站状态: Get-Website -Name '$SiteName'" -ForegroundColor White
Write-Host "  2. 应用程序池: Get-WebAppPoolState -Name '$AppPoolName'" -ForegroundColor White
Write-Host "  3. 访问 Swagger: http://localhost:$Port/swagger" -ForegroundColor White
Write-Host "  4. 查看日志: $DeployPath\Logs" -ForegroundColor White
Write-Host ""

if (!$FirstInstall) {
    Write-Host "如需回滚，运行：" -ForegroundColor Cyan
    Write-Host "  .\rollback-iis.ps1" -ForegroundColor Gray
    Write-Host ""
}
