using System;
using System.Collections.Generic;
using System.Text;
using NHibernate.Mapping.Attributes;
using Feng;
using Feng.Data;
using Hd.Model;

namespace Cd.Model
{
    public enum 任务关系
    {
        套箱 = 1,
        对箱 = 2
    }

    public enum 特殊情况
    {
        换班 = 1,
        两地装卸 =2
    }
    [Serializable]
    [Auditable]
    [JoinedSubclass(NameType = typeof(车辆产值), Table = "业务备案_车辆产值", ExtendsType = typeof(费用实体))]
    [Key(Column = "ID", ForeignKey = "FK_车辆产值_费用实体")]
    public class 车辆产值 : 费用实体, IOperatingEntity, 
        IMasterEntity<车辆产值, 任务>
    {
        #region "Interface"
        void IOperatingEntity.PreparingOperate(OperateArgs e)
        {
            if (e.OperateType == OperateType.Save)
            {
                if (string.IsNullOrEmpty(this.编号))
                {
                    // Todo
                    int delta = Feng.Utils.RepositoryHelper.GetRepositoryDelta(e.Repository, typeof(车辆产值).Name);

                    this.编号 = PrimaryMaxIdGenerator.GetMaxId("财务_费用实体", "编号", 8, PrimaryMaxIdGenerator.GetIdYearMonth(日期), delta).ToString();
                }
            }

            base.PreparingOperate(e);
        }

        void IOperatingEntity.PreparedOperate(OperateArgs e)
        {
        }


        IList<任务> IMasterEntity<车辆产值, 任务>.DetailEntities
        {
            get { return this.任务; }
            set { this.任务 = value; }
        }
        #endregion

        [Bag(0, Cascade = "none", Inverse = true)]
        [Key(1, Column = "车辆产值")]
        [OneToMany(2, ClassType = typeof(任务), NotFound = NotFoundMode.Ignore)]
        public virtual IList<任务> 任务
        {
            get;
            set;
        }

        [Bag(0, Cascade = "none", Inverse = true)]
        [Key(1, Column = "费用实体")]
        [OneToMany(2, ClassType = typeof(业务费用), NotFound = NotFoundMode.Ignore)]
        public virtual IList<业务费用> 业务费用
        {
            get;
            set;
        }

        //[Bag(0, Cascade = "none", Inverse = true)]
        //[Key(1, Column = "费用实体")]
        //[OneToMany(2, ClassType = typeof(业务油耗), NotFound = NotFoundMode.Ignore)]
        //public virtual IList<业务油耗> 业务油耗
        //{
        //    get;
        //    set;
        //}

        [Property(NotNull = true)]
        public virtual DateTime 日期
        {
            get;
            set;
        }

        [ManyToOne(NotNull = false, Insert = false, Update = false, ForeignKey = "FK_车辆产值_车辆")]
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

        [ManyToOne(NotNull = true, Insert = false, Update = false, ForeignKey = "FK_车辆产值_承运人")]
        public virtual 人员 承运人
        {
            get;
            set;
        }

        [Property(Column = "承运人", Length = 6, NotNull = true)]
        public virtual string 承运人编号
        {
            get;
            set;
        }

        [ManyToOne(NotNull = false, Insert = false, Update = false, ForeignKey = "FK_车辆产值_驾驶员")]
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

        [Property(NotNull = false)]
        public virtual string 任务关系
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual string 特殊情况
        {
            get;
            set;
        }
        //[Property(NotNull = false)]
        //public virtual decimal? 公里
        //{
        //    get;
        //    set;
        //}

        //[Property(NotNull = false)]
        //public virtual decimal? 实耗油
        //{
        //    get;
        //    set;
        //}

        // 同样是富阳，哪里上高速不一样
        [Property(NotNull = false)]
        public virtual string 路线
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

        //[OneToOne(Cascade = "none", Fetch = NHibernate.Mapping.Attributes.FetchMode.Join, Constrained = true)]
        [ManyToOne(Insert = false, Update = false, Column = "ID")]
        public virtual 车辆产值附加任务 附加任务
        {
            get;
            set;
        }
    }
}
