using SqlSugar;

namespace LogisticsProduction.Net8.Domain.Entities.Db91;

/// <summary>
/// 打印模板实体（91 库 PritMod 表）
/// </summary>
[SugarTable("PritMod")]
[Tenant("91Db")]
public partial class PritMod
{
    public PritMod()
    {
    }

    /// <summary>
    /// 模板编号
    /// </summary>
    public string? ModName { get; set; }

    /// <summary>
    /// 服务端保存路径
    /// </summary>
    public string? ServePath { get; set; }

    /// <summary>
    /// 客户端保存路径
    /// </summary>
    public string? ClientPath { get; set; }

    /// <summary>
    /// 版本
    /// </summary>
    public string? VerID { get; set; }

    /// <summary>
    /// Xml 路径
    /// </summary>
    public string? XmlPath { get; set; }

    /// <summary>
    /// Xml 名称
    /// </summary>
    public string? XmlName { get; set; }

    /// <summary>
    /// Fx 模板名称
    /// </summary>
    public string? FxModName { get; set; }

    /// <summary>
    /// 模板类型（后缀）
    /// </summary>
    public string? ModType { get; set; }

    /// <summary>
    /// 模板来源
    /// </summary>
    public string? Source { get; set; }
}
