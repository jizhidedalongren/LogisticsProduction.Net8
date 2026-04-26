using LogisticsProduction.Net8.Tools;
using Microsoft.AspNetCore.Mvc;

namespace LogisticsProduction.Net8.Controllers.Dev;

/// <summary>
/// 实体类生成器 API（仅开发环境）
/// </summary>
[ApiController]
[Route("dev/entity-generator")]
public class EntityGeneratorController : ControllerBase
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<EntityGeneratorController> _logger;
    private readonly IWebHostEnvironment _environment;

    public EntityGeneratorController(
        IConfiguration configuration,
        ILogger<EntityGeneratorController> logger,
        IWebHostEnvironment environment)
    {
        _configuration = configuration;
        _logger = logger;
        _environment = environment;
    }

    /// <summary>
    /// 获取连接字符串
    /// </summary>
    private string? GetConnectionString(string? connectionString, string? connectionName)
    {
        // 优先使用直接传入的连接字符串
        if (!string.IsNullOrEmpty(connectionString))
        {
            return connectionString;
        }

        // 其次使用配置文件中的连接字符串
        if (!string.IsNullOrEmpty(connectionName))
        {
            return _configuration.GetConnectionString(connectionName);
        }

        // 默认使用 MainDb
        return _configuration.GetConnectionString("MainDb");
    }

    /// <summary>
    /// 获取实体类输出路径，根据 connectionName 动态生成子目录
    /// </summary>
    private string GetOutputPath(string? connectionName)
    {
        var basePath = "Generated/Entities";
        
        // 如果提供了 connectionName，则使用它作为子目录
        var outputPath = string.IsNullOrEmpty(connectionName) 
            ? basePath 
            : Path.Combine(basePath, connectionName);
        
        // 确保目录存在
        if (!Directory.Exists(outputPath))
        {
            Directory.CreateDirectory(outputPath);
        }
        
        return outputPath;
    }

    /// <summary>
    /// 获取输出路径的提示信息
    /// </summary>
    private string GetOutputTip(string? connectionName)
    {
        if (string.IsNullOrEmpty(connectionName))
        {
            return "生成的文件位于项目根目录的 Generated/Entities/ 文件夹，请手动复制到 Domain/Entities/";
        }
        return $"生成的文件位于项目根目录的 Generated/Entities/{connectionName}/ 文件夹，请手动复制到 Domain/Entities/";
    }

    /// <summary>
    /// 生成所有表的实体类
    /// </summary>
    [HttpPost("generate-all")]
    public IActionResult GenerateAll([FromBody] GenerateAllRequest request)
    {
        if (!_environment.IsDevelopment())
        {
            return BadRequest(new { error = "此接口仅在开发环境可用" });
        }

        try
        {
            var connectionString = GetConnectionString(request.ConnectionString, request.ConnectionName);
            if (string.IsNullOrEmpty(connectionString))
            {
                return BadRequest(new { error = "未提供有效的数据库连接字符串" });
            }

            var outputPath = GetOutputPath(request.ConnectionName);
            var generator = new EntityGenerator(connectionString, outputPath);
            
            var tables = GetTableList(connectionString);
            generator.GenerateAllEntities();

            return Ok(new
            {
                success = true,
                message = "实体类生成完成",
                outputPath = Path.GetFullPath(outputPath),
                connectionName = request.ConnectionName ?? "MainDb",
                tableCount = tables.Count,
                tables = tables.Select(t => t.Name).ToList(),
                tip = GetOutputTip(request.ConnectionName)
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "生成所有实体类失败");
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// 生成指定表的实体类
    /// </summary>
    [HttpPost("generate")]
    public IActionResult Generate([FromBody] GenerateRequest request)
    {
        if (!_environment.IsDevelopment())
        {
            return BadRequest(new { error = "此接口仅在开发环境可用" });
        }

        if (string.IsNullOrEmpty(request.TableName))
        {
            return BadRequest(new { error = "请提供表名参数 tableName" });
        }

        try
        {
            var connectionString = GetConnectionString(request.ConnectionString, request.ConnectionName);
            if (string.IsNullOrEmpty(connectionString))
            {
                return BadRequest(new { error = "未提供有效的数据库连接字符串" });
            }

            var outputPath = GetOutputPath(request.ConnectionName);
            var generator = new EntityGenerator(connectionString, outputPath);

            if (request.WithBase)
            {
                generator.GenerateEntityWithBase(request.TableName);
            }
            else
            {
                generator.GenerateEntity(request.TableName);
            }

            var filePath = Path.GetFullPath(Path.Combine(outputPath, $"{request.TableName}.cs"));

            return Ok(new
            {
                success = true,
                message = $"实体类 {request.TableName} 生成完成",
                tableName = request.TableName,
                connectionName = request.ConnectionName ?? "MainDb",
                filePath,
                withBase = request.WithBase,
                tip = GetOutputTip(request.ConnectionName)
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "生成实体类 {TableName} 失败", request.TableName);
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// 批量生成指定的表
    /// </summary>
    [HttpPost("generate-batch")]
    public IActionResult GenerateBatch([FromBody] GenerateBatchRequest request)
    {
        if (!_environment.IsDevelopment())
        {
            return BadRequest(new { error = "此接口仅在开发环境可用" });
        }

        if (request.TableNames == null || request.TableNames.Length == 0)
        {
            return BadRequest(new { error = "请提供表名列表 tableNames" });
        }

        try
        {
            var connectionString = GetConnectionString(request.ConnectionString, request.ConnectionName);
            if (string.IsNullOrEmpty(connectionString))
            {
                return BadRequest(new { error = "未提供有效的数据库连接字符串" });
            }

            var outputPath = GetOutputPath(request.ConnectionName);
            var generator = new EntityGenerator(connectionString, outputPath);

            var results = new List<object>();
            foreach (var tableName in request.TableNames)
            {
                try
                {
                    if (request.WithBase)
                    {
                        generator.GenerateEntityWithBase(tableName);
                    }
                    else
                    {
                        generator.GenerateEntity(tableName);
                    }

                    results.Add(new
                    {
                        tableName,
                        success = true,
                        filePath = Path.GetFullPath(Path.Combine(outputPath, $"{tableName}.cs"))
                    });
                }
                catch (Exception ex)
                {
                    results.Add(new
                    {
                        tableName,
                        success = false,
                        error = ex.Message
                    });
                }
            }

            return Ok(new
            {
                success = true,
                message = "批量生成完成",
                outputPath = Path.GetFullPath(outputPath),
                connectionName = request.ConnectionName ?? "MainDb",
                results,
                tip = GetOutputTip(request.ConnectionName)
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "批量生成实体类失败");
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// 获取数据库中的所有表
    /// </summary>
    [HttpPost("tables")]
    public IActionResult GetTables([FromBody] ConnectionRequest request)
    {
        if (!_environment.IsDevelopment())
        {
            return BadRequest(new { error = "此接口仅在开发环境可用" });
        }

        try
        {
            var connectionString = GetConnectionString(request.ConnectionString, request.ConnectionName);
            if (string.IsNullOrEmpty(connectionString))
            {
                return BadRequest(new { error = "未提供有效的数据库连接字符串" });
            }

            var tables = GetTableList(connectionString);

            return Ok(new
            {
                success = true,
                tableCount = tables.Count,
                tables = tables.Select(t => new
                {
                    name = t.Name,
                    description = t.Description
                }).ToList()
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "获取表列表失败");
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// 获取表的列信息
    /// </summary>
    [HttpPost("table-columns")]
    public IActionResult GetTableColumns([FromBody] TableColumnsRequest request)
    {
        if (!_environment.IsDevelopment())
        {
            return BadRequest(new { error = "此接口仅在开发环境可用" });
        }

        if (string.IsNullOrEmpty(request.TableName))
        {
            return BadRequest(new { error = "请提供表名参数 tableName" });
        }

        try
        {
            var connectionString = GetConnectionString(request.ConnectionString, request.ConnectionName);
            if (string.IsNullOrEmpty(connectionString))
            {
                return BadRequest(new { error = "未提供有效的数据库连接字符串" });
            }

            var db = new SqlSugar.SqlSugarClient(new SqlSugar.ConnectionConfig
            {
                ConnectionString = connectionString,
                DbType = SqlSugar.DbType.SqlServer,
                IsAutoCloseConnection = true
            });

            var columns = db.DbMaintenance.GetColumnInfosByTableName(request.TableName, false);

            return Ok(new
            {
                success = true,
                tableName = request.TableName,
                columnCount = columns.Count,
                columns = columns.Select(c => new
                {
                    name = c.DbColumnName,
                    dataType = c.DataType,
                    length = c.Length,
                    isPrimaryKey = c.IsPrimarykey,
                    isIdentity = c.IsIdentity,
                    isNullable = c.IsNullable,
                    description = c.ColumnDescription
                }).ToList()
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "获取表 {TableName} 的列信息失败", request.TableName);
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// 清空生成的文件夹
    /// </summary>
    [HttpDelete("clean")]
    public IActionResult Clean([FromQuery] string? connectionName = null)
    {
        if (!_environment.IsDevelopment())
        {
            return BadRequest(new { error = "此接口仅在开发环境可用" });
        }

        try
        {
            var outputPath = string.IsNullOrEmpty(connectionName) 
                ? "Generated/Entities" 
                : Path.Combine("Generated/Entities", connectionName);
                
            if (Directory.Exists(outputPath))
            {
                var files = Directory.GetFiles(outputPath, "*.cs");
                foreach (var file in files)
                {
                    System.IO.File.Delete(file);
                }

                return Ok(new
                {
                    success = true,
                    message = "清空完成",
                    outputPath = Path.GetFullPath(outputPath),
                    connectionName = connectionName ?? "(默认)",
                    deletedCount = files.Length
                });
            }

            return Ok(new
            {
                success = true,
                message = "文件夹不存在或已为空",
                outputPath = Path.GetFullPath(outputPath),
                connectionName = connectionName ?? "(默认)",
                deletedCount = 0
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "清空生成文件夹失败");
            return StatusCode(500, new { error = ex.Message });
        }
    }

    private List<SqlSugar.DbTableInfo> GetTableList(string connectionString)
    {
        var db = new SqlSugar.SqlSugarClient(new SqlSugar.ConnectionConfig
        {
            ConnectionString = connectionString,
            DbType = SqlSugar.DbType.SqlServer,
            IsAutoCloseConnection = true
        });

        return db.DbMaintenance.GetTableInfoList(false);
    }
}

/// <summary>
/// 连接请求基类
/// </summary>
public class ConnectionRequest
{
    /// <summary>
    /// 数据库连接字符串（优先使用）
    /// </summary>
    public string? ConnectionString { get; set; }

    /// <summary>
    /// 连接字符串名称（从配置文件读取）
    /// </summary>
    public string? ConnectionName { get; set; }
}

/// <summary>
/// 生成所有表请求模型
/// </summary>
public class GenerateAllRequest : ConnectionRequest
{
}

/// <summary>
/// 生成单个表请求模型
/// </summary>
public class GenerateRequest : ConnectionRequest
{
    /// <summary>
    /// 表名
    /// </summary>
    public string TableName { get; set; } = string.Empty;

    /// <summary>
    /// 是否继承 BaseEntity
    /// </summary>
    public bool WithBase { get; set; } = true;
}

/// <summary>
/// 批量生成请求模型
/// </summary>
public class GenerateBatchRequest : ConnectionRequest
{
    /// <summary>
    /// 表名列表
    /// </summary>
    public string[] TableNames { get; set; } = Array.Empty<string>();

    /// <summary>
    /// 是否继承 BaseEntity
    /// </summary>
    public bool WithBase { get; set; } = true;
}

/// <summary>
/// 查看表列信息请求模型
/// </summary>
public class TableColumnsRequest : ConnectionRequest
{
    /// <summary>
    /// 表名
    /// </summary>
    public string TableName { get; set; } = string.Empty;
}
