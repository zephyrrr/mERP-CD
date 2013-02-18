using System;
using System.Collections.Generic;
using System.Text;
using NHibernate.Mapping.Attributes;
using Feng;
using Hd.Model;

namespace Cd.Model
{
    public enum 机油类别
    {
        防冻液 = 2,
        机油 = 3,
    }

    public enum 买卖标志
    {
        买入 = 1,
        卖出 = 2,
        损耗 = 3
    }

    [Serializable]
    [Auditable]
    //[UnionSubclass(NameType = typeof(车辆机油), ExtendsType = typeof(车辆费用实体), Table = "车辆_机油")]
    [JoinedSubclass(NameType = typeof(车辆机油), Table = "车辆_机油", ExtendsType = typeof(车辆费用实体))]
    [Key(Column = "ID")]
    public class 车辆机油 : 车辆费用实体
    {
        [Property(NotNull = false)]
        public virtual 机油类别 机油类别
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual 买卖标志 买卖标志
        {
            get;
            set;
        }

        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 数量
        {
            get;
            set;
        }
    }
}
