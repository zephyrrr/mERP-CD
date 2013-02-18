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
    [Class(NameType = typeof(车队费用项), Table = "参数备案_费用项", OptimisticLock = OptimisticLockMode.Version)]
    public class 车队费用项 : BaseEntity<string>
    {
        public override string Identity
        {
            get { return this.编号; }
        }

        ///<summary>
        ///编号
        ///</summary>
        [Id(0, Name = "编号", Column = "编号", Length = 3)]
        [Generator(1, Class = "assigned")]
        public virtual string 编号
        {
            get;
            set;
        }

        ///<summary>
        ///名称
        ///</summary>
        [Property(Length = 10, NotNull = true, Unique = true, UniqueKey = "UK_费用项_名称")]
        public virtual string 名称
        {
            get;
            set;
        }

        [Property()]
        public virtual int? 收入类别
        {
            get;
            set;
        }

        [Property()]
        public virtual int? 支出类别
        {
            get;
            set;
        }

        [Property(NotNull = true)]
        public virtual bool 票
        {
            get;
            set;
        }

        [Property(NotNull = true)]
        public virtual bool 箱
        {
            get;
            set;
        }

        [Property()]
        public virtual int? 委托人
        {
            get;
            set;
        }

        [Property()]
        public virtual int? 车主
        {
            get;
            set;
        }

        [Property()]
        public virtual int? 驾驶员
        {
            get;
            set;
        }

        [Property()]
        public virtual int? 对外
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
