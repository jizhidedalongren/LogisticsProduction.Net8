# 修复 PowerShell 脚本编码为 UTF-8 BOM
# 确保中文字符正确显示

$files = @(
    "scaffold-cn.ps1",
    "deploy.ps1",
    "deploy-to-iis.ps1"
)

$scriptRoot = $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PowerShell 脚本编码修复工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$utf8Bom = New-Object System.Text.UTF8Encoding $true
$successCount = 0
$failCount = 0

foreach ($file in $files) {
    $filePath = Join-Path $scriptRoot $file
    if (Test-Path $filePath) {
        try {
            # 读取文件内容
            $content = Get-Content -Path $filePath -Raw -Encoding UTF8
            
            # 使用 UTF-8 BOM 编码写入
            [System.IO.File]::WriteAllText($filePath, $content, $utf8Bom)
            
            Write-Host "  ✓ 已转换: $file" -ForegroundColor Green
            $successCount++
        }
        catch {
            Write-Host "  ✗ 转换失败: $file - $($_.Exception.Message)" -ForegroundColor Red
            $failCount++
        }
    }
    else {
        Write-Host "  ⚠ 文件不存在: $file" -ForegroundColor Yellow
        $failCount++
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "转换完成: 成功 $successCount 个，失败 $failCount 个" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "所有包含中文的 PowerShell 脚本已转换为 UTF-8 BOM 编码" -ForegroundColor White
Write-Host "现在可以正常显示中文字符了" -ForegroundColor White
