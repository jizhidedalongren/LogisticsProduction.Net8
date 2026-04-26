# SqlSugar 实体类生成器 - 完整指南

## 📖 概述

从数据库表自动生成 C# 实体类，支持 SqlSugar ORM 特性标注。

**核心功能：**
- ✅ 通过 API 接口生成（推荐）
- ✅ 支持直接传入数据库连接字符串
- ✅ 生成到临时文件夹，手动复制
- ✅ 自动继承 BaseEntity
- ✅ 支持单个、批量、全部生成

## 🚀 快速开始

### 1. 启动项目
```bash
dotnet run
```

### 2. 访问 Swagger
```
http://localhost:5000/swagger
```

### 3. 使用 API 生成

找到 `EntityGenerator` 分组，使用以下接口：

```bash
POST /dev/entity-generator/generate
```

**请求体：**
```json
{
  "tableName": "Product",
  "connectionString": "Data Source=localhost;Initial Catalog=LogisticsDB;User ID=sa;Password=123456;TrustServerCertificate=True"
}
```

### 4. 查看生成的文件

生成位置：`Generated/Entities/Product.cs`

### 5. 手动复制到项目

复制到：`Domain/Entities/Product.cs`

## 📡 API 接口列表

### 1. 查看所有表
```
POST /dev/entity-generator/tables
```
```json
{
  "connectionString": "你的连接字符串"
}
```

### 2. 生成单个表 ⭐
```
POST /dev/entity-generator/generate
```
```json
{
  "tableName": "Product",
  "withBase": true,
  "connectionString": "你的连接字符串"
}
```

### 3. 批量生成 ⭐
```
POST /dev/entity-generator/generate-batch
```
```json
{
  "tableNames": ["Product", "Order", "Customer"],
  "withBase": true,
  "connectionString": "你的连接字符串"
}
```

### 4. 生成所有表
```
POST /dev/entity-generator/generate-all
```
```json
{
  "connectionString": "你的连接字符串"
}
```

### 5. 查看表结构
```
POST /dev/entity-generator/table-columns
```
```json
{
  "tableName": "Product",
  "connectionString": "你的连接字符串"
}
```

### 6. 清空临时文件
```
DELETE /dev/entity-generator/clean
```

## 🎯 三种连接方式

### 方式 1：直接传入连接字符串（推荐）
```json
{
  "tableName": "Product",
  "connectionString": "Data Source=localhost;Initial Catalog=LogisticsDB;User ID=sa;Password=123456;TrustServerCertificate=True"
}
```

**优点：** 灵活，可以连接任意数据库

### 方式 2：使用配置文件中的连接
```json
{
  "tableName": "Product",
  "connectionName": "MainDb"
}
```

**优点：** 安全，不暴露密码

### 方式 3：使用默认连接
```json
{
  "tableName": "Product"
}
```

**优点：** 最简单

## 📂 文件位置

```
项目根目录/
├── Generated/              ← 生成位置（临时）
│   └── Entities/
│       ├── Product.cs
│       └── Order.cs
│
└── Domain/                 ← 目标位置（手动复制）
    └── Entities/
        ├── Product.cs
        └── Order.cs
```

## 🔍 GenerateEntity vs GenerateEntityWithBase

### GenerateEntity (withBase: false)
- 使用 SqlSugar DbFirst 标准生成
- 生成所有字段
- 不继承 BaseEntity

### GenerateEntityWithBase (withBase: true) ⭐
- 使用 SqlSugar DbFirst 增强生成
- 智能检测审计字段
- 自动继承 BaseEntity
- 自动移除重复字段

**两种方式都使用 SqlSugar 官方的 DbFirst 功能，稳定可靠！**

**推荐使用 `withBase: true`**

### 示例对比

**数据库表：**
```sql
CREATE TABLE Product (
    ProductId INT PRIMARY KEY,
    ProductName NVARCHAR(100),
    CreateTime DATETIME,
    UpdateTime DATETIME
);
```

**withBase: false 生成：**
```csharp
public class Product
{
    public int ProductId { get; set; }
    public string ProductName { get; set; }
    public DateTime CreateTime { get; set; }    // ← 重复
    public DateTime? UpdateTime { get; set; }   // ← 重复
}
```

**withBase: true 生成：** ✅
```csharp
public class Product : BaseEntity  // ← 继承
{
    public int ProductId { get; set; }
    public string ProductName { get; set; }
    // CreateTime 和 UpdateTime 继承自 BaseEntity
}
```

## 💡 使用示例

### 示例 1：生成单个表

**curl：**
```bash
curl -X POST http://localhost:5000/dev/entity-generator/generate \
  -H "Content-Type: application/json" \
  -d '{
    "tableName": "Product",
    "connectionString": "Data Source=localhost;Initial Catalog=LogisticsDB;User ID=sa;Password=123456;TrustServerCertificate=True"
  }'
```

**PowerShell：**
```powershell
$body = @{
    tableName = "Product"
    connectionString = "Data Source=localhost;Initial Catalog=LogisticsDB;User ID=sa;Password=123456;TrustServerCertificate=True"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5000/dev/entity-generator/generate" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body
```

### 示例 2：批量生成多个表

```bash
curl -X POST http://localhost:5000/dev/entity-generator/generate-batch \
  -H "Content-Type: application/json" \
  -d '{
    "tableNames": ["Product", "Order", "Customer"],
    "withBase": true,
    "connectionString": "Data Source=localhost;Initial Catalog=LogisticsDB;User ID=sa;Password=123456;TrustServerCertificate=True"
  }'
```

### 示例 3：使用配置文件中的连接

```bash
curl -X POST http://localhost:5000/dev/entity-generator/generate \
  -H "Content-Type: application/json" \
  -d '{
    "tableName": "Product",
    "connectionName": "MainDb"
  }'
```

## ⚙️ 配置数据库连接

编辑 `appsettings.json`：

```json
{
  "ConnectionStrings": {
    "MainDb": "Data Source=localhost;Initial Catalog=LogisticsDB;User ID=sa;Password=YourPassword;TrustServerCertificate=True"
  }
}
```

### 连接字符串参数说明

| 参数 | 说明 | 示例 |
|------|------|------|
| Data Source | 服务器地址 | localhost 或 192.168.1.100 |
| Initial Catalog | 数据库名 | LogisticsDB |
| User ID | 用户名 | sa |
| Password | 密码 | YourPassword |
| TrustServerCertificate | 信任证书 | True（必需） |

### 常见连接字符串

```json
// 本地 SQL Server（SQL Server 身份验证）
"MainDb": "Data Source=localhost;Initial Catalog=LogisticsDB;User ID=sa;Password=123456;TrustServerCertificate=True"

// 本地 SQL Server（Windows 身份验证）
"MainDb": "Data Source=localhost;Initial Catalog=LogisticsDB;Integrated Security=True;TrustServerCertificate=True"

// 远程 SQL Server
"MainDb": "Data Source=192.168.1.100;Initial Catalog=LogisticsDB;User ID=sa;Password=123456;TrustServerCertificate=True"

// 指定端口
"MainDb": "Data Source=localhost,1433;Initial Catalog=LogisticsDB;User ID=sa;Password=123456;TrustServerCertificate=True"
```

## 🎯 使用流程

### 标准流程

1. 启动项目：`dotnet run`
2. 访问 Swagger：`http://localhost:5000/swagger`
3. 调用接口生成实体类
4. 打开 `Generated/Entities/` 查看生成的文件
5. 手动复制需要的文件到 `Domain/Entities/`
6. 清理临时文件（可选）

### 快速流程

1. 启动项目
2. 使用 curl 或 PowerShell 调用接口
3. 复制生成的文件

## 🔒 安全说明

- ✅ 接口仅在开发环境可用（`IsDevelopment`）
- ✅ 生产环境自动禁用
- ✅ 生成到临时文件夹，不会覆盖现有文件
- ✅ `Generated/` 文件夹已添加到 `.gitignore`

## 🐛 故障排查

### 问题 1：提示"此接口仅在开发环境可用"

**原因：** 当前环境不是开发环境

**解决：** 确保 `ASPNETCORE_ENVIRONMENT` 设置为 `Development`

### 问题 2：提示"未提供有效的数据库连接字符串"

**原因：** 未提供连接字符串或配置文件中没有对应的连接

**解决：** 
- 直接传入 `connectionString`
- 或在 `appsettings.json` 中配置 `ConnectionStrings:MainDb`

### 问题 3：连接失败

**原因：** 数据库连接失败

**解决：**
1. 检查 SQL Server 服务是否运行
2. 检查连接字符串是否正确
3. 检查防火墙设置
4. 确认数据库存在

### 问题 4：生成的文件找不到

**解决：** 查看项目根目录的 `Generated/Entities/` 文件夹

## 💡 最佳实践

### 1. 使用 API 接口生成
- 安全：不会覆盖现有文件
- 灵活：可以预览后再复制
- 便捷：通过浏览器或命令行操作

### 2. 默认使用 withBase: true
- 自动处理审计字段
- 避免字段重复
- 代码更规范

### 3. 生成到临时文件夹
- 可以对比新旧文件
- 决定是否覆盖
- 避免误操作

### 4. 定期清理临时文件
```bash
curl -X DELETE http://localhost:5000/dev/entity-generator/clean
```

## 📚 相关文档

- [项目架构](../../ARCHITECTURE.md)
- [开发指南](../../DEVELOPMENT_GUIDE.md)
- [文档索引](../../DOCS_INDEX.md)

## 🎉 总结

使用 API 接口生成实体类：

1. **安全** - 生成到临时文件夹
2. **灵活** - 支持直接传入连接字符串
3. **便捷** - 通过 Swagger 或命令行操作
4. **智能** - 自动继承 BaseEntity
5. **可控** - 手动复制需要的文件

**立即开始：**
```bash
dotnet run
# 访问 http://localhost:5000/swagger
```
