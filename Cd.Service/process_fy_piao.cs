using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;
using Feng;
using Feng.Windows.Forms;
using Feng.Grid;
using Cd.Model;
using Hd.Model;

namespace Cd.Service
{
    public class process_fy_piao
    {

        public static void FyDoubleClick(object sender1, EventArgs e1)
        {
            Xceed.Grid.DataCell cell = sender1 as Xceed.Grid.DataCell;
            Xceed.Grid.DataRow row = cell.ParentRow as Xceed.Grid.DataRow;

            ArchiveSeeForm masterForm = cell.GridControl.FindForm() as ArchiveSeeForm;
            if (masterForm == null)
            {
                // 通过DetailForm来的
                masterForm = (cell.GridControl.FindForm() as ArchiveDetailForm).ParentForm as ArchiveSeeForm;
            }
            ArchiveOperationForm fydjForm = masterForm.Tag as ArchiveOperationForm;

            //if (cell.FieldName == "拟付金额" || cell.FieldName == "拟收金额" || cell.FieldName == "费用项")
            {
                if (fydjForm == null)
                {
                    fydjForm = ServiceProvider.GetService<IWindowFactory>().CreateWindow(ADInfoBll.Instance.GetWindowInfo("业务备案_车辆产值费用_双击")) as ArchiveOperationForm;
                    masterForm.Tag = fydjForm;

                    Dictionary<string, object> setDatanew = new Dictionary<string, object>();
                    fydjForm.Tag = setDatanew;

                    (fydjForm.ControlManager.Dao as 业务费用Dao).TransactionBeginning += new EventHandler<OperateArgs<费用>>(delegate(object sender, OperateArgs<费用> e)
                    {
                        if (e.Entity.费用实体 == null)
                        {
                            业务费用 fy = e.Entity as 业务费用;
                            fy.费用实体 = e.Repository.Get<费用实体>(setDatanew["费用实体"]);
                            fy.费用项编号 = (string)setDatanew["费用项"];
                            fy.车辆产值 = fy.费用实体 as 车辆产值;
                        }
                    });
                    fydjForm.DisplayManager.SearchManager.EnablePage = false;
                    fydjForm.DisplayManager.SearchManager.DataLoaded += new EventHandler<DataLoadedEventArgs>(delegate(object sender, DataLoadedEventArgs e)
                    {
                        fydjForm.TopMost = true;
                        fydjForm.Show();
                    });

                    fydjForm.FormClosing += new FormClosingEventHandler(delegate(object sender, FormClosingEventArgs e)
                    {
                        if (e.CloseReason == CloseReason.UserClosing)
                        {
                            if (!masterForm.IsDisposed)
                            {
                                if (masterForm is ArchiveOperationForm)
                                {
                                    (masterForm as ArchiveOperationForm).ControlManager.DisplayManager.SearchManager.ReloadItem((masterForm as ArchiveOperationForm).ControlManager.DisplayManager.Position);
                                    (masterForm as ArchiveOperationForm).ControlManager.OnCurrentItemChanged();
                                }

                                e.Cancel = true;
                                fydjForm.Hide();
                            }
                            else
                            {
                            }
                        }
                    });
                }

                Dictionary<string, object> setData = fydjForm.Tag as Dictionary<string, object>;
                setData.Clear();

                // 票费用登记窗体
                if (row.Cells["费用实体"] != null)
                {
                    setData["费用实体"] = (Guid)row.Cells["费用实体"].Value;
                    setData["费用项"] = (string)row.Cells["费用项"].Value;
                    if (/*cell.FieldName == "已收金额" || cell.FieldName == "应收金额" || */cell.FieldName == "拟收金额")
                    {
                        setData["收付标志"] = 收付标志.收;
                    }
                    else if (/*cell.FieldName == "已付金额" || cell.FieldName == "应付金额" || */cell.FieldName == "拟付金额")
                    {
                        setData["收付标志"] = 收付标志.付;
                    }
                }
                else
                {
                    throw new ArgumentException("There must be a column named 费用实体!");
                }
                //NameValueMappingCollection.Instance["信息_箱号_动态"].Params["@票"] = (Guid)setData["费用实体"];
                //NameValueMappingCollection.Instance.Reload("信息_箱号_动态");

                //Feng.Windows.Forms.MyObjectPicker op = (fydjForm.MasterGrid.GetInsertionRow().Cells["任务"].CellEditorManager as Feng.Grid.Editors.MyObjectPickerEditor).TemplateControl;
                //string exp = "车辆产值.ID = " + ((Guid)setData["费用实体"]).ToString();
                //op.SearchExpressionParam = exp;

                Feng.Windows.Forms.MyObjectPicker op = (fydjForm.MasterGrid.Columns["任务"].CellEditorManager as Feng.Grid.Editors.MyObjectPickerEditor).TemplateControl;
                string exp = "车辆产值.ID = " + ((Guid)setData["费用实体"]).ToString();
                op.SearchExpressionParam = exp;

                ISearchExpression se = SearchExpression.And(SearchExpression.Eq("费用实体.ID", (Guid)setData["费用实体"]),
                    SearchExpression.Eq("费用项编号", (string)setData["费用项"]));

                if (setData.ContainsKey("收付标志"))
                {
                    se = SearchExpression.And(se, SearchExpression.Eq("收付标志", setData["收付标志"]));
                }
                fydjForm.ControlManager.DisplayManager.SearchManager.LoadData(se, new List<ISearchOrder>());
            }
        }

        public static void 自动生成费用(ArchiveOperationForm masterForm)
        {
            Dictionary<string, object> setData = masterForm.Tag as Dictionary<string, object>;
            费用实体 entity;
            using (IRepository rep = ServiceProvider.GetService<IRepositoryFactory>().GenerateRepository<业务费用>())
            {
                entity = rep.Get<费用实体>(setData["费用实体"]);
            }
            using (IRepository rep = ServiceProvider.GetService<IRepositoryFactory>().GenerateRepository<车辆产值>())
            {
                车辆产值 piao = rep.Get<车辆产值>(setData["费用实体"]);
                rep.Initialize(piao.任务, piao);
                process_fy_yw.批量生成费用(rep, piao, piao.任务, (string)setData["费用项"], !setData.ContainsKey("收付标志") ? null : (收付标志?)setData["收付标志"]);
            }

            (masterForm.MasterGrid as IBoundGrid).ReloadData();
        }

        public static void 自动生成全部费用(ArchiveOperationForm masterForm)
        {
            if (!ServiceProvider.GetService<IMessageBox>().ShowYesNo("是否要自动全部生成费用？", "确认"))
            {
                return;
            }
            ProgressForm progressForm = new ProgressForm();
            progressForm.Start(masterForm, "生成");

            Feng.Async.AsyncHelper asyncHelper = new Feng.Async.AsyncHelper(
                new Feng.Async.AsyncHelper.DoWork(delegate()
                {
                    费用实体 entity = masterForm.DisplayManager.CurrentItem as 费用实体;
                    if (entity == null)
                    {
                        throw new ArgumentException("请选择要生成费用的产值！");
                    }
                    using (IRepository rep = ServiceProvider.GetService<IRepositoryFactory>().GenerateRepository<车辆产值>())
                    {
                        车辆产值 piao = rep.Get<车辆产值>(entity.ID);
                        rep.Initialize(piao.任务, piao);
                        process_fy_yw.批量生成费用(rep, piao, piao.任务, null, null);
                    }

                    return null;
                }),
                new Feng.Async.AsyncHelper.WorkDone(delegate(object result)
                {
                    masterForm.ControlManager.OnCurrentItemChanged();
                    progressForm.Stop();
                }));
        }

        public static void 生成车主承担费用(ArchiveOperationForm masterForm)
        {
            if (MessageForm.ShowYesNo("是否自动生成车主承担费用？", "提示"))
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

                            车队费用项 fyx = EntityBufferCollection.Instance.Get<车队费用项>(fy.费用项编号);

                            if (fyx.车主 == null)
                            {
                                continue;
                            }

                            // 把 费用归属<>车主 的记录 逐条生成  费用归属=车主的
                            // 收付标志 反一下   相关人=承运人  。。。
                            using (IRepository rep = ServiceProvider.GetService<IRepositoryFactory>().GenerateRepository<业务费用>())
                            {
                                rep.Initialize(fy.车辆产值, fy);
                            }

                            if (fy.费用归属 != 费用归属.车主)
                            {
                                业务费用 kps = masterForm.ControlManager.AddNew() as 业务费用;

                                kps.费用归属 = 费用归属.车主;
                                kps.收付标志 = fy.收付标志 == 收付标志.收 ? 收付标志.付 : 收付标志.收;
                                kps.相关人编号 = fy.车辆产值.承运人编号;
                                kps.数量 = fy.数量;

                                kps.费用项编号 = fy.费用项编号;
                                kps.金额 = fy.金额;
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

                        //    // 把 费用归属<>车主 的记录 逐条生成  费用归属=车主的
                        //    // 收付标志 反一下   相关人=承运人  。。。
                        //    using (IRepository rep = ServiceProvider.GetService<IRepositoryFactory>().GenerateRepository<业务费用>())
                        //    {
                        //        rep.Initialize(fy.车辆产值, fy);
                        //    }

                        //    if (fy.费用归属 != 费用归属.车主)
                        //    {
                        //        业务费用 kps = masterForm.ControlManager.AddNew() as 业务费用;

                        //        kps.费用归属 = 费用归属.车主;
                        //        kps.收付标志 = fy.收付标志 == 收付标志.收 ? 收付标志.付 : 收付标志.收;
                        //        kps.相关人编号 = fy.车辆产值.承运人编号;

                        //        kps.费用项编号 = fy.费用项编号;
                        //        kps.金额 = fy.金额;
                        //        kps.费用类别编号 = fy.费用类别编号;
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
                    MessageForm.ShowInfo("已生成 " + count + " 条车主费用！");
                }
            }
        }

        public static void 生成油费对外费用(ArchiveOperationForm masterForm)
        {
            if (MessageForm.ShowYesNo("是否自动生成油费对外费用？", "提示"))
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

                            // 把 费用归属=驾驶员 费用项=204 的记录 逐条生成  费用归属=对外的
                            // 收付标志 反一下   相关人=null
                            using (IRepository rep = ServiceProvider.GetService<IRepositoryFactory>().GenerateRepository<业务费用>())
                            {
                                rep.Initialize(fy.车辆产值, fy);
                            }

                            if (fy.费用归属 == 费用归属.驾驶员 && fy.费用项编号 == "204")
                            {
                                业务费用 kps = masterForm.ControlManager.AddNew() as 业务费用;

                                kps.费用归属 = 费用归属.对外;
                                kps.收付标志 = fy.收付标志 == 收付标志.收 ? 收付标志.付 : 收付标志.收;
                                kps.数量 = fy.数量;
                                kps.费用项编号 = fy.费用项编号;
                                kps.金额 = fy.金额;
                                kps.费用实体 = fy.费用实体;
                                kps.车辆产值 = fy.车辆产值;
                                kps.车辆编号 = fy.车辆编号;
                                kps.任务 = fy.任务;

                                masterForm.DisplayManager.DisplayCurrent();
                                masterForm.ControlManager.EndEdit(true);
                                count++;
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    throw new InvalidUserOperationException(ex.Message);
                }
                finally
                {
                    MessageForm.ShowInfo("已生成 " + count + " 条对外费用！");
                }
            }
        }
    }
}
