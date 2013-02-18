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
    [JoinedSubclass(NameType = typeof(车队合同费用项), Table = "参数备案_车队合同费用项", ExtendsType = typeof(合同费用项))]
    [Key(Column = "ID", ForeignKey = "FK_车队合同费用项_合同费用项")]
    public class 车队合同费用项 : Hd.Model.合同费用项,
        IDetailEntity<车队合同, 车队合同费用项>
    {
        #region "interface"
        车队合同 IDetailEntity<车队合同, 车队合同费用项>.MasterEntity
        {
            get { return 车队合同; }
            set { 车队合同 = value; }
        }
        #endregion

        [ManyToOne(NotNull = true, Cascade = "none", ForeignKey = "FK_车队合同费用项_车队合同")]
        public virtual 车队合同 车队合同
        {
            get;
            set;
        }

        [Property(NotNull = true)]
        public virtual 收付标志 收付标志
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

        [Property(NotNull = false, Length = 255)]
        public virtual string 默认相关人
        {
            get;
            set;
        }
    }
}
