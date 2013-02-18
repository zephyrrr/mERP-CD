using System;
using System.Collections.Generic;
using System.Text;
using NHibernate.Mapping.Attributes;
using Feng;
using Hd.Model;

namespace Cd.Model
{
    [Class(NameType = typeof(费用信息), Table = "财务_费用信息", OptimisticLock = OptimisticLockMode.Version, Polymorphism = PolymorphismType.Explicit)]
    public class 费用信息 : SubmittedEntity, IDeletableEntity,
        IMasterEntity<费用信息, 业务费用>
    {
        #region "Interface"
        bool IDeletableEntity.CanBeDelete(OperateArgs e)
        {
            e.Repository.Initialize(this.费用, this);
            return (this.费用.Count == 0);
        }

        IList<业务费用> IMasterEntity<费用信息, 业务费用>.DetailEntities
        {
            get { return 费用; }
            set { 费用 = value; }
        }

        #endregion


        [ManyToOne(Insert = false, Update = false, NotNull = true, ForeignKey = "FK_费用信息_费用项")]
        public virtual Hd.Model.费用项 费用项
        {
            get;
            set;
        }

        [Property(Column = "费用项", Length = 3, NotNull = true)]
        public virtual string 费用项编号
        {
            get;
            set;
        }

        [Property(NotNull = true)]
        public virtual bool 完全标志付
        {
            get;
            set;
        }

        ///<summary>
        ///备注
        ///</summary>
        [Property(Length = 500)]
        public virtual string 备注
        {
            get;
            set;
        }

        [ManyToOne(NotNull = true, Cascade = "none", ForeignKey = "FK_费用信息_车辆产值")]
        public virtual 车辆产值 车辆产值
        {
            get;
            set;
        }

        //[Property(Column = "车辆产值", NotNull = true)]
        //public virtual Guid 车辆产值ID
        //{
        //    get;
        //    set;
        //}

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
        public virtual decimal? 对外理论值
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
        public virtual decimal? 车主理论值
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
        public virtual decimal? 驾驶员理论值
        {
            get;
            set;
        }

        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 委托人已确认
        {
            get;
            set;
        }

        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 委托人未确认
        {
            get;
            set;
        }

        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 委托人理论值
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

        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 车队理论值
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

        [Bag(0, Cascade = "none", Inverse = true)]
        [Key(1, Column = "费用信息")]
        [OneToMany(2, ClassType = typeof(业务费用), NotFound = NotFoundMode.Ignore)]
        //[ManyToMany(2, ClassType = typeof(费用), Column = "ID", NotFound = NotFoundMode.Ignore)]
        public virtual IList<业务费用> 费用
        {
            get;
            set;
        }
    }
}
