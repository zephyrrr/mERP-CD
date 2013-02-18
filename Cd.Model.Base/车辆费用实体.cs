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
    [JoinedSubclass(NameType = typeof(车辆费用实体), Table = "车辆_车辆费用实体", ExtendsType = typeof(费用实体))]
    [Key(Column = "ID")]
    public abstract class 车辆费用实体 : 费用实体, IDeletableEntity
    {
        #region "Interface"
        bool IDeletableEntity.CanBeDelete(OperateArgs e)
        {
            e.Repository.Initialize(this.费用, this);
            if (this.费用 != null && this.费用.Count > 0)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        #endregion

        [Property(NotNull = false)]
        public virtual DateTime? 日期
        {
            get;
            set;
        }

        [ManyToOne(NotNull = false, Insert = false, Update = false)]
        public virtual 人员 相关人
        {
            get;
            set;
        }

        [Property(Column = "相关人", Length = 6, NotNull = false)]
        public virtual string 相关人编号
        {
            get;
            set;
        }

        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 金额
        {
            get;
            set;
        }

        [ManyToOne(NotNull = false, Insert = false, Update = false)]
        public virtual 人员 车主
        {
            get;
            set;
        }

        [Property(Column = "车主", Length = 6, NotNull = false)]
        public virtual string 车主编号
        {
            get;
            set;
        }

        [ManyToOne(NotNull = false, Insert = false, Update = false)]
        public virtual 车辆 车辆
        {
            get;
            set;
        }

        [Property(Column = "车辆", NotNull = false)]
        public virtual Guid? 车辆编号
        {
            get;
            set;
        }
        [ManyToOne(NotNull = false, Insert = false, Update = false)]
        public virtual 人员 驾驶员
        {
            get;
            set;
        }

        [Property(Column = "驾驶员", Length = 6, NotNull = false)]
        public virtual string 驾驶员编号
        {
            get;
            set;
        }

        [Property(NotNull = false, Length = 500)]
        public virtual string 备注
        {
            get;
            set;
        }

        [Property(NotNull = false, Length = 100)]
        public virtual string 警示状态
        {
            get;
            set;
        }

        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 对外已确认
        {
            get;
            set;
        }

        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 对外未确认
        {
            get;
            set;
        }

        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 车主未确认
        {
            get;
            set;
        }

        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 车主已确认
        {
            get;
            set;
        }

        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 驾驶员已确认
        {
            get;
            set;
        }

        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 驾驶员未确认
        {
            get;
            set;
        }

        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 车队承担
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual DateTime? 更新时间
        {
            get;
            set;
        }
    }
}
