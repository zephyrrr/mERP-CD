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
    [Class(NameType = typeof(车辆合同), Table = "参数备案_车辆合同", OptimisticLock = OptimisticLockMode.Version)]
    public class 车辆合同 : BaseBOEntity,
        IMasterEntity<车辆合同, 车辆合同费用项>
    {
        #region "interface"
        IList<车辆合同费用项> IMasterEntity<车辆合同, 车辆合同费用项>.DetailEntities
        {
            get { return 合同费用项; }
            set { 合同费用项 = value; }
        }
        #endregion

        [Bag(0, Cascade = "none", Inverse = true)]
        [Key(1, Column = "车辆合同")]
        [OneToMany(2, ClassType = typeof(车辆合同费用项), NotFound = NotFoundMode.Ignore)]
        public virtual IList<车辆合同费用项> 合同费用项
        {
            get;
            set;
        }

        [ManyToOne(NotNull = true, Insert = false, Update = false, ForeignKey = "FK_车辆合同_车辆")]
        public virtual 车辆 车辆
        {
            get;
            set;
        }

        [Property(Column = "车辆", NotNull = true)]
        public virtual Guid 车辆编号
        {
            get;
            set;
        }

        [ManyToOne(Insert = false, Update = false, ForeignKey = "FK_车辆合同_经手人")]
        public virtual 人员 经手人
        {
            get;
            set;
        }

        [Property(Column = "经手人", NotNull = true, Length = 6)]
        public virtual string 经手人编号
        {
            get;
            set;
        }

        [Property(NotNull = true)]
        public virtual DateTime 签约时间
        {
            get;
            set;
        }

        /// <summary>
        /// 有效期始
        /// </summary>
        [Property(NotNull = true)]
        public virtual DateTime 有效期始
        {
            get;
            set;
        }

        /// <summary>
        /// 有效期止
        /// </summary>
        [Property(NotNull = true)]
        public virtual DateTime 有效期止
        {
            get;
            set;
        }
    }
}
