using SqlSugar;
using System.Text;

namespace LogisticsProduction.Net8.Tools;

/// <summary>
/// SqlSugar 实体类生成器
/// </summary>
public class EntityGenerator
{
    private readonly SqlSugarClient _db;
    private readonly string _outputPath;

    public EntityGenerator(string connectionString, string outputPath = "Domain/Entities")
    {
        _db = new SqlSugarClient(new ConnectionConfig
        {
            ConnectionString = connectionString,
            DbType = DbType.SqlServer,
            IsAutoCloseConnection = true
        });
        _outputPath = outputPath;
    }

    /// <summary>
    /// 生成所有表的实体类
    /// </summary>
    public void GenerateAllEntities(string namespaceName = "LogisticsProduction.Net8.Domain.Entities")
    {
        var tables = _db.DbMaintenance.GetTableInfoList(false);
        Console.WriteLine($"找到 {tables.Count} 个表");

        foreach (var table in tables)
        {
            GenerateEntity(table.Name, namespaceName);
        }
        
        Console.WriteLine($"\n完成！共生成 {tables.Count} 个实体类");
    }

    /// <summary>
    /// 生成指定表的实体类
    /// </summary>
    public void GenerateEntity(string tableName, string namespaceName = "LogisticsProduction.Net8.Domain.Entities")
    {
        try
        {
            // 先删除已存在的文件，避免内容追加导致重复
            DeleteExistingFile(tableName);

            // 使用 SqlSugar 的 DbFirst 功能 - 直接生成到文件
            _db.DbFirst
                .Where(tableName)
                .IsCreateAttribute() // 生成 SqlSugar 特性
                .IsCreateDefaultValue() // 生成默认值
                .SettingClassTemplate(old => old) // 使用默认模板
                .SettingNamespaceTemplate(old => 
                {
                    // SqlSugar 会自动生成 using SqlSugar，无需额外添加
                    return string.Empty;
                })
                .CreateClassFile(_outputPath, namespaceName);

            var filePath = Path.Combine(_outputPath, $"{tableName}.cs");
            Console.WriteLine($"✓ 生成实体类: {filePath}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"✗ 生成 {tableName} 失败: {ex.Message}");
        }
    }

    /// <summary>
    /// 生成指定表的实体类（继承 BaseEntity）
    /// 使用 SqlSugar DbFirst，但增强处理 BaseEntity 继承
    /// </summary>
    public void GenerateEntityWithBase(string tableName, string namespaceName = "LogisticsProduction.Net8.Domain.Entities")
    {
        try
        {
            // 先删除已存在的文件，避免内容追加导致重复
            DeleteExistingFile(tableName);

            // 检查表是否包含 BaseEntity 的字段
            var columns = _db.DbMaintenance.GetColumnInfosByTableName(tableName, false);
            var baseEntityFields = new[] { "CreateTime", "UpdateTime", "CreateUser", "UpdateUser" };
            var hasBaseFields = columns.Any(c => baseEntityFields.Contains(c.DbColumnName));

            if (hasBaseFields)
            {
                // 使用 SqlSugar DbFirst 生成，然后修改继承和移除重复字段
                _db.DbFirst
                    .Where(tableName)
                    .IsCreateAttribute()
                    .IsCreateDefaultValue()
                    .SettingClassTemplate(old =>
                    {
                        // 修改类声明，添加 BaseEntity 继承
                        var modified = old.Replace($"public class {tableName}", $"public class {tableName} : BaseEntity");
                        
                        // 移除 BaseEntity 中已有的字段
                        foreach (var field in baseEntityFields)
                        {
                            // 移除字段定义（包括特性和属性）
                            var pattern = $@"\s*\[SugarColumn[^\]]*\]\s*public\s+\w+\??\s+{field}\s*{{{{\s*get;\s*set;\s*}}}}[^}}]*";
                            modified = System.Text.RegularExpressions.Regex.Replace(modified, pattern, "", System.Text.RegularExpressions.RegexOptions.Multiline);
                        }
                        
                        return modified;
                    })
                    .SettingNamespaceTemplate(old =>
                    {
                        // SqlSugar 会自动生成 using SqlSugar，无需额外添加
                        return string.Empty;
                    })
                    .CreateClassFile(_outputPath, namespaceName);
            }
            else
            {
                // 不包含审计字段，使用标准生成
                _db.DbFirst
                    .Where(tableName)
                    .IsCreateAttribute()
                    .IsCreateDefaultValue()
                    .SettingNamespaceTemplate(old =>
                    {
                        // SqlSugar 会自动生成 using SqlSugar，无需额外添加
                        return string.Empty;
                    })
                    .CreateClassFile(_outputPath, namespaceName);
            }

            var filePath = Path.Combine(_outputPath, $"{tableName}.cs");
            Console.WriteLine($"✓ 生成实体类: {filePath}{(hasBaseFields ? " (继承 BaseEntity)" : "")}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"✗ 生成 {tableName} 失败: {ex.Message}");
        }
    }

    /// <summary>
    /// 删除已存在的实体类文件，避免 SqlSugar 追加内容导致重复
    /// </summary>
    private void DeleteExistingFile(string tableName)
    {
        var filePath = Path.Combine(_outputPath, $"{tableName}.cs");
        if (File.Exists(filePath))
        {
            File.Delete(filePath);
            Console.WriteLine($"  已删除旧文件: {filePath}");
        }
    }
}
