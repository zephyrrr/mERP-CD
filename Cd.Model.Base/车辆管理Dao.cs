using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Feng;

namespace Cd.Model
{
    public class 车辆管理Dao : Hd.Model.BaseSubmittedDao<车辆费用实体>
    {
        public override void Submit(IRepository rep, 车辆费用实体 entity)
        {
            if (entity is 车辆事故)
            {
                车辆事故 clsg = entity as 车辆事故;
                if (clsg.日期 == null)
                {
                    throw new InvalidUserOperationException("入账日期不能为空！");
                }

                entity.Submitted = true;
                rep.Update(entity);
            }
        }

        public override void Unsubmit(IRepository rep, 车辆费用实体 entity)
        {
            entity.Submitted = false;
            rep.Update(entity);
        }
    }
}
