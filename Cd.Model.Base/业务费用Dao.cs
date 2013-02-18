using System;
using System.Collections.Generic;
using System.Text;
using Feng;
using Hd.Model;

namespace Cd.Model
{
    internal class 业务费用处理费用信息Dao : BaseDao<业务费用>
    {
        public 业务费用处理费用信息Dao()
        {
            this.EntityOperating += new EventHandler<OperateArgs<业务费用>>(业务费用处理费用信息Dao_EntityOperating);
        }
        private HdBaseDao<费用信息> m_dao = new HdBaseDao<费用信息>();
        void 业务费用处理费用信息Dao_EntityOperating(object sender, OperateArgs<业务费用> e)
        {
            if (e.OperateType == OperateType.Save || e.OperateType == OperateType.Update)
            {
                业务费用 entity = e.Entity as 业务费用;

                // 费用信息
                if (string.IsNullOrEmpty(entity.费用项编号))
                {
                    entity.费用信息 = null;
                }
                else
                {
                    HdBaseDao<费用信息> daoFyxx = new HdBaseDao<费用信息>();

                    // 当费用项变换时，要重新设置费用信息
                    IList<费用信息> list = (e.Repository as Feng.NH.INHibernateRepository).List<费用信息>(NHibernate.Criterion.DetachedCriteria.For<费用信息>()
                                .Add(NHibernate.Criterion.Expression.Eq("费用项编号", entity.费用项编号))
                                .Add(NHibernate.Criterion.Expression.Eq("车辆产值.ID", entity.费用实体.ID)));

                    if (list.Count == 0)
                    {
                        费用信息 item = new 费用信息();
                        item.车辆产值 = entity.车辆产值;
                        item.费用项编号 = entity.费用项编号;

                        daoFyxx.Save(e.Repository, item);

                        entity.费用信息 = item;
                    }
                    else if (list.Count == 1)
                    {
                        // 修改的时候，和完全标志无关?? && e.OperateType == OperateType.Save
                        if ((entity.收付标志 == 收付标志.收 && list[0].Submitted)
                            || (entity.收付标志 == 收付标志.付 && list[0].完全标志付))
                        {
                            throw new InvalidUserOperationException("车辆产值" + entity.费用实体.ID + " 费用项" + entity.费用项编号 + "已打完全标志，不能操作费用！");
                        }
                        entity.费用信息 = list[0];
                    }
                    else
                    {
                        System.Diagnostics.Debug.Assert(false, "费用信息对同一费用主体同一费用项有多条！");
                    }
                }
            }
        }
    }

    internal class 业务费用处理费用类别Dao : BaseDao<业务费用>
    {
        public 业务费用处理费用类别Dao()
        {
            this.EntityOperating += new EventHandler<OperateArgs<业务费用>>(业务费用处理费用类别Dao_EntityOperating);
        }

        void 业务费用处理费用类别Dao_EntityOperating(object sender, OperateArgs<业务费用> e)
        {
            if (e.OperateType == OperateType.Save || e.OperateType == OperateType.Update)
            {
                业务费用 entity = e.Entity as 业务费用;

                // 费用类别
                if (string.IsNullOrEmpty(entity.费用项编号))
                {
                    entity.费用类别编号 = null;
                }
                else
                {
                    // 当费用项变换时，要重新设置费用信息
                    车队费用项 cdfyx = EntityBufferCollection.Instance.Get<车队费用项>(entity.费用项编号);
                    switch (entity.费用归属)
                    {
                        case 费用归属.委托人:
                            entity.费用类别编号 = cdfyx.委托人;
                            break;
                        case 费用归属.车主:
                            //如果是车主的，付给车主的  费用类别：拆、装、回 这种的
                            //问车主收的话，费用类别：业务支出
                            entity.费用类别编号 = cdfyx.车主;
                            if (entity.费用项编号 == "111" && entity.收付标志 == 收付标志.付)
                            {
                                entity.费用类别编号 = 321;
                            }
                            break;
                        case 费用归属.驾驶员:
                            entity.费用类别编号 = cdfyx.驾驶员;
                            break;
                        case 费用归属.对外:
                            entity.费用类别编号 = cdfyx.对外;
                            break;
                        default:
                            entity.费用类别编号 = null;
                            break;
                    }
                   
                    if (entity.费用类别编号.HasValue && entity.费用类别编号.Value == 321)    // 运费，税
                    {
                        if (entity.任务 == null)
                        {
                            throw new InvalidUserOperationException("任务为空，无法保存");
                        }
                        e.Repository.Initialize(entity.任务, entity);
                        entity.费用类别编号 = (int?)entity.任务.任务类别;
                    }

                    if (!entity.费用类别编号.HasValue)
                    {
                        throw new InvalidUserOperationException("您选择的费用项和费用归属有误，请重新选择！费用项为" + entity.费用项编号);
                    }
                }
            }
        }
    }

    internal class 业务费用处理车辆承担Dao : BaseDao<业务费用>
    {
        public 业务费用处理车辆承担Dao()
        {
            this.EntityOperating += new EventHandler<OperateArgs<业务费用>>(业务费用处理车辆承担Dao_EntityOperating);
        }

        void 业务费用处理车辆承担Dao_EntityOperating(object sender, OperateArgs<业务费用> e)
        {
            if (e.OperateType == OperateType.Save || e.OperateType == OperateType.Update)
            {
                业务费用 entity = e.Entity as 业务费用;

                // 车辆承担
                if (string.IsNullOrEmpty(entity.费用项编号))
                {
                    entity.车辆承担 = false;
                }
                else
                {
                    车队费用项 cdfyx = EntityBufferCollection.Instance.Get<车队费用项>(entity.费用项编号);

                    e.Repository.Initialize(entity.车辆产值, entity);
                    // 费用项.车辆承担 = true AND 费用归属 = 车主 AND 相关人 = 新概念（即自有车） 设置车辆承担 = true
                    if (cdfyx.车辆承担 && entity.费用归属 != 费用归属.车主 && entity.车辆产值.承运人编号 == "900001")
                    {
                        entity.车辆承担 = true;
                    }
                    else
                    {
                        entity.车辆承担 = false;
                    }

                    // 吊机费
                    if (entity.费用项编号 == "111" && entity.费用归属 == 费用归属.委托人)
                    {
                        entity.车辆承担 = false;
                    }
                }
            }  
        }
    }

    internal class 业务费用处理相关人Dao : BaseDao<业务费用>
    {
        public 业务费用处理相关人Dao()
        {
            this.EntityOperating += new EventHandler<OperateArgs<业务费用>>(业务费用处理相关人Dao_EntityOperating);
        }

        void 业务费用处理相关人Dao_EntityOperating(object sender, OperateArgs<业务费用> e)
        {
            if (e.OperateType == OperateType.Save || e.OperateType == OperateType.Update)
            {
                业务费用 entity = e.Entity as 业务费用;

                if (entity.相关人编号 == null)
                {                    
                    //当 费用归属=车主   相关人=车辆产值.承运人
                    //当 费用归属=委托人 相关人=任务.委托人
                    //当 费用归属=驾驶员  相关人=车辆产值.驾驶员
                    switch (entity.费用归属)
                    {
                        case 费用归属.委托人:
                            entity.相关人编号 = entity.任务.委托人编号;                        
                            break;
                        case 费用归属.车主:
                            entity.相关人编号 = entity.车辆产值.承运人编号;
                            break;
                        case 费用归属.驾驶员:
                            entity.相关人编号 = entity.车辆产值.驾驶员编号;
                            break;
                        default:
                            break;
                    }
                }
                if (entity.车辆编号 == null)
                {
                    entity.车辆编号 = entity.车辆产值.车辆编号;
                }
            }
        }
    }

    public class 业务费用Dao : 费用Dao
    {
        public override IRepository GenerateRepository()
        {
            return ServiceProvider.GetService<IRepositoryFactory>().GenerateRepository<业务费用>();
        }

        public 业务费用Dao()
        {
            this.AddRelationalDao(new 业务费用处理费用信息Dao());
            this.AddRelationalDao(new 业务费用处理费用类别Dao());
            this.AddRelationalDao(new 业务费用处理车辆承担Dao());
            this.AddRelationalDao(new 业务费用处理相关人Dao());
        }
    }
}
