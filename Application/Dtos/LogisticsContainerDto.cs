using System.ComponentModel.DataAnnotations;

namespace LogisticsProduction.Net8.Application.Dtos;

/// <summary>
/// 物流线容器 DTO
/// </summary>
public class LogisticsContainerDto
{
    public string ContainerCode { get; set; } = string.Empty;
    public string ContainerName { get; set; } = string.Empty;
    public string LogisticsLineCode { get; set; } = string.Empty;
    public string ContainerType { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public string? CurrentLocation { get; set; }
    public decimal Capacity { get; set; }
    public DateTime CreateTime { get; set; }
}

/// <summary>
/// 容器查询请求
/// </summary>
public class ContainerQueryRequest
{
    [StringLength(50)]
    public string? LogisticsLineCode { get; set; }

    [StringLength(20)]
    public string? Status { get; set; }

    [StringLength(100)]
    public string? Keyword { get; set; }
}
