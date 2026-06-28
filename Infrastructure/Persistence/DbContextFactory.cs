using SqlSugar;
using LogisticsProduction.Net8.Infrastructure.Configuration;

namespace LogisticsProduction.Net8.Infrastructure.Persistence;

/// <summary>
/// 数据库上下文工厂
/// 维护一个单例 <see cref="SqlSugarScope"/>，承载所有已配置的数据库连接。
/// 实体通过 <c>[Tenant("ConfigId")]</c> 特性声明归属，查询时由 SqlSugar 自动路由到对应连接。
/// </summary>
public class DbContextFactory
{
    private readonly SqlSugarScope _scope;

    public DbContextFactory(AppConfigService configService)
    {
        var configs = new List<ConnectionConfig>();

        // 主库（必配）—— 作为首个连接，即默认连接
        var main = configService.GetConnectionStringOrNull("MainDb");
        if (!string.IsNullOrEmpty(main))
        {
            configs.Add(new ConnectionConfig
            {
                ConfigId = "MainDb",
                ConnectionString = main,
                DbType = DbType.SqlServer,
                IsAutoCloseConnection = true,
                InitKeyType = InitKeyType.Attribute
            });
        }

        // 91 库（可选）—— 未配置时跳过，避免生产环境启动崩溃
        var db91 = configService.GetConnectionStringOrNull("91Db");
        if (!string.IsNullOrEmpty(db91))
        {
            configs.Add(new ConnectionConfig
            {
                ConfigId = "91Db",
                ConnectionString = db91,
                DbType = DbType.SqlServer,
                IsAutoCloseConnection = true,
                InitKeyType = InitKeyType.Attribute
            });
        }

        _scope = new SqlSugarScope(configs);
    }

    /// <summary>
    /// 返回多库作用域，实体凭 [Tenant] 特性自动路由到对应数据库。
    /// </summary>
    public SqlSugarScope GetClient() => _scope;

    /// <summary>
    /// 显式获取指定数据库的连接（兼容旧用法及跨库场景）。
    /// </summary>
    public ISqlSugarClient GetClient(string configId) => _scope.GetConnectionScope(configId);
}
