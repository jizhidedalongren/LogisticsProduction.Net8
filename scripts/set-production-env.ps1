# ============================================
# 生产环境变量配置脚本
# ============================================
# 用途：自动设置数据库连接字符串到系统环境变量
# 使用：以管理员身份运行 PowerShell，执行此脚本
# ============================================

# 设置控制台编码为 UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ 错误：此脚本需要管理员权限" -ForegroundColor Red
    Write-Host "请右键点击 PowerShell，选择'以管理员身份运行'，然后重新执行此脚本" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  生产环境数据库配置脚本" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# 配置区域 - 请修改为实际的生产环境配置
# ============================================

$config = @{
    "ConnectionStrings__91Db" = "Data Source=192.168.2.91;Initial Catalog=cwbase0006;User ID=LC00069999;Password=aaaaaa;Encrypt=True;TrustServerCertificate=True;"
    "ConnectionStrings__MainDb" = "Data Source=生产服务器;Initial Catalog=LogisticsProduction_DB;User ID=生产用户;Password=生产密码;Encrypt=True;TrustServerCertificate=True;"
    "ASPNETCORE_ENVIRONMENT" = "Production"
}

# ============================================
# 可选：外部服务配置
# ============================================
# 如果需要覆盖 appsettings.json 中的外部服务配置，取消下面的注释
# $config["ExternalServices__PrintServiceUrl"] = "http://10.101.16.30:30123"
# $config["ExternalServices__AgvServiceUrl"] = "http://生产AGV服务器:8080"
# $config["ExternalServices__WmsServiceUrl"] = "http://生产WMS服务器:8081"

# ============================================
# 执行配置
# ============================================

Write-Host "📋 将要设置以下环境变量：" -ForegroundColor Yellow
Write-Host ""

foreach ($key in $config.Keys) {
    # 隐藏密码显示
    $displayValue = $config[$key]
    if ($displayValue -match "Password=([^;]+)") {
        $displayValue = $displayValue -replace "Password=([^;]+)", "Password=****"
    }
    Write-Host "  $key" -ForegroundColor Green
    Write-Host "    = $displayValue" -ForegroundColor Gray
}

Write-Host ""
$confirm = Read-Host "确认设置这些环境变量吗？(Y/N)"

if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "❌ 操作已取消" -ForegroundColor Yellow
    pause
    exit 0
}

Write-Host ""
Write-Host "⏳ 正在设置环境变量..." -ForegroundColor Cyan

$successCount = 0
$failCount = 0

foreach ($key in $config.Keys) {
    try {
        [System.Environment]::SetEnvironmentVariable(
            $key,
            $config[$key],
            [System.EnvironmentVariableTarget]::Machine
        )
        Write-Host "✅ $key" -ForegroundColor Green
        $successCount++
    }
    catch {
        Write-Host "❌ $key - 失败: $_" -ForegroundColor Red
        $failCount++
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  配置完成" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "成功: $successCount 个" -ForegroundColor Green
Write-Host "失败: $failCount 个" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Gray" })
Write-Host ""

# ============================================
# 重启 IIS（如果需要）
# ============================================

Write-Host "请选择重启方式：" -ForegroundColor Yellow
Write-Host "  1. 重启应用程序池（推荐，更快）" -ForegroundColor Gray
Write-Host "  2. 完全重启 IIS（较慢，影响所有网站）" -ForegroundColor Gray
Write-Host "  3. 跳过重启（稍后手动重启）" -ForegroundColor Gray
Write-Host ""
$restartChoice = Read-Host "请输入选项 (1/2/3)"

if ($restartChoice -eq '1') {
    Write-Host ""
    Write-Host "📋 可用的应用程序池：" -ForegroundColor Cyan
    
    try {
        Import-Module WebAdministration -ErrorAction Stop
        $appPools = Get-ChildItem IIS:\AppPools | Select-Object -ExpandProperty Name
        
        for ($i = 0; $i -lt $appPools.Count; $i++) {
            Write-Host "  $($i + 1). $($appPools[$i])" -ForegroundColor Gray
        }
        
        Write-Host ""
        $poolChoice = Read-Host "请输入应用程序池编号（或输入名称）"
        
        # 判断是数字还是名称
        $poolName = $null
        if ($poolChoice -match '^\d+$') {
            $index = [int]$poolChoice - 1
            if ($index -ge 0 -and $index -lt $appPools.Count) {
                $poolName = $appPools[$index]
            }
        }
        else {
            $poolName = $poolChoice
        }
        
        if ($poolName) {
            Write-Host ""
            Write-Host "⏳ 正在重启应用程序池: $poolName" -ForegroundColor Cyan
            
            # 停止应用程序池
            Stop-WebAppPool -Name $poolName -ErrorAction Stop
            Write-Host "  ⏸️  已停止应用程序池" -ForegroundColor Yellow
            
            # 等待停止完成
            Start-Sleep -Seconds 2
            
            # 启动应用程序池
            Start-WebAppPool -Name $poolName -ErrorAction Stop
            Write-Host "  ▶️  已启动应用程序池" -ForegroundColor Green
            
            # 等待启动完成
            Start-Sleep -Seconds 3
            
            # 验证状态
            $pool = Get-WebAppPoolState -Name $poolName
            if ($pool.Value -eq 'Started') {
                Write-Host ""
                Write-Host "✅ 应用程序池重启成功！" -ForegroundColor Green
            }
            else {
                Write-Host ""
                Write-Host "⚠️  应用程序池状态: $($pool.Value)" -ForegroundColor Yellow
                Write-Host "请检查 IIS 管理器确认状态" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "❌ 无效的应用程序池选择" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "❌ 重启应用程序池失败: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "💡 手动重启方法：" -ForegroundColor Yellow
        Write-Host "  1. 打开 IIS 管理器" -ForegroundColor Gray
        Write-Host "  2. 找到应用程序池" -ForegroundColor Gray
        Write-Host "  3. 右键 → 回收" -ForegroundColor Gray
    }
}
elseif ($restartChoice -eq '2') {
    Write-Host ""
    Write-Host "⏳ 正在完全重启 IIS..." -ForegroundColor Cyan
    Write-Host "⚠️  这将影响服务器上的所有网站" -ForegroundColor Yellow
    Write-Host ""
    
    $confirm = Read-Host "确认要完全重启 IIS 吗？(Y/N)"
    
    if ($confirm -eq 'Y' -or $confirm -eq 'y') {
        try {
            # 停止 IIS
            Write-Host "  ⏸️  正在停止 IIS..." -ForegroundColor Yellow
            iisreset /stop
            Start-Sleep -Seconds 3
            
            # 启动 IIS
            Write-Host "  ▶️  正在启动 IIS..." -ForegroundColor Yellow
            iisreset /start
            Start-Sleep -Seconds 5
            
            Write-Host ""
            Write-Host "✅ IIS 重启成功！" -ForegroundColor Green
        }
        catch {
            Write-Host ""
            Write-Host "❌ IIS 重启失败: $_" -ForegroundColor Red
            Write-Host "请手动执行: iisreset" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "❌ 已取消 IIS 重启" -ForegroundColor Yellow
    }
}
else {
    Write-Host ""
    Write-Host "⏭️  跳过重启" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 稍后手动重启方法：" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "方法 1 - 重启应用程序池（推荐）：" -ForegroundColor Cyan
    Write-Host "  Restart-WebAppPool -Name '你的应用程序池名称'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "方法 2 - 完全重启 IIS：" -ForegroundColor Cyan
    Write-Host "  iisreset" -ForegroundColor Gray
    Write-Host ""
}

Write-Host ""
Write-Host "✅ 所有操作完成！" -ForegroundColor Green
Write-Host ""
Write-Host "💡 提示：" -ForegroundColor Yellow
Write-Host "  - 环境变量已设置到系统级别" -ForegroundColor Gray
Write-Host "  - 新启动的进程会自动读取这些变量" -ForegroundColor Gray
Write-Host "  - 如果应用已在运行，需要重启应用或 IIS" -ForegroundColor Gray
Write-Host ""

pause
