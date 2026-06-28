using SqlSugar;

namespace LogisticsProduction.Net8.Domain.Entities.MainDb;

/// <summary>
/// 物流线容器实体
/// </summary>
[SugarTable("LogisticsContainer")]
[Tenant("MainDb")]
public class LogisticsContainer : BaseEntity
{
    /// <summary>
    /// 容器编码（主键）
    /// </summary>
    [SugarColumn(IsPrimaryKey = true, Length = 50)]
    public string ContainerCode { get; set; } = string.Empty;

    /// <summary>
    /// 容器名称
    /// </summary>
    [SugarColumn(Length = 100)]
    public string ContainerName { get; set; } = string.Empty;

    /// <summary>
    /// 物流线编码
    /// </summary>
    [SugarColumn(Length = 50)]
    public string LogisticsLineCode { get; set; } = string.Empty;

    /// <summary>
    /// 容器类型（托盘、周转箱等）
    /// </summary>
    [SugarColumn(Length = 50)]
    public string ContainerType { get; set; } = string.Empty;

    /// <summary>
    /// 当前状态（空闲、使用中、维护中）
    /// </summary>
    [SugarColumn(Length = 20)]
    public string Status { get; set; } = string.Empty;

    /// <summary>
    /// 当前位置
    /// </summary>
    [SugarColumn(Length = 100, IsNullable = true)]
    public string? CurrentLocation { get; set; }

    /// <summary>
    /// 容量
    /// </summary>
    [SugarColumn(DecimalDigits = 2)]
    public decimal Capacity { get; set; }

    /// <summary>
    /// 是否启用
    /// </summary>
    public bool IsEnabled { get; set; } = true;

    /// <summary>
    /// 备注
    /// </summary>
    [SugarColumn(Length = 500, IsNullable = true)]
    public string? Remark { get; set; }
}
