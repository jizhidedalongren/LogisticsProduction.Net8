namespace LogisticsProduction.Net8.Models.Responses;

/// <summary>
/// 统一响应模型
/// </summary>
public class ApiResponse<T>
{
    public string Code { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public T? Data { get; set; }
    public string Timestamp { get; set; }
    public object? Errors { get; set; }

    public ApiResponse()
    {
        Timestamp = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss");
    }
}

/// <summary>
/// 响应工厂
/// </summary>
public static class ApiResponse
{
    public const string SuccessCode = "00";

    public static ApiResponse<T> Success<T>(T data, string message = "操作成功")
    {
        return new ApiResponse<T>
        {
            Code = SuccessCode,
            Message = message,
            Data = data,
            Errors = null
        };
    }

    public static ApiResponse<object?> Success(string message = "操作成功")
    {
        return Success<object?>(null, message);
    }

    public static ApiResponse<object?> Fail(string code, string message, object? errors = null)
    {
        return new ApiResponse<object?>
        {
            Code = code,
            Message = message,
            Data = null,
            Errors = errors
        };
    }
}
