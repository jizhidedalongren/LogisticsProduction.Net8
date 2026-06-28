# GenerateEntity vs GenerateEntityWithBase - 快速对比

## 🎯 一句话总结

- **GenerateEntity** - 生成完整的实体类，包含所有字段
- **GenerateEntityWithBase** - 智能生成，自动继承 BaseEntity 并跳过审计字段

## 📊 核心区别

```
GenerateEntity:
数据库表 → 生成所有字段 → 不继承 BaseEntity

GenerateEntityWithBase:
数据库表 → 检测审计字段 → 继承 BaseEntity → 跳过重复字段
```

## 🔍 实际效果对比

### 数据库表
```sql
CREATE TABLE Product (
    ProductId INT PRIMARY KEY,
    ProductName NVARCHAR(100),
    CreateTime DATETIME,
    UpdateTime DATETIME
);
```

### GenerateEntity 生成
```csharp
public class Product
{
    public int ProductId { get; set; }
    public string ProductName { get; set; }
    public DateTime CreateTime { get; set; }    // ← 重复
    public DateTime? UpdateTime { get; set; }   // ← 重复
}
```

### GenerateEntityWithBase 生成 ✅
```csharp
public class Product : BaseEntity  // ← 继承
{
    public int ProductId { get; set; }
    public string ProductName { get; set; }
    // CreateTime 和 UpdateTime 继承自 BaseEntity
}
```

## 🎯 何时使用

### 使用 GenerateEntityWithBase（推荐 ⭐）
- ✅ 表包含 CreateTime、UpdateTime 字段
- ✅ 需要继承 BaseEntity
- ✅ 想要避免字段重复
- ✅ 需要完整的注释

### 使用 GenerateEntity
- ✅ 表不包含审计字段
- ✅ 不需要继承 BaseEntity
- ✅ 需要快速生成

## 💡 API 中的使用

```json
// 使用 GenerateEntityWithBase（推荐）
{
  "tableName": "Product",
  "withBase": true
}

// 使用 GenerateEntity
{
  "tableName": "Product",
  "withBase": false
}
```

**默认：** `withBase = true`

## 🎉 推荐

**默认使用 `GenerateEntityWithBase`（withBase: true）**

原因：
- 自动检测审计字段
- 智能继承 BaseEntity
- 避免字段重复
- 生成完整注释

## 📚 详细文档

查看完整对比：[GENERATE_ENTITY_COMPARISON.md](GENERATE_ENTITY_COMPARISON.md)
