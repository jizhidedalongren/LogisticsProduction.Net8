using System.Net;
using System.Text.Json;
using LogisticsProduction.Net8.Domain.Exceptions;
using LogisticsProduction.Net8.Models.Responses;

namespace LogisticsProduction.Net8.CrossCutting.Middleware;

/// <summary>
/// 全局异常处理中间件
/// </summary>
public class GlobalExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<GlobalExceptionMiddleware> _logger;

    public GlobalExceptionMiddleware(RequestDelegate next, ILogger<GlobalExceptionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (BizException bizEx)
        {
            _logger.LogWarning(bizEx, "业务异常: {Code} - {Message}", bizEx.Code, bizEx.Message);
            await HandleExceptionAsync(context, HttpStatusCode.OK, 
                ApiResponse.Fail(bizEx.Code, bizEx.Message));
        }
        catch (DataAccessException dataEx)
        {
            _logger.LogError(dataEx, "数据访问异常");
            await HandleExceptionAsync(context, HttpStatusCode.InternalServerError,
                ApiResponse.Fail("DB_ERROR", "数据库操作失败"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "系统异常");
            await HandleExceptionAsync(context, HttpStatusCode.InternalServerError,
                ApiResponse.Fail("SYS_ERROR", "系统内部错误"));
        }
    }

    private static async Task HandleExceptionAsync(HttpContext context, HttpStatusCode statusCode, object response)
    {
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)statusCode;
        await context.Response.WriteAsync(JsonSerializer.Serialize(response));
    }
}
