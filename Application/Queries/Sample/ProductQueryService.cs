using LogisticsProduction.Net8.Application.Dtos;

namespace LogisticsProduction.Net8.Application.Queries.Sample;

/// <summary>
/// 产品查询服务实现
/// </summary>
public class ProductQueryService : IProductQueryService
{
    // TODO: 注入所需的 Repository

    public async Task<List<ProductDto>> GetProductListAsync(string keyword)
    {
        // TODO: 实现查询逻辑
        await Task.CompletedTask;
        return new List<ProductDto>();
    }

    public async Task<ProductDto?> GetProductDetailAsync(string productCode)
    {
        // TODO: 实现查询逻辑
        await Task.CompletedTask;
        return null;
    }
}
