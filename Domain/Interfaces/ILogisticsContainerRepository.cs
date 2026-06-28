using LogisticsProduction.Net8.Domain.Entities.MainDb;

namespace LogisticsProduction.Net8.Domain.Interfaces;

/// <summary>
/// 物流线容器仓储接口
/// </summary>
public interface ILogisticsContainerRepository : IRepository<LogisticsContainer>
{
    /// <summary>
    /// 根据物流线编码获取容器列表
    /// </summary>
    Task<List<LogisticsContainer>> GetByLogisticsLineAsync(string logisticsLineCode);

    /// <summary>
    /// 根据容器编码获取容器信息
    /// </summary>
    Task<LogisticsContainer?> GetByContainerCodeAsync(string containerCode);

    /// <summary>
    /// 获取指定状态的容器列表
    /// </summary>
    Task<List<LogisticsContainer>> GetByStatusAsync(string status);
}
