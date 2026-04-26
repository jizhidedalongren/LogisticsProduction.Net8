# 🚀 快速参考卡片

## 📋 PowerShell 执行策略

```powershell
# 遇到"无法加载文件"错误时运行
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

## 🔧 端口配置

### 本地 Debug（Visual Studio / VS Code / Rider）
```json
// 编辑 Properties/launchSettings.json
{
  "profiles": {
    "http": {
      "applicationUrl": "http://localhost:8080"
    },
    "https": {
      "applicationUrl": "https://localhost:8443;http://localhost:8080"
    }
  }
}
```

### 开发环境（dotnet run）
```bash
# 方式一：命令行指定
dotnet run --urls "http://localhost:8080"

# 方式二：环境变量
$env:ASPNETCORE_URLS="http://localhost:8080"
dotnet run

# 方式三：配置文件 appsettings.Development.json
{
  "Kestrel": {
    "Endpoints": {
      "Http": { "Url": "http://localhost:8080" }
    }
  }
}
```

**优先级：** launchSettings.json > 环境变量 > appsettings.json

### IIS 部署
```powershell
# 首次安装指定端口
.\scripts\deploy-to-iis.ps1 -FirstInstall -Port 9000

# 修改已部署的端口
Set-WebBinding -Name "LogisticsProduction.API" -BindingInformation "*:8008:*" -PropertyName Port -Value 9000
Restart-WebAppPool -Name "LogisticsProductionNet8"
```

### Windows 服务
```powershell
# 编辑 appsettings.Production.json
{
  "Kestrel": {
    "Endpoints": {
      "Http": { "Url": "http://0.0.0.0:9000" }
    }
  }
}

# 重启服务
Restart-Service -Name "LogisticsProductionNet8"
```

## 🛠️ 脚手架生成

```powershell
# 允许脚本执行
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# 中文交互式生成
.\scripts\scaffold-cn.ps1

# 英文交互式生成
.\scripts\scaffold.ps1

# 命令行直接生成
.\scripts\scaffold-feature.ps1 -FeatureName WareHouse -EntityName WareHouseTask -IncludeCommand
```

## 📦 部署命令

### IIS 部署
```powershell
# 首次安装
.\scripts\deploy-to-iis.ps1 -FirstInstall

# 标准更新
.\scripts\deploy-to-iis.ps1

# 热更新（停机 2-5 秒）
.\scripts\deploy-to-iis.ps1 -HotUpdate
```

### Windows 服务
```powershell
# 部署/更新
.\scripts\deploy.ps1 -Environment Production
```

## 🔍 管理命令

### IIS
```powershell
# 查看状态
Get-Website -Name "LogisticsProduction.API"
Get-WebAppPoolState -Name "LogisticsProductionNet8"

# 重启
Restart-WebAppPool -Name "LogisticsProductionNet8"

# 查看日志
Get-Content "F:\IIS\LogisticsProductionNet8\Logs\*.log" -Tail 50
```

### Windows 服务
```powershell
# 查看状态
Get-Service -Name "LogisticsProductionNet8"

# 重启
Restart-Service -Name "LogisticsProductionNet8"

# 查看日志
Get-Content "F:\LogisticsProductionNet8\Logs\*.log" -Tail 50
```

## 🔥 防火墙配置

```powershell
# 允许端口访问
New-NetFirewallRule -DisplayName "Logistics API" -Direction Inbound -LocalPort 8008 -Protocol TCP -Action Allow

# 删除规则
Remove-NetFirewallRule -DisplayName "Logistics API"

# 查看规则
Get-NetFirewallRule -DisplayName "Logistics API"
```

## 🐛 故障排查

### 检查端口占用
```powershell
# 查看端口占用
netstat -ano | findstr :8008

# 查看进程
Get-Process -Id <PID>

# 停止进程
Stop-Process -Id <PID> -Force
```

### 查看错误日志
```powershell
# 应用日志
Get-Content "路径\Logs\*.log" | Select-String "ERROR|FATAL"

# Windows 事件日志
Get-EventLog -LogName Application -Source "IIS*" -Newest 50
Get-EventLog -LogName Application -Source ".NET Runtime" -Newest 50
```

### IIS 常见错误
```powershell
# 500.19 - 配置错误
Get-WebGlobalModule | Where-Object { $_.Name -like "*AspNetCore*" }
iisreset

# 502.5 - 启动失败
Get-Content "F:\IIS\LogisticsProductionNet8\logs\stdout*.log" -Tail 100

# 503 - 应用程序池停止
Start-WebAppPool -Name "LogisticsProductionNet8"
```

## 📝 配置文件位置

| 项目 | 路径 |
|------|------|
| 开发配置 | `appsettings.Development.json` |
| 生产配置（IIS） | `F:\IIS\LogisticsProductionNet8\appsettings.Production.json` |
| 生产配置（服务） | `F:\LogisticsProductionNet8\appsettings.Production.json` |
| IIS 日志 | `F:\IIS\LogisticsProductionNet8\Logs\` |
| 服务日志 | `F:\LogisticsProductionNet8\Logs\` |

## 🔗 快速链接

- Swagger（开发）: http://localhost:5000/swagger
- Swagger（IIS）: http://localhost:8008/swagger
- IIS 管理器: `Win + R` → `inetmgr`
- 服务管理: `Win + R` → `services.msc`
- 事件查看器: `Win + R` → `eventvwr`

## 💾 备份与回滚

### 备份
```powershell
# IIS 配置备份
Backup-WebConfiguration -Name "Backup_$(Get-Date -Format 'yyyyMMdd')"

# 文件备份（自动）
# 部署脚本会自动创建备份：*.backup.yyyyMMdd_HHmmss
```

### 回滚
```powershell
# IIS
Stop-Website -Name "LogisticsProduction.API"
Copy-Item "F:\IIS\LogisticsProductionNet8.backup.20240327_143022\*" -Destination "F:\IIS\LogisticsProductionNet8" -Recurse -Force
Start-Website -Name "LogisticsProduction.API"

# Windows 服务
Stop-Service -Name "LogisticsProductionNet8"
Copy-Item "F:\LogisticsProductionNet8.backup.20240327_143022\*" -Destination "F:\LogisticsProductionNet8" -Recurse -Force
Start-Service -Name "LogisticsProductionNet8"
```

## 📚 更多信息

- 完整文档索引: `DOCS_INDEX.md`
- 项目概览: `README.md`
- 部署指南: `DEPLOYMENT_WINDOWS.md`
- 开发指南: `DEVELOPMENT_GUIDE.md`
- 架构规范: `ARCHITECTURE.md`
