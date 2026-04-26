using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.Caching.Memory;
using LogisticsProduction.Net8.Models.Responses;

namespace LogisticsProduction.Net8.CrossCutting.Filters;

/// <summary>
/// 防重复请求过滤器
/// </summary>
[AttributeUsage(AttributeTargets.Method)]
public class AvoidDuplicateRequestAttribute : ActionFilterAttribute
{
    private static readonly IMemoryCache Cache = new MemoryCache(new MemoryCacheOptions());
    private readonly int _intervalSeconds;

    public AvoidDuplicateRequestAttribute(int intervalSeconds = 2)
    {
        _intervalSeconds = intervalSeconds;
    }

    public override void OnActionExecuting(ActionExecutingContext context)
    {
        var cacheKey = GenerateCacheKey(context);

        if (Cache.TryGetValue(cacheKey, out _))
        {
            context.Result = new OkObjectResult(
                ApiResponse.Fail("DUPLICATE_REQUEST", "请求过于频繁，请稍后再试")
            );
            return;
        }

        Cache.Set(cacheKey, true, TimeSpan.FromSeconds(_intervalSeconds));
    }

    private string GenerateCacheKey(ActionExecutingContext context)
    {
        var clientIp = context.HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        var actionName = context.ActionDescriptor.DisplayName ?? "unknown";
        var parameters = JsonSerializer.Serialize(context.ActionArguments);

        var rawKey = $"{clientIp}_{actionName}_{parameters}";
        return ComputeHash(rawKey);
    }

    private string ComputeHash(string input)
    {
        var bytes = Encoding.UTF8.GetBytes(input);
        var hash = MD5.HashData(bytes);
        return BitConverter.ToString(hash).Replace("-", "");
    }
}
