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
    //[UnionSubclass(NameType = typeof(车辆其他), ExtendsType = typeof(车辆费用实体), Table = "车辆_其他")]
    [JoinedSubclass(NameType = typeof(车辆其他), Table = "车辆_其他", ExtendsType = typeof(车辆费用实体))]
    [Key(Column = "ID")]
    public class 车辆其他 : 车辆费用实体
    {
    }
}
