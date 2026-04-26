using Microsoft.AspNetCore.Mvc;
using LogisticsProduction.Net8.Application.Commands.Sample;
using LogisticsProduction.Net8.CrossCutting.Filters;
using LogisticsProduction.Net8.Models.Responses;

namespace LogisticsProduction.Net8.Controllers.Command;

/// <summary>
/// 产品命令控制器（示例）
/// </summary>
[ApiController]
[Route("api/command/product")]
public class ProductCommandController : ControllerBase
{
    private readonly IProductCommandService _commandService;

    public ProductCommandController(IProductCommandService commandService)
    {
        _commandService = commandService;
    }

    [HttpPost("save")]
    [AvoidDuplicateRequest(3)]
    public async Task<IActionResult> SaveProduct([FromBody] SaveProductCommand command)
    {
        if (command == null)
        {
            return Ok(ApiResponse.Fail("INVALID_PARAM", "请求参数不能为空"));
        }

        var result = await _commandService.SaveProductAsync(command);
        return Ok(ApiResponse.Success(result, "保存成功"));
    }
}
