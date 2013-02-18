using System;
using System.Collections.Generic;
using System.Text;
using NHibernate.Mapping.Attributes;
using Feng;
using Hd.Model;

namespace Cd.Model
{
    public enum 轮胎资产类别 
    {
        轮胎 = 1,
        钢圈 = 2
    }

    [Serializable]
    [Auditable]
    //[UnionSubclass(NameType = typeof(车辆轮胎), ExtendsType = typeof(车辆费用实体), Table = "车辆_轮胎")]
    [JoinedSubclass(NameType = typeof(车辆轮胎), Table = "车辆_轮胎", ExtendsType = typeof(车辆费用实体))]
    [Key(Column = "ID")]
    public class 车辆轮胎 : 车辆费用实体
    {
        [Property(NotNull = false)]
        public virtual 轮胎资产类别? 资产类别
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual DateTime? 购入时间
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual DateTime? 返回时间
        {
            get;
            set;
        }

        [Property(Length = 20, NotNull = false)]
        public virtual string 名称
        {
            get;
            set;
        }

        [Property(Length = 20, NotNull = false)]
        public virtual string 型号
        {
            get;
            set;
        }

        [Property(Length = 20, NotNull = true)]
        public virtual string 轮胎号
        {
            get;
            set;
        }
    }
}
