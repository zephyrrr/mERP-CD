using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Feng.Windows.Forms;
using Cd.Model;
using Hd.Model;
using Hd.Model.Kj;
using Feng;
using System.Windows.Forms;

namespace Cd.Service
{
    public class process_fy_cl
    {
        public static void 车辆管理_生成全部费用(GeneratedArchiveOperationForm masterForm)
        {
            if (MessageForm.ShowYesNo("是否生产当前所有费用？","提示"))
            {
                IList list = masterForm.DisplayManager.Items;
                using (IRepository rep = ServiceProvider.GetService<IRepositoryFactory>().GenerateRepository<非业务车辆费用>())
                {
                    非业务车辆费用Dao dao = new 非业务车辆费用Dao();
                    rep.BeginTransaction();
                    foreach (object i in list)
                    {
                        非业务车辆费用 fy_dw = new 非业务车辆费用();
                        非业务车辆费用 fy_cz = new 非业务车辆费用();                        
                        if (i is 车辆资产)
                        {                            
                            车辆资产 item = i as 车辆资产;
                            if (item.Submitted)
                            {
                                continue;
                            }
                            fy_dw.费用实体 = item;
                            fy_dw.收付标志 = Hd.Model.收付标志.付;
                            fy_dw.费用归属 = Cd.Model.费用归属.对外;
                            fy_dw.相关人编号 = "900031";
                            fy_dw.费用项编号 = "387";
                            fy_dw.金额 = item.金额;
                            if (item.车主编号 != "900001")
                            {
                                //fy_dw.车辆承担 = false;
                                fy_cz.费用实体 = item;
                                fy_cz.收付标志 = Hd.Model.收付标志.收;
                                fy_cz.费用归属 = Cd.Model.费用归属.车主;
                                fy_cz.相关人编号 = item.车主编号;
                                fy_cz.费用项编号 = "387";
                                fy_cz.金额 = item.金额;
                                dao.Save(rep, fy_cz);                             
                            }
                            dao.Save(rep, fy_dw);
                        }
                        else if (i is 车辆保险)
                        {
                            车辆保险 item = i as 车辆保险;
                            if (item.Submitted)
                            {
                                continue;
                            }
                            fy_dw.费用实体 = item;
                            fy_dw.收付标志 = Hd.Model.收付标志.付;
                            fy_dw.费用归属 = Cd.Model.费用归属.对外;
                            fy_dw.相关人编号 = "900031";
                            fy_dw.费用项编号 = "387";
                            fy_dw.金额 = item.金额;
                            dao.Save(rep, fy_dw);
                        }
                        else if (i is 车辆维修)
                        {
                            车辆维修 item = i as 车辆维修;
                            if (item.Submitted)
                            {
                                continue;
                            }
                            fy_dw.费用实体 = item;
                            fy_dw.收付标志 = Hd.Model.收付标志.付;
                            fy_dw.费用归属 = Cd.Model.费用归属.对外;
                            fy_dw.相关人编号 = item.相关人编号;
                            fy_dw.费用项编号 = "383";
                            fy_dw.金额 = item.金额;
                            if (item.车主编号 != "900001")
                            {
                                ///fy_dw.车辆承担 = false;
                                fy_cz.费用实体 = item;
                                fy_cz.收付标志 = Hd.Model.收付标志.收;
                                fy_cz.费用归属 = Cd.Model.费用归属.车主;
                                fy_cz.相关人编号 = item.车主编号;
                                fy_cz.费用项编号 = "383";
                                fy_cz.金额 = item.金额;
                                dao.Save(rep, fy_cz);
                            }
                            dao.Save(rep, fy_dw);
                        }
                        else if (i is 车辆加油)
                        {
                            车辆加油 item = i as 车辆加油;
                            if (item.Submitted)
                            {
                                continue;
                            }
                            fy_dw.费用实体 = item;
                            fy_dw.收付标志 = Hd.Model.收付标志.付;
                            fy_dw.费用归属 = Cd.Model.费用归属.对外;
                            fy_dw.相关人编号 = item.相关人编号;
                            fy_dw.费用项编号 = "204";
                            fy_dw.金额 = item.金额;
                            fy_dw.数量 = item.升数;
                            if (item.车主编号 != "900001")
                            {
                                //fy_dw.车辆承担 = false;
                                fy_cz.费用实体 = item;
                                fy_cz.收付标志 = Hd.Model.收付标志.收;
                                fy_cz.费用归属 = Cd.Model.费用归属.车主;
                                fy_cz.相关人编号 = item.车主编号;
                                fy_cz.费用项编号 = "204";
                                fy_cz.金额 = item.金额;
                                fy_cz.数量 = item.升数;
                                dao.Save(rep, fy_cz);
                            }
                            dao.Save(rep, fy_dw);
                        }
                        else if (i is 车辆机油)
                        {
                            车辆机油 item = i as 车辆机油;
                            if (item.Submitted || item.买卖标志 == 买卖标志.买入)
                            {
                                continue;
                            }
                            fy_dw.费用实体 = item;
                            fy_dw.收付标志 = Hd.Model.收付标志.付;
                            fy_dw.费用归属 = Cd.Model.费用归属.对外;
                            fy_dw.相关人编号 = "900031";
                            fy_dw.费用项编号 = "384";
                            fy_dw.金额 = item.金额;
                            fy_dw.数量 = item.数量;
                            if (item.车主编号 != "900001" && item.买卖标志 == 买卖标志.卖出)
                            {
                                //fy_dw.车辆承担 = false;
                                fy_cz.费用实体 = item;
                                fy_cz.收付标志 = Hd.Model.收付标志.收;
                                fy_cz.费用归属 = Cd.Model.费用归属.车主;
                                fy_cz.相关人编号 = item.车主编号;
                                fy_cz.费用项编号 = "384";
                                fy_cz.金额 = item.金额;
                                fy_cz.数量 = item.数量;
                                dao.Save(rep, fy_cz);
                            }
                            dao.Save(rep, fy_dw);
                        }
                        else if (i is 车辆事故)
                        {
                            车辆事故 item = i as 车辆事故;
                            if (item.Submitted)
                            {
                                continue;
                            }
                            fy_dw.费用实体 = item;
                            fy_dw.费用归属 = Cd.Model.费用归属.对外;
                            fy_dw.收付标志 = Hd.Model.收付标志.收;
                            fy_dw.相关人编号 = item.相关人编号;
                            fy_dw.费用项编号 = "375";
                            fy_dw.金额 = item.金额;
                            dao.Save(rep, fy_dw);
                        }
                        else if (i is 车辆其他)
                        {
                            车辆其他 item = i as 车辆其他;
                            if (item.Submitted)
                            {
                                continue;
                            }
                            fy_dw.费用实体 = item;
                            fy_dw.收付标志 = Hd.Model.收付标志.付;
                            fy_dw.费用归属 = Cd.Model.费用归属.对外;
                            fy_dw.相关人编号 = item.相关人编号;
                            fy_dw.费用项编号 = "234";
                            fy_dw.金额 = item.金额;
                            if (item.车主编号 != "900001")
                            {
                                //fy_dw.车辆承担 = false;
                                fy_cz.费用实体 = item;
                                fy_cz.收付标志 = Hd.Model.收付标志.收;
                                fy_cz.费用归属 = Cd.Model.费用归属.车主;
                                fy_cz.相关人编号 = item.车主编号;
                                fy_cz.费用项编号 = "234";
                                fy_cz.金额 = item.金额;
                                dao.Save(rep, fy_cz);
                            }
                            dao.Save(rep, fy_dw);
                        }
                        else if (i is 车辆库存加油)
                        {
                            车辆库存加油 item = i as 车辆库存加油;
                            if (item.Submitted || item.买卖标志 == 买卖标志.买入 || item.车辆编号 == null)
                            {
                                continue;
                            }

                            string czyj = ServiceProvider.GetService<IDefinition>().TryGetValue("车主油价");
                            string cbyj = ServiceProvider.GetService<IDefinition>().TryGetValue("成本油价");
                            string jsyyj = ServiceProvider.GetService<IDefinition>().TryGetValue("驾驶员油价");

                            item.车辆 = rep.Get<车辆>(item.车辆编号);
                            fy_dw.费用实体 = item;
                            fy_dw.收付标志 = Hd.Model.收付标志.付;
                            fy_dw.费用归属 = Cd.Model.费用归属.对外;
                            fy_dw.相关人编号 = "900031";
                            fy_dw.费用项编号 = "204";
                            fy_dw.数量 = item.数量;
                            // 根据成本油价计算金额 
                            if (cbyj != null && Convert.ToDecimal(cbyj) != 0)
	                        {
                                fy_dw.金额 = item.数量 * Convert.ToDecimal(cbyj);
	                        }
                            if (item.车辆编号 != null && item.车辆.车辆类别 == 车辆类别.挂靠车 && item.买卖标志 == 买卖标志.卖出)
                            {
                                //fy_dw.车辆承担 = false;
                                fy_cz.费用实体 = item;
                                fy_cz.收付标志 = Hd.Model.收付标志.收;
                                fy_cz.费用归属 = Cd.Model.费用归属.车主;
                                fy_cz.相关人编号 = item.车主编号;
                                fy_cz.费用项编号 = "204";
                                fy_cz.数量 = item.数量;
                                // 根据油价计算 
                                if (czyj != null && Convert.ToDecimal(czyj) != 0)
                                {
                                    fy_cz.金额 = item.数量 * Convert.ToDecimal(czyj);
                                }
                                dao.Save(rep, fy_cz);
                            }
                            if (item.车辆编号 != null && (item.车辆.车辆类别 == 车辆类别.代管车 || item.车辆.车辆类别 == 车辆类别.自有车) && item.买卖标志 == 买卖标志.卖出)
                            {
                                //fy_dw.车辆承担 = false;
                                fy_cz.费用实体 = item;
                                fy_cz.收付标志 = Hd.Model.收付标志.收;
                                fy_cz.费用归属 = Cd.Model.费用归属.驾驶员;
                                fy_cz.相关人编号 = item.驾驶员编号;
                                fy_cz.费用项编号 = "204";
                                fy_cz.数量 = item.数量;
                                // 根据油价计算 
                                if (jsyyj != null && Convert.ToDecimal(jsyyj) != 0)
                                {
                                    fy_cz.金额 = item.数量 * Convert.ToDecimal(jsyyj);
                                }
                                dao.Save(rep, fy_cz);
                            }
                            dao.Save(rep, fy_dw);
                        }
                        else
                        {
                            rep.RollbackTransaction();
                            System.Diagnostics.Debug.Assert(false, "费用实体类型不是要求类型，而是" + i.GetType().ToString());
                        }
                    }
                    rep.CommitTransaction();
                }
                masterForm.DisplayManager.DisplayCurrent();
            }
        }
    }
}
