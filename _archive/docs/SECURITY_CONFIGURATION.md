# 安全配置指南

## 概述

本文档说明项目中的敏感信息管理和配置方法。

## 敏感文件清单

以下文件包含敏感信息，已添加到 `.gitignore`，**不应提交到版本控制系统**：

### 1. 配置文件
- `appsettings.Development.json` - 开发环境配置（包含数据库连接字符串）
- `appsettings.Production.json` - 生产环境配置
- `appsettings.Staging.json` - 预发布环境配置
- `web.config` - IIS 部署配置

### 2. 构建输出
- `publish/` - 发布输出目录
- `bin/` - 编译输出
- `obj/` - 中间编译文件

### 3. IDE 配置
- `.idea/` - JetBrains Rider 配置
- `.vs/` - Visual Studio 配置
- `.vscode/` - VS Code 配置

### 4. 生成文件
- `Generated/` - 实体生成器输出

### 5. 日志文件
- `Logs/` - 应用程序日志（可能包含敏感业务数据）

## 配置步骤

### 首次设置

1. **复制配置模板**
   ```bash
   cp appsettings.Development.json.example appsettings.Development.json
   cp appsettings.Production.json.example appsettings.Production.json
   ```

2. **编辑配置文件**
   
   编辑 `appsettings.Development.json`，填入实际的数据库连接信息：
   ```json
   {
     "ConnectionStrings": {
       "91Db": "Data Source=YOUR_SERVER;Initial Catalog=YOUR_DATABASE;User ID=YOUR_USER;Password=YOUR_PASSWORD;Encrypt=True;TrustServerCertificate=True;",
       "MainDb": "Data Source=.;Initial Catalog=LogisticsProduction_DB;Integrated Security=True;TrustServerCertificate=True"
     }
   }
   ```

3. **验证配置**
   
   运行项目确保配置正确：
   ```bash
   dotnet run
   ```

## 敏感信息保护最佳实践

### 1. 数据库连接字符串

**不要做：**
- ❌ 将真实的数据库密码提交到 Git
- ❌ 在代码中硬编码连接字符串
- ❌ 在日志中输出完整的连接字符串

**应该做：**
- ✅ 使用配置文件管理连接字符串
- ✅ 在日志中屏蔽密码（参考 `Tools/GenerateEntitiesProgram.cs` 中的 `MaskConnectionString` 方法）
- ✅ 生产环境使用环境变量或密钥管理服务

### 2. API 密钥和令牌

如果项目需要使用外部 API：
- 使用 User Secrets（开发环境）
- 使用 Azure Key Vault 或类似服务（生产环境）

### 3. 日志安全

- 不要在日志中记录密码、令牌等敏感信息
- 定期清理旧日志文件
- 确保日志文件权限设置正确

## 环境变量配置（推荐用于生产环境）

### Windows 服务器

```powershell
# 设置环境变量
[System.Environment]::SetEnvironmentVariable("ConnectionStrings__MainDb", "YOUR_CONNECTION_STRING", "Machine")
```

### Linux 服务器

```bash
# 在 /etc/environment 或 systemd 服务文件中设置
export ConnectionStrings__MainDb="YOUR_CONNECTION_STRING"
```

### Docker

```yaml
# docker-compose.yml
environment:
  - ConnectionStrings__MainDb=YOUR_CONNECTION_STRING
```

## 团队协作

### 新成员加入

1. 提供配置模板文件（`.example` 文件）
2. 通过安全渠道（如密码管理器）共享开发环境凭据
3. 确保新成员理解不要提交敏感配置

### 配置更新

当需要添加新的配置项时：
1. 更新 `.example` 模板文件
2. 通知团队成员更新本地配置
3. 更新本文档

## 检查清单

在提交代码前，请确认：

- [ ] 没有提交 `appsettings.Development.json`
- [ ] 没有提交 `appsettings.Production.json`
- [ ] 没有提交 `publish/` 目录
- [ ] 没有提交 `.idea/` 或 `.vs/` 目录
- [ ] 没有在代码中硬编码密码或密钥
- [ ] 已更新 `.example` 配置模板（如有新配置项）

## 验证命令

检查是否有敏感文件被暂存：

```bash
# 查看暂存的文件
git status

# 检查是否有敏感文件
git ls-files | Select-String -Pattern "(appsettings\.(Development|Production)|web\.config|publish/)"
```

## 紧急情况处理

### 如果不小心提交了敏感信息

1. **立即更改泄露的密码/密钥**
2. **从 Git 历史中移除敏感信息**
   ```bash
   # 使用 git filter-branch 或 BFG Repo-Cleaner
   # 警告：这会重写 Git 历史
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch appsettings.Development.json" \
     --prune-empty --tag-name-filter cat -- --all
   ```
3. **强制推送（需要团队协调）**
   ```bash
   git push origin --force --all
   ```
4. **通知团队成员重新克隆仓库**

## 相关文档

- [数据库配置指南](DATABASE_CONFIGURATION_GUIDE.md)
- [部署指南](DEPLOYMENT_WINDOWS.md)
- [开发指南](DEVELOPMENT_GUIDE.md)

## 联系方式

如有安全相关问题，请联系项目负责人。
