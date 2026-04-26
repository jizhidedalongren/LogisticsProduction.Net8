using Autofac;
using LogisticsProduction.Net8.Application.Commands.Sample;
using LogisticsProduction.Net8.Application.Queries.Sample;
using LogisticsProduction.Net8.Application.Queries.LogisticsContainer;
using LogisticsProduction.Net8.Domain.Interfaces;
using LogisticsProduction.Net8.Infrastructure.Configuration;
using LogisticsProduction.Net8.Infrastructure.ExternalServices;
using LogisticsProduction.Net8.Infrastructure.Http;
using LogisticsProduction.Net8.Infrastructure.Persistence;

namespace LogisticsProduction.Net8.Infrastructure;

/// <summary>
/// Autofac 依赖注入模块
/// </summary>
public class InfrastructureModule : Module
{
    protected override void Load(ContainerBuilder builder)
    {
        // 单例组件
        builder.RegisterType<AppConfigService>().SingleInstance();
        builder.RegisterType<DbContextFactory>().SingleInstance();

        // 请求级组件 - Application 层
        builder.RegisterType<ProductQueryService>().As<IProductQueryService>().InstancePerLifetimeScope();
        builder.RegisterType<ProductCommandService>().As<IProductCommandService>().InstancePerLifetimeScope();
        
        // 物流容器模块
        builder.RegisterType<LogisticsContainerQueryService>()
            .As<ILogisticsContainerQueryService>()
            .InstancePerLifetimeScope();

        // 请求级组件 - Infrastructure 层
        builder.RegisterType<HttpClientService>().InstancePerLifetimeScope();
        builder.RegisterType<PrintServiceClient>().InstancePerLifetimeScope();
        builder.RegisterType<AgvServiceClient>().InstancePerLifetimeScope();
        
        // 物流容器仓储
        builder.RegisterType<LogisticsContainerRepository>()
            .As<ILogisticsContainerRepository>()
            .InstancePerLifetimeScope();
    }
}
