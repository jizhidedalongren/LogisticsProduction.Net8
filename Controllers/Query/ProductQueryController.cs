using Microsoft.AspNetCore.Mvc;
using LogisticsProduction.Net8.Application.Queries.Sample;
using LogisticsProduction.Net8.Models.Responses;

namespace LogisticsProduction.Net8.Controllers.Query;

/// <summary>
/// 产品查询控制器（示例）
/// </summary>
[ApiController]
[Route("api/query/product")]
public class ProductQueryController : ControllerBase
{
    private readonly IProductQueryService _queryService;

    public ProductQueryController(IProductQueryService queryService)
    {
        _queryService = queryService;
    }

    [HttpGet("list")]
    public async Task<IActionResult> GetProductList([FromQuery] string keyword = "")
    {
        var result = await _queryService.GetProductListAsync(keyword);
        return Ok(ApiResponse.Success(result));
    }

    [HttpGet("detail/{productCode}")]
    public async Task<IActionResult> GetProductDetail(string productCode)
    {
        var result = await _queryService.GetProductDetailAsync(productCode);
        return Ok(ApiResponse.Success(result));
    }
}
