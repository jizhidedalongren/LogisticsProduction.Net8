# 生产环境配置脚本

本目录包含用于管理生产环境变量的 PowerShell 脚本。

## 📁 脚本列表

| 脚本 | 用途 | 需要管理员权限 |
|------|------|---------------|
| `set-development-env.ps1` | 配置开发环境（User Secrets） | ❌ 否 |
| `set-production-env.ps1` | 设置生产环境变量 | ✅ 是 |
| `get-production-env.ps1` | 查看当前环境变量 | ❌ 否 |
| `remove-production-env.ps1` | 删除环境变量 | ✅ 是 |
| `restart-iis-apppool.ps1` | 重启 IIS 应用程序池 | ✅ 是 |
| `restart-iis-full.ps1` | 完全重启 IIS | ✅ 是 |
| `encrypt-config.ps1` | 加密配置文件 | ❌ 否 |
| `decrypt-config.ps1` | 解密配置文件 | ❌ 否 |
| `backup-all-configs.ps1` | 一键备份所有配置 | ❌ 否 |

---

## 🚀 使用方法

### 1. 设置生产环境变量

**步骤 1：编辑配置**

打开 `set-production-env.ps1`，修改配置区域：

```powershell
$config = @{
    "ConnectionStrings__91Db" = "Data Source=192.168.2.91;Initial Catalog=cwbase0006;User ID=LC00069999;Password=你的生产密码;Encrypt=True;TrustServerCertificate=True;"
    "ConnectionStrings__MainDb" = "Data Source=生产服务器;Initial Catalog=LogisticsProduction_DB;User ID=生产用户;Password=生产密码;Encrypt=True;TrustServerCertificate=True;"
    "ASPNETCORE_ENVIRONMENT" = "Production"
}
```

**步骤 2：以管理员身份运行**

```powershell
# 右键点击 PowerShell → 以管理员身份运行
cd C:\path\to\project\scripts
.\set-production-env.ps1
```

**步骤 3：确认并执行**

脚本会显示将要设置的变量（密码会被隐藏），输入 `Y` 确认。

---

### 2. 查看当前环境变量

```powershell
# 不需要管理员权限
.\get-production-env.ps1
```

输出示例：
```
✅ ConnectionStrings__91Db
   Data Source=192.168.2.91;Initial Catalog=cwbase0006;User ID=LC00069999;Password=****;...

✅ ASPNETCORE_ENVIRONMENT
   Production

❌ ExternalServices__PrintServiceUrl
   (未设置)
```

---

### 3. 删除环境变量

```powershell
# 以管理员身份运行
.\remove-production-env.ps1
```

---

## ⚙️ 执行策略问题

如果遇到"无法加载，因为在此系统上禁止运行脚本"错误：

```powershell
# 临时允许执行（当前会话）
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 或永久允许（需要管理员权限）
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

---

## 🔒 安全建议

1. **不要提交包含真实密码的脚本到 Git**
   - 在服务器上直接编辑脚本
   - 或使用参数化方式传递密码

2. **限制脚本访问权限**
   ```powershell
   # 设置文件权限，仅管理员可读写
   icacls set-production-env.ps1 /inheritance:r /grant:r Administrators:F
   ```

3. **使用加密存储**
   - 考虑使用 Windows Credential Manager
   - 或 Azure Key Vault 等密钥管理服务

---

## 🔄 自动化部署

### 在部署脚本中集成

编辑 `deploy.ps1` 或 `deploy-to-iis.ps1`，添加：

```powershell
# 设置环境变量
Write-Host "设置生产环境变量..." -ForegroundColor Cyan
.\scripts\set-production-env.ps1 -NonInteractive

# 部署应用
# ... 你的部署代码 ...

# 重启 IIS
iisreset
```

### 使用参数化脚本

创建 `set-production-env-parameterized.ps1`：

```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$Db91Password,
    
    [Parameter(Mandatory=$true)]
    [string]$MainDbPassword
)

$config = @{
    "ConnectionStrings__91Db" = "Data Source=192.168.2.91;...;Password=$Db91Password;..."
    "ConnectionStrings__MainDb" = "Data Source=...;Password=$MainDbPassword;..."
}

# ... 设置逻辑 ...
```

使用：
```powershell
.\set-production-env-parameterized.ps1 -Db91Password "密码1" -MainDbPassword "密码2"
```

---

## 📝 相关文档

- [数据库配置完整指南](../docs/DATABASE_CONFIGURATION_GUIDE.md)
- [快速开始](../docs/QUICK_START_DATABASE_CONFIG.md)
- [部署指南](../DEPLOYMENT_WINDOWS.md)

---

**最后更新**: 2026-03-28


---

## 🖥️ 开发环境快速配置

### 新开发者入职配置

```powershell
# 1. 克隆代码仓库
git clone https://your-repo.git
cd LogisticsProduction.Net8

# 2. 运行开发环境配置向导
.\scripts\set-development-env.ps1

# 3. 按照提示输入数据库连接信息
# 4. 运行项目
dotnet run
```

### 配置向导功能

`set-development-env.ps1` 提供交互式配置：

- ✅ 自动检查 .NET SDK
- ✅ 选择配置方式（User Secrets 或 appsettings.Development.json）
- ✅ 交互式输入数据库连接信息
- ✅ 可选配置外部服务 URL
- ✅ 显示配置摘要供确认
- ✅ 自动验证配置结果
- ✅ 密码输入隐藏显示

### 配置方式对比

| 方式 | 优点 | 缺点 | 适用场景 |
|------|------|------|---------|
| User Secrets | 不会提交到 Git，每人独立配置 | 需要每个开发者单独配置 | 个人开发环境 |
| appsettings.Development.json | 团队共享，一次配置 | 会提交到 Git，不能包含真实密码 | 团队开发环境 |
| 两者都配置 | 灵活性最高 | 配置较复杂 | 混合场景 |

---

## 🏭 生产环境配置

### 使用环境变量（推荐）

