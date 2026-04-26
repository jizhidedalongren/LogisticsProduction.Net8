using LogisticsProduction.Net8.Domain.Exceptions;

namespace LogisticsProduction.Net8.Application.Commands.Sample;

/// <summary>
/// 产品命令服务实现
/// </summary>
public class ProductCommandService : IProductCommandService
{
    // TODO: 注入所需的 Repository

    public async Task<bool> SaveProductAsync(SaveProductCommand command)
    {
        if (string.IsNullOrEmpty(command.ProductCode))
        {
            throw new BizException("INVALID_PARAM", "产品编码不能为空");
        }

        // TODO: 调用 Repository 保存数据
        await Task.CompletedTask;
        
        return true;
    }
}
