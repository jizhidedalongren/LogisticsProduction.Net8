# 本地测试环境更新指南

## 场景说明

你已经在本地电脑通过 IIS 部署了一个测试环境：
- 物理路径：`F:\LogisticsProductionNet8`
- IIS 站点名称：`LogisticsProduction.API`（根据实际情况调整）
- 应用程序池：`LogisticsProductionNet8`（根据实际情况调整）

当代码有更新时，需要重新部署到这个测试环境。

---

## 快速更新步骤

### 方式一：使用脚本自动更新（推荐）

在项目根目录打开 PowerShell（管理员权限）：

```powershell
# 1. 发布项目
dotnet publish -c Release -o ./publish

# 2. 进入发布目录
cd publish

# 3. 运行 IIS 部署脚本（更新模式）
.\deploy-to-iis.ps1
```

脚本会自动：
- 停止 IIS 网站
- 备份现有文件
- 复制新文件
- 启动网站

**停机时间：约 5-10 秒**

---

### 方式二：热更新（停机时间更短）

```powershell
# 1. 发布项目
dotnet publish -c Release -o ./publish

# 2. 进入发布目录
cd publish

# 3. 使用热更新模式
.\deploy-to-iis.ps1 -HotUpdate
```

热更新使用 `app_offline.htm` 方法，停机时间约 2-5 秒。

---

### 方式三：手动更新

如果不想使用脚本，可以手动操作：

#### 步骤 1：停止 IIS 网站

打开 PowerShell（管理员权限）：

```powershell
# 导入 IIS 模块
Import-Module WebAdministration

# 停止网站（替换为你的实际站点名称）
Stop-Website -Name "LogisticsProduction.API"

# 或者停止应用程序池
Stop-WebAppPool -Name "LogisticsProductionNet8"
```

或者使用 IIS 管理器：
1. Win + R → 输入 `inetmgr` → 回车
2. 找到你的网站 → 右键 → 停止

#### 步骤 2：发布项目

在项目根目录：

```powershell
dotnet publish -c Release -o ./publish
```

#### 步骤 3：备份现有文件（可选但推荐）

```powershell
# 备份到带时间戳的文件夹
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Copy-Item -Path "F:\LogisticsProductionNet8" -Destination "F:\LogisticsProductionNet8.backup.$timestamp" -Recurse
```

#### 步骤 4：复制新文件

```powershell
# 复制所有文件到部署目录
Copy-Item -Path ".\publish\*" -Destination "F:\LogisticsProductionNet8" -Recurse -Force
```

#### 步骤 5：启动网站

```powershell
# 启动网站
Start-Website -Name "LogisticsProduction.API"

# 或者启动应用程序池
Start-WebAppPool -Name "LogisticsProductionNet8"
```

或者在 IIS 管理器中右键 → 启动

---

## 验证更新

更新完成后，验证是否成功：

```powershell
# 1. 检查网站状态
Get-Website -Name "LogisticsProduction.API"

# 2. 检查应用程序池状态
Get-WebAppPoolState -Name "LogisticsProductionNet8"

# 3. 访问 Swagger 测试
Start-Process "http://localhost:8008/swagger"

# 4. 查看日志（如果有问题）
Get-Content "F:\LogisticsProductionNet8\Logs\*.log" -Tail 50
```

---

## 常见问题

### 问题 1：文件被占用，无法复制

**原因：** IIS 网站或应用程序池没有完全停止

**解决：**
```powershell
# 强制停止应用程序池
Stop-WebAppPool -Name "LogisticsProductionNet8"
Start-Sleep -Seconds 5

# 再次尝试复制
Copy-Item -Path ".\publish\*" -Destination "F:\LogisticsProductionNet8" -Recurse -Force
```

### 问题 2：更新后网站无法启动

**解决：**
```powershell
# 1. 查看应用日志
Get-Content "F:\LogisticsProductionNet8\Logs\*.log" -Tail 100

# 2. 查看 IIS 日志
Get-Content "C:\inetpub\logs\LogFiles\W3SVC*\*.log" -Tail 50

# 3. 查看 Windows 事件日志
Get-EventLog -LogName Application -Source "IIS*" -Newest 20

# 4. 如果需要回滚
$backupPath = "F:\LogisticsProductionNet8.backup.20260328_100000"  # 替换为实际备份路径
Stop-Website -Name "LogisticsProduction.API"
Remove-Item "F:\LogisticsProductionNet8\*" -Recurse -Force -Exclude "Logs"
Copy-Item -Path "$backupPath\*" -Destination "F:\LogisticsProductionNet8" -Recurse -Force
Start-Website -Name "LogisticsProduction.API"
```

### 问题 3：配置文件被覆盖

如果你有自定义的配置文件（如 `appsettings.Production.json`），更新前先备份：

```powershell
# 更新前备份配置
Copy-Item "F:\LogisticsProductionNet8\appsettings.Production.json" -Destination ".\appsettings.Production.backup.json"

# 更新后恢复配置
Copy-Item ".\appsettings.Production.backup.json" -Destination "F:\LogisticsProductionNet8\appsettings.Production.json" -Force
```

---

## 一键更新脚本

创建一个快捷脚本 `quick-update.ps1`：

```powershell
# 快速更新本地测试环境
param(
    [string]$DeployPath = "F:\LogisticsProductionNet8",
    [string]$SiteName = "LogisticsProduction.API",
    [string]$AppPoolName = "LogisticsProductionNet8"
)

Write-Host "开始更新本地测试环境..." -ForegroundColor Cyan

# 1. 发布项目
Write-Host "[1/5] 发布项目..." -ForegroundColor Green
dotnet publish -c Release -o ./publish
if ($LASTEXITCODE -ne 0) {
    Write-Host "发布失败！" -ForegroundColor Red
    exit 1
}

# 2. 停止网站
Write-Host "[2/5] 停止网站..." -ForegroundColor Green
Import-Module WebAdministration
Stop-Website -Name $SiteName -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# 3. 备份配置
Write-Host "[3/5] 备份配置..." -ForegroundColor Green
$configBackup = "$DeployPath\appsettings.Production.json.backup"
if (Test-Path "$DeployPath\appsettings.Production.json") {
    Copy-Item "$DeployPath\appsettings.Production.json" -Destination $configBackup -Force
}

# 4. 复制文件
Write-Host "[4/5] 复制文件..." -ForegroundColor Green
Copy-Item -Path ".\publish\*" -Destination $DeployPath -Recurse -Force

# 恢复配置
if (Test-Path $configBackup) {
    Copy-Item $configBackup -Destination "$DeployPath\appsettings.Production.json" -Force
    Remove-Item $configBackup
}

# 5. 启动网站
Write-Host "[5/5] 启动网站..." -ForegroundColor Green
Start-Website -Name $SiteName
Start-Sleep -Seconds 3

Write-Host "更新完成！" -ForegroundColor Green
Write-Host "访问: http://localhost:8008/swagger" -ForegroundColor Yellow
```

使用方法：
```powershell
# 以管理员身份运行
.\quick-update.ps1
```

---

## 提示

1. **始终以管理员身份运行 PowerShell**
2. **更新前建议备份**，特别是有重要配置时
3. **更新后检查日志**，确保没有错误
4. **保留最近几个备份**，以便快速回滚
5. 如果频繁更新，推荐使用脚本自动化

---

## 相关文档

- 完整部署指南：`DEPLOYMENT_WINDOWS.md`
- IIS 部署脚本：`deploy-to-iis.ps1`
- Windows 服务部署：`deploy.ps1`
