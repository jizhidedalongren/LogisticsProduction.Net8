# 业务功能脚手架生成器（.NET 8 版本）
# 用法: .\scaffold-feature.ps1 -FeatureName "WareHouse" -EntityName "WareHouseTask"

param(
    [Parameter(Mandatory=$true)]
    [string]$FeatureName,
    
    [Parameter(Mandatory=$true)]
    [string]$EntityName,
    
    [string]$Description = "",
    
    [switch]$IncludeCommand = $false
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "业务功能脚手架生成器 (.NET 8)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "功能名称: $FeatureName" -ForegroundColor Yellow
Write-Host "实体名称: $EntityName" -ForegroundColor Yellow
Write-Host "包含写操作: $IncludeCommand" -ForegroundColor Yellow
Write-Host ""

# 定义文件路径
$paths = @{
    Entity = "Domain/Entities/$EntityName.cs"
    RepositoryInterface = "Domain/Interfaces/I${EntityName}Repository.cs"
    Repository = "Infrastructure/Persistence/${EntityName}Repository.cs"
    Dto = "Application/Dtos/${EntityName}Dto.cs"
    QueryServiceInterface = "Application/Queries/$FeatureName/I${EntityName}QueryService.cs"
    QueryService = "Application/Queries/$FeatureName/${EntityName}QueryService.cs"
    QueryController = "Controllers/Query/${FeatureName}Controller.cs"
    SqlScript = "Database/${EntityName}_table.sql"
}

if ($IncludeCommand) {
    $paths.CommandDto = "Application/Commands/$FeatureName/Save${EntityName}Command.cs"
    $paths.CommandServiceInterface = "Application/Commands/$FeatureName/I${EntityName}CommandService.cs"
    $paths.CommandService = "Application/Commands/$FeatureName/${EntityName}CommandService.cs"
    $paths.CommandController = "Controllers/Command/${FeatureName}Controller.cs"
}

# 创建目录
Write-Host "[1/3] 创建目录结构..." -ForegroundColor Green
foreach ($path in $paths.Values) {
    $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  创建目录: $dir" -ForegroundColor Gray
    }
}

# 生成文件内容
Write-Host "[2/3] 生成代码文件..." -ForegroundColor Green

# 1. Entity
$entityContent = @"
using SqlSugar;

namespace LogisticsProduction.Net8.Domain.Entities;

/// <summary>
/// $Description
/// </summary>
[SugarTable("$EntityName")]
public class $EntityName : BaseEntity
{
    /// <summary>
    /// 主键ID
    /// </summary>
    [SugarColumn(IsPrimaryKey = true, Length = 50)]
    public string Id { get; set; } = string.Empty;

    /// <summary>
    /// 名称
    /// </summary>
    [SugarColumn(Length = 100)]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// 是否启用
    /// </summary>
    public bool IsEnabled { get; set; } = true;

    /// <summary>
    /// 备注
    /// </summary>
    [SugarColumn(Length = 500, IsNullable = true)]
    public string? Remark { get; set; }

    // TODO: 添加其他业务字段
}
"@

# 2. Repository Interface
$repoInterfaceContent = @"
using LogisticsProduction.Net8.Domain.Entities;

namespace LogisticsProduction.Net8.Domain.Interfaces;

/// <summary>
/// ${EntityName} 仓储接口
/// </summary>
public interface I${EntityName}Repository : IRepository<$EntityName>
{
    /// <summary>
    /// 根据ID获取
    /// </summary>
    Task<${EntityName}?> GetByIdAsync(string id);

    /// <summary>
    /// 获取列表
    /// </summary>
    Task<List<$EntityName>> GetListAsync();

    // TODO: 添加其他业务查询方法
}
"@

# 3. Repository Implementation
$repoContent = @"
using LogisticsProduction.Net8.Domain.Entities;
using LogisticsProduction.Net8.Domain.Interfaces;

namespace LogisticsProduction.Net8.Infrastructure.Persistence;

/// <summary>
/// ${EntityName} 仓储实现
/// </summary>
public class ${EntityName}Repository : BaseRepository<$EntityName>, I${EntityName}Repository
{
    public ${EntityName}Repository(DbContextFactory dbFactory) : base(dbFactory)
    {
    }

    public async Task<${EntityName}?> GetByIdAsync(string id)
    {
        return await Db.Queryable<$EntityName>()
            .Where(e => e.Id == id)
            .FirstAsync();
    }

    public async Task<List<$EntityName>> GetListAsync()
    {
        return await Db.Queryable<$EntityName>()
            .Where(e => e.IsEnabled)
            .OrderBy(e => e.CreateTime, SqlSugar.OrderByType.Desc)
            .ToListAsync();
    }

    // TODO: 实现其他业务查询方法
}
"@

# 4. DTO
$dtoContent = @"
using System.ComponentModel.DataAnnotations;

namespace LogisticsProduction.Net8.Application.Dtos;

/// <summary>
/// ${EntityName} DTO
/// </summary>
public class ${EntityName}Dto
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public bool IsEnabled { get; set; }
    public string? Remark { get; set; }
    public DateTime CreateTime { get; set; }

    // TODO: 添加其他字段
}

/// <summary>
/// ${EntityName} 查询请求
/// </summary>
public class ${EntityName}QueryRequest
{
    [StringLength(100)]
    public string? Keyword { get; set; }

    // TODO: 添加其他查询条件
}
"@

# 5. Query Service Interface
$queryServiceInterfaceContent = @"
using LogisticsProduction.Net8.Application.Dtos;

namespace LogisticsProduction.Net8.Application.Queries.$FeatureName;

/// <summary>
/// ${EntityName} 查询服务接口
/// </summary>
public interface I${EntityName}QueryService
{
    /// <summary>
    /// 获取列表
    /// </summary>
    Task<List<${EntityName}Dto>> GetListAsync(${EntityName}QueryRequest request);

    /// <summary>
    /// 获取详情
    /// </summary>
    Task<${EntityName}Dto?> GetDetailAsync(string id);

    // TODO: 添加其他查询方法
}
"@

# 6. Query Service Implementation
$queryServiceContent = @"
using LogisticsProduction.Net8.Application.Dtos;
using LogisticsProduction.Net8.Domain.Interfaces;

namespace LogisticsProduction.Net8.Application.Queries.$FeatureName;

/// <summary>
/// ${EntityName} 查询服务实现
/// </summary>
public class ${EntityName}QueryService : I${EntityName}QueryService
{
    private readonly I${EntityName}Repository _repository;
    private readonly ILogger<${EntityName}QueryService> _logger;

    public ${EntityName}QueryService(
        I${EntityName}Repository repository,
        ILogger<${EntityName}QueryService> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    public async Task<List<${EntityName}Dto>> GetListAsync(${EntityName}QueryRequest request)
    {
        _logger.LogInformation("查询${EntityName}列表，参数: {@Request}", request);

        var entities = await _repository.GetListAsync();

        if (!string.IsNullOrEmpty(request.Keyword))
        {
            entities = entities.Where(e => e.Name.Contains(request.Keyword)).ToList();
        }

        _logger.LogInformation("查询到 {Count} 条记录", entities.Count);

        return entities.Select(MapToDto).ToList();
    }

    public async Task<${EntityName}Dto?> GetDetailAsync(string id)
    {
        _logger.LogInformation("查询${EntityName}详情，ID: {Id}", id);

        var entity = await _repository.GetByIdAsync(id);

        if (entity == null)
        {
            _logger.LogWarning("${EntityName}不存在: {Id}", id);
            return null;
        }

        return MapToDto(entity);
    }

    private static ${EntityName}Dto MapToDto(Domain.Entities.$EntityName entity)
    {
        return new ${EntityName}Dto
        {
            Id = entity.Id,
            Name = entity.Name,
            IsEnabled = entity.IsEnabled,
            Remark = entity.Remark,
            CreateTime = entity.CreateTime
            // TODO: 映射其他字段
        };
    }
}
"@

# 7. Query Controller
$queryControllerContent = @"
using Microsoft.AspNetCore.Mvc;
using LogisticsProduction.Net8.Application.Dtos;
using LogisticsProduction.Net8.Application.Queries.$FeatureName;
using LogisticsProduction.Net8.Models.Responses;

namespace LogisticsProduction.Net8.Controllers.Query;

/// <summary>
/// ${EntityName} 查询控制器
/// </summary>
[ApiController]
[Route("api/query/$($FeatureName.ToLower())")]
public class ${FeatureName}Controller : ControllerBase
{
    private readonly I${EntityName}QueryService _queryService;

    public ${FeatureName}Controller(I${EntityName}QueryService queryService)
    {
        _queryService = queryService;
    }

    /// <summary>
    /// 获取列表
    /// </summary>
    [HttpGet("list")]
    public async Task<IActionResult> GetList([FromQuery] ${EntityName}QueryRequest request)
    {
        var result = await _queryService.GetListAsync(request);
        return Ok(ApiResponse.Success(result));
    }

    /// <summary>
    /// 获取详情
    /// </summary>
    [HttpGet("detail/{id}")]
    public async Task<IActionResult> GetDetail(string id)
    {
        var result = await _queryService.GetDetailAsync(id);
        if (result == null)
        {
            return Ok(ApiResponse.Fail("NOT_FOUND", "${EntityName}不存在"));
        }
        return Ok(ApiResponse.Success(result));
    }
}
"@

# 8. SQL Script
$sqlContent = @"
-- ${EntityName} 表
CREATE TABLE $EntityName (
    Id NVARCHAR(50) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    IsEnabled BIT NOT NULL DEFAULT 1,
    Remark NVARCHAR(500),
    CreateTime DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateTime DATETIME
);

-- TODO: 添加其他字段和索引

-- 创建索引
CREATE INDEX IX_${EntityName}_Name ON $EntityName(Name);
CREATE INDEX IX_${EntityName}_CreateTime ON $EntityName(CreateTime DESC);

-- 插入测试数据
INSERT INTO $EntityName (Id, Name, IsEnabled, CreateTime)
VALUES 
('TEST001', '测试数据001', 1, GETDATE()),
('TEST002', '测试数据002', 1, GETDATE());
"@

# 写入文件
$files = @{
    $paths.Entity = $entityContent
    $paths.RepositoryInterface = $repoInterfaceContent
    $paths.Repository = $repoContent
    $paths.Dto = $dtoContent
    $paths.QueryServiceInterface = $queryServiceInterfaceContent
    $paths.QueryService = $queryServiceContent
    $paths.QueryController = $queryControllerContent
    $paths.SqlScript = $sqlContent
}

foreach ($file in $files.GetEnumerator()) {
    Set-Content -Path $file.Key -Value $file.Value -Encoding UTF8
    Write-Host "  创建文件: $($file.Key)" -ForegroundColor Gray
}

# Command 相关文件
if ($IncludeCommand) {
    # Command DTO
    $commandDtoContent = @"
using System.ComponentModel.DataAnnotations;

namespace LogisticsProduction.Net8.Application.Commands.$FeatureName;

/// <summary>
/// 保存${EntityName}命令
/// </summary>
public class Save${EntityName}Command
{
    [Required]
    [StringLength(50)]
    public string Id { get; set; } = string.Empty;

    [Required]
    [StringLength(100)]
    public string Name { get; set; } = string.Empty;

    [StringLength(500)]
    public string? Remark { get; set; }

    // TODO: 添加其他字段
}
"@

    # Command Service Interface
    $commandServiceInterfaceContent = @"
namespace LogisticsProduction.Net8.Application.Commands.$FeatureName;

/// <summary>
/// ${EntityName} 命令服务接口
/// </summary>
public interface I${EntityName}CommandService
{
    /// <summary>
    /// 保存
    /// </summary>
    Task<bool> SaveAsync(Save${EntityName}Command command);

    // TODO: 添加其他命令方法
}
"@

    # Command Service Implementation
    $commandServiceContent = @"
using LogisticsProduction.Net8.Domain.Exceptions;
using LogisticsProduction.Net8.Domain.Interfaces;

namespace LogisticsProduction.Net8.Application.Commands.$FeatureName;

/// <summary>
/// ${EntityName} 命令服务实现
/// </summary>
public class ${EntityName}CommandService : I${EntityName}CommandService
{
    private readonly I${EntityName}Repository _repository;
    private readonly ILogger<${EntityName}CommandService> _logger;

    public ${EntityName}CommandService(
        I${EntityName}Repository repository,
        ILogger<${EntityName}CommandService> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    public async Task<bool> SaveAsync(Save${EntityName}Command command)
    {
        _logger.LogInformation("保存${EntityName}，ID: {Id}", command.Id);

        if (string.IsNullOrEmpty(command.Id))
        {
            throw new BizException("INVALID_PARAM", "ID不能为空");
        }

        var entity = new Domain.Entities.$EntityName
        {
            Id = command.Id,
            Name = command.Name,
            Remark = command.Remark,
            IsEnabled = true,
            CreateTime = DateTime.Now
            // TODO: 映射其他字段
        };

        await _repository.InsertAsync(entity);
        
        _logger.LogInformation("${EntityName}保存成功，ID: {Id}", command.Id);
        
        return true;
    }
}
"@

    # Command Controller
    $commandControllerContent = @"
using Microsoft.AspNetCore.Mvc;
using LogisticsProduction.Net8.Application.Commands.$FeatureName;
using LogisticsProduction.Net8.CrossCutting.Filters;
using LogisticsProduction.Net8.Models.Responses;

namespace LogisticsProduction.Net8.Controllers.Command;

/// <summary>
/// ${EntityName} 命令控制器
/// </summary>
[ApiController]
[Route("api/command/$($FeatureName.ToLower())")]
public class ${FeatureName}CommandController : ControllerBase
{
    private readonly I${EntityName}CommandService _commandService;

    public ${FeatureName}CommandController(I${EntityName}CommandService commandService)
    {
        _commandService = commandService;
    }

    /// <summary>
    /// 保存
    /// </summary>
    [HttpPost("save")]
    [AvoidDuplicateRequest(3)]
    public async Task<IActionResult> Save([FromBody] Save${EntityName}Command command)
    {
        if (command == null)
        {
            return Ok(ApiResponse.Fail("INVALID_PARAM", "请求参数不能为空"));
        }

        var result = await _commandService.SaveAsync(command);
        return Ok(ApiResponse.Success(result, "保存成功"));
    }
}
"@

    Set-Content -Path $paths.CommandDto -Value $commandDtoContent -Encoding UTF8
    Set-Content -Path $paths.CommandServiceInterface -Value $commandServiceInterfaceContent -Encoding UTF8
    Set-Content -Path $paths.CommandService -Value $commandServiceContent -Encoding UTF8
    Set-Content -Path $paths.CommandController -Value $commandControllerContent -Encoding UTF8
    
    Write-Host "  创建文件: $($paths.CommandDto)" -ForegroundColor Gray
    Write-Host "  创建文件: $($paths.CommandServiceInterface)" -ForegroundColor Gray
    Write-Host "  创建文件: $($paths.CommandService)" -ForegroundColor Gray
    Write-Host "  创建文件: $($paths.CommandController)" -ForegroundColor Gray
}

# 生成 DI 注册代码
Write-Host "[3/3] 生成 DI 注册代码..." -ForegroundColor Green

$diRegistration = @"

// ========== 以下代码需要添加到 Infrastructure/InfrastructureModule.cs 的 Load 方法中 ==========

// $FeatureName 模块
builder.RegisterType<${EntityName}Repository>()
    .As<I${EntityName}Repository>()
    .InstancePerLifetimeScope();

builder.RegisterType<${EntityName}QueryService>()
    .As<I${EntityName}QueryService>()
    .InstancePerLifetimeScope();
"@

if ($IncludeCommand) {
    $diRegistration += @"

builder.RegisterType<${EntityName}CommandService>()
    .As<I${EntityName}CommandService>()
    .InstancePerLifetimeScope();
"@
}

$diRegistration += @"

// ========== 复制以上代码到 InfrastructureModule.cs ==========
"@

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "脚手架生成完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "已创建的文件：" -ForegroundColor Yellow
foreach ($path in $paths.Values) {
    Write-Host "  ✓ $path" -ForegroundColor Green
}

Write-Host ""
Write-Host "下一步操作：" -ForegroundColor Yellow
Write-Host "1. 编辑实体类，添加业务字段" -ForegroundColor White
Write-Host "2. 运行 SQL 脚本创建数据库表: Database/${EntityName}_table.sql" -ForegroundColor White
Write-Host "3. 完善 Repository、Service 中的 TODO 部分" -ForegroundColor White
Write-Host "4. 将以下代码添加到 Infrastructure/InfrastructureModule.cs：" -ForegroundColor White
Write-Host $diRegistration -ForegroundColor Cyan
Write-Host ""
Write-Host "5. 编译项目: dotnet build" -ForegroundColor White
Write-Host "6. 运行项目: dotnet run" -ForegroundColor White
Write-Host "7. 访问 Swagger: https://localhost:5001/swagger" -ForegroundColor White
Write-Host ""

# 保存 DI 注册代码到文件
$diFile = "scaffold_output_${FeatureName}_DI.txt"
Set-Content -Path $diFile -Value $diRegistration -Encoding UTF8
Write-Host "DI 注册代码已保存到: $diFile" -ForegroundColor Cyan
Write-Host ""
