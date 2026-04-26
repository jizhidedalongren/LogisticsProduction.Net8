namespace LogisticsProduction.Net8.Application.Commands.Sample;

/// <summary>
/// 保存产品命令 DTO
/// </summary>
public class SaveProductCommand
{
    public string ProductCode { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public decimal Quantity { get; set; }
}
