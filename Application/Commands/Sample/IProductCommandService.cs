namespace LogisticsProduction.Net8.Application.Commands.Sample;

/// <summary>
/// 产品命令服务接口
/// </summary>
public interface IProductCommandService
{
    Task<bool> SaveProductAsync(SaveProductCommand command);
}
