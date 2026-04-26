# Windows 部署指南

## ⚠️ 部署前准备

### PowerShell 执行策略

如果运行脚本时提示"无法加载文件，因为在此系统上禁止运行脚本"：

```powershell
# 方式一：临时允许（推荐，仅当前会话）
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# 方式二：永久允许当前用户（需管理员权限）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 查看当前策略
Get-ExecutionPolicy -List
```

**说明：**
- `Bypass` - 不阻止任何脚本，不显示警告
- `RemoteSigned` - 本地脚本可运行，下载的脚本需签名
- `Scope Process` - 仅当前 PowerShell 进程生效
- `Scope CurrentUser` - 仅当前用户生效

### 管理员权限

所有部署操作需要管理员权限：
1. 右键 PowerShell → "以管理员身份运行"
2. 或在 PowerShell 中运行：`Start-Process powershell -Verb RunAs`

---

## 🎯 部署方式选择

| 方式 | 适用场景 | 停机时间 | 复杂度 |
|------|---------|---------|--------|
| **IIS 部署** | 生产环境（推荐） | 2-10 秒 | ⭐⭐ |
| **Windows 服务** | 无 IIS 环境 | 5-10 秒 | ⭐⭐ |
| **Kestrel 自托管** | 开发测试 | - | ⭐ |

---

## 方式一：IIS 部署（推荐）

### 前置要求

1. **安装 .NET 8 Hosting Bundle**
   - 下载：https://dotnet.microsoft.com/download/dotnet/8.0
   - 选择 "ASP.NET Core Runtime 8.x.x - Windows Hosting Bundle"
   - 安装后运行：`iisreset`

2. **启用 IIS**（如未安装）
   ```powershell
   # 以管理员身份运行
   Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
   Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45
   ```

### 首次部署

#### 开发电脑
```powershell
# 发布项目
dotnet publish -c Release -o ./publish
```

#### 服务器（管理员权限）
```powershell
# 运行部署脚本
.\deploy-to-iis.ps1 -FirstInstall

# 编辑生产配置
notepad F:\IIS\LogisticsProductionNet8\appsettings.Production.json

# 重启应用程序池
Restart-WebAppPool -Name "LogisticsProductionNet8"
```

### 日常更新

#### 开发电脑
```powershell
dotnet publish -c Release -o ./publish
```

#### 服务器
```powershell
# 标准更新（停机 5-10 秒）
.\deploy-to-iis.ps1

# 热更新（停机 2-5 秒）
.\deploy-to-iis.ps1 -HotUpdate
```

### IIS 管理命令

```powershell
# 查看状态
Get-Website -Name "LogisticsProduction.API"
Get-WebAppPoolState -Name "LogisticsProductionNet8"

# 重启
Restart-WebAppPool -Name "LogisticsProductionNet8"

# 查看日志
Get-Content "F:\IIS\LogisticsProductionNet8\Logs\*.log" -Tail 50
```

---

## 方式二：Windows 服务部署

### 前置要求

1. **安装 .NET 8 Runtime**
   - 下载：https://dotnet.microsoft.com/download/dotnet/8.0
   - 选择 "ASP.NET Core Runtime 8.x.x - Windows x64"
   - 验证安装：`dotnet --list-runtimes`

2. **管理员权限**
   - 必须以管理员身份运行 PowerShell

### 首次部署

#### 开发电脑
```powershell
# 发布项目
dotnet publish -c Release -o ./publish

# 将 publish 文件夹打包
Compress-Archive -Path .\publish\* -DestinationPath LogisticsProduction_v1.0.0.zip
```

#### 服务器（管理员权限）

```powershell
# 1. 解压文件到服务器
Expand-Archive -Path LogisticsProduction_v1.0.0.zip -DestinationPath D:\Deploy\LogisticsProduction

# 2. 进入解压目录
cd D:\Deploy\LogisticsProduction

# 3. 运行部署脚本（首次安装）
.\deploy.ps1 -Environment Production

# 脚本会自动：
# - 创建部署目录（F:\LogisticsProductionNet8）
# - 复制文件
# - 创建 Windows 服务
# - 配置服务自动启动
# - 启动服务

# 4. 编辑生产配置
notepad F:\LogisticsProductionNet8\appsettings.Production.json

# 修改数据库连接字符串和外部服务地址后保存

# 5. 重启服务使配置生效
Restart-Service -Name "LogisticsProductionNet8"

# 6. 验证服务状态
Get-Service -Name "LogisticsProductionNet8"

# 7. 测试 API
Start-Process "http://localhost:8008/swagger"
```

### 日常更新

#### 开发电脑
```powershell
# 发布新版本
dotnet publish -c Release -o ./publish

# 打包
Compress-Archive -Path .\publish\* -DestinationPath LogisticsProduction_v1.0.5.zip -Force
```

#### 服务器
```powershell
# 1. 解压新版本
Expand-Archive -Path LogisticsProduction_v1.0.5.zip -DestinationPath D:\Deploy\LogisticsProduction_v1.0.5 -Force

# 2. 进入目录
cd D:\Deploy\LogisticsProduction_v1.0.5

# 3. 运行更新（不带 -FirstInstall 参数）
.\deploy.ps1 -Environment Production

# 脚本会自动：
# - 停止服务
# - 备份现有文件
# - 复制新文件
# - 保留生产配置
# - 启动服务
```

### 服务管理

```powershell
# 查看服务状态
Get-Service -Name "LogisticsProductionNet8"

# 查看详细信息
Get-Service -Name "LogisticsProductionNet8" | Select-Object *

# 启动服务
Start-Service -Name "LogisticsProductionNet8"

# 停止服务
Stop-Service -Name "LogisticsProductionNet8"

# 重启服务
Restart-Service -Name "LogisticsProductionNet8"

# 查看服务配置
sc.exe qc "LogisticsProductionNet8"

# 查看服务状态
sc.exe query "LogisticsProductionNet8"
```

### 日志管理

```powershell
# 查看应用日志
Get-Content "F:\LogisticsProductionNet8\Logs\*.log" -Tail 50

# 实时监控日志
Get-Content "F:\LogisticsProductionNet8\Logs\*.log" -Wait

# 查看错误日志
Get-Content "F:\LogisticsProductionNet8\Logs\*.log" | Select-String "ERROR|FATAL"

# 查看 Windows 事件日志
Get-EventLog -LogName Application -Source ".NET Runtime" -Newest 50
```

### 故障排查

#### 服务无法启动
```powershell
# 1. 查看服务状态
Get-Service -Name "LogisticsProductionNet8"

# 2. 查看 Windows 事件日志
Get-EventLog -LogName Application -Source ".NET Runtime" -Newest 20

# 3. 手动运行测试
cd F:\LogisticsProductionNet8
dotnet LogisticsProduction.Net8.dll

# 4. 检查端口占用
netstat -ano | findstr :8008

# 5. 检查配置文件
Get-Content F:\LogisticsProductionNet8\appsettings.Production.json
```

#### 服务频繁停止
```powershell
# 查看崩溃日志
Get-EventLog -LogName Application -Source ".NET Runtime" -Newest 50 | 
    Where-Object { $_.EntryType -eq "Error" }

# 查看应用日志
Get-Content "F:\LogisticsProductionNet8\Logs\*.log" | Select-String "ERROR|FATAL" -Context 5

# 配置服务失败重启（已在 deploy.ps1 中配置）
sc.exe failure "LogisticsProductionNet8" reset= 86400 actions= restart/60000/restart/60000/restart/60000
```

### 回滚操作

```powershell
# 停止服务
Stop-Service -Name "LogisticsProductionNet8"

# 删除当前版本
Remove-Item "F:\LogisticsProductionNet8\*" -Recurse -Force -Exclude "Logs"

# 恢复备份（替换为实际备份路径）
Copy-Item "F:\LogisticsProductionNet8.backup.20240327_143022\*" -Destination "F:\LogisticsProductionNet8" -Recurse -Force

# 启动服务
Start-Service -Name "LogisticsProductionNet8"

# 验证
Get-Service -Name "LogisticsProductionNet8"
```

### 卸载服务

```powershell
# 停止服务
Stop-Service -Name "LogisticsProductionNet8"

# 删除服务
sc.exe delete "LogisticsProductionNet8"

# 删除部署文件
Remove-Item "F:\LogisticsProductionNet8" -Recurse -Force
```

---

## 方式三：Kestrel 自托管（开发测试）

### 运行应用

```bash
# 发布
dotnet publish -c Release -o ./publish

# 运行
cd publish
.\LogisticsProduction.Net8.exe
```

### 配置监听地址

编辑 `appsettings.json`：

```json
{
  "Kestrel": {
    "Endpoints": {
      "Http": {
        "Url": "http://0.0.0.0:5000"
      }
    }
  }
}
```

---

## 🔧 配置管理

### 生产环境配置

`appsettings.Production.json`：

```json
{
  "ConnectionStrings": {
    "MainDb": "Data Source=生产服务器;Initial Catalog=LogisticsProduction_DB;User ID=用户名;Password=密码;TrustServerCertificate=True"
  },
  "ExternalServices": {
    "PrintServiceUrl": "http://10.101.16.30:30123",
    "AgvServiceUrl": "http://生产AGV地址:8080",
    "WmsServiceUrl": "http://生产WMS地址:8081"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  }
}
```

### 环境变量方式（更安全）

```powershell
# 设置环境变量
[System.Environment]::SetEnvironmentVariable("ConnectionStrings__MainDb", "连接字符串", "Machine")
[System.Environment]::SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", "Production", "Machine")
```

---

## 🚨 故障排查

### IIS 常见错误

#### 500.19 - 配置错误
```powershell
# 验证 Hosting Bundle
dotnet --list-runtimes

# 重启 IIS
iisreset

# 检查 ASP.NET Core Module
Get-WebGlobalModule | Where-Object { $_.Name -like "*AspNetCore*" }
```

#### 502.5 - 启动失败
```powershell
# 查看 stdout 日志
Get-Content "F:\IIS\LogisticsProductionNet8\logs\stdout*.log" -Tail 100

# 手动测试
cd F:\IIS\LogisticsProductionNet8
dotnet LogisticsProduction.Net8.dll

# 检查权限
icacls "F:\IIS\LogisticsProductionNet8" /grant "IIS AppPool\LogisticsProductionNet8:(OI)(CI)RX" /T
```

#### 503 - 应用程序池停止
```powershell
# 查看事件日志
Get-EventLog -LogName Application -Source "IIS*" -Newest 50

# 启动应用程序池
Start-WebAppPool -Name "LogisticsProductionNet8"

# 查看应用日志
Get-Content "F:\IIS\LogisticsProductionNet8\Logs\*.log" | Select-String "ERROR|FATAL"
```

### Windows 服务错误

```powershell
# 查看服务状态
Get-Service -Name "LogisticsProductionNet8"

# 查看事件日志
Get-EventLog -LogName Application -Source ".NET Runtime" -Newest 50

# 查看应用日志
Get-Content "F:\LogisticsProductionNet8\Logs\*.log" -Tail 100
```

---

## 🔄 回滚操作

### IIS 回滚
```powershell
Stop-Website -Name "LogisticsProduction.API"
Remove-Item "F:\IIS\LogisticsProductionNet8\*" -Recurse -Force -Exclude "Logs"
Copy-Item "F:\IIS\LogisticsProductionNet8.backup.20240327_143022\*" -Destination "F:\IIS\LogisticsProductionNet8" -Recurse -Force
Start-Website -Name "LogisticsProduction.API"
```

### Windows 服务回滚
```powershell
Stop-Service -Name "LogisticsProductionNet8"
Remove-Item "F:\LogisticsProductionNet8\*" -Recurse -Force -Exclude "Logs"
Copy-Item "F:\LogisticsProductionNet8.backup.20240327_143022\*" -Destination "F:\LogisticsProductionNet8" -Recurse -Force
Start-Service -Name "LogisticsProductionNet8"
```

---

## 📊 性能优化

### IIS 优化

```powershell
$poolName = "LogisticsProductionNet8"

# AlwaysRunning 模式
Set-ItemProperty "IIS:\AppPools\$poolName" -Name "startMode" -Value "AlwaysRunning"

# 禁用空闲超时
Set-ItemProperty "IIS:\AppPools\$poolName" -Name "processModel.idleTimeout" -Value "00:00:00"

# 禁用定期回收
Set-ItemProperty "IIS:\AppPools\$poolName" -Name "recycling.periodicRestart.time" -Value "00:00:00"

# 回收应用程序池
Restart-WebAppPool -Name $poolName
```

### 启用压缩

```powershell
Set-WebConfigurationProperty -Filter "/system.webServer/urlCompression" `
    -PSPath "IIS:\Sites\LogisticsProduction.API" `
    -Name "doDynamicCompression" -Value $true
```

---

## ⚙️ 端口配置

### 本地 Debug 端口配置

#### Visual Studio / VS Code / Rider

编辑 `Properties/launchSettings.json`：

```json
{
  "profiles": {
    "http": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "launchUrl": "swagger",
      "applicationUrl": "http://localhost:8080",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    },
    "https": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "launchUrl": "swagger",
      "applicationUrl": "https://localhost:8443;http://localhost:8080",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
```

**说明：**
- `http` profile：仅 HTTP，默认端口 5000
- `https` profile：HTTPS + HTTP，默认端口 5001 + 5000
- 修改 `applicationUrl` 即可更改端口
- Visual Studio 会在调试工具栏显示可选的 profile

#### 命令行调试

```bash
# 指定单个端口
dotnet run --urls "http://localhost:8080"

# 指定多个端口
dotnet run --urls "https://localhost:8443;http://localhost:8080"

# 监听所有网卡（局域网访问）
dotnet run --urls "http://0.0.0.0:8080"
```

#### 配置优先级

1. **launchSettings.json** - 最高优先级（IDE 调试时）
2. **命令行参数** - `--urls` 参数
3. **环境变量** - `ASPNETCORE_URLS`
4. **appsettings.json** - Kestrel 配置
5. **默认值** - http://localhost:5000

### IIS 部署端口配置

#### 首次安装时指定端口
```powershell
# 修改 deploy-to-iis.ps1 中的端口参数
.\deploy-to-iis.ps1 -FirstInstall -Port 9000
```

#### 修改已部署的端口
```powershell
# 方式一：使用 PowerShell
Import-Module WebAdministration
Set-WebBinding -Name "LogisticsProduction.API" -BindingInformation "*:8008:*" -PropertyName Port -Value 9000

# 方式二：使用 IIS 管理器
# 1. 打开 IIS 管理器（Win + R → inetmgr）
# 2. 选择网站 → 右键 → 编辑绑定
# 3. 选择绑定 → 编辑 → 修改端口号 → 确定

# 重启网站
Restart-WebAppPool -Name "LogisticsProductionNet8"
```

#### 添加多个端口绑定
```powershell
# 添加 HTTPS 绑定
New-WebBinding -Name "LogisticsProduction.API" -Protocol "https" -Port 8443

# 添加额外的 HTTP 端口
New-WebBinding -Name "LogisticsProduction.API" -Protocol "http" -Port 9000
```

### Windows 服务端口配置

#### 修改配置文件
编辑 `F:\LogisticsProductionNet8\appsettings.Production.json`：

```json
{
  "Kestrel": {
    "Endpoints": {
      "Http": {
        "Url": "http://0.0.0.0:8008"
      },
      "Https": {
        "Url": "https://0.0.0.0:8443",
        "Certificate": {
          "Path": "certificate.pfx",
          "Password": "证书密码"
        }
      }
    }
  }
}
```

#### 修改服务环境变量
```powershell
# 停止服务
Stop-Service -Name "LogisticsProductionNet8"

# 修改注册表中的环境变量
$servicePath = "HKLM:\SYSTEM\CurrentControlSet\Services\LogisticsProductionNet8"
$envVars = @(
    "ASPNETCORE_ENVIRONMENT=Production",
    "ASPNETCORE_URLS=http://0.0.0.0:9000"
)
Set-ItemProperty -Path $servicePath -Name "Environment" -Value $envVars

# 启动服务
Start-Service -Name "LogisticsProductionNet8"
```

### 防火墙配置

修改端口后，需要更新防火墙规则：

```powershell
# 删除旧规则
Remove-NetFirewallRule -DisplayName "Logistics API HTTP" -ErrorAction SilentlyContinue

# 添加新规则
New-NetFirewallRule -DisplayName "Logistics API HTTP" -Direction Inbound -LocalPort 9000 -Protocol TCP -Action Allow

# 验证规则
Get-NetFirewallRule -DisplayName "Logistics API HTTP"
```

### 端口占用检查

```powershell
# 检查端口是否被占用
netstat -ano | findstr :8008

# 查看占用端口的进程
Get-Process -Id <PID>

# 释放端口（停止占用进程）
Stop-Process -Id <PID> -Force
```

---

## 🔐 安全配置

### HTTPS 配置

```powershell
# 添加 HTTPS 绑定
New-WebBinding -Name "LogisticsProduction.API" -Protocol "https" -Port 8443

# 绑定证书（替换为你的证书指纹）
$cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Subject -like "*你的域名*" }
$binding = Get-WebBinding -Name "LogisticsProduction.API" -Protocol "https"
$binding.AddSslCertificate($cert.Thumbprint, "My")
```

### 防火墙配置

```powershell
# 允许端口访问
New-NetFirewallRule -DisplayName "Logistics API HTTP" -Direction Inbound -LocalPort 8008 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Logistics API HTTPS" -Direction Inbound -LocalPort 8443 -Protocol TCP -Action Allow
```

---

## 📈 监控和日志

### 查看日志

```powershell
# IIS 日志
Get-Content "C:\inetpub\logs\LogFiles\W3SVC*\*.log" -Tail 50

# 应用程序日志
Get-Content "F:\IIS\LogisticsProductionNet8\Logs\*.log" -Tail 50

# 实时监控
Get-Content "F:\IIS\LogisticsProductionNet8\Logs\*.log" -Wait

# 错误日志
Get-Content "F:\IIS\LogisticsProductionNet8\Logs\*.log" | Select-String "ERROR|FATAL"
```

### 健康检查

```powershell
# 检查网站状态
$site = Get-Website -Name "LogisticsProduction.API"
Write-Host "网站状态: $($site.State)"

# 检查应用程序池
$pool = Get-WebAppPoolState -Name "LogisticsProductionNet8"
Write-Host "应用程序池: $($pool.Value)"

# 测试 API
Invoke-WebRequest -Uri "http://localhost:8008/health" -UseBasicParsing
```

---

## 📝 快速命令参考

### 部署
```powershell
# IIS 首次部署
.\deploy-to-iis.ps1 -FirstInstall

# IIS 更新
.\deploy-to-iis.ps1

# IIS 热更新
.\deploy-to-iis.ps1 -HotUpdate

# Windows 服务部署
.\deploy.ps1 -Environment Production
```

### 管理
```powershell
# 重启 IIS
Restart-WebAppPool -Name "LogisticsProductionNet8"

# 重启服务
Restart-Service -Name "LogisticsProductionNet8"

# 查看日志
Get-Content "路径\Logs\*.log" -Tail 50
```

### 故障排查
```powershell
# 查看状态
Get-Website -Name "LogisticsProduction.API"
Get-Service -Name "LogisticsProductionNet8"

# 查看事件日志
Get-EventLog -LogName Application -Newest 50

# 测试连接
Test-NetConnection -ComputerName localhost -Port 8008
```

---

## 🎓 更多信息

详细的架构说明和开发流程，请参考：
- **ARCHITECTURE.md** - 项目架构和规范
- **DEVELOPMENT_GUIDE.md** - 新功能开发流程
- **SCAFFOLD_GUIDE.md** - 脚手架使用指南
