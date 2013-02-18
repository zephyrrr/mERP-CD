using System;
using System.Collections.Generic;
using System.Text;
using Feng;
using Feng.Grid;
using Feng.Windows.Forms;
using Cd.Model;

namespace Cd.Service
{
    public class process_cl_cezjy
    {
        public static void 车辆_车主驾驶员_对应(object sender, SelectedDataValueChangedEventArgs e)
        {
            if (e.DataControlName == "车辆编号")
            {
                IDisplayManager dm = sender as IDisplayManager;

                IDataControl dc = e.Container as IDataControl;
                if (dc != null)
                {
                    if (dc.SelectedDataValue != null)
                    {
                        车辆 cl = EntityBufferCollection.Instance.Get<车辆>(dc.SelectedDataValue);
                        if (cl != null)
                        {
                            if (dm.DataControls["车主编号"] != null && dm.DataControls["车主编号"].SelectedDataValue == null)
                            {
                                dm.DataControls["车主编号"].SelectedDataValue = cl.车主编号;
                            }
                            if (dm.DataControls["承运人编号"] != null && dm.DataControls["承运人编号"].SelectedDataValue == null)
                            {
                                dm.DataControls["承运人编号"].SelectedDataValue = cl.车主编号;
                            }
                            if (dm.DataControls["驾驶员编号"] != null && dm.DataControls["驾驶员编号"].SelectedDataValue == null)
                            {
                                dm.DataControls["驾驶员编号"].SelectedDataValue = cl.默认驾驶员编号;
                            }
                        }
                    }
                }
                else
                {
                    Xceed.Grid.Cell cell = e.Container as Xceed.Grid.Cell;
                    if (cell.Value != null)
                    {
                        车辆 cl = EntityBufferCollection.Instance.Get<车辆>(cell.Value);
                        if (cl != null)
                        {
                            if (cell.ParentRow.Cells["车主编号"] != null && cell.ParentRow.Cells["车主编号"].Value == null)
                            {
                                cell.ParentRow.Cells["车主编号"].Value = cl.车主编号;
                            }
                            if (cell.ParentRow.Cells["承运人编号"] != null && cell.ParentRow.Cells["承运人编号"].Value == null)
                            {
                                cell.ParentRow.Cells["承运人编号"].Value = cl.车主编号;
                            }
                            if (cell.ParentRow.Cells["驾驶员编号"] != null && cell.ParentRow.Cells["驾驶员编号"].Value == null)
                            {
                                cell.ParentRow.Cells["驾驶员编号"].Value = cl.默认驾驶员编号;
                            }
                        }
                    }
                }
            }
        }

        static decimal? jsyyj = Feng.Utils.ConvertHelper.ToDecimal(ServiceProvider.GetService<IDefinition>().TryGetValue("驾驶员油价"));
        static decimal? czyj = Feng.Utils.ConvertHelper.ToDecimal(ServiceProvider.GetService<IDefinition>().TryGetValue("车主油价"));
        static decimal? cbyj = Feng.Utils.ConvertHelper.ToDecimal(ServiceProvider.GetService<IDefinition>().TryGetValue("成本油价"));

        public static void 油费金额计算(object sender, EventArgs e)
        {
            decimal count = 0;

            if (sender is Xceed.Grid.DataCell)
            {
                Xceed.Grid.DataCell cell = sender as Xceed.Grid.DataCell;
                Xceed.Grid.DataRow row = cell.ParentRow as Xceed.Grid.DataRow;

                if (cell.ReadOnly || !((string)row.Cells["费用项编号"].Value == "204"
                    || (string)row.Cells["费用项编号"].Value == "205") || row.Cells["车辆编号"].Value == null)
                {
                    return;
                }

                if (row.Cells["升数"] != null && row.Cells["升数"].Value != null)
                {
                    count = (decimal)row.Cells["升数"].Value;
                }
                else if (row.Cells["数量"] != null && row.Cells["数量"].Value != null)
                {
                    count = (decimal)row.Cells["数量"].Value;
                }
                else
                {
                    return;
                }

                //ArchiveSeeForm form = cell.GridControl.FindForm() as ArchiveSeeForm;
                车辆 cl = null;

                //if ((form.DisplayManager.CurrentItem) is 业务费用)
                //{
                //    cl = (form.DisplayManager.CurrentItem as 业务费用).车辆;
                //}
                //else if ((form.DisplayManager.CurrentItem) is 非业务车辆费用)
                //{
                //    cl = (form.DisplayManager.CurrentItem as 非业务车辆费用).车辆;
                //}
                //else
                //{
                //    throw new InvalidOperationException("实体不属于业务费用或非业务车辆费用！");
                //}

                using (IRepository rep = ServiceProvider.GetService<IRepositoryFactory>().GenerateRepository<车辆>())
                {
                    cl = rep.Get<车辆>(new Guid(row.Cells["车辆编号"].Value.ToString()));
                }

                if (cl != null)
                {
                    switch (cl.车辆类别)
                    {
                        case 车辆类别.自有车:
                        case 车辆类别.代管车:
                            if (row.Cells["费用归属"] != null && row.Cells["费用归属"].Value.ToString() == "对外")
                            {
                                if (cbyj.HasValue)
                                {
                                    cell.CellEditorControl.Text = (cbyj * count).ToString();
                                }
                                else
                                {
                                    throw new ArgumentException("数据库中必须配置成本油价！");
                                }                                
                            }
                            else
                            {
                                if (jsyyj.HasValue)
                                {
                                     cell.CellEditorControl.Text = (jsyyj * count).ToString();
                                }
                                else
                                {
                                    throw new ArgumentException("数据库中必须配置驾驶员油价！");
                                }                               
                            }
                            break;
                        case 车辆类别.挂靠车:
                            if (row.Cells["费用归属"] != null && row.Cells["费用归属"].Value.ToString() == "对外")
                            {
                                cell.CellEditorControl.Text = decimal.Multiply(Convert.ToDecimal(cbyj), count).ToString();
                            }
                            else if (row.Cells["费用归属"] != null && row.Cells["费用归属"].Value.ToString() == "车主")
                            {
                                if ((string)row.Cells["费用项编号"].Value == "204") //油费
                                {
                                    if (czyj.HasValue)
                                    {
                                        cell.CellEditorControl.Text = (czyj * count).ToString();
                                    }
                                    else
                                    {
                                        throw new ArgumentException("数据库中必须配置车主油价！");
                                    }                                   
                                }
                                else //定耗油
                                {
                                    if (czyj.HasValue && jsyyj.HasValue)
                                    {
                                        cell.CellEditorControl.Text = ((czyj - jsyyj) * count).ToString();
                                    }
                                    else
                                    {
                                        throw new ArgumentException("数据库中必须配置车主油价、驾驶员油价！！");
                                    }  
                                }
                            }
                            else
                            {
                                throw new ArgumentException("费用归属不规范！");
                            }
                            break;
                        case 车辆类别.外协车:
                            break;
                        default:
                            throw new ArgumentException("车辆类别不规范！");
                    }
                }
            }
            else if (sender is Xceed.Grid.InsertionCell)
            {
                Xceed.Grid.InsertionCell cell = sender as Xceed.Grid.InsertionCell;
                Xceed.Grid.InsertionRow row = cell.ParentRow as Xceed.Grid.InsertionRow;

                if (cell.ReadOnly || !((string)row.Cells["费用项编号"].Value == "204"
                    || (string)row.Cells["费用项编号"].Value == "205") || row.Cells["车辆编号"].Value == null)
                {
                    return;
                }

                if (row.Cells["升数"] != null && row.Cells["升数"].Value != null)
                {
                    count = (decimal)row.Cells["升数"].Value;
                }
                else if (row.Cells["数量"] != null && row.Cells["数量"].Value != null)
                {
                    count = (decimal)row.Cells["数量"].Value;
                }
                else
                {
                    return;
                }

                //ArchiveSeeForm form = cell.GridControl.FindForm() as ArchiveSeeForm;
                车辆 cl = null;

                //if ((form.DisplayManager.CurrentItem) is 业务费用)
                //{
                //    cl = (form.DisplayManager.CurrentItem as 业务费用).车辆;
                //}
                //else if ((form.DisplayManager.CurrentItem) is 非业务车辆费用)
                //{
                //    cl = (form.DisplayManager.CurrentItem as 非业务车辆费用).车辆;
                //}
                //else
                //{
                //    throw new InvalidOperationException("实体不属于业务费用或非业务车辆费用！");
                //}

                using (IRepository rep = ServiceProvider.GetService<IRepositoryFactory>().GenerateRepository<车辆>())
                {
                    cl = rep.Get<车辆>(new Guid(row.Cells["车辆编号"].Value.ToString()));
                }

                if (cl != null)
                {
                    switch (cl.车辆类别)
                    {
                        case 车辆类别.自有车:
                        case 车辆类别.代管车:
                            if (row.Cells["费用归属"] != null && row.Cells["费用归属"].Value.ToString() == "对外")
                            {
                                cell.CellEditorControl.Text = decimal.Multiply(Convert.ToDecimal(cbyj), count).ToString();
                            }
                            else
                            {
                                cell.CellEditorControl.Text = decimal.Multiply(Convert.ToDecimal(jsyyj), count).ToString();
                            }
                            break;
                        case 车辆类别.挂靠车:
                            if (row.Cells["费用归属"] != null && row.Cells["费用归属"].Value.ToString() == "对外")
                            {
                                cell.CellEditorControl.Text = decimal.Multiply(Convert.ToDecimal(cbyj), count).ToString();
                            }
                            else if (row.Cells["费用归属"] != null && row.Cells["费用归属"].Value.ToString() == "车主")
                            {
                                if ((string)row.Cells["费用项编号"].Value == "204") //油费
                                {
                                    cell.CellEditorControl.Text = decimal.Multiply(Convert.ToDecimal(czyj), count).ToString();
                                }
                                else //定耗油
                                {
                                    cell.CellEditorControl.Text = decimal.Multiply(Convert.ToDecimal(czyj) - Convert.ToDecimal(jsyyj), count).ToString();
                                }
                            }
                            else
                            {
                                throw new ArgumentException("费用归属不规范！");
                            }
                            break;
                        case 车辆类别.外协车:
                            break;
                        default:
                            throw new ArgumentException("车辆类别不规范！");
                    }
                }
            }
        }

        public static void Auto油费金额计算(ArchiveSeeForm masterForm)
        {
            (masterForm.ArchiveDetailForm as ArchiveDetailFormAuto).DataControlsCreated += new EventHandler(ArchiveDetailForm_DataControlsCreated);
            
            //((masterForm.ArchiveDetailForm as IArchiveDetailFormWithDetailGrids).DetailGrids[0] as IArchiveGrid).InsertionRow.Cells["付款金额"].DoubleClick += new EventHandler(油费金额计算);
            //((masterForm.ArchiveDetailForm as IArchiveDetailFormWithDetailGrids).DetailGrids[0] as IArchiveGrid).InsertionRow.Cells["收款金额"].DoubleClick += new EventHandler(油费金额计算);
        }

        static void ArchiveDetailForm_DataControlsCreated(object sender, EventArgs e)
        {
            ArchiveDetailForm form = sender as ArchiveDetailForm;
            ((form.DisplayManager.DataControls["金额"] as IWindowControl).Control as MyCurrencyTextBox).DoubleClick += new EventHandler(process_cl_cezjy_DoubleClick);
        }

        static void process_cl_cezjy_DoubleClick(object sender, EventArgs e)
        {
            MyCurrencyTextBox box = sender as MyCurrencyTextBox;
            ArchiveDetailForm form = box.FindForm() as ArchiveDetailForm;

            decimal count = Convert.ToDecimal(form.DisplayManager.DataControls["升数"].SelectedDataValue);
            if (form.DisplayManager.DataControls["费用归属"] != null && form.DisplayManager.DataControls["费用归属"].SelectedDataValue.ToString() == "驾驶员")
            {
                box.SelectedDataValue = decimal.Multiply(Convert.ToDecimal(jsyyj), count).ToString();
            }
            else if (form.DisplayManager.DataControls["费用归属"] != null && form.DisplayManager.DataControls["费用归属"].SelectedDataValue.ToString() == "车主")
            {
                box.SelectedDataValue = decimal.Multiply(Convert.ToDecimal(czyj), count).ToString();
            }
            else
            {
                box.SelectedDataValue = decimal.Multiply(Convert.ToDecimal(cbyj), count).ToString();
            }
        }
    }
}
