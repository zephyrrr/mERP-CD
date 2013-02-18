using System;
using System.Collections.Generic;
using System.Text;
using NHibernate.Mapping.Attributes;
using Feng;
using Hd.Model;

namespace Cd.Model
{
    //public enum 类型
    //{
    //    保险 = 1,
    //    事故 = 2
    //} 

    [Serializable]
    [Auditable]
    //[UnionSubclass(NameType = typeof(车辆事故), ExtendsType = typeof(车辆费用实体), Table = "车辆_事故")]
    [JoinedSubclass(NameType = typeof(车辆事故), Table = "车辆_事故", ExtendsType = typeof(车辆费用实体))]
    [Key(Column = "ID")]
    public class 车辆事故 : 车辆费用实体
    {
        //[Property(NotNull = true)]
        //public virtual 类型 类型
        //{
        //    get;
        //    set;
        //}
    }
}
