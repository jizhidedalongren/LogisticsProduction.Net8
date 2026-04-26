# 物流生产管理系统 API (.NET 8)

## 📖 文档导航

- 📚 **[文档索引](DOCS_INDEX.md)** - 完整文档导航
- ⚡ **[快速参考](QUICK_REFERENCE.md)** - 常用命令速查卡片
- 🔌 **[端口配置](PORT_CONFIG_GUIDE.md)** - 端口配置完整指南
- 🏗️ **[架构规范](ARCHITECTURE.md)** - 项目架构和开发规范
- 📝 **[开发指南](DEVELOPMENT_GUIDE.md)** - 新功能开发流程
- 🚀 **[部署指南](DEPLOYMENT_WINDOWS.md)** - Windows 部署完整说明
- 🛠️ **[脚手架指南](SCAFFOLD_GUIDE.md)** - 脚手架工具使用
- 🔄 **[实体生成器指南](docs/entity-generator/README.md)** - SqlSugar 实体类生成 ⭐

---

## 📁 项目结构

```
LogisticsProduction.Net8/
├── Domain/              # 领域层（实体、接口、业务异常）
├── Application/         # 应用层（业务逻辑、DTO、Service）
├── Infrastructure/      # 基础设施层（数据访问、外部服务）
├── Controllers/         # 控制器层（API 端点）
├── CrossCutting/        # 横切关注点（中间件、过滤器）
└── Database/            # 数据库脚本
```

## 🚀 快速开始

### 前置要求
- .NET 8 SDK
- SQL Server 2016+
- PowerShell 5.1+（Windows 自带）

### 开发环境

```bash
# 1. 克隆项目
git clone <repository-url>
cd LogisticsProduction.Net8

# 2. 还原依赖
dotnet restore

# 3. 配置数据库连接
# 编辑 appsettings.Development.json

# 4. 运行项目
dotnet run

# 5. 访问 Swagger
http://localhost:5000/swagger
```

### 运行 PowerShell 脚本

如果遇到"无法加载文件"错误，先执行：

```powershell
# 临时允许脚本执行（仅当前会话）
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# 然后运行脚本
.\scaffold-cn.ps1
```

### 生产部署

#### IIS 部署（推荐）
```powershell
# 1. 发布项目
dotnet publish -c Release -o ./publish

# 2. 在服务器上运行（管理员权限）
# 首次安装（默认端口 8008）
.\deploy-to-iis.ps1 -FirstInstall

# 首次安装（自定义端口）
.\deploy-to-iis.ps1 -FirstInstall -Port 9000

# 3. 日常更新
.\deploy-to-iis.ps1

# 热更新（停机时间 2-5 秒）
.\deploy-to-iis.ps1 -HotUpdate
```

#### Windows 服务部署
```powershell
# 1. 发布项目
dotnet publish -c Release -o ./publish

# 2. 打包并传输到服务器
Compress-Archive -Path .\publish\* -DestinationPath LogisticsProduction.zip

# 3. 在服务器上解压并部署（管理员权限）
.\deploy.ps1 -Environment Production

# 4. 日常更新（使用相同命令）
.\deploy.ps1 -Environment Production
```

详细部署说明参考 `DEPLOYMENT_WINDOWS.md`

## 📖 文档

- **ARCHITECTURE.md** - 项目架构和开发规范
- **DEVELOPMENT_GUIDE.md** - 新功能开发流程
- **DEPLOYMENT_WINDOWS.md** - Windows 部署完整指南

## 🛠️ 开发工具

### 实体类生成器（SqlSugar）

从数据库表自动生成实体类，支持 SqlSugar 特性标注。

#### 方式 A：使用 API 接口（最推荐 ⭐）

**优点：** 生成到临时文件夹，不会覆盖现有文件，可以预览后再复制。支持直接传入数据库连接字符串。

1. 启动项目：`dotnet run`
2. 访问 Swagger：`http://localhost:5000/swagger`
3. 找到 `EntityGenerator` 分组
4. 使用接口生成实体类

**常用接口（全部为 POST 方式）：**

```bash
# 生成单个表
POST /dev/entity-generator/generate
Body: { "tableName": "Product", "connectionString": "你的连接字符串" }

# 批量生成
POST /dev/entity-generator/generate-batch
Body: { 
  "tableNames": ["Product", "Order"], 
  "connectionString": "你的连接字符串",
  "withBase": true 
}
```

生成的文件位于 `Generated/Entities/`，手动复制到 `Domain/Entities/`。

详细说明：**[docs/entity-generator/README.md](docs/entity-generator/README.md)** ⭐

#### 方式 B：在代码中使用

```csharp
using LogisticsProduction.Net8.Tools;

// 创建生成器
var connectionString = Configuration.GetConnectionString("MainDb");
var generator = new EntityGenerator(connectionString!, "Domain/Entities");

// 生成所有表
generator.GenerateAllEntities();

// 生成指定表
generator.GenerateEntity("Product");

// 生成指定表（继承 BaseEntity，自动跳过审计字段）
generator.GenerateEntityWithBase("Product");
```

#### 方式 B：在代码中使用

```csharp
using LogisticsProduction.Net8.Tools;

// 创建生成器
var connectionString = Configuration.GetConnectionString("MainDb");
var generator = new EntityGenerator(connectionString!, "Domain/Entities");

// 生成所有表
generator.GenerateAllEntities();

// 生成指定表
generator.GenerateEntity("Product");

// 生成指定表（继承 BaseEntity，自动跳过审计字段）
generator.GenerateEntityWithBase("Product");
```

详细说明：**[HOW_TO_USE_ENTITY_GENERATOR.md](HOW_TO_USE_ENTITY_GENERATOR.md)**

#### 方式 C：使用 PowerShell 脚本

```powershell
# 交互式生成
.\generate-entities.ps1

# 生成所有表
.\generate-entities.ps1 -All

# 生成指定表
.\generate-entities.ps1 -Table "Product"

# 生成指定表（继承 BaseEntity）
.\generate-entities.ps1 -Table "Product" -WithBase
```

#### 配置数据库连接

在 `appsettings.json` 中配置数据库连接：

```json
{
  "ConnectionStrings": {
    "MainDb": "Data Source=localhost;Initial Catalog=LogisticsDB;User ID=sa;Password=YourPassword;TrustServerCertificate=True"
  }
}
```

#### 生成示例

假设有以下数据库表：

```sql
CREATE TABLE Product (
    ProductId INT PRIMARY KEY IDENTITY(1,1),
    ProductCode NVARCHAR(50) NOT NULL,
    ProductName NVARCHAR(100) NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    Stock INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    CreateTime DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateTime DATETIME NULL,
    CreateUser NVARCHAR(50) NULL,
    UpdateUser NVARCHAR(50) NULL
);
```

使用 `GenerateEntityWithBase("Product")` 生成的实体类：

```csharp
using SqlSugar;

namespace LogisticsProduction.Net8.Domain.Entities;

/// <summary>
/// Product 实体类
/// </summary>
[SugarTable("Product")]
public class Product : BaseEntity
{
    /// <summary>
    /// 产品ID
    /// </summary>
    [SugarColumn(IsPrimaryKey = true, IsIdentity = true)]
    public int ProductId { get; set; }

    /// <summary>
    /// 产品编码
    /// </summary>
    [SugarColumn(Length = 50)]
    public string ProductCode { get; set; } = string.Empty;

    /// <summary>
    /// 产品名称
    /// </summary>
    [SugarColumn(Length = 100)]
    public string ProductName { get; set; } = string.Empty;

    /// <summary>
    /// 价格
    /// </summary>
    [SugarColumn(DecimalDigits = 2)]
    public decimal Price { get; set; }

    /// <summary>
    /// 库存
    /// </summary>
    public int Stock { get; set; }

    /// <summary>
    /// 是否启用
    /// </summary>
    public bool IsActive { get; set; }
    
    // CreateTime, UpdateTime, CreateUser, UpdateUser 继承自 BaseEntity
}
```

#### 生成选项说明

- **GenerateEntity** - 生成完整的实体类，包含所有字段
- **GenerateEntityWithBase** - 生成继承 BaseEntity 的实体类，自动跳过审计字段（CreateTime、UpdateTime、CreateUser、UpdateUser）
- **GenerateAllEntities** - 批量生成数据库中所有表的实体类

#### 数据类型映射

| SQL Server 类型 | C# 类型 |
|----------------|---------|
| int | int |
| bigint | long |
| bit | bool |
| decimal/numeric/money | decimal |
| datetime/datetime2 | DateTime |
| varchar/nvarchar | string |
| uniqueidentifier | Guid |

详细使用说明参考 `ENTITY_GENERATION_GUIDE.md`

### 脚手架生成器

快速生成新功能的完整代码结构：

```powershell
# 中文交互式生成（推荐）
.\scaffold-cn.ps1

# 英文交互式生成
.\scaffold.ps1

# 命令行直接生成
.\scaffold-feature.ps1 -FeatureName WareHouse -EntityName WareHouseTask -IncludeCommand
```

按提示输入：
- 功能名称（如：WareHouse）
- 实体名称（如：WareHouseTask）
- 是否包含写操作（y/n）

自动生成：
- Domain 层实体和接口
- Infrastructure 层 Repository
- Application 层 Service 和 DTO
- Controllers 层 API 端点
- 数据库建表 SQL 脚本

详细使用说明参考 `SCAFFOLD_GUIDE.md`

**注意：** 所有包含中文的 PowerShell 脚本均使用 UTF-8 BOM 编码保存，确保中文正确显示。

## 🔧 常用命令

### 开发
```bash
dotnet restore              # 还原依赖
dotnet build                # 编译项目
dotnet run                  # 运行项目
dotnet run --urls "http://localhost:8080"  # 指定端口运行
dotnet test                 # 运行测试
```

### 部署
```powershell
# IIS 部署
.\deploy-to-iis.ps1 -FirstInstall           # 首次安装（默认端口 8008）
.\deploy-to-iis.ps1 -FirstInstall -Port 9000  # 首次安装（自定义端口）
.\deploy-to-iis.ps1                         # 更新部署
.\deploy-to-iis.ps1 -HotUpdate              # 热更新（停机 2-5 秒）

# Windows 服务部署
.\deploy.ps1 -Environment Production
```

### IIS 管理
```powershell
Get-Website -Name "LogisticsProduction.API"              # 查看状态
Restart-WebAppPool -Name "LogisticsProductionNet8"       # 重启
Get-Content "F:\IIS\LogisticsProductionNet8\Logs\*.log" -Tail 50  # 查看日志

# 修改端口
Set-WebBinding -Name "LogisticsProduction.API" -BindingInformation "*:8008:*" -PropertyName Port -Value 9000
```

### Windows 服务管理
```powershell
Get-Service -Name "LogisticsProductionNet8"              # 查看状态
Restart-Service -Name "LogisticsProductionNet8"          # 重启
Get-Content "F:\LogisticsProductionNet8\Logs\*.log" -Tail 50  # 查看日志
```

## 📝 配置说明

### 数据库连接

编辑 `appsettings.json` 或 `appsettings.Production.json`：

```json
{
  "ConnectionStrings": {
    "MainDb": "Data Source=服务器;Initial Catalog=数据库名;User ID=用户名;Password=密码;TrustServerCertificate=True"
  }
}
```

### 外部服务

```json
{
  "ExternalServices": {
    "PrintServiceUrl": "http://打印服务地址:端口",
    "AgvServiceUrl": "http://AGV服务地址:端口",
    "WmsServiceUrl": "http://WMS服务地址:端口"
  }
}
```

## ⚙️ 端口配置

### 本地 Debug 端口修改

**方式一：修改 launchSettings.json（推荐）**

编辑 `Properties/launchSettings.json`：

```json
{
  "profiles": {
    "http": {
      "commandName": "Project",
      "launchBrowser": true,
      "launchUrl": "swagger",
      "applicationUrl": "http://localhost:8080",  // 修改这里
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    },
    "https": {
      "commandName": "Project",
      "launchBrowser": true,
      "launchUrl": "swagger",
      "applicationUrl": "https://localhost:8443;http://localhost:8080",  // 修改这里
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
```

修改后：
- Visual Studio：直接按 F5 调试
- VS Code：使用调试面板启动
- Rider：使用运行配置启动

**方式二：命令行指定端口**

```bash
# HTTP 单端口
dotnet run --urls "http://localhost:8080"

# HTTPS + HTTP 双端口
dotnet run --urls "https://localhost:8443;http://localhost:8080"
```

**方式三：环境变量**

```powershell
# PowerShell
$env:ASPNETCORE_URLS="http://localhost:8080"
dotnet run

# CMD
set ASPNETCORE_URLS=http://localhost:8080
dotnet run
```

### 开发环境端口修改

编辑 `appsettings.Development.json`：

```json
{
  "Kestrel": {
    "Endpoints": {
      "Http": {
        "Url": "http://localhost:8080"
      },
      "Https": {
        "Url": "https://localhost:8443"
      }
    }
  }
}
```

**注意：** launchSettings.json 的优先级高于 appsettings.json

### 生产环境端口修改

#### IIS 部署
```powershell
# 修改 IIS 绑定端口
Set-WebBinding -Name "LogisticsProduction.API" -BindingInformation "*:8008:*" -PropertyName Port -Value 9000

# 或在 IIS 管理器中修改
# 1. 打开 IIS 管理器（inetmgr）
# 2. 选择网站 → 右键 → 编辑绑定
# 3. 修改端口号
```

#### Windows 服务部署
编辑 `appsettings.Production.json`：
```json
{
  "Kestrel": {
    "Endpoints": {
      "Http": {
        "Url": "http://0.0.0.0:8008"
      }
    }
  }
}
```

修改后重启服务：
```powershell
Restart-Service -Name "LogisticsProductionNet8"
```

## ⚠️ 重要提示

### PowerShell 执行策略
如果运行脚本时提示"无法加载文件，因为在此系统上禁止运行脚本"，需要临时允许脚本执行：

```powershell
# 临时允许当前 PowerShell 会话执行脚本（推荐）
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# 然后运行脚本
.\deploy.ps1
```

**说明：**
- `-Scope Process` 表示仅对当前 PowerShell 进程生效
- 关闭 PowerShell 窗口后自动恢复原策略
- 不会影响系统安全设置

### PowerShell 脚本编码
- 所有包含中文的 PowerShell 脚本使用 **UTF-8 BOM** 编码
- 如遇到中文乱码，运行：`.\fix-utf8-bom.ps1`
- 新建包含中文的脚本时，请使用 UTF-8 BOM 编码保存

### 管理员权限
- 所有部署脚本需要以管理员权限运行
- 右键 PowerShell → "以管理员身份运行"

## 🏗️ 新功能开发流程

1. **Domain 层** - 定义实体和仓储接口
2. **Infrastructure 层** - 实现 Repository
3. **Application 层** - 定义 DTO 和 Service
4. **Controllers 层** - 创建 API 端点
5. **DI 注册** - 在 InfrastructureModule 中注册

详细步骤参考 `DEVELOPMENT_GUIDE.md`

## 📊 技术栈

- .NET 8
- ASP.NET Core Web API
- SqlSugar ORM
- Autofac DI
- NLog 日志
- Swagger/OpenAPI

## 📞 故障排查

### IIS 部署问题

```powershell
# 查看应用日志
Get-Content "F:\IIS\LogisticsProductionNet8\Logs\*.log" -Tail 100

# 查看 stdout 日志（启动错误）
Get-Content "F:\IIS\LogisticsProductionNet8\logs\stdout*.log" -Tail 100

# 检查网站状态
Get-Website -Name "LogisticsProduction.API"
Get-WebAppPoolState -Name "LogisticsProductionNet8"
```

详细故障处理参考 `DEPLOYMENT_WINDOWS.md`
