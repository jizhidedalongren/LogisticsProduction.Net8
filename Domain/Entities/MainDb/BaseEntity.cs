namespace LogisticsProduction.Net8.Domain.Entities.MainDb;

/// <summary>
/// 实体基类
/// </summary>
public abstract class BaseEntity
{
    public DateTime CreateTime { get; set; }
    public DateTime? UpdateTime { get; set; }
}
