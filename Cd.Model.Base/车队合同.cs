using System;
using System.Collections.Generic;
using System.Text;
using NHibernate.Mapping.Attributes;
using Hd.Model;
using Feng;

namespace Cd.Model
{
    [Serializable]
    [Auditable]
    [Class(NameType = typeof(车队合同), Table = "参数备案_车队合同", OptimisticLock = OptimisticLockMode.Version)]
    public class 车队合同 : BaseBOEntity,
        IMasterEntity<车队合同, 车队合同费用项>
    {
        #region "interface"
        IList<车队合同费用项> IMasterEntity<车队合同, 车队合同费用项>.DetailEntities
        {
            get { return 合同费用项; }
            set { 合同费用项 = value; }
        }
        #endregion

        [Bag(0, Cascade = "none", Inverse = true)]
        [Key(1, Column = "车队合同")]
        [OneToMany(2, ClassType = typeof(车队合同费用项), NotFound = NotFoundMode.Ignore)]
        public virtual IList<车队合同费用项> 合同费用项
        {
            get;
            set;
        }

        [ManyToOne(Insert = false, Update = false, ForeignKey = "FK_合同_经手人")]
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
