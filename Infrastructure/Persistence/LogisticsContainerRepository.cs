using LogisticsProduction.Net8.Domain.Entities;
using LogisticsProduction.Net8.Domain.Interfaces;

namespace LogisticsProduction.Net8.Infrastructure.Persistence;

/// <summary>
/// 物流线容器仓储实现
/// </summary>
public class LogisticsContainerRepository : BaseRepository<LogisticsContainer>, ILogisticsContainerRepository
{
    public LogisticsContainerRepository(DbContextFactory dbFactory) : base(dbFactory)
    {
    }

    public async Task<List<LogisticsContainer>> GetByLogisticsLineAsync(string logisticsLineCode)
    {
        return await Db.Queryable<LogisticsContainer>()
            .Where(c => c.LogisticsLineCode == logisticsLineCode && c.IsEnabled)
            .OrderBy(c => c.ContainerCode)
            .ToListAsync();
    }

    public async Task<LogisticsContainer?> GetByContainerCodeAsync(string containerCode)
    {
        return await Db.Queryable<LogisticsContainer>()
            .Where(c => c.ContainerCode == containerCode)
            .FirstAsync();
    }

    public async Task<List<LogisticsContainer>> GetByStatusAsync(string status)
    {
        return await Db.Queryable<LogisticsContainer>()
            .Where(c => c.Status == status && c.IsEnabled)
            .ToListAsync();
    }
}
