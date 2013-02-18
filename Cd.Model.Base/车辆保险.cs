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
    [JoinedSubclass(NameType = typeof(车辆保险), Table = "车辆_保险", ExtendsType = typeof(车辆费用实体), Abstract = true)]
    [Key(Column = "ID")]
    public class 车辆保险 : 车辆费用实体
    {
        [Property(NotNull = false, Precision = 19, Scale = 2)]//总金额
        public virtual decimal? 购入金额
        {
            get;
            set;
        }

        [Property(NotNull = false, Precision = 19, Scale = 2)]//剩余分摊
        public virtual decimal? 剩余折旧
        {
            get;
            set;
        }

        [Property(NotNull = false)]//上次分摊日期
        public virtual DateTime? 上次折旧日期
        {
            get;
            set;
        }

        [Property(NotNull = false)]//日期止
        public virtual DateTime? 卖出时间
        {
            get;
            set;
        }
    }
}
