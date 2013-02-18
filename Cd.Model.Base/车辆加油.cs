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
    //[UnionSubclass(NameType = typeof(车辆加油), ExtendsType = typeof(车辆费用实体), Table = "车辆_加油")]
    [JoinedSubclass(NameType = typeof(车辆加油), Table = "车辆_加油", ExtendsType = typeof(车辆费用实体))]
    [Key(Column = "ID")]
    public class 车辆加油 : 车辆费用实体
    {
        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 升数
        {
            get;
            set;
        }
    }
}
