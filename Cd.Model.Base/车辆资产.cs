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
    //[UnionSubclass(NameType = typeof(车辆资产), ExtendsType = typeof(车辆费用实体), Table = "车辆_资产")]
    [JoinedSubclass(NameType = typeof(车辆资产), Table = "车辆_资产", ExtendsType = typeof(车辆费用实体))]
    [Key(Column = "ID")]
    public class 车辆资产 : 车辆费用实体
    {
        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 购入金额
        {
            get;
            set;
        }

        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 购置税
        {
            get;
            set;
        }

        [Property(Length = 50, NotNull = false)]
        public virtual string 发动机号
        {
            get;
            set;
        }

        [Property(Length = 50, NotNull = false)]
        public virtual string 合格证号
        {
            get;
            set;
        }

        [Property(Length = 50, NotNull = false)]
        public virtual string 识别代号
        {
            get;
            set;
        }

        [Property(Length = 50, NotNull = false)]
        public virtual string 厂牌
        {
            get;
            set;
        }

        [Property(Length = 50, NotNull = false)]
        public virtual string 产地
        {
            get;
            set;
        }

        [Property(Length = 50, NotNull = false)]
        public virtual string 销售单位
        {
            get;
            set;
        }

        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 卖出金额
        {
            get;
            set;
        }

        [Property(NotNull = false, Precision = 19, Scale = 2)]
        public virtual decimal? 剩余折旧
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual DateTime? 上次折旧日期
        {
            get;
            set;
        }

        //[Property(NotNull = false)]//这个字段放到车辆备案
        //public virtual DateTime? 卖出时间
        //{
        //    get;
        //    set;
        //}

        [ManyToOne(NotNull = false, Insert = false, Update = false)]
        public virtual 人员 买方
        {
            get;
            set;
        }

        [Property(Column = "买方", Length = 6, NotNull = false)]
        public virtual string 买方编号
        {
            get;
            set;
        }
    }
}
