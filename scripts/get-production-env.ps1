# ============================================
# 查看生产环境变量脚本
# ============================================
# 用途：查看当前系统中已设置的数据库连接环境变量
# 使用：直接运行（不需要管理员权限）
# ============================================

# 设置控制台编码为 UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  当前生产环境变量" -ForegroundColor Cyan
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

$foundCount = 0

foreach ($varName in $envVars) {
    $value = [System.Environment]::GetEnvironmentVariable($varName, [System.EnvironmentVariableTarget]::Machine)
    
    if ($value) {
        $foundCount++
        Write-Host "✅ $varName" -ForegroundColor Green
        
        # 隐藏密码
        $displayValue = $value
        if ($displayValue -match "Password=([^;]+)") {
            $displayValue = $displayValue -replace "Password=([^;]+)", "Password=****"
        }
        
        Write-Host "   $displayValue" -ForegroundColor Gray
        Write-Host ""
    }
    else {
        Write-Host "❌ $varName" -ForegroundColor Yellow
        Write-Host "   (未设置)" -ForegroundColor Gray
        Write-Host ""
    }
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "找到 $foundCount 个已配置的环境变量" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

pause
