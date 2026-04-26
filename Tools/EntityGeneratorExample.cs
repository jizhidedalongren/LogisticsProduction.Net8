using LogisticsProduction.Net8.Tools;
using Microsoft.Extensions.Configuration;

namespace LogisticsProduction.Net8.Tools;

/// <summary>
/// 实体类生成器使用示例
/// 可以在 Program.cs 中调用这些方法
/// </summary>
public static class EntityGeneratorExample
{
    /// <summary>
    /// 示例1: 生成所有表的实体类
    /// </summary>
    public static void Example1_GenerateAllEntities(IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("MainDb");
        if (string.IsNullOrEmpty(connectionString))
        {
            Console.WriteLine("错误: 未找到数据库连接字符串");
            return;
        }

        var generator = new EntityGenerator(connectionString, "Domain/Entities");
        generator.GenerateAllEntities();
    }

    /// <summary>
    /// 示例2: 生成指定表的实体类
    /// </summary>
    public static void Example2_GenerateSingleEntity(IConfiguration configuration, string tableName)
    {
        var connectionString = configuration.GetConnectionString("MainDb");
        if (string.IsNullOrEmpty(connectionString))
        {
            Console.WriteLine("错误: 未找到数据库连接字符串");
            return;
        }

        var generator = new EntityGenerator(connectionString, "Domain/Entities");
        generator.GenerateEntity(tableName);
    }

    /// <summary>
    /// 示例3: 生成继承 BaseEntity 的实体类
    /// </summary>
    public static void Example3_GenerateEntityWithBase(IConfiguration configuration, string tableName)
    {
        var connectionString = configuration.GetConnectionString("MainDb");
        if (string.IsNullOrEmpty(connectionString))
        {
            Console.WriteLine("错误: 未找到数据库连接字符串");
            return;
        }

        var generator = new EntityGenerator(connectionString, "Domain/Entities");
        generator.GenerateEntityWithBase(tableName);
    }

    /// <summary>
    /// 示例4: 批量生成指定的表
    /// </summary>
    public static void Example4_GenerateMultipleTables(IConfiguration configuration, params string[] tableNames)
    {
        var connectionString = configuration.GetConnectionString("MainDb");
        if (string.IsNullOrEmpty(connectionString))
        {
            Console.WriteLine("错误: 未找到数据库连接字符串");
            return;
        }

        var generator = new EntityGenerator(connectionString, "Domain/Entities");
        
        foreach (var tableName in tableNames)
        {
            generator.GenerateEntityWithBase(tableName);
        }
    }

    /// <summary>
    /// 示例5: 在开发环境自动生成（添加到 Program.cs）
    /// </summary>
    public static void Example5_AutoGenerateInDevelopment(WebApplication app, IConfiguration configuration)
    {
        if (app.Environment.IsDevelopment())
        {
            var connectionString = configuration.GetConnectionString("MainDb");
            if (!string.IsNullOrEmpty(connectionString))
            {
                var generator = new EntityGenerator(connectionString, "Domain/Entities");
                
                // 取消注释以启用自动生成
                // generator.GenerateAllEntities();
                
                Console.WriteLine("提示: 实体生成器已就绪，可在代码中调用生成方法");
            }
        }
    }
}

/// <summary>
/// 在 Program.cs 中的使用示例
/// </summary>
public static class ProgramUsageExample
{
    /*
    // 在 Program.cs 中添加以下代码：

    // 方式1: 在应用启动前生成（开发环境）
    if (builder.Environment.IsDevelopment())
    {
        var connectionString = builder.Configuration.GetConnectionString("MainDb");
        if (!string.IsNullOrEmpty(connectionString))
        {
            var generator = new EntityGenerator(connectionString, "Domain/Entities");
            
            // 生成所有表
            // generator.GenerateAllEntities();
            
            // 或生成指定表
            // generator.GenerateEntity("Product");
            // generator.GenerateEntityWithBase("Order");
        }
    }

    var app = builder.Build();

    // 方式2: 创建一个开发端点（仅开发环境）
    if (app.Environment.IsDevelopment())
    {
        app.MapGet("/dev/generate-entities", (IConfiguration config) =>
        {
            var connectionString = config.GetConnectionString("MainDb");
            if (string.IsNullOrEmpty(connectionString))
            {
                return Results.BadRequest("未配置数据库连接");
            }

            var generator = new EntityGenerator(connectionString, "Domain/Entities");
            generator.GenerateAllEntities();
            
            return Results.Ok("实体类生成完成");
        });

        app.MapGet("/dev/generate-entity/{tableName}", (string tableName, IConfiguration config) =>
        {
            var connectionString = config.GetConnectionString("MainDb");
            if (string.IsNullOrEmpty(connectionString))
            {
                return Results.BadRequest("未配置数据库连接");
            }

            var generator = new EntityGenerator(connectionString, "Domain/Entities");
            generator.GenerateEntityWithBase(tableName);
            
            return Results.Ok($"实体类 {tableName} 生成完成");
        });
    }

    app.Run();
    */
}
