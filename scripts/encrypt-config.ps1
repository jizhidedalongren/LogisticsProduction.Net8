# ============================================
# 加密配置文件脚本
# ============================================
# 用途：将敏感配置文件加密保存
# 使用：以管理员身份运行
# ============================================

# 设置控制台编码为 UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

param(
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "..\appsettings.Production.json",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "appsettings.Production.encrypted"
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  配置文件加密工具" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 检查源文件是否存在
if (-not (Test-Path $ConfigFile)) {
    Write-Host "❌ 错误：找不到配置文件 $ConfigFile" -ForegroundColor Red
    pause
    exit 1
}

# 读取配置文件内容
$content = Get-Content -Path $ConfigFile -Raw

# 提示输入加密密码
Write-Host "请输入加密密码（用于解密时验证）：" -ForegroundColor Yellow
$password = Read-Host -AsSecureString

Write-Host "请再次输入密码确认：" -ForegroundColor Yellow
$passwordConfirm = Read-Host -AsSecureString

# 转换为明文比较
$pwd1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
$pwd2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwordConfirm))

if ($pwd1 -ne $pwd2) {
    Write-Host "❌ 两次输入的密码不一致" -ForegroundColor Red
    pause
    exit 1
}

# 使用 AES 加密
try {
    $key = [System.Text.Encoding]::UTF8.GetBytes($pwd1.PadRight(32).Substring(0, 32))
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $key
    $aes.GenerateIV()
    
    $encryptor = $aes.CreateEncryptor()
    $contentBytes = [System.Text.Encoding]::UTF8.GetBytes($content)
    $encryptedBytes = $encryptor.TransformFinalBlock($contentBytes, 0, $contentBytes.Length)
    
    # 保存 IV 和加密内容
    $result = $aes.IV + $encryptedBytes
    [System.IO.File]::WriteAllBytes($OutputFile, $result)
    
    Write-Host ""
    Write-Host "✅ 加密成功！" -ForegroundColor Green
    Write-Host "加密文件：$OutputFile" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💡 提示：" -ForegroundColor Yellow
    Write-Host "  - 请将加密文件保存到安全位置（如网盘、USB）" -ForegroundColor Gray
    Write-Host "  - 请妥善保管加密密码" -ForegroundColor Gray
    Write-Host "  - 使用 decrypt-config.ps1 解密" -ForegroundColor Gray
}
catch {
    Write-Host "❌ 加密失败：$_" -ForegroundColor Red
}
finally {
    if ($aes) { $aes.Dispose() }
}

Write-Host ""
pause
