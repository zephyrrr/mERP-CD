using System;
using System.Collections.Generic;
using System.Text;
using NHibernate.Mapping.Attributes;
using Hd.Model;

namespace Cd.Model
{
    [Class(NameType = typeof(业务费用理论值), Table = "财务_业务费用理论值", OptimisticLock = OptimisticLockMode.Version)]
    public class 业务费用理论值: Feng.BaseBOEntity
    {
        [ManyToOne(NotNull = true, Cascade = "none", ForeignKey = "FK_业务费用理论值_费用实体", Index = "Idx_业务费用理论值_费用实体")]
        public virtual Hd.Model.费用实体 费用实体
        {
            get;
            set;
        }

        [ManyToOne(Insert = false, Update = false, ForeignKey = "FK_业务费用理论值_费用项")]
        public virtual 费用项 费用项
        {
            get;
            set;
        }

        [Property(Column = "费用项", NotNull = false, Length = 3)]
        public virtual string 费用项编号
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual 收付标志 收付标志
        {
            get;
            set;
        }


        [ManyToOne(Insert = false, Update = false, ForeignKey = "FK_业务费用理论值_相关人")]
        public virtual 人员 相关人
        {
            get;
            set;
        }

        [Property(Column = "相关人", NotNull = false, Length = 6)]
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

        [ManyToOne(Insert = false, Update = false, NotNull = false, ForeignKey = "FK_业务费用理论值_任务")]
        public virtual 任务 任务
        {
            get;
            set;
        }

        [Property(Column = "任务", NotNull = false)]
        public virtual Guid? 任务ID
        {
            get;
            set;
        }

        [ManyToOne(Insert = false, Update = false, Column = "费用实体", NotNull = true, ForeignKey = "FK_业务费用理论值_普通票")]
        public virtual 车辆产值 票
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

        [Property(NotNull = true)]
        public virtual 费用归属 费用归属
        {
            get;
            set;
        }

        [ManyToOne(NotNull = false, Insert = false, Update = false, ForeignKey = "FK_业务费用理论值_车辆")]
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
    }
}
