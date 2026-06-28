using LogisticsProduction.Net8.Tools;
using Microsoft.Extensions.Configuration;

namespace LogisticsProduction.Net8.Tools;

/// <summary>
/// 实体类生成程序入口
/// </summary>
public class GenerateEntitiesProgram
{
    public static void Main(string[] args)
    {
        Console.WriteLine("=== SqlSugar 实体类生成工具 ===\n");

        // 读取配置文件
        var configuration = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: false)
            .Build();

        var connectionString = configuration.GetConnectionString("MainDb");
        
        if (string.IsNullOrEmpty(connectionString))
        {
            Console.WriteLine("错误: 未找到数据库连接字符串");
            return;
        }

        Console.WriteLine($"数据库连接: {MaskConnectionString(connectionString)}\n");

        var generator = new EntityGenerator(connectionString, "Domain/Entities");

        Console.WriteLine("请选择操作:");
        Console.WriteLine("1. 生成所有表的实体类");
        Console.WriteLine("2. 生成指定表的实体类");
        Console.WriteLine("3. 生成指定表的实体类（继承 BaseEntity）");
        Console.Write("\n请输入选项 (1-3): ");

        var choice = Console.ReadLine();

        switch (choice)
        {
            case "1":
                generator.GenerateAllEntities();
                break;
            case "2":
                Console.Write("请输入表名: ");
                var tableName = Console.ReadLine();
                if (!string.IsNullOrEmpty(tableName))
                {
                    generator.GenerateEntity(tableName);
                }
                break;
            case "3":
                Console.Write("请输入表名: ");
                var tableNameWithBase = Console.ReadLine();
                if (!string.IsNullOrEmpty(tableNameWithBase))
                {
                    generator.GenerateEntityWithBase(tableNameWithBase);
                }
                break;
            default:
                Console.WriteLine("无效的选项");
                break;
        }

        Console.WriteLine("\n按任意键退出...");
        Console.ReadKey();
    }

    private static string MaskConnectionString(string connectionString)
    {
        var parts = connectionString.Split(';');
        var masked = parts.Select(part =>
        {
            if (part.Contains("Password", StringComparison.OrdinalIgnoreCase) ||
                part.Contains("Pwd", StringComparison.OrdinalIgnoreCase))
            {
                return part.Split('=')[0] + "=****";
            }
            return part;
        });
        return string.Join(";", masked);
    }
}
