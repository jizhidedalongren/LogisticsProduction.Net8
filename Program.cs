using Autofac;
using Autofac.Extensions.DependencyInjection;
using LogisticsProduction.Net8.CrossCutting.Middleware;
using LogisticsProduction.Net8.Infrastructure;
using NLog;
using NLog.Web;

var logger = LogManager.Setup().LoadConfigurationFromFile("nlog.config").GetCurrentClassLogger();

try
{
    var builder = WebApplication.CreateBuilder(args);

    // Windows 服务支持
    builder.Host.UseWindowsService();

    // NLog 集成
    builder.Logging.ClearProviders();
    builder.Host.UseNLog();

    // Autofac 集成
    builder.Host.UseServiceProviderFactory(new AutofacServiceProviderFactory());
    builder.Host.ConfigureContainer<ContainerBuilder>(containerBuilder =>
    {
        containerBuilder.RegisterModule<InfrastructureModule>();
    });

    // 添加服务
    builder.Services.AddControllers();
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen(options =>
    {
        // 启用 XML 注释（包括控制器级别的注释）
        var xmlFile = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
        var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
        options.IncludeXmlComments(xmlPath, includeControllerXmlComments: true);
    });

    // 添加 HttpClient
    builder.Services.AddHttpClient();

    var app = builder.Build();

    // 配置中间件管道
    // Swagger 在所有环境下启用（便于生产环境调试和文档查看）
    app.UseSwagger();
    app.UseSwaggerUI();

    // 全局异常处理中间件
    app.UseMiddleware<GlobalExceptionMiddleware>();

    // 认证中间件（暂时禁用）
    // app.UseMiddleware<AuthenticationMiddleware>();

    app.UseHttpsRedirection();
    app.UseAuthorization();
    app.MapControllers();

    app.Run();
}
catch (Exception ex)
{
    logger.Error(ex, "应用启动失败");
    throw;
}
finally
{
    LogManager.Shutdown();
}
