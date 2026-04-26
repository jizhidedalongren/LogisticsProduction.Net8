namespace LogisticsProduction.Net8.Domain.Exceptions;

/// <summary>
/// 数据访问异常
/// </summary>
public class DataAccessException : Exception
{
    public DataAccessException(string message) : base(message)
    {
    }

    public DataAccessException(string message, Exception innerException) 
        : base(message, innerException)
    {
    }
}
