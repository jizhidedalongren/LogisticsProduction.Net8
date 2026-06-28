# 配置文件备份与管理指南

本文档说明如何安全地保存和管理不上传到 Git 的敏感配置文件。

## 📋 目录

- [为什么不上传到 Git](#为什么不上传到-git)
- [推荐的保存方案](#推荐的保存方案)
- [加密备份方案](#加密备份方案)
- [团队协作方案](#团队协作方案)
- [灾难恢复](#灾难恢复)

---

## 为什么不上传到 Git

敏感配置文件（如 `appsettings.Production.json`）包含：
- 数据库密码
- API 密钥
- 第三方服务凭证

上传到 Git 的风险：
- ❌ 代码库泄露导致生产环境被攻击
- ❌ Git 历史记录永久保存，即使删除也能恢复
- ❌ 团队成员离职后仍可访问

---

## 推荐的保存方案

### 方案 1：企业密码管理器（最推荐）

**适用场景**：团队协作、多人需要访问

**推荐工具**：
- **1Password for Teams** - 易用，支持团队共享
- **Bitwarden** - 开源，可自建服务器
- **LastPass Enterprise** - 功能全面
- **Azure Key Vault** - 云原生，应用可直接读取

**操作步骤**：

1. 在密码管理器中创建"生产环境配置"条目
2. 存储完整的配置文件内容或连接字符串
3. 设置访问权限（仅运维/DevOps 团队）
4. 需要时复制粘贴到服务器

**优点**：
- ✅ 集中管理，易于更新
- ✅ 访问审计日志
- ✅ 权限控制
- ✅ 自动备份

---

### 方案 2：加密文件备份（推荐）

**适用场景**：个人项目、小团队

**操作步骤**：

#### 加密配置文件

```powershell
# 在 scripts 目录执行
.\encrypt-config.ps1

# 输入加密密码（两次）
# 生成 appsettings.Production.encrypted
```

#### 保存加密文件

将 `appsettings.Production.encrypted` 保存到：
- 公司内部文件服务器
- 企业网盘（OneDrive、SharePoint）
- 加密 USB 驱动器
- 个人加密云盘（坚果云、Dropbox）

#### 恢复配置文件

```powershell
# 在 scripts 目录执行
.\decrypt-config.ps1

# 输入解密密码
# 生成 appsettings.Production.json
```

**优点**：
- ✅ 简单易用
- ✅ 不依赖第三方服务
- ✅ 可以版本化（加密文件可以提交到 Git）

**注意**：
- ⚠️ 密码必须妥善保管
- ⚠️ 密码丢失无法恢复

---

### 方案 3：服务器本地保存

**适用场景**：配置很少变更

**操作步骤**：

1. 直接在生产服务器上创建配置文件
2. 设置文件权限，仅管理员可读

```powershell
# 设置文件权限
icacls "C:\inetpub\wwwroot\YourApp\appsettings.Production.json" /inheritance:r /grant:r Administrators:F SYSTEM:F
```

3. 定期备份到安全位置

```powershell
# 备份脚本
$date = Get-Date -Format "yyyyMMdd"
Copy-Item "appsettings.Production.json" "\\backup-server\configs\appsettings.Production.$date.json"
```

**优点**：
- ✅ 最简单
- ✅ 配置不离开服务器

**缺点**：
- ❌ 服务器故障可能丢失配置
- ❌ 不便于团队协作

---

### 方案 4：环境变量（最安全）

**适用场景**：生产环境部署

**操作步骤**：

使用我们提供的脚本设置环境变量：

```powershell
# 编辑 scripts/set-production-env.ps1
# 填入真实配置

# 以管理员身份运行
.\scripts\set-production-env.ps1
```

**保存环境变量配置**：

将 `set-production-env.ps1` 脚本（包含真实密码）保存到：
- 密码管理器（作为安全笔记）
- 加密文件
- 服务器本地（不上传 Git）

**优点**：
- ✅ 最安全，配置在系统级别
- ✅ 不需要配置文件
- ✅ 应用重启自动加载

---

## 加密备份方案

### 使用我们提供的加密工具

#### 1. 加密配置文件

```powershell
cd scripts

# 加密 appsettings.Production.json
.\encrypt-config.ps1

# 或指定文件
.\encrypt-config.ps1 -ConfigFile "..\appsettings.Production.json" -OutputFile "prod-config.encrypted"
```

#### 2. 保存加密文件

**选项 A：提交到 Git（推荐）**

```bash
# 加密文件可以安全地提交到 Git
git add scripts/appsettings.Production.encrypted
git commit -m "Add encrypted production config"
git push
```

**选项 B：保存到网盘**

将 `appsettings.Production.encrypted` 上传到：
- 企业 OneDrive / SharePoint
- 坚果云 / Dropbox
- 公司内部文件服务器

#### 3. 解密恢复

```powershell
cd scripts

# 解密配置文件
.\decrypt-config.ps1

# 或指定文件
.\decrypt-config.ps1 -EncryptedFile "prod-config.encrypted" -OutputFile "..\appsettings.Production.json"
```

### 密码管理

**密码保存位置**：
1. 密码管理器（1Password、Bitwarden）
2. 团队文档（加密的 Word/PDF）
3. 公司保险柜（物理存储）

**密码轮换**：
- 每季度更换一次加密密码
- 重新加密配置文件
- 通知团队成员

---

## 团队协作方案

### 小团队（2-5人）

**推荐方案**：加密文件 + 密码管理器

1. 使用 `encrypt-config.ps1` 加密配置
2. 将加密文件提交到 Git
3. 密码保存在 1Password 团队保险库
4. 团队成员需要时自行解密

### 中型团队（5-20人）

**推荐方案**：企业密码管理器

1. 使用 Bitwarden / 1Password Teams
2. 创建"生产环境"保险库
3. 存储完整配置文件内容
4. 设置访问权限（仅运维团队）

### 大型团队（20+人）

**推荐方案**：云密钥管理服务

1. 使用 Azure Key Vault / AWS Secrets Manager
2. 应用程序直接从云端读取配置
3. 配置更新无需重启应用
4. 完整的审计日志

**集成示例**（Azure Key Vault）：

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);

// 添加 Azure Key Vault
var keyVaultUrl = builder.Configuration["KeyVaultUrl"];
if (!string.IsNullOrEmpty(keyVaultUrl))
{
    builder.Configuration.AddAzureKeyVault(
        new Uri(keyVaultUrl),
        new DefaultAzureCredential());
}
```

---

## 灾难恢复

### 配置丢失怎么办？

**场景 1：服务器故障，配置文件丢失**

恢复步骤：
1. 从密码管理器获取配置
2. 或从加密备份解密恢复
3. 或从备份服务器复制

**场景 2：加密密码忘记**

预防措施：
- 密码保存在多个位置
- 团队至少 2 人知道密码
- 定期测试解密流程

**场景 3：团队成员离职**

安全措施：
1. 立即更换所有密码
2. 重新加密配置文件
3. 撤销密码管理器访问权限
4. 轮换数据库密码

---

## 最佳实践

### ✅ 应该做的

1. **多重备份**
   - 至少 2 个不同位置保存配置
   - 定期测试恢复流程

2. **访问控制**
   - 仅必要人员可访问生产配置
   - 使用密码管理器的权限功能

3. **定期审计**
   - 每季度检查谁有访问权限
   - 审查密码管理器日志

4. **文档化**
   - 记录配置保存位置
   - 记录恢复步骤

### ❌ 不应该做的

1. **不要**将明文配置发送到：
   - 邮件
   - 即时通讯工具（微信、钉钉）
   - 未加密的网盘

2. **不要**在多个地方保存明文配置
   - 容易忘记更新
   - 增加泄露风险

3. **不要**使用弱密码加密
   - 至少 16 位
   - 包含大小写字母、数字、符号

---

## 配置文件清单

需要备份的文件：

- [ ] `appsettings.Production.json`
- [ ] `scripts/set-production-env.ps1`（如果包含真实密码）
- [ ] `web.config`（如果包含敏感信息）
- [ ] SSL 证书和私钥
- [ ] 数据库连接字符串
- [ ] API 密钥和令牌

---

## 相关文档

- [数据库配置指南](./DATABASE_CONFIGURATION_GUIDE.md)
- [快速开始](./QUICK_START_DATABASE_CONFIG.md)
- [脚本使用说明](../scripts/README.md)

---

## 快速参考

```powershell
# 加密配置
cd scripts
.\encrypt-config.ps1

# 解密配置
.\decrypt-config.ps1

# 查看环境变量
.\get-production-env.ps1

# 设置环境变量
.\set-production-env.ps1
```

---

**最后更新**: 2026-03-28
