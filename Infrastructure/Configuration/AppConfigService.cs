namespace LogisticsProduction.Net8.Infrastructure.Configuration;

/// <summary>
/// 统一配置服务
/// </summary>
public class AppConfigService
{
    private readonly IConfiguration _configuration;

    public AppConfigService(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public string GetConnectionString(string name)
    {
        var connStr = _configuration.GetConnectionString(name);
        if (string.IsNullOrEmpty(connStr))
        {
            throw new InvalidOperationException($"连接字符串 '{name}' 未配置");
        }
        return connStr;
    }

    /// <summary>
    /// 读取连接字符串，未配置时返回 null（不抛异常）。
    /// 用于多库场景下可选数据库（如 91Db）的判断，避免生产环境未配置时启动崩溃。
    /// </summary>
    public string? GetConnectionStringOrNull(string name)
    {
        return _configuration.GetConnectionString(name);
    }

    public string GetAppSetting(string key, string defaultValue = "")
    {
        return _configuration[key] ?? defaultValue;
    }

    public T GetAppSetting<T>(string key, T defaultValue = default!)
    {
        var value = _configuration[key];
        if (string.IsNullOrEmpty(value))
        {
            return defaultValue;
        }

        try
        {
            return (T)Convert.ChangeType(value, typeof(T));
        }
        catch
        {
            return defaultValue;
        }
    }
}
