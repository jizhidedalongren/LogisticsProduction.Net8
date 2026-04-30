using SqlSugar;

namespace LogisticsProduction.Net8.Domain.Entities
{
    ///<summary>
    ///
    ///</summary>
    [SugarTable("PritMod")]
    public partial class PritMod
    {
        public PritMod()
        {


        }
        /// <summary>
        /// Desc: 模板编号
        /// Default:
        /// Nullable:True
        /// </summary>           
        public string ModName { get; set; }

        /// <summary>
        /// Desc:服务端保存路径
        /// Default:
        /// Nullable:True
        /// </summary>           
        public string ServePath { get; set; }

        /// <summary>
        /// Desc:客户端保存路径
        /// Default:
        /// Nullable:True
        /// </summary>           
        public string ClientPath { get; set; }

        /// <summary>
        /// Desc:版本
        /// Default:
        /// Nullable:True
        /// </summary>           
        public string VerID { get; set; }

        /// <summary>
        /// Desc:
        /// Default:
        /// Nullable:True
        /// </summary>           
        public string XmlPath { get; set; }

        /// <summary>
        /// Desc:
        /// Default:
        /// Nullable:True
        /// </summary>           
        public string XmlName { get; set; }

        /// <summary>
        /// Desc:
        /// Default:
        /// Nullable:True
        /// </summary>           
        public string FxModName { get; set; }

        /// <summary>
        /// Desc:模板类型（后缀）
        /// Default:
        /// Nullable:True
        /// </summary>           
        public string ModType { get; set; }

        /// <summary>
        /// Desc:模板来源
        /// Default:
        /// Nullable:True
        /// </summary>           
        public string Source { get; set; }

    }
}
