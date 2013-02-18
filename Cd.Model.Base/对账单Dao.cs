using System;
using System.Collections.Generic;
using System.Text;
using Feng;
using Feng.Utils;
using Hd.Model;

namespace Cd.Model
{
    public enum 车队对账单类型
    {
        应收对账单_委托人 = 11,
        应付对账单_车主 = 12,
        应付对账单_对外 = 13,
        应付对账单_驾驶员 = 14,
        固定资产折旧_车辆 = 16
    }

    public class 对账单Dao : BaseSubmittedDao<对账单>
    {
        // 业务类型，相关人
        private static Dictionary<Tuple<int, string>, IList<费用>> GroupFy(IList<费用> list, IRepository rep)
        {
            Dictionary<Tuple<int, string>, IList<费用>> dict = CollectionHelper.Group<费用, Tuple<int, string>>(list,
                             new CollectionHelper.GetGroupKey<费用, Tuple<int, string>>(delegate(费用 i)
                             {
                                 if (!i.费用类别编号.HasValue
                                    || string.IsNullOrEmpty(i.相关人编号)
                                    || !i.金额.HasValue)
                                 {
                                     return null;
                                 }
                                 return new Tuple<int, string>(i.费用类别编号.Value, i.相关人编号);
                             }));
            return dict;
        }

        internal static void GenerateDzdYsyf(IRepository rep, 对账单 entity)
        {
            if (!entity.Submitted)
            {
                throw new InvalidUserOperationException("对账单还未提交！");
            }

            entity.应收应付款 = new List<应收应付款>();

            // 费用实体类型=车辆产值， 费用类别=11 -》任务类别
            // 费用实体类型=车辆产值， 费用类别《》11 -》费用类别
            // 费用实体类型 <>车辆产值 -》费用实体类型

            switch (entity.对账单类型)
            {
                case (int)车队对账单类型.应收对账单_委托人:
                case (int)车队对账单类型.应付对账单_驾驶员:
                case (int)车队对账单类型.应付对账单_对外:
                case (int)车队对账单类型.应付对账单_车主:
                    {
                        if (entity.对账单类型 == (int)车队对账单类型.应付对账单_车主 && entity.相关人编号 == "900001")
                        {
                            return;
                        }
                        // 任务类别， 收付标志，相关人编号
                        Dictionary<Tuple<int, string>, IList<费用>> dict = GroupFy(entity.费用, rep);

                        foreach (KeyValuePair<Tuple<int, string>, IList<费用>> kvp in dict)
                        {
                            decimal sum = 0;
                            foreach (费用 k4 in kvp.Value)
                            {
                                if (k4.收付标志 == entity.收付标志)
                                {
                                    sum += k4.金额.Value;
                                }
                                else
                                {
                                    sum -= k4.金额.Value;
                                }
                            }

                            应收应付款 ysyfk = new 应收应付款();
                            ysyfk.费用项编号 = "000";
                            ysyfk.结算期限 = entity.结算期限.HasValue ? entity.结算期限.Value : entity.关账日期.Value;
                            ysyfk.金额 = sum;
                            ysyfk.日期 = entity.关账日期.Value;
                            ysyfk.收付标志 = entity.收付标志;
                            ysyfk.相关人编号 = kvp.Key.Item2;
                            ysyfk.业务类型编号 = kvp.Key.Item1;
                            ysyfk.应收应付源 = entity;

                            (new HdBaseDao<应收应付款>()).Save(rep, ysyfk);

                            entity.应收应付款.Add(ysyfk);
                        }
                    }
                    break;
                case (int)车队对账单类型.固定资产折旧_车辆:
                    if (entity.对账单类型 == (int)车队对账单类型.固定资产折旧_车辆 && entity.相关人编号 == "900001")
                    {
                        return;
                    }
                    // 任务类别， 收付标志，相关人编号
                    Dictionary<Tuple<int, string>, IList<费用>> dic = GroupFy(entity.费用, rep);

                    foreach (KeyValuePair<Tuple<int, string>, IList<费用>> kvp in dic)
                    {
                        decimal sum = 0;
                        foreach (费用 k4 in kvp.Value)
                        {
                            if (k4.收付标志 == 收付标志.付)
                            {
                                sum -= k4.金额.Value;
                            }
                            else
                            {
                                sum += k4.金额.Value;
                            }
                        }

                        应收应付款 ysyfk = new 应收应付款();
                        ysyfk.费用项编号 = "004";
                        ysyfk.结算期限 = entity.关账日期.Value;
                        ysyfk.金额 = sum;
                        ysyfk.日期 = entity.关账日期.Value;
                        ysyfk.收付标志 = 收付标志.收;
                        ysyfk.相关人编号 = kvp.Key.Item2;
                        ysyfk.业务类型编号 = kvp.Key.Item1;
                        ysyfk.应收应付源 = entity;

                        (new HdBaseDao<应收应付款>()).Save(rep, ysyfk);

                        entity.应收应付款.Add(ysyfk);
                    }
                    break;
                default:
                    throw new NotSupportedException("Not Supported 对账单类型 of " + entity.对账单类型 + "!");
            }
        }

        internal static void UngenerateDzdYsyf(IRepository rep, 对账单 entity)
        {
            rep.Initialize(entity.应收应付款, entity);

            switch (entity.对账单类型)
            {
                case (int)车队对账单类型.应收对账单_委托人:
                case (int)车队对账单类型.应付对账单_驾驶员:
                case (int)车队对账单类型.应付对账单_对外:
                case (int)车队对账单类型.应付对账单_车主:
                case (int)车队对账单类型.固定资产折旧_车辆:
                    {
                        foreach (应收应付款 i in entity.应收应付款)
                        {
                            rep.Delete(i);
                        }
                        entity.应收应付款.Clear();
                    }
                    break;
                default:
                    throw new NotSupportedException("Not Supported 对账单类型 of " + entity.对账单类型 + "!");
            }

           
        }

        /// <summary>
        /// 提交
        /// </summary>
        /// <param name="rep"></param>
        /// <param name="entity"></param>
        public override void Submit(IRepository rep, 对账单 entity)
        {
            if (!entity.关账日期.HasValue)
            {
                throw new InvalidUserOperationException("请输入 关账日期！");
            }

            entity.Submitted = true;

            if (entity.费用 == null)
            {
                entity.费用 = rep.List<费用>("from 费用 where 对账单 = :对账单", new Dictionary<string, object> { { "对账单", entity } });
            }
            else
            {
                rep.Initialize(entity.费用, entity);
            }
            decimal sum = 0;
            foreach (费用 i in entity.费用)
            {
                if (i.收付标志 == 收付标志.收)
                {
                    sum += i.金额.Value;
                }
                else
                {
                    sum -= i.金额.Value;
                }

                if (i.凭证费用明细 != null)
                {
                    throw new InvalidUserOperationException("费用已经出凭证！");
                }
            }

            if (entity.收付标志 == 收付标志.收)
            {
                entity.金额 = sum;
            }
            else
            {
                entity.金额 = -sum;
            }
            this.Update(rep, entity);

            费用Dao fyDao = new 费用Dao();
            switch (entity.对账单类型)
            {
                case (int)车队对账单类型.应收对账单_委托人:
                case (int)车队对账单类型.应付对账单_驾驶员:
                case (int)车队对账单类型.应付对账单_对外:
                case (int)车队对账单类型.应付对账单_车主:
                    {
                        GenerateDzdYsyf(rep, entity);

                        foreach (费用 i in entity.费用)
                        {
                            fyDao.Update(rep, i);

                            // rep.Update() 无用，可能NHibernate判断无数据更改然后不更新
                        }
                    }
                    break;
                case (int)车队对账单类型.固定资产折旧_车辆:
                    GenerateDzdYsyf(rep, entity);

                    foreach (费用 i in entity.费用)
                    {
                        fyDao.Update(rep, i);
                    }
                    break;

                default:
                    throw new NotSupportedException("Not Supported 对账单类型 of " + entity.对账单类型 + "!");
            }
        }


        /// <summary>
        /// 撤销提交
        /// </summary>
        /// <param name="rep"></param>
        /// <param name="entity"></param>
        public override void Unsubmit(IRepository rep, 对账单 entity)
        {
            entity.Submitted = false;
            entity.金额 = null;

            this.Update(rep, entity);

            rep.Initialize(entity.费用, entity);
            foreach (费用 i in entity.费用)
            {
                if (i.凭证费用明细 != null)
                {
                    throw new InvalidUserOperationException("费用已经出凭证！");
                }
            }

            switch (entity.对账单类型)
            {
                case (int)车队对账单类型.应收对账单_委托人:
                case (int)车队对账单类型.应付对账单_驾驶员:
                case (int)车队对账单类型.应付对账单_对外:
                case (int)车队对账单类型.应付对账单_车主:                    
                case (int)车队对账单类型.固定资产折旧_车辆:
                    {
                        UngenerateDzdYsyf(rep, entity);
                    }
                    break;
                default:
                    throw new NotSupportedException("Not Supported 对账单类型 of " + entity.对账单类型 + "!");
            }
        }
    }
}
