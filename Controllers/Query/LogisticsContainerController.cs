using Microsoft.AspNetCore.Mvc;
using LogisticsProduction.Net8.Application.Dtos;
using LogisticsProduction.Net8.Application.Queries.LogisticsContainer;
using LogisticsProduction.Net8.Models.Responses;

namespace LogisticsProduction.Net8.Controllers.Query;

/// <summary>
/// 物流线容器查询控制器
/// </summary>
[ApiController]
[Route("api/query/container")]
public class LogisticsContainerController : ControllerBase
{
    private readonly ILogisticsContainerQueryService _queryService;

    public LogisticsContainerController(ILogisticsContainerQueryService queryService)
    {
        _queryService = queryService;
    }

    /// <summary>
    /// 获取容器列表
    /// </summary>
    /// <param name="request">查询条件</param>
    /// <returns>容器列表</returns>
    [HttpGet("list")]
    public async Task<IActionResult> GetContainerList([FromQuery] ContainerQueryRequest request)
    {
        var result = await _queryService.GetContainerListAsync(request);
        return Ok(ApiResponse.Success(result));
    }

    /// <summary>
    /// 获取容器详情
    /// </summary>
    /// <param name="containerCode">容器编码</param>
    /// <returns>容器详情</returns>
    [HttpGet("detail/{containerCode}")]
    public async Task<IActionResult> GetContainerDetail(string containerCode)
    {
        var result = await _queryService.GetContainerDetailAsync(containerCode);
        if (result == null)
        {
            return Ok(ApiResponse.Fail("NOT_FOUND", "容器不存在"));
        }
        return Ok(ApiResponse.Success(result));
    }

    /// <summary>
    /// 根据物流线获取容器
    /// </summary>
    /// <param name="logisticsLineCode">物流线编码</param>
    /// <returns>容器列表</returns>
    [HttpGet("by-line/{logisticsLineCode}")]
    public async Task<IActionResult> GetContainersByLine(string logisticsLineCode)
    {
        var result = await _queryService.GetContainersByLineAsync(logisticsLineCode);
        return Ok(ApiResponse.Success(result));
    }
}
