# 数据库配置快速开始

## 🚀 开发环境（5分钟配置）

### 使用 User Secrets（推荐）

在项目根目录执行以下命令：

```bash
# 1. 初始化 User Secrets
dotnet user-secrets init

# 2. 设置数据库连接字符串（替换为你的实际密码）
dotnet user-secrets set "ConnectionStrings:91Db" "Data Source=192.168.2.91;Initial Catalog=cwbase0006;User ID=LC00069999;Password=你的密码;Encrypt=True;TrustServerCertificate=True;"

dotnet user-secrets set "ConnectionStrings:MainDb" "Data Source=.;Initial Catalog=LogisticsProduction_DB;Integrated Security=True;TrustServerCertificate=True"

# 3. 验证配置
dotnet user-secrets list

# 4. 运行项目
dotnet run
```

完成！你的敏感信息不会提交到 Git。

---

## 🏭 生产环境（Windows Server / IIS）

### 方法 1：设置系统环境变量

```powershell
# 在 PowerShell 中执行（需要管理员权限）
[System.Environment]::SetEnvironmentVariable(
    "ConnectionStrings__91Db",
    "Data Source=192.168.2.91;Initial Catalog=cwbase0006;User ID=LC00069999;Password=生产密码;Encrypt=True;TrustServerCertificate=True;",
    [System.EnvironmentVariableTarget]::Machine
)

[System.Environment]::SetEnvironmentVariable(
    "ConnectionStrings__MainDb",
    "Data Source=生产服务器;Initial Catalog=LogisticsProduction_DB;User ID=生产用户;Password=生产密码;Encrypt=True;TrustServerCertificate=True;",
    [System.EnvironmentVariableTarget]::Machine
)

# 重启 IIS
iisreset
```

### 方法 2：使用 appsettings.Production.json

1. 编辑服务器上的 `appsettings.Production.json`
2. 填入生产连接字符串
3. 确保此文件不提交到 Git

---

## ⚠️ 重要提示

- `appsettings.json` 现在只包含空字符串模板
- 开发环境必须配置 User Secrets 或 appsettings.Development.json
- 生产环境必须配置环境变量或 appsettings.Production.json
- 详细文档请查看：[DATABASE_CONFIGURATION_GUIDE.md](./DATABASE_CONFIGURATION_GUIDE.md)

---

## 🔍 验证配置

运行项目后，检查日志输出，确认数据库连接成功。

如果遇到问题，请参考完整文档中的"常见问题"部分。
