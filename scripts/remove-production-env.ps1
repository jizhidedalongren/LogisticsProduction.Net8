# ============================================
# 删除生产环境变量脚本
# ============================================
# 用途：删除系统中的数据库连接环境变量
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
Write-Host "  删除生产环境变量" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$envVars = @(
    "ConnectionStrings__91Db",
    "ConnectionStrings__MainDb",
    "ASPNETCORE_ENVIRONMENT",
    "ExternalServices__PrintServiceUrl",
    "ExternalServices__AgvServiceUrl",
    "ExternalServices__WmsServiceUrl"
)

Write-Host "⚠️  警告：将要删除以下环境变量：" -ForegroundColor Yellow
Write-Host ""

foreach ($varName in $envVars) {
    $value = [System.Environment]::GetEnvironmentVariable($varName, [System.EnvironmentVariableTarget]::Machine)
    if ($value) {
        Write-Host "  - $varName" -ForegroundColor Red
    }
}

Write-Host ""
$confirm = Read-Host "确认删除这些环境变量吗？(Y/N)"

if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "❌ 操作已取消" -ForegroundColor Yellow
    pause
    exit 0
}

Write-Host ""
Write-Host "⏳ 正在删除环境变量..." -ForegroundColor Cyan

$successCount = 0

foreach ($varName in $envVars) {
    try {
        [System.Environment]::SetEnvironmentVariable(
            $varName,
            $null,
            [System.EnvironmentVariableTarget]::Machine
        )
        Write-Host "✅ 已删除: $varName" -ForegroundColor Green
        $successCount++
    }
    catch {
        Write-Host "❌ 删除失败: $varName - $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "✅ 删除完成！共删除 $successCount 个环境变量" -ForegroundColor Green
Write-Host ""

pause
