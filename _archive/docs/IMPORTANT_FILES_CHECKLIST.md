# 重要文件备份清单

本文档列出所有需要单独保存、不上传到 Git 的重要文件。

## 📋 必须备份的文件

### 🔴 高优先级（包含敏感信息）

| 文件 | 位置 | 说明 | 备份方式 |
|------|------|------|---------|
| `appsettings.Production.json` | 项目根目录 | 生产环境配置（数据库密码、API密钥） | 加密备份 |
| `web.config` | 项目根目录 | IIS 部署配置（可能包含环境变量） | 加密备份 |
| `scripts/set-production-env.ps1` | scripts/ | 环境变量设置脚本（如果包含真实密码） | 加密备份 |
| User Secrets | `%APPDATA%\Microsoft\UserSecrets\` | 开发环境密钥 | 导出备份 |

### 🟡 中优先级（重要但不敏感）

| 文件 | 位置 | 说明 | 备份方式 |
|------|------|------|---------|
| `appsettings.Development.json` | 项目根目录 | 开发环境配置 | Git 提交 |
| `nlog.config` | 项目根目录 | 日志配置 | Git 提交 |
| `.gitignore` | 项目根目录 | Git 忽略规则 | Git 提交 |
| `LogisticsProduction.Net8.csproj` | 项目根目录 | 项目配置 | Git 提交 |

### 🟢 低优先级（可选备份）

| 文件 | 位置 | 说明 | 备份方式 |
|------|------|------|---------|
| `scripts/deploy.ps1` | scripts/ | 部署脚本 | Git 提交 |
| `scripts/deploy-to-iis.ps1` | scripts/ | IIS 部署脚本 | Git 提交 |
| 文档文件 | docs/ | 项目文档 | Git 提交 |

---

## 📂 按目录分类

### 项目根目录 `/`

**需要备份（不在 Git）：**
```
appsettings.Production.json    ← 生产配置（加密备份）
web.config                      ← IIS 配置（加密备份）
```

**已在 Git（无需额外备份）：**
```
appsettings.json
appsettings.Development.json
nlog.config
LogisticsProduction.Net8.csproj
LogisticsProduction.Net8.sln
scripts/deploy.ps1
scripts/deploy-to-iis.ps1
```

---

### scripts/ 目录

**需要备份（不在 Git）：**
```
set-production-env.ps1          ← 如果包含真实密码（加密备份）
appsettings.Production.encrypted ← 加密的配置文件（可选提交到 Git）
```

**已在 Git（无需额外备份）：**
```
encrypt-config.ps1
decrypt-config.ps1
get-production-env.ps1
remove-production-env.ps1
README.md
```

---

### 发布目录 `publish/` 或 `bin/Release/net8.0/publish/`

**需要备份（部署后）：**
```
appsettings.Production.json    ← 服务器上的实际配置
web.config                      ← 服务器上的实际配置
```

**注意**：这些是部署到服务器后的文件，应该在服务器上单独备份。

---

### User Secrets 目录

**Windows 位置**：
```
%APPDATA%\Microsoft\UserSecrets\logistics-production-net8-secrets\secrets.json
```

**完整路径示例**：
```
C:\Users\你的用户名\AppData\Roaming\Microsoft\UserSecrets\logistics-production-net8-secrets\secrets.json
```

**备份方式**：
```powershell
# 导出 User Secrets
dotnet user-secrets list > user-secrets-backup.txt

# 或直接复制 secrets.json 文件
```

---

## 🔐 SSL 证书和密钥（如果使用）

如果项目使用 HTTPS 证书：

| 文件类型 | 常见位置 | 说明 |
|---------|---------|------|
| `*.pfx` | 项目根目录或 certs/ | SSL 证书（包含私钥） |
| `*.cer` / `*.crt` | 项目根目录或 certs/ | 公钥证书 |
| `*.key` | 项目根目录或 certs/ | 私钥文件 |

**备份方式**：加密备份，妥善保管密码

---

## 📝 数据库相关

### 数据库脚本

| 文件 | 位置 | 说明 |
|------|------|------|
| `create_table.sql` | Database/ | 建表脚本 |
| 迁移脚本 | Database/migrations/ | 数据库版本迁移 |

**备份方式**：Git 提交（不包含敏感数据）

### 数据库备份

**不在项目中，但需要定期备份**：
- 生产数据库备份（.bak 文件）
- 测试数据库备份

---

## 🚀 快速备份指南

### 方法 1：使用加密脚本（推荐）

```powershell
# 1. 进入 scripts 目录
cd scripts

# 2. 加密生产配置
.\encrypt-config.ps1 -ConfigFile "..\appsettings.Production.json" -OutputFile "appsettings.Production.encrypted"

# 3. 加密 web.config（如果存在）
.\encrypt-config.ps1 -ConfigFile "..\web.config" -OutputFile "web.config.encrypted"

# 4. 加密环境变量脚本（如果包含密码）
.\encrypt-config.ps1 -ConfigFile "set-production-env.ps1" -OutputFile "set-production-env.encrypted"

# 5. 将加密文件保存到安全位置
# - 提交到 Git（加密文件是安全的）
# - 或上传到企业网盘
```

### 方法 2：导出 User Secrets

```powershell
# 导出到文本文件
dotnet user-secrets list > user-secrets-backup.txt

# 加密备份
.\scripts\encrypt-config.ps1 -ConfigFile "user-secrets-backup.txt" -OutputFile "user-secrets.encrypted"

# 删除明文文件
Remove-Item user-secrets-backup.txt
```

### 方法 3：完整备份脚本

创建 `scripts/backup-all-configs.ps1`：

```powershell
# 备份所有敏感配置
$date = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = "config-backup-$date"

New-Item -ItemType Directory -Path $backupDir

# 备份文件列表
$files = @(
    "..\appsettings.Production.json",
    "..\web.config",
    "set-production-env.ps1"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $fileName = Split-Path $file -Leaf
        .\encrypt-config.ps1 -ConfigFile $file -OutputFile "$backupDir\$fileName.encrypted"
    }
}

# 导出 User Secrets
dotnet user-secrets list > "$backupDir\user-secrets.txt"
.\encrypt-config.ps1 -ConfigFile "$backupDir\user-secrets.txt" -OutputFile "$backupDir\user-secrets.encrypted"
Remove-Item "$backupDir\user-secrets.txt"

Write-Host "✅ 备份完成：$backupDir" -ForegroundColor Green
```

---

## 📍 备份存储位置建议

### 选项 1：企业密码管理器
- 1Password / Bitwarden / LastPass
- 存储为"安全笔记"或"文档"
- 设置访问权限

### 选项 2：企业网盘
- OneDrive for Business
- SharePoint
- 公司内部文件服务器
- **注意**：必须加密后再上传

### 选项 3：加密 USB
- 使用 BitLocker 加密的 USB 驱动器
- 存放在公司保险柜
- 定期更新

### 选项 4：Git 仓库（仅加密文件）
```bash
# 加密文件可以安全地提交到 Git
git add scripts/*.encrypted
git commit -m "Add encrypted config backups"
git push
```

---

## ⚠️ 安全注意事项

### ✅ 应该做的

1. **定期备份**
   - 每次修改配置后立即备份
   - 每月验证备份可用性

2. **多重备份**
   - 至少 2 个不同位置
   - 使用不同的备份方式

3. **访问控制**
   - 限制备份文件访问权限
   - 记录谁访问了备份

4. **加密存储**
   - 所有敏感文件必须加密
   - 使用强密码（16位以上）

### ❌ 不应该做的

1. **不要**将明文配置文件：
   - 发送到邮件
   - 上传到公共网盘
   - 保存在未加密的 USB

2. **不要**在多个地方保存明文
   - 容易忘记更新
   - 增加泄露风险

3. **不要**使用弱密码
   - 避免使用 "123456"、"password"
   - 不要使用公司名称或项目名称

---

## 🔄 恢复流程

### 场景 1：新服务器部署

```powershell
# 1. 克隆代码仓库
git clone https://your-repo.git
cd LogisticsProduction.Net8

# 2. 解密配置文件
cd scripts
.\decrypt-config.ps1 -EncryptedFile "appsettings.Production.encrypted" -OutputFile "..\appsettings.Production.json"

# 3. 设置环境变量
.\set-production-env.ps1

# 4. 发布部署
cd ..
dotnet publish -c Release
```

### 场景 2：开发环境配置

```powershell
# 1. 克隆代码仓库
git clone https://your-repo.git
cd LogisticsProduction.Net8

# 2. 设置 User Secrets
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:91Db" "你的连接字符串"
dotnet user-secrets set "ConnectionStrings:MainDb" "你的连接字符串"

# 3. 运行项目
dotnet run
```

### 场景 3：灾难恢复

```powershell
# 1. 从备份位置获取加密文件
# 2. 解密所有配置
cd scripts
.\decrypt-config.ps1 -EncryptedFile "backup\appsettings.Production.encrypted"
.\decrypt-config.ps1 -EncryptedFile "backup\web.config.encrypted"

# 3. 恢复到服务器
# 4. 重启应用
```

---

## 📊 备份检查清单

部署前检查：

- [ ] `appsettings.Production.json` 已加密备份
- [ ] `web.config` 已加密备份（如果存在）
- [ ] `set-production-env.ps1` 已加密备份（如果包含密码）
- [ ] User Secrets 已导出备份
- [ ] SSL 证书已备份（如果使用）
- [ ] 加密密码已保存在密码管理器
- [ ] 备份文件已上传到安全位置
- [ ] 团队成员知道如何恢复配置
- [ ] 已测试恢复流程

---

## 📞 紧急联系

如果配置丢失或密码忘记：

1. 联系团队负责人
2. 检查密码管理器
3. 检查备份服务器
4. 查看团队文档

---

## 相关文档

- [配置备份指南](./CONFIG_BACKUP_GUIDE.md)
- [数据库配置指南](./DATABASE_CONFIGURATION_GUIDE.md)
- [快速开始](./QUICK_START_DATABASE_CONFIG.md)
- [脚本使用说明](../scripts/README.md)

---

**最后更新**: 2026-03-28
