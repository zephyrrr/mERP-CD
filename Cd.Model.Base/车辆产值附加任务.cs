using System;
using System.Collections.Generic;
using System.Text;
using NHibernate.Mapping.Attributes;
using Feng;
using Hd.Model;

namespace Cd.Model
{
    //[JoinedSubclass(NameType = typeof(车辆产值附加任务), ExtendsType = typeof(车辆产值), Table = "视图查询_车辆产值_信息汇总")]
    //[Key(Column = "车辆产值", ForeignKey = "FK_车辆产值附加任务_车辆产值")]
    [Class(NameType = typeof(车辆产值附加任务), Table = "视图查询_车辆产值_信息汇总", Mutable = false)]
    public class 车辆产值附加任务 : IEntity
    {
        [Id(0, Name = "ID", Column = "Id")]
        [Generator(1, Class = "assigned")]
        public virtual Guid ID
        {
            get;
            set;
        }

        [Property(NotNull = false, Insert = false, Update = false)]
        public virtual string 装卸货地
        {
            get;
            set;
        }

        [Property(NotNull = false, Insert = false, Update = false)]
        public virtual string 委托人   
        {
            get;
            set;
        }

        [Property(NotNull = false, Insert = false, Update = false)]
        public virtual string 货代自编号
        {
            get;
            set;
        }

        [Property(NotNull = false, Insert = false, Update = false)]
        public virtual string 箱号
        {
            get;
            set;
        }

        [Property(NotNull = false, Insert = false, Update = false)]
        public virtual string 箱型
        {
            get;
            set;
        }

        [Property(NotNull = false, Insert = false, Update = false)]
        public virtual string 任务类别
        {
            get;
            set;
        }

        [Property(Column = "驾驶员", NotNull = false, Insert = false, Update = false)]
        public virtual string 驾驶员明细
        {
            get;
            set;
        }

        [Property(NotNull = false, Insert = false, Update = false)]
        public virtual Guid 车辆产值
        {
            get;
            set;
        }

        [Property(NotNull = false, Insert = false, Update = false)]
        public virtual string 指运地
        {
            get;
            set;
        }
    }
}
