using LogisticsProduction.Net8.Application.Dtos;

namespace LogisticsProduction.Net8.Application.Queries.LogisticsContainer;

/// <summary>
/// 物流线容器查询服务接口
/// </summary>
public interface ILogisticsContainerQueryService
{
    /// <summary>
    /// 获取容器列表
    /// </summary>
    Task<List<LogisticsContainerDto>> GetContainerListAsync(ContainerQueryRequest request);

    /// <summary>
    /// 获取容器详情
    /// </summary>
    Task<LogisticsContainerDto?> GetContainerDetailAsync(string containerCode);

    /// <summary>
    /// 根据物流线获取容器
    /// </summary>
    Task<List<LogisticsContainerDto>> GetContainersByLineAsync(string logisticsLineCode);
}
