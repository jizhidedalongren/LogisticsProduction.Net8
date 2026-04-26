# ============================================
# 瀹屽叏閲嶅惎 IIS 鑴氭湰
# ============================================
# 鐢ㄩ€旓細瀹屽叏閲嶅惎 IIS 鏈嶅姟锛堝奖鍝嶆墍鏈夌綉绔欙級
# 浣跨敤锛氫互绠＄悊鍛樿韩浠借繍琛?
# ============================================

# 妫€鏌ョ鐞嗗憳鏉冮檺
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "鉂?閿欒锛氭鑴氭湰闇€瑕佺鐞嗗憳鏉冮檺" -ForegroundColor Red
    Write-Host "璇峰彸閿偣鍑?PowerShell锛岄€夋嫨'浠ョ鐞嗗憳韬唤杩愯'锛岀劧鍚庨噸鏂版墽琛屾鑴氭湰" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  IIS 瀹屽叏閲嶅惎宸ュ叿" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "鈿狅笍  璀﹀憡锛? -ForegroundColor Yellow
Write-Host "  - 杩欏皢閲嶅惎鏁翠釜 IIS 鏈嶅姟" -ForegroundColor Gray
Write-Host "  - 鏈嶅姟鍣ㄤ笂鐨勬墍鏈夌綉绔欏皢鏆傛椂涓嶅彲鐢? -ForegroundColor Gray
Write-Host "  - 棰勮鍋滄満鏃堕棿锛?0-30 绉? -ForegroundColor Gray
Write-Host ""

$confirm = Read-Host "纭瑕佸畬鍏ㄩ噸鍚?IIS 鍚楋紵(Y/N)"

if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "鉂?鎿嶄綔宸插彇娑? -ForegroundColor Yellow
    pause
    exit 0
}

Write-Host ""
Write-Host "鈴?姝ｅ湪閲嶅惎 IIS..." -ForegroundColor Cyan
Write-Host ""

try {
    # 璁板綍寮€濮嬫椂闂?
    $startTime = Get-Date
    
    # 鍋滄 IIS
    Write-Host "  鈴革笍  姝ｅ湪鍋滄 IIS..." -ForegroundColor Yellow
    $stopResult = iisreset /stop 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  鉁?IIS 宸插仠姝? -ForegroundColor Green
    }
    else {
        Write-Host "  鈿狅笍  鍋滄鏃跺嚭鐜拌鍛? -ForegroundColor Yellow
    }
    
    # 绛夊緟鍋滄瀹屾垚
    Write-Host "  鈴?绛夊緟鏈嶅姟瀹屽叏鍋滄..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    
    # 鍚姩 IIS
    Write-Host "  鈻讹笍  姝ｅ湪鍚姩 IIS..." -ForegroundColor Yellow
    $startResult = iisreset /start 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  鉁?IIS 宸插惎鍔? -ForegroundColor Green
    }
    else {
        Write-Host "  鈿狅笍  鍚姩鏃跺嚭鐜拌鍛? -ForegroundColor Yellow
    }
    
    # 绛夊緟鍚姩瀹屾垚
    Write-Host "  鈴?绛夊緟鏈嶅姟瀹屽叏鍚姩..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    # 楠岃瘉鏈嶅姟鐘舵€?
    Write-Host "  馃攳 楠岃瘉鏈嶅姟鐘舵€?.." -ForegroundColor Yellow
    
    $w3svc = Get-Service -Name W3SVC -ErrorAction SilentlyContinue
    $was = Get-Service -Name WAS -ErrorAction SilentlyContinue
    
    $allRunning = $true
    
    if ($w3svc) {
        if ($w3svc.Status -eq 'Running') {
            Write-Host "  鉁?W3SVC (World Wide Web Publishing Service): 杩愯涓? -ForegroundColor Green
        }
        else {
            Write-Host "  鉂?W3SVC: $($w3svc.Status)" -ForegroundColor Red
            $allRunning = $false
        }
    }
    
    if ($was) {
        if ($was.Status -eq 'Running') {
            Write-Host "  鉁?WAS (Windows Process Activation Service): 杩愯涓? -ForegroundColor Green
        }
        else {
            Write-Host "  鉂?WAS: $($was.Status)" -ForegroundColor Red
            $allRunning = $false
        }
    }
    
    # 璁＄畻鑰楁椂
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalSeconds
    
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    
    if ($allRunning) {
        Write-Host "  鉁?IIS 閲嶅惎鎴愬姛锛? -ForegroundColor Green
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "鎬昏€楁椂: $([math]::Round($duration, 1)) 绉? -ForegroundColor Gray
        Write-Host ""
        Write-Host "馃挕 鎻愮ず锛? -ForegroundColor Yellow
        Write-Host "  - 鎵€鏈夌綉绔欏簲璇ュ凡缁忔仮澶嶆甯? -ForegroundColor Gray
        Write-Host "  - 寤鸿璁块棶缃戠珯楠岃瘉鍔熻兘" -ForegroundColor Gray
        Write-Host "  - 妫€鏌ュ簲鐢ㄧ▼搴忔棩蹇楃‘璁ゆ棤閿欒" -ForegroundColor Gray
    }
    else {
        Write-Host "  鈿狅笍  IIS 閲嶅惎瀹屾垚锛屼絾閮ㄥ垎鏈嶅姟鏈繍琛? -ForegroundColor Yellow
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "馃挕 寤鸿锛? -ForegroundColor Yellow
        Write-Host "  1. 鎵撳紑鏈嶅姟绠＄悊鍣ㄦ鏌?IIS 鐩稿叧鏈嶅姟" -ForegroundColor Gray
        Write-Host "  2. 鏌ョ湅浜嬩欢鏌ョ湅鍣ㄤ腑鐨勯敊璇棩蹇? -ForegroundColor Gray
        Write-Host "  3. 灏濊瘯鎵嬪姩鍚姩澶辫触鐨勬湇鍔? -ForegroundColor Gray
    }
}
catch {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  鉂?IIS 閲嶅惎澶辫触" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "閿欒淇℃伅: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "馃挕 鍙兘鐨勫師鍥狅細" -ForegroundColor Yellow
    Write-Host "  1. IIS 鏈嶅姟鏈畨瑁呮垨宸叉崯鍧? -ForegroundColor Gray
    Write-Host "  2. 鏉冮檺涓嶈冻" -ForegroundColor Gray
    Write-Host "  3. 绯荤粺璧勬簮涓嶈冻" -ForegroundColor Gray
    Write-Host ""
    Write-Host "馃挕 瑙ｅ喅鏂规硶锛? -ForegroundColor Yellow
    Write-Host "  1. 妫€鏌ヤ簨浠舵煡鐪嬪櫒涓殑绯荤粺鏃ュ織" -ForegroundColor Gray
    Write-Host "  2. 鍦ㄦ湇鍔＄鐞嗗櫒涓墜鍔ㄩ噸鍚?IIS 鏈嶅姟" -ForegroundColor Gray
    Write-Host "  3. 閲嶅惎鏈嶅姟鍣? -ForegroundColor Gray
}

Write-Host ""
pause
