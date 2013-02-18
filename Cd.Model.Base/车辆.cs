using System;
using System.Collections.Generic;
using System.Text;
using NHibernate.Mapping.Attributes;
using Feng;
using Hd.Model;

namespace Cd.Model
{
    public enum 车辆类别
    {
        自有车 = 1,
        代管车 = 2,
        挂靠车 = 3,
        外协车 = 4
    }

    [Serializable]
    [Auditable]
    [Class(NameType = typeof(车辆), Table = "参数备案_车辆", OptimisticLock = OptimisticLockMode.Version)]
    public class 车辆 : BaseBOEntity
    {
        [Property(Length = 20, NotNull = true, Unique = true, UniqueKey = "UK_车辆_简称")]
        public virtual string 简称
        {
            get;
            set;
        }

        [Property(NotNull = true)]
        public virtual 车辆类别 车辆类别
        {
            get;
            set;
        }


        [Property(Length = 20, NotNull = true)]
        public virtual string 车牌
        {
            get;
            set;
        }

        [Property(Length = 20, NotNull = false)]
        public virtual string 挂车号
        {
            get;
            set;
        }

        [ManyToOne(NotNull = true, Insert = false, Update = false, ForeignKey = "FK_车辆_车主")]
        public virtual 人员 车主
        {
            get;
            set;
        }

        [Property(Column = "车主", Length = 6, NotNull = true)]
        public virtual string 车主编号
        {
            get;
            set;
        }

        [ManyToOne(NotNull = false, Insert = false, Update = false, ForeignKey = "FK_车辆_默认驾驶员")]
        public virtual 人员 默认驾驶员
        {
            get;
            set;
        }

        [Property(Column = "默认驾驶员", Length = 6, NotNull = false)]
        public virtual string 默认驾驶员编号
        {
            get;
            set;
        }

        [Property(Length = 6, NotNull = true)]
        public virtual string 马力
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual bool 默认出车
        {
            get;
            set;
        }

        [Property(Length = 500, NotNull = false)]
        public virtual string 备注
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual DateTime? 卖出时间
        {
            get;
            set;
        }
    }
}
