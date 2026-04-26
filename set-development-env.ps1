# ============================================
# 开发环境配置脚本
# ============================================
# 用途：自动配置开发环境（User Secrets）
# 使用：在项目根目录执行（不需要管理员权限）
# ============================================

# 设置控制台编码为 UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  开发环境配置向导" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 检查是否在项目根目录
if (-not (Test-Path "LogisticsProduction.Net8.csproj")) {
    Write-Host "❌ 错误：请在项目根目录执行此脚本" -ForegroundColor Red
    Write-Host "当前目录：$PWD" -ForegroundColor Gray
    Write-Host ""
    Write-Host "正确的执行方式：" -ForegroundColor Yellow
    Write-Host "  cd 项目根目录" -ForegroundColor Gray
    Write-Host "  .\scripts\set-development-env.ps1" -ForegroundColor Gray
    Write-Host ""
    pause
    exit 1
}

# 检查 .NET SDK
Write-Host "🔍 检查 .NET SDK..." -ForegroundColor Cyan
try {
    $dotnetVersion = dotnet --version 2>&1
    Write-Host "  ✅ .NET SDK 版本: $dotnetVersion" -ForegroundColor Green
}
catch {
    Write-Host "  ❌ 未找到 .NET SDK" -ForegroundColor Red
    Write-Host "  请先安装 .NET 8.0 SDK: https://dotnet.microsoft.com/download" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  配置方式选择" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "请选择配置方式：" -ForegroundColor Yellow
Write-Host "  1. User Secrets（推荐，不会提交到 Git）" -ForegroundColor Gray
Write-Host "  2. appsettings.Development.json（团队共享配置）" -ForegroundColor Gray
Write-Host "  3. 两者都配置" -ForegroundColor Gray
Write-Host ""
$configChoice = Read-Host "请输入选项 (1/2/3)"

# ============================================
# 配置数据收集
# ============================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  数据库连接配置" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 91Db 配置
Write-Host "📋 91Db 数据库配置：" -ForegroundColor Yellow
Write-Host ""

$use91DbIntegratedSecurity = Read-Host "  使用 Windows 集成身份验证？(Y/N) [默认: N]"
if ([string]::IsNullOrWhiteSpace($use91DbIntegratedSecurity)) { $use91DbIntegratedSecurity = "N" }

$db91Server = Read-Host "  数据库服务器 [默认: 192.168.2.91]"
if ([string]::IsNullOrWhiteSpace($db91Server)) { $db91Server = "192.168.2.91" }

$db91Database = Read-Host "  数据库名称 [默认: cwbase0006]"
if ([string]::IsNullOrWhiteSpace($db91Database)) { $db91Database = "cwbase0006" }

if ($use91DbIntegratedSecurity -eq 'Y' -or $use91DbIntegratedSecurity -eq 'y') {
    $db91ConnectionString = "Data Source=$db91Server;Initial Catalog=$db91Database;Integrated Security=True;TrustServerCertificate=True"
}
else {
    $db91User = Read-Host "  用户名 [默认: LC00069999]"
    if ([string]::IsNullOrWhiteSpace($db91User)) { $db91User = "LC00069999" }

    Write-Host "  密码: " -NoNewline -ForegroundColor Gray
    $db91Password = Read-Host -AsSecureString
    $db91PasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($db91Password))

    if ([string]::IsNullOrWhiteSpace($db91PasswordPlain)) {
        Write-Host ""
        Write-Host "⚠️  警告：密码为空，将使用默认密码 'aaaaaa'" -ForegroundColor Yellow
        $db91PasswordPlain = "aaaaaa"
    }

    $db91ConnectionString = "Data Source=$db91Server;Initial Catalog=$db91Database;User ID=$db91User;Password=$db91PasswordPlain;Encrypt=True;TrustServerCertificate=True;"
}

Write-Host ""
Write-Host "📋 MainDb 数据库配置：" -ForegroundColor Yellow
Write-Host ""

$useIntegratedSecurity = Read-Host "  使用 Windows 集成身份验证？(Y/N) [默认: Y]"
if ([string]::IsNullOrWhiteSpace($useIntegratedSecurity)) { $useIntegratedSecurity = "Y" }

if ($useIntegratedSecurity -eq 'Y' -or $useIntegratedSecurity -eq 'y') {
    $mainDbServer = Read-Host "  数据库服务器 [默认: .]"
    if ([string]::IsNullOrWhiteSpace($mainDbServer)) { $mainDbServer = "." }
    
    $mainDbDatabase = Read-Host "  数据库名称 [默认: LogisticsProduction_DB]"
    if ([string]::IsNullOrWhiteSpace($mainDbDatabase)) { $mainDbDatabase = "LogisticsProduction_DB" }
    
    $mainDbConnectionString = "Data Source=$mainDbServer;Initial Catalog=$mainDbDatabase;Integrated Security=True;TrustServerCertificate=True"
}
else {
    $mainDbServer = Read-Host "  数据库服务器"
    $mainDbDatabase = Read-Host "  数据库名称"
    $mainDbUser = Read-Host "  用户名"
    Write-Host "  密码: " -NoNewline -ForegroundColor Gray
    $mainDbPassword = Read-Host -AsSecureString
    $mainDbPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($mainDbPassword))
    
    $mainDbConnectionString = "Data Source=$mainDbServer;Initial Catalog=$mainDbDatabase;User ID=$mainDbUser;Password=$mainDbPasswordPlain;Encrypt=True;TrustServerCertificate=True;"
}

# ============================================
# 外部服务配置（可选）
# ============================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  外部服务配置（可选）" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$configExternalServices = Read-Host "是否配置外部服务 URL？(Y/N) [默认: N]"

$printServiceUrl = ""
$agvServiceUrl = ""
$wmsServiceUrl = ""

if ($configExternalServices -eq 'Y' -or $configExternalServices -eq 'y') {
    Write-Host ""
    $printServiceUrl = Read-Host "  打印服务 URL [默认: http://10.101.16.30:30123]"
    if ([string]::IsNullOrWhiteSpace($printServiceUrl)) { $printServiceUrl = "http://10.101.16.30:30123" }
    
    $agvServiceUrl = Read-Host "  AGV 服务 URL [默认: http://localhost:8080]"
    if ([string]::IsNullOrWhiteSpace($agvServiceUrl)) { $agvServiceUrl = "http://localhost:8080" }
    
    $wmsServiceUrl = Read-Host "  WMS 服务 URL [默认: http://localhost:8081]"
    if ([string]::IsNullOrWhiteSpace($wmsServiceUrl)) { $wmsServiceUrl = "http://localhost:8081" }
}

# ============================================
# 显示配置摘要
# ============================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  配置摘要" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "91Db 连接：" -ForegroundColor Yellow
Write-Host "  服务器: $db91Server" -ForegroundColor Gray
Write-Host "  数据库: $db91Database" -ForegroundColor Gray
if ($use91DbIntegratedSecurity -eq 'Y' -or $use91DbIntegratedSecurity -eq 'y') {
    Write-Host "  认证: Windows 集成身份验证" -ForegroundColor Gray
}
else {
    Write-Host "  用户名: $db91User" -ForegroundColor Gray
    Write-Host "  密码: ****" -ForegroundColor Gray
}
Write-Host ""

Write-Host "MainDb 连接：" -ForegroundColor Yellow
if ($useIntegratedSecurity -eq 'Y' -or $useIntegratedSecurity -eq 'y') {
    Write-Host "  服务器: $mainDbServer" -ForegroundColor Gray
    Write-Host "  数据库: $mainDbDatabase" -ForegroundColor Gray
    Write-Host "  认证: Windows 集成身份验证" -ForegroundColor Gray
}
else {
    Write-Host "  服务器: $mainDbServer" -ForegroundColor Gray
    Write-Host "  数据库: $mainDbDatabase" -ForegroundColor Gray
    Write-Host "  用户名: $mainDbUser" -ForegroundColor Gray
    Write-Host "  密码: ****" -ForegroundColor Gray
}

if ($configExternalServices -eq 'Y' -or $configExternalServices -eq 'y') {
    Write-Host ""
    Write-Host "外部服务：" -ForegroundColor Yellow
    Write-Host "  打印服务: $printServiceUrl" -ForegroundColor Gray
    Write-Host "  AGV 服务: $agvServiceUrl" -ForegroundColor Gray
    Write-Host "  WMS 服务: $wmsServiceUrl" -ForegroundColor Gray
}

Write-Host ""
$confirm = Read-Host "确认配置信息正确吗？(Y/N)"

if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "❌ 配置已取消" -ForegroundColor Yellow
    pause
    exit 0
}

# ============================================
# 执行配置
# ============================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  开始配置" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$successCount = 0
$failCount = 0

# ============================================
# 方式 1: User Secrets
# ============================================

if ($configChoice -eq '1' -or $configChoice -eq '3') {
    Write-Host "📦 配置 User Secrets..." -ForegroundColor Cyan
    Write-Host ""
    
    try {
        # 初始化 User Secrets（如果尚未初始化）
        Write-Host "  初始化 User Secrets..." -ForegroundColor Gray
        $initResult = dotnet user-secrets init 2>&1
        
        if ($LASTEXITCODE -eq 0 -or $initResult -match "already") {
            Write-Host "  ✅ User Secrets 已初始化" -ForegroundColor Green
        }
        
        # 设置连接字符串
        Write-Host "  设置 91Db 连接字符串..." -ForegroundColor Gray
        dotnet user-secrets set "ConnectionStrings:91Db" $db91ConnectionString | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ 91Db 连接字符串已设置" -ForegroundColor Green
            $successCount++
        }
        else {
            Write-Host "  ❌ 91Db 连接字符串设置失败" -ForegroundColor Red
            $failCount++
        }
        
        Write-Host "  设置 MainDb 连接字符串..." -ForegroundColor Gray
        dotnet user-secrets set "ConnectionStrings:MainDb" $mainDbConnectionString | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ MainDb 连接字符串已设置" -ForegroundColor Green
            $successCount++
        }
        else {
            Write-Host "  ❌ MainDb 连接字符串设置失败" -ForegroundColor Red
            $failCount++
        }
        
        # 设置外部服务（如果配置了）
        if ($configExternalServices -eq 'Y' -or $configExternalServices -eq 'y') {
            Write-Host "  设置外部服务 URL..." -ForegroundColor Gray
            
            dotnet user-secrets set "ExternalServices:PrintServiceUrl" $printServiceUrl | Out-Null
            dotnet user-secrets set "ExternalServices:AgvServiceUrl" $agvServiceUrl | Out-Null
            dotnet user-secrets set "ExternalServices:WmsServiceUrl" $wmsServiceUrl | Out-Null
            
            Write-Host "  ✅ 外部服务 URL 已设置" -ForegroundColor Green
            $successCount++
        }
        
        Write-Host ""
        Write-Host "✅ User Secrets 配置完成" -ForegroundColor Green
    }
    catch {
        Write-Host "  ❌ User Secrets 配置失败: $_" -ForegroundColor Red
        $failCount++
    }
}

# ============================================
# 方式 2: appsettings.Development.json
# ============================================

if ($configChoice -eq '2' -or $configChoice -eq '3') {
    Write-Host ""
    Write-Host "📝 配置 appsettings.Development.json..." -ForegroundColor Cyan
    Write-Host ""
    
    try {
        $devConfig = @{
            ConnectionStrings = @{
                "91Db" = $db91ConnectionString
                MainDb = $mainDbConnectionString
            }
            Logging = @{
                LogLevel = @{
                    Default = "Debug"
                    "Microsoft.AspNetCore" = "Information"
                }
            }
        }
        
        if ($configExternalServices -eq 'Y' -or $configExternalServices -eq 'y') {
            $devConfig.ExternalServices = @{
                PrintServiceUrl = $printServiceUrl
                AgvServiceUrl = $agvServiceUrl
                WmsServiceUrl = $wmsServiceUrl
            }
        }
        
        $jsonContent = $devConfig | ConvertTo-Json -Depth 10
        
        # 使用 UTF-8 with BOM
        $utf8Bom = New-Object System.Text.UTF8Encoding $true
        [System.IO.File]::WriteAllText("appsettings.Development.json", $jsonContent, $utf8Bom)
        
        Write-Host "  ✅ appsettings.Development.json 已更新" -ForegroundColor Green
        $successCount++
        
        Write-Host ""
        Write-Host "  ⚠️  注意：此文件会被提交到 Git" -ForegroundColor Yellow
        Write-Host "  请确保不包含真实的生产密码" -ForegroundColor Yellow
    }
    catch {
        Write-Host "  ❌ appsettings.Development.json 配置失败: $_" -ForegroundColor Red
        $failCount++
    }
}

# ============================================
# 验证配置
# ============================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  验证配置" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

if ($configChoice -eq '1' -or $configChoice -eq '3') {
    Write-Host "📋 User Secrets 内容：" -ForegroundColor Cyan
    Write-Host ""
    
    $secrets = dotnet user-secrets list 2>&1
    
    if ($secrets -match "ConnectionStrings") {
        # 隐藏密码
        $secrets -split "`n" | ForEach-Object {
            if ($_ -match "Password=([^;]+)") {
                $_ = $_ -replace "Password=([^;]+)", "Password=****"
            }
            Write-Host "  $_" -ForegroundColor Gray
        }
    }
    else {
        Write-Host "  ⚠️  未找到配置或配置为空" -ForegroundColor Yellow
    }
}

# ============================================
# 完成
# ============================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  配置完成" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "成功: $successCount 项" -ForegroundColor Green
Write-Host "失败: $failCount 项" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Gray" })
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "✅ 开发环境配置成功！" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 下一步：" -ForegroundColor Yellow
    Write-Host "  1. 运行项目：dotnet run" -ForegroundColor Gray
    Write-Host "  2. 或在 Visual Studio 中按 F5" -ForegroundColor Gray
    Write-Host "  3. 访问：https://localhost:5001" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💡 提示：" -ForegroundColor Yellow
    Write-Host "  - User Secrets 不会被提交到 Git" -ForegroundColor Gray
    Write-Host "  - 配置存储在：%APPDATA%\Microsoft\UserSecrets\" -ForegroundColor Gray
    Write-Host "  - 查看配置：dotnet user-secrets list" -ForegroundColor Gray
}
else {
    Write-Host "⚠️  部分配置失败，请检查错误信息" -ForegroundColor Yellow
}

Write-Host ""
pause
