using System;
using System.Collections.Generic;
using System.Text;
using Feng;
using Hd.Model;

namespace Cd.Model
{
    internal class 非业务车辆费用处理车辆承担Dao : BaseDao<非业务车辆费用>
    {
        public 非业务车辆费用处理车辆承担Dao()
        {
            this.EntityOperating += new EventHandler<OperateArgs<非业务车辆费用>>(非业务车辆费用处理车辆承担Dao_EntityOperating);
        }

        void 非业务车辆费用处理车辆承担Dao_EntityOperating(object sender, OperateArgs<非业务车辆费用> e)
        {
            if (e.OperateType == OperateType.Save || e.OperateType == OperateType.Update)
            {
                非业务车辆费用 entity = e.Entity as 非业务车辆费用;

                // 车辆承担
                if (string.IsNullOrEmpty(entity.费用项编号))
                {
                    entity.车辆承担 = false;
                }
                else
                {
                    if (entity.车辆费用实体 == null)
                    {
                        entity.车辆费用实体 = entity.费用实体 as 车辆费用实体;
                    }
                    else
                    {
                        e.Repository.Initialize(entity.车辆费用实体, entity);
                    }

                    // 费用项 != 固定资产出让 AND 费用归属 = 车主 AND 相关人 = 新概念（即自有车） 设置车辆承担 = true
                    if (entity.费用项编号 != "204" && entity.费用项编号 != "386" && entity.费用归属 != 费用归属.车主 && entity.车辆费用实体.车主编号 == "900001")
                    {
                        entity.车辆承担 = true;
                    }
                    else
                    {
                        entity.车辆承担 = false;
                    }
                }
            }
        }
    }

    public class 非业务车辆费用Dao : 费用Dao
    {
        public 非业务车辆费用Dao()
        {
            this.AddRelationalDao(new 非业务车辆费用处理车辆承担Dao());
        }
    }
}
