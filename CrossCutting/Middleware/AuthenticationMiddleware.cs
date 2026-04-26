using System.Text.Json;
using LogisticsProduction.Net8.Models.Responses;

namespace LogisticsProduction.Net8.CrossCutting.Middleware;

/// <summary>
/// 认证中间件
/// </summary>
public class AuthenticationMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<AuthenticationMiddleware> _logger;

    public AuthenticationMiddleware(RequestDelegate next, ILogger<AuthenticationMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // 检查是否是匿名端点
        var endpoint = context.GetEndpoint();
        var allowAnonymous = endpoint?.Metadata.GetMetadata<AllowAnonymousAttribute>() != null;

        if (!allowAnonymous)
        {
            if (!context.Request.Headers.TryGetValue("Ticket", out var ticket) || string.IsNullOrEmpty(ticket))
            {
                context.Response.StatusCode = 401;
                context.Response.ContentType = "application/json";
                await context.Response.WriteAsync(
                    JsonSerializer.Serialize(ApiResponse.Fail("AUTH_REQUIRED", "缺少认证票据"))
                );
                return;
            }

            if (!ValidateTicket(ticket!))
            {
                context.Response.StatusCode = 401;
                context.Response.ContentType = "application/json";
                await context.Response.WriteAsync(
                    JsonSerializer.Serialize(ApiResponse.Fail("AUTH_FAILED", "认证失败"))
                );
                return;
            }
        }

        await _next(context);
    }

    private bool ValidateTicket(string ticket)
    {
        // TODO: 对接数据库或外部身份服务进行票据验证
        return !string.IsNullOrEmpty(ticket);
    }
}

[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
public class AllowAnonymousAttribute : Attribute
{
}
