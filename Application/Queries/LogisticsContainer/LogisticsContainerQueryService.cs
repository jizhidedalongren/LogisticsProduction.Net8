using LogisticsProduction.Net8.Application.Dtos;
using LogisticsProduction.Net8.Domain.Interfaces;

namespace LogisticsProduction.Net8.Application.Queries.LogisticsContainer;

/// <summary>
/// 物流线容器查询服务实现
/// </summary>
public class LogisticsContainerQueryService : ILogisticsContainerQueryService
{
    private readonly ILogisticsContainerRepository _repository;
    private readonly ILogger<LogisticsContainerQueryService> _logger;

    public LogisticsContainerQueryService(
        ILogisticsContainerRepository repository,
        ILogger<LogisticsContainerQueryService> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    public async Task<List<LogisticsContainerDto>> GetContainerListAsync(ContainerQueryRequest request)
    {
        _logger.LogInformation("查询容器列表，参数: {@Request}", request);

        List<Domain.Entities.LogisticsContainer> containers;

        if (!string.IsNullOrEmpty(request.LogisticsLineCode))
        {
            containers = await _repository.GetByLogisticsLineAsync(request.LogisticsLineCode);
        }
        else if (!string.IsNullOrEmpty(request.Status))
        {
            containers = await _repository.GetByStatusAsync(request.Status);
        }
        else
        {
            containers = await _repository.GetListAsync(c => c.IsEnabled);
        }

        if (!string.IsNullOrEmpty(request.Keyword))
        {
            containers = containers.Where(c =>
                c.ContainerCode.Contains(request.Keyword) ||
                c.ContainerName.Contains(request.Keyword)
            ).ToList();
        }

        _logger.LogInformation("查询到 {Count} 条容器记录", containers.Count);

        return containers.Select(MapToDto).ToList();
    }

    public async Task<LogisticsContainerDto?> GetContainerDetailAsync(string containerCode)
    {
        _logger.LogInformation("查询容器详情，容器编码: {ContainerCode}", containerCode);

        var container = await _repository.GetByContainerCodeAsync(containerCode);

        if (container == null)
        {
            _logger.LogWarning("容器不存在: {ContainerCode}", containerCode);
            return null;
        }

        return MapToDto(container);
    }

    public async Task<List<LogisticsContainerDto>> GetContainersByLineAsync(string logisticsLineCode)
    {
        _logger.LogInformation("查询物流线容器，物流线编码: {LineCode}", logisticsLineCode);

        var containers = await _repository.GetByLogisticsLineAsync(logisticsLineCode);

        _logger.LogInformation("物流线 {LineCode} 有 {Count} 个容器", logisticsLineCode, containers.Count);

        return containers.Select(MapToDto).ToList();
    }

    private static LogisticsContainerDto MapToDto(Domain.Entities.LogisticsContainer entity)
    {
        return new LogisticsContainerDto
        {
            ContainerCode = entity.ContainerCode,
            ContainerName = entity.ContainerName,
            LogisticsLineCode = entity.LogisticsLineCode,
            ContainerType = entity.ContainerType,
            Status = entity.Status,
            CurrentLocation = entity.CurrentLocation,
            Capacity = entity.Capacity,
            CreateTime = entity.CreateTime
        };
    }
}
