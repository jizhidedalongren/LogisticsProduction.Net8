# 架构规范与开发指南 (.NET 8)

## 层间依赖规则

| 引用方 → 被引用方 | Domain | Application | Infrastructure | Controllers | CrossCutting |
|-------------------|--------|-------------|----------------|-------------|--------------|
| Domain            | -      | ❌          | ❌             | ❌          | ❌           |
| Application       | ✅     | -           | ❌             | ❌          | ✅           |
| Infrastructure    | ✅     | ✅          | -              | ❌          | ✅           |
| Controllers       | ❌     | ✅          | ❌             | -           | ✅           |
| CrossCutting      | ✅     | ❌          | ❌             | ❌          | -            |

## 新功能开发流程

1. **Domain 层**：定义实体、仓储接口、业务异常
2. **Application 层**：创建 Command/Query Service 接口和实现
3. **Infrastructure 层**：实现 Repository，编写参数化 SQL
4. **Controllers 层**：创建 Controller，调用 Service
5. **DI 注册**：在 InfrastructureModule 或 Program.cs 中注册新组件

## .NET 8 特性使用规范

- 使用 nullable 引用类型（已启用）
- 使用 file-scoped namespace
- 优先使用 async/await
- 使用 record 类型定义 DTO
- 使用 minimal API 或 Controller（当前使用 Controller）

## 代码审查检查清单

- [ ] Domain 层没有引用 SqlSugar、ASP.NET Core 等外部库
- [ ] Controller 方法体不超过 15 行，无业务逻辑
- [ ] 所有 SQL 操作使用参数化查询，无字符串拼接
- [ ] Service 返回 DTO 或抛出异常
- [ ] 通过构造函数注入依赖
- [ ] 写操作使用 AvoidDuplicateRequest 防重
- [ ] 所有 I/O 操作使用异步方法

## 命名规范

- 类名/方法：PascalCase
- 参数/变量：camelCase
- 接口：I + PascalCase
- 常量：PascalCase 或 UPPER_CASE
- 异步方法：以 Async 结尾
