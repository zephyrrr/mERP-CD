using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Reflection;
using Feng;
using Cd.Model;
using Hd.Model;
using Feng.Windows.Forms;
using System.Windows.Forms;

namespace Cd.Service
{
    public class process_fy_yw
    {
        public static int 批量生成费用(IRepository rep, 车辆产值 票, IEnumerable 箱, string 费用项编号, 收付标志? 收付标志)
        {
            int cnt = 0;

            // 需按照委托人合同和付款合同生成相应费用和费用理论值
            // 如果总体来生成，则按照：
            // 如果费用已经打了完全标志，则不生成。如果相应理论值已经生成过，也不生成。
            // 如果单个费用项来生成，则不管理论值是否已经生成过
            // Todo: 理论值可能显示生成票的，后来信息完全了再生成箱的，此时要删除票的 
            //using (IRepository rep = ServiceProvider.GetService<IRepositoryFactory>().GenerateRepository(票.GetType()))
            {
                try
                {
                    rep.BeginTransaction();

                    IList<业务费用理论值> llzs = (rep as Feng.NH.INHibernateRepository).List<业务费用理论值>(NHibernate.Criterion.DetachedCriteria.For<业务费用理论值>()
                                            .Add(NHibernate.Criterion.Expression.Eq("费用实体.ID", 票.ID)));

                    rep.Initialize(票.费用, 票);

                    process_fy_generate.批量生成费用(rep, 票, 箱, 费用项编号, 收付标志, llzs);


                    ////  有几项（发票税，贴息费）要看收款费用
                    // 不行，会多生成
                    //批量生成费用付款(rep, 费用实体类型, 票, 箱, 费用项编号, 收付标志, llzs);

                    rep.CommitTransaction();
                }
                catch (Exception ex)
                {
                    rep.RollbackTransaction();
                    ServiceProvider.GetService<IExceptionProcess>().ProcessWithNotify(ex);
                }
            }
            return cnt;
        }

        public static void 批量添加费用(ArchiveOperationForm masterForm)
        {
            IControlManager cm = masterForm.ControlManager;

            ArchiveSelectForm selectForm = new ArchiveSelectForm("批量添加业务费用");
            if (selectForm.ShowDialog() == DialogResult.OK)
            {
                ArchiveCheckForm form = selectForm.SelectedForm as ArchiveCheckForm;

                if (form != null && form.ShowDialog() == DialogResult.OK)
                {
                    foreach (object i in form.SelectedEntites)
                    {
                        业务费用 item = new 业务费用();
                        if (i is 车辆产值)
                        {
                            车辆产值 tang = i as 车辆产值;
                            item.车辆 = (i == null ? null : tang.车辆);
                            item.车辆编号 = i == null ? null : (Guid?)tang.车辆编号;
                            item.费用实体 = tang;
                            item.车辆产值 = tang;
                        }
                        else if (i is 任务)
                        {
                            任务 xiang = i as 任务;

                            // it must have piao
                            //item.车辆产值 = xiang.车辆产值;
                            item.任务 = (i == null ? null : xiang);
                            item.车辆 = (i == null ? null : xiang.车辆产值.车辆);
                            item.车辆编号 = i == null ? null : (Guid?)xiang.车辆产值.车辆编号;
                            item.费用实体 = xiang.车辆产值;// new 车辆产值 { ID = item.车辆产值.ID, Version = item.车辆产值.Version };
                            item.车辆产值 = xiang.车辆产值;
                        }
                        else
                        {
                            System.Diagnostics.Debug.Assert(false, "选中的费用实体类型不是要求类型，而是" + i.GetType().ToString());
                        }

                        object entity = cm.AddNew();
                        if (entity != null)
                        {
                            cm.DisplayManager.Items[cm.DisplayManager.Position] = item;
                            cm.EndEdit();
                        }
                        else
                        {
                            // 出现错误，不再继续。 AddNew的时候，前一个出现错误，没保存。然后提示时候保存，选不继续
                            masterForm.ControlManager.CancelEdit();
                            break;
                        }

                        //bool isPiao = (i is 普通票);
                        //string filter = "现有费用实体类型 LIKE '%" + (int)item.票.费用实体类型;
                        //if (isPiao)
                        //{
                        //    filter += ",%' AND 票 = " + isPiao;
                        //}
                        //else
                        //{
                        //    filter += ",%' AND 箱 = " + !isPiao;
                        //}
                        //masterForm.ActiveGrid.CurrentDataRow.Cells["费用项编号"].CellEditorManager = ControlDataLoad.GetGridComboEditor("费用项_业务", filter);
                    }
                }
            }
        }

        public static void 生成开票税(ArchiveOperationForm masterForm)
        {
            decimal sl = Convert.ToDecimal(ServiceProvider.GetService<IDefinition>().TryGetValue("开票税率"));

            if (sl == 0)
            {
                throw new InvalidUserOperationException("当前开票税率值无效！");
            }

            if (MessageForm.ShowYesNo("是否自动生成开票税？当前税率: " + sl * 100 + "%", "提示"))
            {
                int count = 0;

               try
               {
                   if (masterForm.DisplayManager.Items != null && masterForm.DisplayManager.Items.Count > 0)
                   {                 
                        foreach (Xceed.Grid.Row row in masterForm.MasterGrid.GridControl.SelectedRows)
                        {
                            Xceed.Grid.DataRow dataRow = row as Xceed.Grid.DataRow;
                            if (dataRow == null)
                                continue;

                            业务费用 fy = dataRow.Tag as 业务费用;

                            if ((fy.费用项编号 == "102" || fy.费用项编号 == "103") && fy.费用归属 == 费用归属.委托人 && fy.收付标志 == 收付标志.收)
                            {
                                业务费用 kps = masterForm.ControlManager.AddNew() as 业务费用;

                                kps.费用归属 = 费用归属.对外;
                                kps.收付标志 = 收付标志.付;
                                kps.相关人编号 = "900130";
                                kps.费用项编号 = "335";
                                kps.金额 = decimal.Multiply(fy.金额.Value, sl);

                                kps.费用实体 = fy.费用实体;
                                kps.车辆产值 = fy.车辆产值;
                                kps.车辆编号 = fy.车辆编号;
                                kps.任务 = fy.任务;

                                masterForm.DisplayManager.DisplayCurrent();
                                masterForm.ControlManager.EndEdit(true);
                                count++;
                            }
                        }

                        //for (int i = 0; i < masterForm.DisplayManager.Items.Count; i++)
                        //{
                        //    masterForm.DisplayManager.Position = i;
                        //    业务费用 fy = masterForm.DisplayManager.CurrentItem as 业务费用;
                            
                        //    // 当 费用项=运费   费用归属=委托人  收款记录  生成：
                        //    // 费用归属=对外 付  相关人=税务局   费用项=开票税  金额=运费*开票税率
                        //    if (fy.费用项编号 == "102" && fy.费用归属 == 费用归属.委托人 && fy.收付标志 == 收付标志.收)
                        //    {
                        //        业务费用 kps = masterForm.ControlManager.AddNew() as 业务费用;

                        //        kps.费用归属 = 费用归属.对外;
                        //        kps.收付标志 = 收付标志.付;
                        //        kps.相关人编号 = "900130";
                        //        kps.费用项编号 = "335";
                        //        kps.金额 = decimal.Multiply(fy.金额.Value, sl);

                        //        kps.费用实体 = fy.费用实体;
                        //        kps.车辆编号 = fy.车辆编号;
                        //        kps.任务 = fy.任务;

                        //        masterForm.DisplayManager.DisplayCurrent();
                        //        masterForm.ControlManager.EndEdit(true);
                        //        count++;
                        //    }
                        //}
                    }
               }
               catch (Exception ex)
               {
                   throw new InvalidUserOperationException(ex.Message);
               }
               finally
               {
                   MessageForm.ShowInfo("已生成 " + count + " 条开票税！");
               }
            }
        }
    }
}
