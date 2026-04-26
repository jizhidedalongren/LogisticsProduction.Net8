using LogisticsProduction.Net8.Tools;
using Microsoft.Extensions.Configuration;

namespace LogisticsProduction.Net8.Tools;

/// <summary>
/// 实体类生成器测试程序
/// 用于快速测试实体生成功能
/// </summary>
public class TestEntityGenerator
{
    public static void TestGeneration()
    {
        Console.WriteLine("=== SqlSugar 实体类生成器测试 ===\n");

        try
        {
            // 读取配置文件
            var configuration = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: false)
                .AddJsonFile("appsettings.Development.json", optional: true)
                .Build();

            var connectionString = configuration.GetConnectionString("MainDb");

            if (string.IsNullOrEmpty(connectionString))
            {
                Console.WriteLine("❌ 错误: 未找到数据库连接字符串");
                Console.WriteLine("请在 appsettings.json 中配置 ConnectionStrings:MainDb");
                return;
            }

            Console.WriteLine("✓ 数据库连接字符串已配置");
            Console.WriteLine($"  {MaskConnectionString(connectionString)}\n");

            // 创建生成器
            var generator = new EntityGenerator(connectionString, "Domain/Entities");
            Console.WriteLine("✓ 实体生成器已创建\n");

            // 测试连接并获取表列表
            Console.WriteLine("正在连接数据库...");
            var db = new SqlSugar.SqlSugarClient(new SqlSugar.ConnectionConfig
            {
                ConnectionString = connectionString,
                DbType = SqlSugar.DbType.SqlServer,
                IsAutoCloseConnection = true
            });

            var tables = db.DbMaintenance.GetTableInfoList(false);
            Console.WriteLine($"✓ 数据库连接成功！找到 {tables.Count} 个表\n");

            if (tables.Count == 0)
            {
                Console.WriteLine("⚠️  数据库中没有表，无法生成实体类");
                return;
            }

            // 显示表列表
            Console.WriteLine("数据库表列表：");
            for (int i = 0; i < tables.Count; i++)
            {
                Console.WriteLine($"  {i + 1}. {tables[i].Name}");
            }
            Console.WriteLine();

            // 提示用户选择
            Console.WriteLine("请选择操作：");
            Console.WriteLine("1. 生成所有表的实体类");
            Console.WriteLine("2. 生成指定表的实体类");
            Console.WriteLine("3. 生成指定表的实体类（继承 BaseEntity）");
            Console.WriteLine("0. 退出");
            Console.Write("\n请输入选项 (0-3): ");

            var choice = Console.ReadLine();

            switch (choice)
            {
                case "1":
                    Console.WriteLine("\n开始生成所有表的实体类...\n");
                    generator.GenerateAllEntities();
                    Console.WriteLine("\n✓ 完成！");
                    break;

                case "2":
                    Console.Write("\n请输入表名: ");
                    var tableName = Console.ReadLine();
                    if (!string.IsNullOrEmpty(tableName))
                    {
                        Console.WriteLine($"\n开始生成 {tableName} 的实体类...\n");
                        generator.GenerateEntity(tableName);
                        Console.WriteLine("\n✓ 完成！");
                    }
                    break;

                case "3":
                    Console.Write("\n请输入表名: ");
                    var tableNameWithBase = Console.ReadLine();
                    if (!string.IsNullOrEmpty(tableNameWithBase))
                    {
                        Console.WriteLine($"\n开始生成 {tableNameWithBase} 的实体类（继承 BaseEntity）...\n");
                        generator.GenerateEntityWithBase(tableNameWithBase);
                        Console.WriteLine("\n✓ 完成！");
                    }
                    break;

                case "0":
                    Console.WriteLine("\n已退出");
                    return;

                default:
                    Console.WriteLine("\n❌ 无效的选项");
                    break;
            }

            Console.WriteLine("\n生成的实体类位于: Domain/Entities/");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"\n❌ 错误: {ex.Message}");
            Console.WriteLine($"\n详细信息: {ex}");
            
            if (ex.Message.Contains("登录") || ex.Message.Contains("连接"))
            {
                Console.WriteLine("\n💡 提示：");
                Console.WriteLine("  1. 检查 SQL Server 服务是否运行");
                Console.WriteLine("  2. 检查连接字符串中的服务器地址、用户名、密码");
                Console.WriteLine("  3. 检查防火墙是否允许连接");
                Console.WriteLine("  4. 确认数据库是否存在");
            }
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
                var keyValue = part.Split('=');
                if (keyValue.Length == 2)
                {
                    return $"{keyValue[0]}=****";
                }
            }
            return part;
        });
        return string.Join(";", masked);
    }
}
