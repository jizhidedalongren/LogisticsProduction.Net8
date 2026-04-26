# 📚 文档索引

## ⚡ 快速导航

| 我想... | 查看文档 | 使用脚本 |
|---------|---------|---------|
| 了解项目 | README.md | - |
| 快速查命令 | QUICK_REFERENCE.md ⭐ | - |
| 开发新功能 | DEVELOPMENT_GUIDE.md | `.\scaffold-cn.ps1` |
| 部署到 IIS | DEPLOYMENT_WINDOWS.md | `.\deploy-to-iis.ps1 -FirstInstall` |
| 部署到 Windows 服务 | DEPLOYMENT_WINDOWS.md | `.\deploy.ps1 -Environment Production` |
| 更新 IIS 应用 | DEPLOYMENT_WINDOWS.md | `.\deploy-to-iis.ps1` |
| 更新 Windows 服务 | DEPLOYMENT_WINDOWS.md | `.\deploy.ps1 -Environment Production` |
| 了解架构规范 | ARCHITECTURE.md | - |
| 使用脚手架 | SCAFFOLD_GUIDE.md | `.\scaffold-cn.ps1` |
| 生成实体类 | docs/entity-generator/README.md ⭐ | 使用 API 接口 |

---

## 🚀 快速开始

新手入门，从这里开始：
- **README.md** - 项目概览、快速开始、常用命令
- **QUICK_REFERENCE.md** - 快速参考卡片（常用命令速查）⭐

## 📖 核心文档

### 开发相关
- **ARCHITECTURE.md** - 项目架构、层间依赖规则、代码规范
- **DEVELOPMENT_GUIDE.md** - 新功能开发完整流程（含示例）
- **SCAFFOLD_GUIDE.md** - 脚手架工具使用指南
- **docs/entity-generator/README.md** - SqlSugar 实体生成器完整指南 ⭐

### 部署相关
- **DEPLOYMENT_WINDOWS.md** - Windows 部署完整指南（IIS、Windows 服务、Kestrel）
- **PORT_CONFIG_GUIDE.md** - 端口配置完整指南（开发 + 生产）⭐

## 🛠️ 脚本工具

### 脚手架生成
- `scaffold-cn.ps1` - 中文交互式脚手架生成器（推荐）⭐
- `scaffold.ps1` - 英文交互式脚手架生成器
- `scaffold-feature.ps1` - 命令行脚手架生成器（核心脚本）
- `create_scaffold.py` - Python 辅助脚本（生成 scaffold-cn.ps1）

### 部署脚本
- `deploy.ps1` - 通用部署脚本（支持 IIS 和 Windows 服务）⭐
- `deploy-to-iis.ps1` - IIS 专用部署脚本（首次安装 + 更新 + 热更新）⭐

### 工具脚本
- `fix-utf8-bom.ps1` - 修复 PowerShell 脚本编码为 UTF-8 BOM
- `generate-entities.ps1` - SqlSugar 实体类生成工具

**注意：** 所有包含中文的 PowerShell 脚本均使用 UTF-8 BOM 编码，确保中文正确显示。如遇到中文乱码，运行 `.\fix-utf8-bom.ps1` 修复。

## 📂 项目结构

```
LogisticsProduction.Net8/
├── Domain/              # 领域层（实体、接口、业务异常）
│   ├── Entities/        # 实体类
│   ├── Interfaces/      # 仓储接口
│   └── Exceptions/      # 业务异常
│
├── Application/         # 应用层（业务逻辑、DTO、Service）
│   ├── Commands/        # 写操作（Command）
│   ├── Queries/         # 读操作（Query）
│   └── Dtos/            # 数据传输对象
│
├── Infrastructure/      # 基础设施层（数据访问、外部服务）
│   ├── Persistence/     # 数据访问（Repository）
│   ├── Configuration/   # 配置服务
│   ├── ExternalServices/# 外部服务客户端
│   └── Http/            # HTTP 客户端
│
├── Controllers/         # 控制器层（API 端点）
│   ├── Command/         # 写操作控制器
│   └── Query/           # 读操作控制器
│
├── CrossCutting/        # 横切关注点
│   ├── Filters/         # 过滤器（防重等）
│   └── Middleware/      # 中间件（异常处理、认证等）
│
└── Database/            # 数据库脚本
```

## 🎯 使用场景

### 我想开发新功能
1. 阅读 **DEVELOPMENT_GUIDE.md** 了解开发流程
2. 运行 `.\scaffold-cn.ps1` 生成代码骨架
3. 参考 **ARCHITECTURE.md** 遵循架构规范

### 我想部署到生产环境
1. 阅读 **DEPLOYMENT_WINDOWS.md** 选择部署方式
2. IIS 部署：运行 `.\deploy-to-iis.ps1 -FirstInstall`
3. Windows 服务：运行 `.\deploy.ps1 -Environment Production`

### 我想更新已部署的应用
1. IIS 更新：`.\deploy-to-iis.ps1`
2. IIS 热更新：`.\deploy-to-iis.ps1 -HotUpdate`
3. Windows 服务：`.\deploy.ps1 -Environment Production`

### 我想了解项目架构
1. 阅读 **ARCHITECTURE.md** 了解层间依赖规则
2. 阅读 **README.md** 了解项目结构
3. 查看现有代码示例（如 LogisticsContainer 功能）

## 📝 文档维护

### 文档更新原则
- 保持文档简洁实用
- 避免重复内容
- 及时更新过时信息
- 添加实际示例

### 当前文档状态
- ✅ 核心文档已精简
- ✅ 冗余文档已清理
- ✅ 脚本工具已整合
- ✅ 使用说明已完善

## 🔗 外部资源

- .NET 8 文档：https://learn.microsoft.com/dotnet/core/whats-new/dotnet-8
- ASP.NET Core 文档：https://learn.microsoft.com/aspnet/core
- SqlSugar 文档：https://www.donet5.com/Home/Doc
- IIS 管理：https://learn.microsoft.com/iis

## 💡 提示

- 所有 PowerShell 脚本需要以管理员权限运行
- 如遇到"无法加载文件"错误，运行：`Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process`
- 部署前请先在测试环境验证
- 定期备份生产配置文件
- 遵循项目架构规范开发新功能

## 🔧 常见配置

### 修改端口
- **开发环境：** 编辑 `appsettings.Development.json` 或使用 `dotnet run --urls "http://localhost:8080"`
- **IIS 部署：** `.\deploy-to-iis.ps1 -FirstInstall -Port 9000` 或使用 IIS 管理器修改绑定
- **Windows 服务：** 编辑 `appsettings.Production.json` 中的 Kestrel 配置

### 执行策略
```powershell
# 临时允许脚本执行（推荐）
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# 永久允许当前用户
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
