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
    [Subclass(NameType = typeof(非业务车辆费用), ExtendsType = typeof(费用), DiscriminatorValueEnumFormat = "d", DiscriminatorValueObject = 费用类型.非业务车辆费用)]
    public class 非业务车辆费用 : 费用
    {
        #region "Interface"
        public override void PreparingOperate(OperateArgs e)
        {
            base.PreparingOperate(e);

            if (e.OperateType == OperateType.Save || e.OperateType == OperateType.Update)
            {
                非业务车辆费用 entity = e.Entity as 非业务车辆费用;
                if (string.IsNullOrEmpty(entity.费用项编号))
                {
                    entity.费用类别编号 = null;
                }
                else
                {
                    e.Repository.Initialize(entity.费用实体, entity);
                    entity.费用类别编号 = entity.费用实体.费用实体类型编号;
                    if (entity.费用类别编号.HasValue && entity.费用类别编号.Value == 13)    // 车辆库存加油
                    {
                        entity.费用类别编号 = 12;//车辆加油
                        if (entity.费用归属 == 费用归属.驾驶员)
                        {
                            entity.费用类别编号 = 325;//业务油耗
                        }
                    }
                }

                if (entity.车辆编号 == null)
                {
                    if (entity.车辆费用实体 == null)
                    {
                        entity.车辆费用实体 = entity.费用实体 as 车辆费用实体;
                    }
                    else
                    {
                        e.Repository.Initialize(entity.车辆费用实体, entity);
                    }
                    entity.车辆编号 = entity.车辆费用实体 == null ? null : entity.车辆费用实体.车辆编号;
                }

                if (entity.费用归属 == 费用归属.车主 && entity.相关人编号 == null)
                {
                    if (entity.车辆费用实体 == null)
                    {
                        entity.车辆费用实体 = entity.费用实体 as 车辆费用实体;
                    }
                    else
                    {
                        e.Repository.Initialize(entity.车辆费用实体, entity);
                    }
                    entity.相关人编号 = entity.车辆费用实体.车主编号;
                }
            }
        }
        #endregion

        [ManyToOne(Insert = false, Update = false, Column = "费用实体", NotNull = false)]
        public virtual 车辆费用实体 车辆费用实体
        {
            get;
            set;
        }

        [ManyToOne(NotNull = false, Insert = false, Update = false, ForeignKey = "FK_非业务费用_车辆")]
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

        [Property(NotNull = true)]
        public virtual 费用归属 费用归属
        {
            get;
            set;
        }

        [Property(NotNull = false)]
        public virtual decimal? 数量
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
