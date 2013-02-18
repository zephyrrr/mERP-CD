using System;
using System.Collections.Generic;
using System.Text;
using NHibernate.Mapping.Attributes;
using Feng;
using Hd.Model;

namespace Cd.Model
{
    public enum 费用类型
    {
        车辆业务费用 = 21,
        非业务车辆费用 = 22
    }

    public enum 费用归属
    {
        委托人 = 1,
        车主 = 2,
        驾驶员 = 3,
        对外 = 4
    }

    [Serializable]
    [Auditable]
    [Subclass(NameType = typeof(业务费用), ExtendsType = typeof(费用), DiscriminatorValueEnumFormat = "d", DiscriminatorValueObject = 费用类型.车辆业务费用)]
    public class 业务费用 : 费用,  
        IDetailEntity<费用信息, 业务费用>
    {
        #region "Interface"
        

        public override bool CanBeDelete(OperateArgs e)
        {
            业务费用 entity = e.Entity as 业务费用;
            if (string.IsNullOrEmpty(entity.费用项编号))
            {
            }
            else
            {
                entity.费用项 = EntityBufferCollection.Instance.Get<费用项>(entity.费用项编号);
                {
                    IList<费用信息> list = (e.Repository as Feng.NH.INHibernateRepository).List<费用信息>(NHibernate.Criterion.DetachedCriteria.For<费用信息>()
                        .Add(NHibernate.Criterion.Expression.Eq("费用项编号", entity.费用项编号))
                        .Add(NHibernate.Criterion.Expression.Eq("车辆产值.ID", entity.费用实体.ID)));

                    if (list.Count == 0)
                    {
                        // 可能原来未有费用项，没生成费用信息
                        //throw new ArgumentException("Deleted 费用 must have 费用信息!");
                    }
                    else if (list.Count == 1)
                    {
                        // 修改的时候，和完全标志无关?? && e.OperateType == OperateType.Save
                        if ((entity.收付标志 == 收付标志.收 && list[0].Submitted)
                            || (entity.收付标志 == 收付标志.付 && list[0].完全标志付))
                        {
                            throw new InvalidUserOperationException("车辆产值" + entity.费用实体.ID + " 费用项" + entity.费用项编号 + "已打完全标志，不能操作费用！");
                        }

                        HdBaseDao<费用信息> daoFyxx = new HdBaseDao<费用信息>();
                        daoFyxx.Update(e.Repository, list[0]); // 更新Updated
                        entity.费用信息 = list[0];
                    }
                    else
                    {
                        System.Diagnostics.Debug.Assert(false, "费用信息对同一费用主体同一费用项有多条！");
                    }
                }
            }

            return base.CanBeDelete(e);
        }

        费用信息 IDetailEntity<费用信息, 业务费用>.MasterEntity
        {
            get { return 费用信息; }
            set { 费用信息 = value; }
        }
        #endregion

        [ManyToOne(NotNull = false, Cascade = "none", ForeignKey = "FK_业务费用_费用信息")]
        public virtual 费用信息 费用信息
        {
            get;
            set;
        }

        [ManyToOne(NotNull = false, Cascade = "none", ForeignKey = "FK_业务费用_任务")]
        public virtual 任务 任务
        {
            get;
            set;
        }

        //[Property(Column = "任务", NotNull = false)]
        //public virtual Guid? 任务ID
        //{
        //    get;
        //    set;
        //}

        [ManyToOne(Insert = false, Update = false, Column = "费用实体", NotNull = false)]
        public virtual 车辆产值 车辆产值
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

        [ManyToOne(NotNull = false, Insert = false, Update = false, ForeignKey = "FK_业务费用_车辆")]
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

        [Property(NotNull = false)]
        public virtual bool 车辆承担
        {
            get;
            set;
        }
    }
}
