# 归档目录（_archive）

本目录集中存放**已不再活跃使用、但保留以备查阅**的历史文档、示例代码、备份与未参与编译的文件。

> 这些文件已从项目主流程中移出，**不会被构建引用**，仅作历史参考。
> 若确认不再需要，可整体删除本目录；Git 历史仍可追溯。

## 目录结构

```
_archive/
├── docs/                    # 历史/重复/已被替代的文档
│   └── entity-generator/    # 实体生成器相关的对比与总结文档
└── code/                    # 示例、备份、未参与编译的代码文件
```

## docs/ — 归档文档清单

| 文件 | 归档原因 |
|------|----------|
| `CLEANUP_SUMMARY.md` | 2026-03-27 历史清理记录（一次性总结） |
| `SECURITY_AUDIT_SUMMARY.md` | 2026-04-30 安全审计记录（已完成操作） |
| `CONFIG_BACKUP_GUIDE.md` | 配置备份指南，内容与 `SECURITY_CONFIGURATION` 重叠 |
| `SECURITY_CONFIGURATION.md` | 安全配置说明，`.gitignore` 已落地，文档冗余 |
| `IMPORTANT_FILES_CHECKLIST.md` | 备份清单，与 `CONFIG_BACKUP_GUIDE` 重叠 |
| `QUICK_START_DATABASE_CONFIG.md` | 数据库配置快速开始，与 `DATABASE_CONFIGURATION_GUIDE` 重叠 |
| `LOCAL_UPDATE_GUIDE.md` | 针对 `F:\` 路径的本地更新说明，场景过窄 |
| `entity-generator/CLEANUP_SUMMARY.md` | 实体生成器历史清理记录 |
| `entity-generator/GENERATE_ENTITY_COMPARISON.md` | 生成方法对比（开发过程记录） |
| `entity-generator/GENERATE_ENTITY_QUICK_COMPARISON.md` | 生成方法快速对比 |
| `entity-generator/IMPLEMENTATION_COMPARISON.md` | 实现方案对比 |
| `entity-generator/ENTITY_GENERATOR_API_V2_GUIDE.md` | API V2 指南，已被 README 整合 |

> 活跃文档仍保留在 `docs/`，见 [docs/DOCS_INDEX.md](../docs/DOCS_INDEX.md)。

## code/ — 归档代码清单

| 文件 | 归档原因 |
|------|----------|
| `Program.cs.example` | Program.cs 的示例旧版本（含已注释的实体生成器代码），与现行 `Program.cs` 重复 |
| `LogisticsProduction.Net8.csproj.Backup.tmp` | csproj 备份临时文件，`.gitignore` 已忽略此类文件 |
| `GenerateEntitiesProgram.cs` | 旧版独立实体生成入口，被 csproj `<Compile Remove>` 排除，已被控制器/工具替代 |

> 注意：`GenerateEntitiesProgram.cs` 原被 csproj 的 `<Compile Remove>` 排除编译。归档后，csproj 中对应的排除规则已同步清理。
>
> 91 库实体 `PritMod.cs`、`SCLZQD2_BARCODE.cs` 已迁回 `Domain/Entities/Db91/` 并启用编译
>（多数据库方案落地，见 [docs/MULTI_DATABASE_GUIDE.md](../docs/MULTI_DATABASE_GUIDE.md)）。
