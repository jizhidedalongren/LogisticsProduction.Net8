# ============================================
# 解密配置文件脚本
# ============================================
# 用途：解密加密的配置文件
# 使用：直接运行
# ============================================

# 设置控制台编码为 UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

param(
    [Parameter(Mandatory=$false)]
    [string]$EncryptedFile = "appsettings.Production.encrypted",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "..\appsettings.Production.json"
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  配置文件解密工具" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 检查加密文件是否存在
if (-not (Test-Path $EncryptedFile)) {
    Write-Host "❌ 错误：找不到加密文件 $EncryptedFile" -ForegroundColor Red
    pause
    exit 1
}

# 提示输入解密密码
Write-Host "请输入解密密码：" -ForegroundColor Yellow
$password = Read-Host -AsSecureString

# 转换为明文
$pwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

# 使用 AES 解密
try {
    $key = [System.Text.Encoding]::UTF8.GetBytes($pwd.PadRight(32).Substring(0, 32))
    $encryptedData = [System.IO.File]::ReadAllBytes($EncryptedFile)
    
    # 提取 IV（前16字节）
    $iv = $encryptedData[0..15]
    $encryptedBytes = $encryptedData[16..($encryptedData.Length - 1)]
    
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $key
    $aes.IV = $iv
    
    $decryptor = $aes.CreateDecryptor()
    $decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
    $content = [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
    
    # 保存解密内容
    $utf8Bom = New-Object System.Text.UTF8Encoding $true
    [System.IO.File]::WriteAllText($OutputFile, $content, $utf8Bom)
    
    Write-Host ""
    Write-Host "✅ 解密成功！" -ForegroundColor Green
    Write-Host "输出文件：$OutputFile" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💡 提示：" -ForegroundColor Yellow
    Write-Host "  - 配置文件已恢复" -ForegroundColor Gray
    Write-Host "  - 请勿将此文件提交到 Git" -ForegroundColor Gray
}
catch {
    Write-Host ""
    Write-Host "❌ 解密失败：密码错误或文件损坏" -ForegroundColor Red
    Write-Host "错误详情：$_" -ForegroundColor Gray
}
finally {
    if ($aes) { $aes.Dispose() }
}

Write-Host ""
pause
