# 实体生成器 API V2 - 使用指南

## 🎉 更新说明

所有接口已改为 **POST 方式**，支持直接传入数据库连接字符串！

### 主要改进

1. ✅ **全部改为 POST 方式** - 更安全，支持复杂参数
2. ✅ **支持直接传入连接字符串** - 无需配置文件
3. ✅ **支持从配置文件读取** - 兼容原有方式
4. ✅ **优先级明确** - 直接传入 > 配置文件 > 默认 MainDb

## 📡 API 接口列表

### 1. 查看所有表

**接口：** `POST /dev/entity-generator/tables`

**请求体：**
```json
{
  "connectionString": "Data Source=localhost;Initial Catalog=LogisticsDB;User ID=sa;Password=123456;TrustServerCertificate=True"
}
```

或使用配置文件中的连接：
```json
{
  "connectionName": "MainDb"
}
```

**响应：**
```json
{
  "success": true,
  "tableCount": 3,
  "tables": [
    { "name": "Product", "description": "产品表" },
    { "name": "Order", "description": "订单表" }
  ]
}
```

---

### 2. 查看表的列信息

**接口：** `POST /dev/entity-generator/table-columns`

**请求体：**
```json
{
  "tableName": "Product",
  "connectionString": "Data Source=localhost;Initial Catalog=LogisticsDB;User ID=sa;Password=123456;TrustServerCertificate=True"
}
```

**响应：**
```json
{
  "success": true,
  "tableName": "Product",
  "columnCount": 8,
  "columns": [
    {
      "name": "ProductId",
      "dataType": "int",
      "isPrimaryKey": true,
      "isIdentity": true,
      "isNullable": false
    }
  ]
}
```

---

### 3. 生成单个表 ⭐

**接口：** `POST /dev/entity-generator/generate`

**请求体：**
```json
{
  "tableName": "Product",
  "withBase": true,
  "connectionString": "Data Source=localhost;Initial Catalog=LogisticsDB;User ID=sa;Password=123456;TrustServerCertificate=True"
}
```

**参数说明：**
- `tableName` (必需) - 表名
- `withBase` (可选) - 是否继承 BaseEntity，默认 true
- `connectionString` (可选) - 数据库连接字符串
- `connectionName` (可选) - 配置文件中的连接名称

**响应：**
```json
{
  "success": true,
  "message": "实体类 Product 生成完成",
  "tableName": "Product",
  "filePath": "F:\\Projects\\LogisticsProduction.Net8\\Generated\\Entities\\Product.cs",
  "withBase": true,
  "tip": "生成的文件位于项目根目录的 Generated/Entities/ 文件夹，请手动复制到 Domain/Entities/"
}
```

---

### 4. 生成所有表

**接口：** `POST /dev/entity-generator/generate-all`

**请求体：**
```json
{
  "connectionString": "Data Source=localhost;Initial Catalog=LogisticsDB;User ID=sa;Password=123456;TrustServerCertificate=True"
}
```

**响应：**
```json
{
  "success": true,
  "message": "实体类生成完成",
  "outputPath": "F:\\Projects\\LogisticsProduction.Net8\\Generated\\Entities",
  "tableCount": 5,
  "tables": ["Product", "Order", "Customer"],
  "tip": "生成的文件位于项目根目录的 Generated/Entities/ 文件夹，请手动复制到 Domain/Entities/"
}
```

---

### 5. 批量生成指定表 ⭐

**接口：** `POST /dev/entity-generator/generate-batch`

**请求体：**
```json
{
  "tableNames": ["Product", "Order", "Customer"],
  "withBase": true,
  "connectionString": "Data Source=localhost;Initial Catalog=LogisticsDB;User ID=sa;Password=123456;TrustServerCertificate=True"
}
```

**响应：**
```json
{
  "success": true,
  "message": "批量生成完成",
  "outputPath": "F:\\Projects\\LogisticsProduction.Net8\\Generated\\Entities",
  "results": [
    {
      "tableName": "Product",
      "success": true,
      "filePath": "F:\\Projects\\LogisticsProduction.Net8\\Generated\\Entities\\Product.cs"
    }
  ],
  "tip": "生成的文件位于项目根目录的 Generated/Entities/ 文件夹，请手动复制到 Domain/Entities/"
}
```

---

### 6. 清空临时文件

**接口：** `DELETE /dev/entity-generator/clean`

**响应：**
```json
{
  "success": true,
  "message": "清空完成",
  "deletedCount": 5
}
```

---

## 🎯 使用方式

### 方式 1：直接传入连接字符串（推荐）

**优点：** 无需配置文件，灵活指定任意数据库

```json
{
  "tableName": "Product",
  "connectionString": "Data Source=192.168.1.100;Initial Catalog=TestDB;User ID=sa;Password=123456;TrustServerCertificate=True"
}
```

### 方式 2：使用配置文件中的连接

**优点：** 安全，不暴露密码

```json
{
  "tableName": "Product",
  "connectionName": "MainDb"
}
```

### 方式 3：使用默认连接

**优点：** 最简单

```json
{
  "tableName": "Product"
}
```

自动使用配置文件中的 `MainDb` 连接。

---

## 📝 完整示例

### 示例 1：从指定数据库生成实体类

```bash
curl -X POST http://localhost:5000/dev/entity-generator/generate \
  -H "Content-Type: application/json" \
  -d '{
    "tableName": "Product",
    "withBase": true,
    "connectionString": "Data Source=localhost;Initial Catalog=LogisticsDB;User ID=sa;Password=123456;TrustServerCertificate=True"
  }'
```

### 示例 2：从配置文件读取连接

```bash
curl -X POST http://localhost:5000/dev/entity-generator/generate \
  -H "Content-Type: application/json" \
  -d '{
    "tableName": "Product",
    "withBase": true,
    "connectionName": "MainDb"
  }'
```

### 示例 3：使用默认连接

```bash
curl -X POST http://localhost:5000/dev/entity-generator/generate \
  -H "Content-Type: application/json" \
  -d '{
    "tableName": "Product",
    "withBase": true
  }'
```

### 示例 4：批量生成多个表

```bash
curl -X POST http://localhost:5000/dev/entity-generator/generate-batch \
  -H "Content-Type: application/json" \
  -d '{
    "tableNames": ["Product", "Order", "Customer"],
    "withBase": true,
    "connectionString": "Data Source=localhost;Initial Catalog=LogisticsDB;User ID=sa;Password=123456;TrustServerCertificate=True"
  }'
```

### 示例 5：查看远程数据库的表

```bash
curl -X POST http://localhost:5000/dev/entity-generator/tables \
  -H "Content-Type: application/json" \
  -d '{
    "connectionString": "Data Source=192.168.1.100;Initial Catalog=RemoteDB;User ID=sa;Password=123456;TrustServerCertificate=True"
  }'
```

---

## 🌐 在 Swagger 中使用

1. 启动项目：`dotnet run`
2. 访问：`http://localhost:5000/swagger`
3. 找到 `EntityGenerator` 分组
4. 点击接口展开
5. 点击 "Try it out"
6. 填写请求体：

```json
{
  "tableName": "Product",
  "connectionString": "你的连接字符串"
}
```

7. 点击 "Execute"

---

## 💡 使用技巧

### 技巧 1：连接多个数据库

无需配置文件，直接传入不同的连接字符串：

```json
// 生产数据库
{
  "tableName": "Product",
  "connectionString": "Data Source=prod-server;Initial Catalog=ProdDB;..."
}

// 测试数据库
{
  "tableName": "Product",
  "connectionString": "Data Source=test-server;Initial Catalog=TestDB;..."
}
```

### 技巧 2：临时连接其他数据库

```json
{
  "tableName": "Report",
  "connectionString": "Data Source=report-server;Initial Catalog=ReportDB;User ID=readonly;Password=123456;TrustServerCertificate=True"
}
```

### 技巧 3：使用 Windows 身份验证

```json
{
  "tableName": "Product",
  "connectionString": "Data Source=localhost;Initial Catalog=LogisticsDB;Integrated Security=True;TrustServerCertificate=True"
}
```

### 技巧 4：批量生成不同数据库的表

```bash
# 从数据库 A 生成
curl -X POST http://localhost:5000/dev/entity-generator/generate-batch \
  -H "Content-Type: application/json" \
  -d '{
    "tableNames": ["Product", "Order"],
    "connectionString": "Data Source=localhost;Initial Catalog=DatabaseA;..."
  }'

# 从数据库 B 生成
curl -X POST http://localhost:5000/dev/entity-generator/generate-batch \
  -H "Content-Type: application/json" \
  -d '{
    "tableNames": ["Customer", "Invoice"],
    "connectionString": "Data Source=localhost;Initial Catalog=DatabaseB;..."
  }'
```

---

## 🔒 安全说明

### 连接字符串安全

1. **开发环境** - 可以直接传入连接字符串
2. **生产环境** - 接口自动禁用（`IsDevelopment` 检查）
3. **建议** - 使用配置文件中的连接名称，避免暴露密码

### 最佳实践

```json
// ✅ 推荐：使用配置文件
{
  "tableName": "Product",
  "connectionName": "MainDb"
}

// ⚠️ 谨慎：直接传入连接字符串（仅开发环境）
{
  "tableName": "Product",
  "connectionString": "Data Source=...;Password=123456;..."
}
```

---

## 📊 参数优先级

```
connectionString (直接传入)
    ↓ 优先
connectionName (配置文件)
    ↓ 其次
MainDb (默认)
    ↓ 最后
```

---

## 🎉 总结

### V2 版本的优势

1. **更灵活** - 支持直接传入连接字符串
2. **更安全** - POST 方式，不在 URL 中暴露参数
3. **更强大** - 可以连接任意数据库
4. **更简单** - 统一的请求格式

### 推荐使用场景

| 场景 | 推荐方式 |
|------|---------|
| 日常开发 | 使用 `connectionName` |
| 临时连接其他数据库 | 使用 `connectionString` |
| 批量生成 | 使用 `generate-batch` |
| 查看表结构 | 使用 `table-columns` |

### 立即开始

```bash
# 1. 启动项目
dotnet run

# 2. 使用 Swagger 测试
http://localhost:5000/swagger

# 3. 或使用 curl
curl -X POST http://localhost:5000/dev/entity-generator/generate \
  -H "Content-Type: application/json" \
  -d '{"tableName": "Product"}'
```

就这么简单！🎊
