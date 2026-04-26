# ============================================
# 閲嶅惎 IIS 搴旂敤绋嬪簭姹犺剼鏈?
# ============================================
# 鐢ㄩ€旓細瀹夊叏鍦伴噸鍚寚瀹氱殑搴旂敤绋嬪簭姹?
# 浣跨敤锛氫互绠＄悊鍛樿韩浠借繍琛?
# ============================================

param(
    [Parameter(Mandatory=$false)]
    [string]$AppPoolName
)

# 妫€鏌ョ鐞嗗憳鏉冮檺
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "鉂?閿欒锛氭鑴氭湰闇€瑕佺鐞嗗憳鏉冮檺" -ForegroundColor Red
    Write-Host "璇峰彸閿偣鍑?PowerShell锛岄€夋嫨'浠ョ鐞嗗憳韬唤杩愯'锛岀劧鍚庨噸鏂版墽琛屾鑴氭湰" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  IIS 搴旂敤绋嬪簭姹犻噸鍚伐鍏? -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 瀵煎叆 WebAdministration 妯″潡
try {
    Import-Module WebAdministration -ErrorAction Stop
}
catch {
    Write-Host "鉂?閿欒锛氭棤娉曞姞杞?IIS 绠＄悊妯″潡" -ForegroundColor Red
    Write-Host "璇风‘淇濆凡瀹夎 IIS 绠＄悊宸ュ叿" -ForegroundColor Yellow
    pause
    exit 1
}

# 濡傛灉娌℃湁鎸囧畾搴旂敤绋嬪簭姹狅紝鏄剧ず鍒楄〃
if ([string]::IsNullOrEmpty($AppPoolName)) {
    Write-Host "馃搵 鍙敤鐨勫簲鐢ㄧ▼搴忔睜锛? -ForegroundColor Cyan
    Write-Host ""
    
    $appPools = Get-ChildItem IIS:\AppPools | Select-Object Name, State, @{Name="Runtime";Expression={$_.managedRuntimeVersion}}
    
    for ($i = 0; $i -lt $appPools.Count; $i++) {
        $pool = $appPools[$i]
        $stateColor = if ($pool.State -eq 'Started') { 'Green' } else { 'Yellow' }
        Write-Host "  $($i + 1). " -NoNewline -ForegroundColor Gray
        Write-Host "$($pool.Name) " -NoNewline -ForegroundColor White
        Write-Host "[$($pool.State)]" -ForegroundColor $stateColor
        Write-Host "     Runtime: $($pool.Runtime)" -ForegroundColor DarkGray
    }
    
    Write-Host ""
    $choice = Read-Host "璇疯緭鍏ュ簲鐢ㄧ▼搴忔睜缂栧彿锛堟垨鐩存帴杈撳叆鍚嶇О锛?
    
    # 鍒ゆ柇鏄暟瀛楄繕鏄悕绉?
    if ($choice -match '^\d+$') {
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $appPools.Count) {
            $AppPoolName = $appPools[$index].Name
        }
        else {
            Write-Host "鉂?鏃犳晥鐨勭紪鍙? -ForegroundColor Red
            pause
            exit 1
        }
    }
    else {
        $AppPoolName = $choice
    }
}

# 楠岃瘉搴旂敤绋嬪簭姹犳槸鍚﹀瓨鍦?
if (-not (Test-Path "IIS:\AppPools\$AppPoolName")) {
    Write-Host "鉂?閿欒锛氭壘涓嶅埌搴旂敤绋嬪簭姹?'$AppPoolName'" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "鈴?姝ｅ湪閲嶅惎搴旂敤绋嬪簭姹? $AppPoolName" -ForegroundColor Cyan
Write-Host ""

try {
    # 鑾峰彇褰撳墠鐘舵€?
    $currentState = Get-WebAppPoolState -Name $AppPoolName
    Write-Host "  褰撳墠鐘舵€? $($currentState.Value)" -ForegroundColor Gray
    
    # 鍋滄搴旂敤绋嬪簭姹?
    Write-Host "  鈴革笍  姝ｅ湪鍋滄..." -ForegroundColor Yellow
    Stop-WebAppPool -Name $AppPoolName -ErrorAction Stop
    
    # 绛夊緟鍋滄瀹屾垚锛堟渶澶氱瓑寰?10 绉掞級
    $timeout = 10
    $elapsed = 0
    while ($elapsed -lt $timeout) {
        Start-Sleep -Seconds 1
        $elapsed++
        $state = Get-WebAppPoolState -Name $AppPoolName
        
        if ($state.Value -eq 'Stopped') {
            Write-Host "  鉁?宸插仠姝紙鐢ㄦ椂 $elapsed 绉掞級" -ForegroundColor Green
            break
        }
        
        Write-Host "  鈴?绛夊緟鍋滄... ($elapsed/$timeout 绉?" -ForegroundColor Yellow
    }
    
    # 濡傛灉瓒呮椂浠嶆湭鍋滄
    if ($state.Value -ne 'Stopped') {
        Write-Host "  鈿狅笍  鍋滄瓒呮椂锛屽皾璇曞己鍒跺仠姝?.." -ForegroundColor Yellow
        Stop-WebAppPool -Name $AppPoolName -ErrorAction Stop
        Start-Sleep -Seconds 2
    }
    
    # 鍚姩搴旂敤绋嬪簭姹?
    Write-Host "  鈻讹笍  姝ｅ湪鍚姩..." -ForegroundColor Yellow
    Start-WebAppPool -Name $AppPoolName -ErrorAction Stop
    
    # 绛夊緟鍚姩瀹屾垚锛堟渶澶氱瓑寰?15 绉掞級
    $timeout = 15
    $elapsed = 0
    while ($elapsed -lt $timeout) {
        Start-Sleep -Seconds 1
        $elapsed++
        $state = Get-WebAppPoolState -Name $AppPoolName
        
        if ($state.Value -eq 'Started') {
            Write-Host "  鉁?宸插惎鍔紙鐢ㄦ椂 $elapsed 绉掞級" -ForegroundColor Green
            break
        }
        
        Write-Host "  鈴?绛夊緟鍚姩... ($elapsed/$timeout 绉?" -ForegroundColor Yellow
    }
    
    Write-Host ""
    
    # 楠岃瘉鏈€缁堢姸鎬?
    $finalState = Get-WebAppPoolState -Name $AppPoolName
    
    if ($finalState.Value -eq 'Started') {
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host "  鉁?閲嶅惎鎴愬姛锛? -ForegroundColor Green
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "搴旂敤绋嬪簭姹? $AppPoolName" -ForegroundColor White
        Write-Host "褰撳墠鐘舵€? $($finalState.Value)" -ForegroundColor Green
        Write-Host ""
        
        # 鏄剧ず鍏宠仈鐨勭綉绔?
        $sites = Get-ChildItem IIS:\Sites | Where-Object { $_.applicationPool -eq $AppPoolName }
        if ($sites) {
            Write-Host "鍏宠仈鐨勭綉绔欙細" -ForegroundColor Cyan
            foreach ($site in $sites) {
                Write-Host "  - $($site.Name)" -ForegroundColor Gray
            }
        }
    }
    else {
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host "  鈿狅笍  閲嶅惎鍙兘鏈畬鎴? -ForegroundColor Yellow
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "褰撳墠鐘舵€? $($finalState.Value)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "馃挕 寤鸿锛? -ForegroundColor Yellow
        Write-Host "  1. 鎵撳紑 IIS 绠＄悊鍣ㄦ鏌ョ姸鎬? -ForegroundColor Gray
        Write-Host "  2. 鏌ョ湅浜嬩欢鏌ョ湅鍣ㄤ腑鐨勯敊璇棩蹇? -ForegroundColor Gray
        Write-Host "  3. 妫€鏌ュ簲鐢ㄧ▼搴忔睜閰嶇疆" -ForegroundColor Gray
    }
}
catch {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  鉂?閲嶅惎澶辫触" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "閿欒淇℃伅: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "馃挕 鍙兘鐨勫師鍥狅細" -ForegroundColor Yellow
    Write-Host "  1. 搴旂敤绋嬪簭姹犳鍦ㄨ浣跨敤" -ForegroundColor Gray
    Write-Host "  2. 搴旂敤绋嬪簭鏈夐敊璇鑷存棤娉曞惎鍔? -ForegroundColor Gray
    Write-Host "  3. 鏉冮檺涓嶈冻" -ForegroundColor Gray
    Write-Host ""
    Write-Host "馃挕 瑙ｅ喅鏂规硶锛? -ForegroundColor Yellow
    Write-Host "  1. 妫€鏌ヤ簨浠舵煡鐪嬪櫒涓殑閿欒鏃ュ織" -ForegroundColor Gray
    Write-Host "  2. 鍦?IIS 绠＄悊鍣ㄤ腑鎵嬪姩閲嶅惎" -ForegroundColor Gray
    Write-Host "  3. 妫€鏌ュ簲鐢ㄧ▼搴忛厤缃枃浠? -ForegroundColor Gray
}

Write-Host ""
pause
