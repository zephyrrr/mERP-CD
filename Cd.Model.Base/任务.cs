using System;
using System.Collections.Generic;
using System.Text;
using NHibernate.Mapping.Attributes;
using Hd.Model;
using Feng;

namespace Cd.Model
{
    public enum 任务类别
    {
        拆 = 1,
        装 = 2,
        回 = 3,
        驳 = 4
    }

    [Serializable]
    [Auditable]
    [Class(NameType = typeof(任务), Table = "业务备案_任务", OptimisticLock = OptimisticLockMode.Version)]
    public class 任务 : BaseBOEntity, IDeletableEntity,
        IDetailEntity<车辆产值, 任务>
    {
        #region "Interface"
        bool IDeletableEntity.CanBeDelete(OperateArgs e)
        {
            if (this.车辆产值 != null)
            {
                e.Repository.Initialize(this.车辆产值, this);
                if (this.车辆产值.Submitted)
                {
                    return false;
                }
            }
            return true;
        }
        车辆产值 IDetailEntity<车辆产值, 任务>.MasterEntity
        {
            get { return this.车辆产值; }
            set { this.车辆产值 = value; }
        }
        #endregion

        public virtual 车辆产值 票
        {
            get { return 车辆产值; }
        }

        [ManyToOne(NotNull = false, Cascade = "none", ForeignKey = "FK_任务_车辆产值")]
        public virtual 车辆产值 车辆产值
        {
            get;
            set;
        }

        [Property(NotNull = true)]
        public virtual 任务类别 任务类别
        {
            get;
            set;
        }

        [ManyToOne(NotNull = true, Insert = false, Update = false, ForeignKey = "FK_任务_委托人")]
        public virtual 人员 委托人
        {
            get;
            set;
        }

        [Property(Column = "委托人", Length = 6, NotNull = true)]
        public virtual string 委托人编号
        {
            get;
            set;
        }

        [ManyToOne(NotNull = false, Insert = false, Update = false, ForeignKey = "FK_任务_指运地")]
        public virtual 人员 指运地
        {
            get;
            set;
        }

        [Property(Column = "指运地", Length = 6, NotNull = false)]
        public virtual string 指运地编号
        {
            get;
            set;
        }

        [ManyToOne(NotNull = false, Insert = false, Update = false, ForeignKey = "FK_任务_装卸货地")]
        public virtual 人员 装卸货地
        {
            get;
            set;
        }

        [Property(Column = "装卸货地", Length = 6, NotNull = false)]
        public virtual string 装卸货地编号
        {
            get;
            set;
        }

        [ManyToOne(NotNull = false, Insert = false, Update = false, ForeignKey = "FK_任务_提箱地")]
        public virtual 人员 提箱地
        {
            get;
            set;
        }

        [Property(Column = "提箱地", Length = 6, NotNull = false)]
        public virtual string 提箱地编号
        {
            get;
            set;
        }


        [ManyToOne(NotNull = false, Insert = false, Update = false, ForeignKey = "FK_任务_还箱地")]
        public virtual 人员 还箱地
        {
            get;
            set;
        }

        [Property(Column = "还箱地", Length = 6, NotNull = false)]
        public virtual string 还箱地编号
        {
            get;
            set;
        }

        [ManyToOne(NotNull = false, Insert = false, Update = false, ForeignKey = "FK_任务_船公司")]
        public virtual 人员 船公司
        {
            get;
            set;
        }

        [Property(Column = "船公司", Length = 6, NotNull = false)]
        public virtual string 船公司编号
        {
            get;
            set;
        }
        
        [Property(Length = 50, NotNull = false)]
        public virtual string 船名航次
        {
            get;
            set;
        }

        [Property(NotNull = true)]
        public virtual bool 自备箱
        {
            get;
            set;
        }

        [Property(Length = 30, NotNull = false, Index = "Idx_任务_货代自编号")]
        public virtual string 货代自编号
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual int? 箱量
        {
            get;
            set;
        }

        [Property(Length = 12, NotNull = false, Index = "Idx_任务_箱号")]
        public virtual string 箱号
        {
            get;
            set;
        }

        [Property(Length = 12, NotNull = false, Index = "Idx_任务_回货箱号")]
        public virtual string 回货箱号
        {
            get;
            set;
        }

        [ManyToOne(Insert = false, Update = false, NotNull = false, ForeignKey = "FK_任务_箱型")]
        public virtual 箱型 箱型
        {
            get;
            set;
        }

        [Property(Column = "箱型", NotNull = false)]
        public virtual int? 箱型编号
        {
            get;
            set;
        }

        [Property(Length = 50, NotNull = false)]
        public virtual string 提单号
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

        //[Property(Length = 10, NotNull = false)]
        //public virtual string 入库单号码
        //{
        //    get;
        //    set;
        //}

        [Property(NotNull = false)]
        public virtual DateTime? 提箱时间
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual DateTime? 还箱时间
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual DateTime? 装卸货时间
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual DateTime? 提箱时间要求止
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual DateTime? 还箱时间要求止 // 委托人还箱时间要求止
        {
            get;
            set;
        }

        //[Property(NotNull = false)]
        //public virtual decimal? 定耗油
        //{
        //    get;
        //    set;
        //}

        [Property(NotNull = false)]
        public virtual int? 重量
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual DateTime? 查验时间
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual DateTime? 到港时间
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual int? 转关标志
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual DateTime? 放行时间
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual DateTime? 白卡排车时间
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual DateTime? 承运人还箱时间要求止
        {
            get;
            set;
        }
    }
}
