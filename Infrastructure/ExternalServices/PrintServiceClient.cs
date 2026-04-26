using LogisticsProduction.Net8.Infrastructure.Configuration;
using LogisticsProduction.Net8.Infrastructure.Http;

namespace LogisticsProduction.Net8.Infrastructure.ExternalServices;

/// <summary>
/// 打印服务客户端
/// </summary>
public class PrintServiceClient
{
    private readonly HttpClientService _httpClient;
    private readonly string _baseUrl;

    public PrintServiceClient(HttpClientService httpClient, IConfiguration configuration)
    {
        _httpClient = httpClient;
        _baseUrl = configuration["ExternalServices:PrintServiceUrl"] ?? "";
    }

    public async Task<string> PrintLabelAsync(string labelData)
    {
        var url = $"{_baseUrl}/api/print";
        return await _httpClient.PostJsonAsync(url, labelData);
    }
}
