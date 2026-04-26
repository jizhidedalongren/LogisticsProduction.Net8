namespace LogisticsProduction.Net8.Domain.Exceptions;

/// <summary>
/// 业务异常基类
/// </summary>
public class BizException : Exception
{
    public string Code { get; }

    public BizException(string code, string message) : base(message)
    {
        Code = code;
    }

    public BizException(string code, string message, Exception innerException) 
        : base(message, innerException)
    {
        Code = code;
    }
}
