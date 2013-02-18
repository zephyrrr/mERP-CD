using System;
using System.Collections.Generic;
using System.Text;
using NHibernate.Mapping.Attributes;
using Feng;
using Hd.Model;

namespace Cd.Model
{
    [Serializable]
    [Auditable]
    [JoinedSubclass(NameType = typeof(车辆库存加油), Table = "车辆_库存加油", ExtendsType = typeof(车辆费用实体))]
    [Key(Column = "ID")]
    public class 车辆库存加油 : 车辆费用实体
    {
        [Property(NotNull = true)]
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

        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 重量
        {
            get;
            set;
        }

        [Property(NotNull = false, Precision = 19, Scale = 3)]
        public virtual decimal? 密度
        {
            get;
            set;
        }
    }
}
