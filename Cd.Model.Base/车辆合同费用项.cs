using System;
using System.Collections.Generic;
using System.Text;
using NHibernate.Mapping.Attributes;
using Feng;

namespace Cd.Model
{
    [Serializable]
    [Auditable]
    [JoinedSubclass(NameType = typeof(车辆合同费用项), Table = "参数备案_车辆合同费用项", ExtendsType = typeof(合同费用项))]
    [Key(Column = "Id", ForeignKey = "FK_车辆合同费用项_合同费用项")]
    public class 车辆合同费用项 : 合同费用项,
        IDetailEntity<车辆合同, 车辆合同费用项>
    {
        #region "interface"
        车辆合同 IDetailEntity<车辆合同, 车辆合同费用项>.MasterEntity
        {
            get { return 车辆合同; }
            set { 车辆合同 = value; }
        }
        #endregion

        [ManyToOne(NotNull = true, ForeignKey = "FK_车辆合同费用项_车辆合同")]
        public virtual 车辆合同 车辆合同
        {
            get;
            set;
        }

        /// <summary>
        /// 否则为车主
        /// </summary>
        [Property(NotNull = true)]
        public virtual bool 相关人为驾驶员
        {
            get;
            set;
        }

        //[Property(NotNull = true)]
        //public virtual bool 可开票标志
        //{
        //    get;
        //    set;
        //}

        //[Property(NotNull = true)]
        //public virtual 付款合同费用项类型 付款合同费用项类型
        //{
        //    get;
        //    set;
        //}

        /////<summary>
        /////默认相关人。表达式。
        /////例如 $a := iif[%卸箱地编号% = \"900125\", \"900005\", %卸箱地编号%];iif[%卸箱地编号% = \"900125\", \"900005\", a]$
        /////车主还是驾驶员
        /////</summary>
        //[Property(Length = 400)]
        //public virtual string 默认相关人
        //{
        //    get;
        //    set;
        //}
    }
}
