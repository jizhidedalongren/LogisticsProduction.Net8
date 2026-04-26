# 脚手架使用指南

## 🎯 快速生成新功能

使用脚手架工具可以快速生成完整的 CQRS 功能代码结构。

## 📦 使用方法

### 方式一：交互式生成（推荐）

```powershell
# 中文版
.\scripts\scaffold-cn.ps1

# 英文版
.\scripts\scaffold.ps1
```

按提示输入：
1. **功能名称**（如：WareHouse, ProductRecord）
2. **实体名称**（如：WareHouseTask, ProductRecord）
3. **功能描述**（可选）
4. **是否包含写操作**（y/n）

### 方式二：命令行直接生成

```powershell
# 只读功能
.\scripts\scaffold-feature.ps1 -FeatureName WareHouse -EntityName WareHouseTask

# 读写功能
.\scripts\scaffold-feature.ps1 -FeatureName WareHouse -EntityName WareHouseTask -IncludeCommand
```

### 示例

```
请输入功能名称（如：WareHouse, ProductRecord）: WareHouse
请输入实体名称（如：WareHouseTask, ProductRecord）: WareHouseTask
请输入功能描述（可选）: 仓库任务管理
是否包含写操作（Command）？(y/n): y

即将生成以下功能：
  功能名称: WareHouse
  实体名称: WareHouseTask
  功能描述: 仓库任务管理
  包含写操作: y

确认生成？(y/n): y
```

## 📂 生成的文件结构

### 只读功能（Query Only）

```
Domain/
├── Entities/
│   └── WareHouseTask.cs                    # 实体类
└── Interfaces/
    └── IWareHouseTaskRepository.cs         # 仓储接口

Infrastructure/
└── Persistence/
    └── WareHouseTaskRepository.cs          # 仓储实现

Application/
├── Dtos/
│   └── WareHouseTaskDto.cs                 # DTO
└── Queries/
    └── WareHouse/
        ├── IWareHouseTaskQueryService.cs   # 查询服务接口
        └── WareHouseTaskQueryService.cs    # 查询服务实现

Controllers/
└── Query/
    └── WareHouseTaskQueryController.cs     # 查询控制器
```

### 读写功能（Query + Command）

在上述基础上增加：

```
Application/
└── Commands/
    └── WareHouse/
        ├── IWareHouseTaskCommandService.cs   # 命令服务接口
        ├── WareHouseTaskCommandService.cs    # 命令服务实现
        └── SaveWareHouseTaskCommand.cs       # 命令对象

Controllers/
└── Command/
    └── WareHouseTaskCommandController.cs     # 命令控制器
```

## ✅ 生成后的步骤

### 1. 注册依赖注入

编辑 `Infrastructure/InfrastructureModule.cs`，添加：

```csharp
// WareHouse 模块
builder.RegisterType<WareHouseTaskRepository>()
    .As<IWareHouseTaskRepository>()
    .InstancePerLifetimeScope();

builder.RegisterType<WareHouseTaskQueryService>()
    .As<IWareHouseTaskQueryService>()
    .InstancePerLifetimeScope();

// 如果包含 Command
builder.RegisterType<WareHouseTaskCommandService>()
    .As<IWareHouseTaskCommandService>()
    .InstancePerLifetimeScope();
```

### 2. 创建数据库表

```sql
CREATE TABLE WareHouseTask (
    Id BIGINT PRIMARY KEY IDENTITY(1,1),
    TaskCode NVARCHAR(50) NOT NULL,
    TaskName NVARCHAR(100) NOT NULL,
    Status NVARCHAR(20) NOT NULL,
    IsEnabled BIT NOT NULL DEFAULT 1,
    CreateTime DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateTime DATETIME
);

CREATE INDEX IX_WareHouseTask_TaskCode ON WareHouseTask(TaskCode);
CREATE INDEX IX_WareHouseTask_Status ON WareHouseTask(Status);
```

### 3. 完善业务逻辑

根据实际需求修改：
- 实体属性
- Repository 查询方法
- Service 业务逻辑
- Controller 端点

### 4. 测试 API

启动项目后访问 Swagger：
- 查询接口：`GET /api/query/warehouse-task/list`
- 详情接口：`GET /api/query/warehouse-task/detail/{id}`
- 保存接口：`POST /api/command/warehouse-task/save`（如果包含 Command）

## 🎨 自定义模板

如需修改生成的代码模板，编辑 `scripts/scaffold-feature.ps1` 文件。

## 💡 最佳实践

1. **命名规范**
   - 功能名称：PascalCase（如：WareHouse）
   - 实体名称：PascalCase（如：WareHouseTask）
   - 避免使用缩写

2. **生成后检查**
   - 确认实体属性是否完整
   - 检查 Repository 方法是否满足需求
   - 验证 DTO 字段是否合适
   - 测试 API 端点

3. **渐进式开发**
   - 先生成基础结构
   - 逐步完善业务逻辑
   - 添加参数验证
   - 优化查询性能

## 🔗 相关文档

- **DEVELOPMENT_GUIDE.md** - 详细的开发流程和示例
- **ARCHITECTURE.md** - 架构规范和代码规范
