using System.Text;

namespace LogisticsProduction.Net8.Infrastructure.Http;

/// <summary>
/// 统一 HTTP 客户端服务
/// </summary>
public class HttpClientService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<HttpClientService> _logger;

    public HttpClientService(HttpClient httpClient, ILogger<HttpClientService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<string> GetAsync(string url)
    {
        try
        {
            _logger.LogDebug("HTTP GET: {Url}", url);
            var response = await _httpClient.GetAsync(url);
            response.EnsureSuccessStatusCode();
            var content = await response.Content.ReadAsStringAsync();
            _logger.LogDebug("HTTP GET Response: {Content}", content);
            return content;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "HTTP GET 失败: {Url}", url);
            throw;
        }
    }

    public async Task<string> PostJsonAsync(string url, string jsonBody)
    {
        try
        {
            _logger.LogDebug("HTTP POST: {Url}, Body: {Body}", url, jsonBody);
            var content = new StringContent(jsonBody, Encoding.UTF8, "application/json");
            var response = await _httpClient.PostAsync(url, content);
            response.EnsureSuccessStatusCode();
            var result = await response.Content.ReadAsStringAsync();
            _logger.LogDebug("HTTP POST Response: {Result}", result);
            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "HTTP POST 失败: {Url}", url);
            throw;
        }
    }
}
