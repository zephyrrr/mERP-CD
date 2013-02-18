using System;
using System.Collections.Generic;
using System.Text;
using NHibernate.Mapping.Attributes;
using Feng;
using Hd.Model;

namespace Cd.Model
{
    public enum 修理类型
    {
        包月 = 1,
        其他 = 9
    }

    [Serializable]
    [Auditable]
    //[UnionSubclass(NameType = typeof(车辆维修), ExtendsType = typeof(车辆费用实体), Table = "车辆_维修")]
    [JoinedSubclass(NameType = typeof(车辆维修), Table = "车辆_维修", ExtendsType = typeof(车辆费用实体))]
    [Key(Column = "ID")]
    public class 车辆维修 : 车辆费用实体
    {
        [Property(NotNull = true)]
        public virtual 修理类型 修理类型
        {
            get;
            set;
        }

        [Property(NotNull = false, Length = 50)]
        public virtual string 项目
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual DateTime? 上次日期
        {
            get;
            set;
        }
    }
}
