namespace LogisticsProduction.Net8.Application.Dtos;

/// <summary>
/// 产品数据传输对象
/// </summary>
public class ProductDto
{
    public string ProductCode { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public decimal Quantity { get; set; }
}
