using LogisticsProduction.Net8.Application.Dtos;

namespace LogisticsProduction.Net8.Application.Queries.Sample;

/// <summary>
/// 产品查询服务接口
/// </summary>
public interface IProductQueryService
{
    Task<List<ProductDto>> GetProductListAsync(string keyword);
    Task<ProductDto?> GetProductDetailAsync(string productCode);
}
