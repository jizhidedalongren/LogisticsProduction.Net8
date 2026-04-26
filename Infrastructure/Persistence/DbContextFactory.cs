using SqlSugar;
using LogisticsProduction.Net8.Infrastructure.Configuration;

namespace LogisticsProduction.Net8.Infrastructure.Persistence;

/// <summary>
/// 数据库上下文工厂
/// </summary>
public class DbContextFactory
{
    private readonly AppConfigService _configService;

    public DbContextFactory(AppConfigService configService)
    {
        _configService = configService;
    }

    public SqlSugarClient CreateClient(string connectionName = "MainDb")
    {
        var connectionString = _configService.GetConnectionString(connectionName);

        return new SqlSugarClient(new ConnectionConfig
        {
            ConnectionString = connectionString,
            DbType = DbType.SqlServer,
            IsAutoCloseConnection = true,
            InitKeyType = InitKeyType.Attribute
        });
    }
}
