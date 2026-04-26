using LogisticsProduction.Net8.Infrastructure.Http;

namespace LogisticsProduction.Net8.Infrastructure.ExternalServices;

/// <summary>
/// AGV 调度服务客户端
/// </summary>
public class AgvServiceClient
{
    private readonly HttpClientService _httpClient;
    private readonly string _baseUrl;

    public AgvServiceClient(HttpClientService httpClient, IConfiguration configuration)
    {
        _httpClient = httpClient;
        _baseUrl = configuration["ExternalServices:AgvServiceUrl"] ?? "";
    }

    public async Task<string> DispatchTaskAsync(string taskData)
    {
        var url = $"{_baseUrl}/api/dispatch";
        return await _httpClient.PostJsonAsync(url, taskData);
    }
}
