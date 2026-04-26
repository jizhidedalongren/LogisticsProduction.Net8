# ============================================
# 备份所有敏感配置脚本
# ============================================
# 用途：一键备份所有敏感配置文件
# 使用：直接运行（不需要管理员权限）
# ============================================

# 设置控制台编码为 UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  配置文件备份工具" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 创建备份目录
$date = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = "config-backup-$date"

Write-Host "📁 创建备份目录：$backupDir" -ForegroundColor Cyan
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

# 需要备份的文件列表
$filesToBackup = @(
    @{Path = "..\appsettings.Production.json"; Name = "appsettings.Production.json"},
    @{Path = "..\web.config"; Name = "web.config"},
    @{Path = "set-production-env.ps1"; Name = "set-production-env.ps1"}
)

Write-Host ""
Write-Host "🔐 开始加密备份..." -ForegroundColor Cyan
Write-Host ""

$successCount = 0
$skipCount = 0

foreach ($file in $filesToBackup) {
    if (Test-Path $file.Path) {
        Write-Host "  处理：$($file.Name)" -ForegroundColor Gray
        
        try {
            # 调用加密脚本
            $outputFile = Join-Path $backupDir "$($file.Name).encrypted"
            
            # 读取文件内容
            $content = Get-Content -Path $file.Path -Raw
            
            # 提示输入密码（仅第一次）
            if ($successCount -eq 0) {
                Write-Host ""
                Write-Host "请输入加密密码（用于所有文件）：" -ForegroundColor Yellow
                $script:password = Read-Host -AsSecureString
                $script:pwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($script:password))
            }
            
            # 加密
            $key = [System.Text.Encoding]::UTF8.GetBytes($script:pwd.PadRight(32).Substring(0, 32))
            $aes = [System.Security.Cryptography.Aes]::Create()
            $aes.Key = $key
            $aes.GenerateIV()
            
            $encryptor = $aes.CreateEncryptor()
            $contentBytes = [System.Text.Encoding]::UTF8.GetBytes($content)
            $encryptedBytes = $encryptor.TransformFinalBlock($contentBytes, 0, $contentBytes.Length)
            
            $result = $aes.IV + $encryptedBytes
            [System.IO.File]::WriteAllBytes($outputFile, $result)
            
            $aes.Dispose()
            
            Write-Host "  ✅ $($file.Name)" -ForegroundColor Green
            $successCount++
        }
        catch {
            Write-Host "  ❌ $($file.Name) - 失败: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "  ⏭️  $($file.Name) - 文件不存在，跳过" -ForegroundColor Yellow
        $skipCount++
    }
}

# 备份 User Secrets
Write-Host ""
Write-Host "📦 导出 User Secrets..." -ForegroundColor Cyan

try {
    $userSecretsFile = Join-Path $backupDir "user-secrets.txt"
    dotnet user-secrets list > $userSecretsFile 2>&1
    
    if (Test-Path $userSecretsFile) {
        $content = Get-Content -Path $userSecretsFile -Raw
        
        if ($content -match "ConnectionStrings" -or $content -match "No secrets configured") {
            # 加密 User Secrets
            $key = [System.Text.Encoding]::UTF8.GetBytes($script:pwd.PadRight(32).Substring(0, 32))
            $aes = [System.Security.Cryptography.Aes]::Create()
            $aes.Key = $key
            $aes.GenerateIV()
            
            $encryptor = $aes.CreateEncryptor()
            $contentBytes = [System.Text.Encoding]::UTF8.GetBytes($content)
            $encryptedBytes = $encryptor.TransformFinalBlock($contentBytes, 0, $contentBytes.Length)
            
            $result = $aes.IV + $encryptedBytes
            $outputFile = Join-Path $backupDir "user-secrets.encrypted"
            [System.IO.File]::WriteAllBytes($outputFile, $result)
            
            $aes.Dispose()
            
            # 删除明文文件
            Remove-Item $userSecretsFile -Force
            
            Write-Host "  ✅ User Secrets" -ForegroundColor Green
            $successCount++
        }
        else {
            Write-Host "  ⏭️  User Secrets - 未配置或无法读取" -ForegroundColor Yellow
            Remove-Item $userSecretsFile -Force
            $skipCount++
        }
    }
}
catch {
    Write-Host "  ❌ User Secrets - 失败: $_" -ForegroundColor Red
}

# 创建备份清单
$manifestFile = Join-Path $backupDir "BACKUP_MANIFEST.txt"
$manifest = @"
配置文件备份清单
================

备份时间: $date
备份文件数: $successCount
跳过文件数: $skipCount

加密文件列表:
"@

Get-ChildItem -Path $backupDir -Filter "*.encrypted" | ForEach-Object {
    $manifest += "`n  - $($_.Name)"
}

$manifest += @"


恢复说明:
=========

1. 使用 decrypt-config.ps1 解密文件
2. 将解密后的文件复制到对应位置
3. 重启应用程序

示例:
  .\decrypt-config.ps1 -EncryptedFile "$backupDir\appsettings.Production.json.encrypted" -OutputFile "..\appsettings.Production.json"

注意:
  - 请妥善保管加密密码
  - 密码丢失将无法恢复配置
  - 建议将备份保存到多个安全位置
"@

$utf8Bom = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText($manifestFile, $manifest, $utf8Bom)

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  备份完成" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "备份目录：$backupDir" -ForegroundColor Green
Write-Host "成功：$successCount 个文件" -ForegroundColor Green
Write-Host "跳过：$skipCount 个文件" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 提示：" -ForegroundColor Yellow
Write-Host "  - 备份文件已加密" -ForegroundColor Gray
Write-Host "  - 请将备份目录保存到安全位置" -ForegroundColor Gray
Write-Host "  - 查看 BACKUP_MANIFEST.txt 了解详情" -ForegroundColor Gray
Write-Host ""

# 询问是否压缩备份
$compress = Read-Host "是否压缩备份目录？(Y/N)"

if ($compress -eq 'Y' -or $compress -eq 'y') {
    $zipFile = "$backupDir.zip"
    Write-Host ""
    Write-Host "📦 正在压缩..." -ForegroundColor Cyan
    
    try {
        Compress-Archive -Path $backupDir -DestinationPath $zipFile -Force
        Write-Host "✅ 压缩完成：$zipFile" -ForegroundColor Green
        
        $deleteDir = Read-Host "是否删除原备份目录？(Y/N)"
        if ($deleteDir -eq 'Y' -or $deleteDir -eq 'y') {
            Remove-Item $backupDir -Recurse -Force
            Write-Host "✅ 已删除原目录" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "❌ 压缩失败：$_" -ForegroundColor Red
    }
}

Write-Host ""
pause
