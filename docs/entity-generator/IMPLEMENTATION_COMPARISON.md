# 实现方案对比

## 🔍 两种实现方式

### 方式 1：SqlSugar DbFirst（推荐 ⭐）

**使用：** `GenerateEntity` 和 `GenerateEntityWithBase`（已改进）

**原理：**
- 使用 SqlSugar 内置的 DbFirst 功能
- 自动读取数据库表结构
- 自动生成实体类代码
- 支持模板定制

**优点：**
- ✅ 官方支持，稳定可靠
- ✅ 自动处理数据类型映射
- ✅ 自动生成 SqlSugar 特性
- ✅ 支持模板定制
- ✅ 代码简洁

**缺点：**
- ⚠️ 需要通过正则表达式移除重复字段（已解决）

### 方式 2：手动构建代码（旧方案）

**原理：**
- 手动读取表结构
- 手动构建 C# 代码字符串
- 手动处理类型映射
- 手动生成特性

**优点：**
- ✅ 完全可控
- ✅ 可以精确控制每个细节

**缺点：**
- ❌ 代码冗长
- ❌ 需要手动维护类型映射
- ❌ 容易出错
- ❌ 难以维护

## 📊 代码对比

### 方式 1：SqlSugar DbFirst（当前实现）

```csharp
public void GenerateEntityWithBase(string tableName)
{
    var columns = _db.DbMaintenance.GetColumnInfosByTableName(tableName, false);
    var baseEntityFields = new[] { "CreateTime", "UpdateTime", "CreateUser", "UpdateUser" };
    var hasBaseFields = columns.Any(c => baseEntityFields.Contains(c.DbColumnName));

    if (hasBaseFields)
    {
        // 使用 SqlSugar DbFirst，通过模板定制添加继承和移除重复字段
        _db.DbFirst
            .Where(tableName)
            .IsCreateAttribute()
            .IsCreateDefaultValue()
            .SettingClassTemplate(old =>
            {
                // 添加 BaseEntity 继承
                var modified = old.Replace($"public class {tableName}", 
                                          $"public class {tableName} : BaseEntity");
                
                // 移除重复字段
                foreach (var field in baseEntityFields)
                {
                    var pattern = $@"\s*\[SugarColumn[^\]]*\]\s*public\s+\w+\??\s+{field}\s*{{\s*get;\s*set;\s*}}[^}]*";
                    modified = Regex.Replace(modified, pattern, "", RegexOptions.Multiline);
                }
                
                return modified;
            })
            .CreateClassFile(_outputPath, namespaceName);
    }
    else
    {
        // 标准生成
        _db.DbFirst.Where(tableName).CreateClassFile(_outputPath, namespaceName);
    }
}
```

**代码行数：** ~30 行

### 方式 2：手动构建（旧实现）

```csharp
public void GenerateEntityWithBase(string tableName)
{
    var columns = _db.DbMaintenance.GetColumnInfosByTableName(tableName, false);
    var sb = new StringBuilder();

    // 手动构建命名空间
    sb.AppendLine("using SqlSugar;");
    sb.AppendLine($"namespace {namespaceName};");
    
    // 手动构建类声明
    var hasBaseFields = columns.Any(c => c.DbColumnName == "CreateTime" || ...);
    if (hasBaseFields)
        sb.AppendLine($"public class {tableName} : BaseEntity");
    else
        sb.AppendLine($"public class {tableName}");
    
    sb.AppendLine("{");

    // 手动构建每个属性
    foreach (var column in columns)
    {
        if (hasBaseFields && IsBaseEntityField(column.DbColumnName))
            continue;

        // 手动构建注释
        sb.AppendLine("    /// <summary>");
        sb.AppendLine($"    /// {column.ColumnDescription ?? column.DbColumnName}");
        sb.AppendLine("    /// </summary>");

        // 手动构建特性
        var attributes = new List<string>();
        if (column.IsPrimarykey) attributes.Add("IsPrimaryKey = true");
        if (column.IsIdentity) attributes.Add("IsIdentity = true");
        if (column.DataType == "varchar" || ...) attributes.Add($"Length = {column.Length}");
        if (column.IsNullable) attributes.Add("IsNullable = true");
        if (column.DecimalDigits > 0) attributes.Add($"DecimalDigits = {column.DecimalDigits}");
        
        if (attributes.Count > 0)
            sb.AppendLine($"    [SugarColumn({string.Join(", ", attributes)})]");

        // 手动构建属性
        var csharpType = GetCSharpType(column);
        sb.AppendLine($"    public {csharpType} {column.DbColumnName} {{ get; set; }}{GetDefaultValue(column, csharpType)}");
    }

    sb.AppendLine("}");

    // 手动写入文件
    File.WriteAllText(filePath, sb.ToString(), Encoding.UTF8);
}

// 还需要手动实现类型映射
private string GetCSharpType(DbColumnInfo column)
{
    var type = column.DataType.ToLower() switch
    {
        "int" => "int",
        "bigint" => "long",
        "smallint" => "short",
        "tinyint" => "byte",
        "bit" => "bool",
        "decimal" or "numeric" or "money" => "decimal",
        "float" => "double",
        "real" => "float",
        "datetime" or "datetime2" or "date" or "smalldatetime" => "DateTime",
        "uniqueidentifier" => "Guid",
        _ => "string"
    };

    if (column.IsNullable && type != "string")
        return $"{type}?";

    return type;
}

private string GetDefaultValue(DbColumnInfo column, string csharpType)
{
    if (csharpType == "string")
        return column.IsNullable ? "" : " = string.Empty;";
    return ";";
}
```

**代码行数：** ~100 行

## 🎯 改进效果

### 改进前（手动构建）
- 代码行数：~100 行
- 需要手动维护类型映射
- 需要手动构建特性
- 容易出错

### 改进后（SqlSugar DbFirst）
- 代码行数：~30 行（减少 70%）
- 自动处理类型映射
- 自动生成特性
- 更稳定可靠

## 💡 为什么 SqlSugar DbFirst 更好？

### 1. 官方支持
SqlSugar 的 DbFirst 是官方提供的功能，经过充分测试，稳定可靠。

### 2. 自动处理
- 自动映射数据类型
- 自动生成特性
- 自动处理可空类型
- 自动生成默认值

### 3. 易于维护
- 代码简洁
- 逻辑清晰
- 不需要维护类型映射表

### 4. 功能完整
- 支持所有 SQL Server 数据类型
- 支持自定义模板
- 支持批量生成

### 5. 扩展性强
通过 `SettingClassTemplate` 可以灵活定制生成的代码。

## 🔧 当前实现的优势

### GenerateEntity
- 使用 SqlSugar DbFirst
- 生成标准实体类
- 简单直接

### GenerateEntityWithBase（改进后）
- 使用 SqlSugar DbFirst
- 通过模板定制添加 BaseEntity 继承
- 通过正则表达式移除重复字段
- 兼顾了灵活性和简洁性

## 📝 最佳实践

### 推荐使用 SqlSugar DbFirst

**原因：**
1. 官方支持，稳定可靠
2. 代码简洁，易于维护
3. 自动处理类型映射
4. 功能完整，扩展性强

### 定制化需求

如果需要特殊定制，使用 `SettingClassTemplate` 和 `SettingNamespaceTemplate`：

```csharp
_db.DbFirst
    .Where(tableName)
    .SettingClassTemplate(old =>
    {
        // 自定义类模板
        return old.Replace("something", "something else");
    })
    .SettingNamespaceTemplate(old =>
    {
        // 自定义命名空间模板
        return "using System;\nusing SqlSugar;\n\nnamespace MyNamespace;";
    })
    .CreateClassFile(outputPath, namespaceName);
```

## 🎉 总结

**SqlSugar DbFirst 方案更好：**
- ✅ 代码量减少 70%
- ✅ 更稳定可靠
- ✅ 更易维护
- ✅ 功能更完整

**当前实现已全部采用 SqlSugar DbFirst 方案！** ⭐
