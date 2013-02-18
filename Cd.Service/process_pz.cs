using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;
using Feng;
using Feng.Windows.Forms;
using Feng.Grid;
using Feng.Utils;
using Hd.Model;

namespace Cd.Service
{
    public class process_pz
    {
        public static void 添加现有车辆管理费用(ArchiveOperationForm masterForm)
        {
            IControlManager<凭证费用明细> detailCm = (((IArchiveDetailFormWithDetailGrids)masterForm.ArchiveDetailForm).DetailGrids[0] as IArchiveGrid).ControlManager as IControlManager<凭证费用明细>;

            ArchiveCheckForm form = ServiceProvider.GetService<IWindowFactory>().CreateWindow(ADInfoBll.Instance.GetWindowInfo("选择_会计凭证_车辆管理费用")) as ArchiveCheckForm;
            if (form.ShowDialog() == DialogResult.OK)
            {
                IList<费用> list = new List<费用>();
                foreach (object i in form.SelectedEntites)
                {
                    list.Add(i as 费用);
                }

                Hd.Service.process_pz.AddFees(masterForm.DisplayManager.CurrentItem as 凭证, list, detailCm);
            }
        }

        public static void 新增会计收款(ArchiveOperationForm masterForm)
        {
            if (masterForm.DoAdd())
            {
                凭证 pz = masterForm.DisplayManager.CurrentItem as 凭证;
                pz.凭证类别 = 凭证类别.收款凭证;
                pz.自动手工标志 = 自动手工标志.手工;
                pz.操作人 = "会计";
                //pz.日期 = System.DateTime.Today;
                (masterForm.ArchiveDetailForm as ArchiveDetailForm).UpdateContent();
            }
        }

        public static void 新增付款凭证(ArchiveOperationForm masterForm)
        {
            if (masterForm.DoAdd())
            {
                凭证 pz = masterForm.DisplayManager.CurrentItem as 凭证;
                pz.凭证类别 = 凭证类别.付款凭证;
                pz.自动手工标志 = 自动手工标志.手工;
                //pz.操作人 = "会计";
                //pz.日期 = System.DateTime.Today;
                (masterForm.ArchiveDetailForm as ArchiveDetailForm).UpdateContent();
            }
        }

        public static void 新增收款凭证(ArchiveOperationForm masterForm)
        {
            if (masterForm.DoAdd())
            {
                凭证 pz = masterForm.DisplayManager.CurrentItem as 凭证;
                pz.凭证类别 = 凭证类别.收款凭证;
                pz.自动手工标志 = 自动手工标志.手工;
                //pz.操作人 = "会计";
                //pz.日期 = System.DateTime.Today;
                (masterForm.ArchiveDetailForm as ArchiveDetailForm).UpdateContent();
            }
        }

        public static void 凭证修改(ArchiveOperationForm masterForm)
        {
            凭证 pz = masterForm.DisplayManager.CurrentItem as 凭证;
            if (pz == null)
            {
                MessageForm.ShowError("请选择要修改的凭证！");
                return;
            }
            //pz.操作人 = "出纳";

            masterForm.DoEdit();
        }

        public static void AddFees(凭证 master, IList<费用> list, IControlManager<凭证费用明细> detailCm)
        {
            AddFees(master, list, detailCm, true, null);
        }

        public static void AddFees(凭证 master, IList<费用> list, IControlManager<凭证费用明细> detailCm, bool add, 收付标志? asDzd收付标志)
        {
            if (list == null)
                return;

            List<费用> newList = new List<费用>();
            foreach (费用 i in list)
            {
                if (i.凭证费用明细 == null)
                {
                    newList.Add(i);
                }
            }

            IList<凭证费用明细> ret = new List<凭证费用明细>();
            if (!asDzd收付标志.HasValue)
            {
                // 费用实体类型. 收付标志, 费用项编号, 相关人编号
                Dictionary<Tuple<int, 收付标志, string, string>, IList<费用>> dict = Cd.Model.Utility.GroupFyToPzYsyf(newList);

                foreach (KeyValuePair<Tuple<int, 收付标志, string, string>, IList<费用>> kvp in dict)
                {
                    凭证费用明细 pzs1 = new 凭证费用明细();

                    decimal sum = 0;
                    foreach (费用 k4 in kvp.Value)
                    {
                        sum += k4.金额.Value;
                        k4.凭证费用明细 = pzs1;
                    }

                    //string s = NameValueMappingCollection.Instance.FindNameFromId("信息_业务类型_全部", kvp.Key.Item1);
                    //if (string.IsNullOrEmpty(s))
                    //{
                    //    pzs1.业务类型编号 = null;
                    //}
                    //else
                    //{
                    //    pzs1.业务类型编号 = kvp.Key.Item1;
                    //}
                    pzs1.业务类型编号 = kvp.Key.Item1;

                    pzs1.费用 = kvp.Value;
                    pzs1.费用项编号 = kvp.Key.Item3;
                    pzs1.金额 = sum;
                    pzs1.收付标志 = kvp.Key.Item2;
                    pzs1.相关人编号 = kvp.Key.Item4;

                    // pzs1.凭证 = pz;

                    ret.Add(pzs1);
                }
            }
            else
            {
                Dictionary<Tuple<int, string>, IList<费用>> dict = Cd.Model.Utility.GroupFyToDzdYsyf(newList);

                foreach (KeyValuePair<Tuple<int, string>, IList<费用>> kvp in dict)
                {
                    凭证费用明细 pzs1 = new 凭证费用明细();

                    decimal sum = 0;
                    foreach (费用 k4 in kvp.Value)
                    {
                        if (k4.收付标志 == asDzd收付标志.Value)
                        {
                            sum += k4.金额.Value;
                        }
                        else
                        {
                            sum -= k4.金额.Value;
                        }
                        k4.凭证费用明细 = pzs1;
                    }

                    //string s = NameValueMappingCollection.Instance.FindNameFromId("信息_业务类型_全部", kvp.Key.First);
                    //if (string.IsNullOrEmpty(s))
                    //{
                    //    pzs1.业务类型编号 = null;
                    //}
                    //else
                    //{
                    //    pzs1.业务类型编号 = kvp.Key.First;
                    //}
                    pzs1.业务类型编号 = kvp.Key.Item1;

                    pzs1.费用 = kvp.Value;
                    pzs1.费用项编号 = "000";    // 常规应收应付
                    pzs1.金额 = sum;
                    pzs1.收付标志 = asDzd收付标志.Value;
                    pzs1.相关人编号 = kvp.Key.Item2;

                    // pzs1.凭证 = pz;

                    ret.Add(pzs1);
                }
            }

            if (add)
            {
                foreach (凭证费用明细 item in ret)
                {
                    detailCm.AddNew();
                    detailCm.DisplayManager.Items[detailCm.DisplayManager.Position] = item;
                    detailCm.EndEdit();

                    foreach (费用 i in item.费用)
                    {
                        i.凭证费用明细 = item;
                    }
                }
            }
            else
            {
                if (ret.Count == 0)
                    return;

                System.Diagnostics.Debug.Assert(ret.Count <= 1, "选出多个凭证费用明细，请查证！");
                System.Diagnostics.Debug.Assert(ret[0].费用项编号 == detailCm.DisplayManagerT.CurrentEntity.费用项编号, "凭证费用明细费用项和选择的费用项不同！");
                System.Diagnostics.Debug.Assert(ret[0].相关人编号 == detailCm.DisplayManagerT.CurrentEntity.相关人编号, "凭证费用明细费用项和选择的相关人不同！");
                System.Diagnostics.Debug.Assert(ret[0].收付标志 == detailCm.DisplayManagerT.CurrentEntity.收付标志, "凭证费用明细费用项和选择的相关人不同！");

                using (IRepository rep = ServiceProvider.GetService<IRepositoryFactory>().GenerateRepository<费用>())
                {
                    rep.Initialize(detailCm.DisplayManagerT.CurrentEntity.费用, detailCm.DisplayManagerT.CurrentEntity);
                }

                if (detailCm.DisplayManagerT.CurrentEntity.费用 == null)
                {
                    detailCm.DisplayManagerT.CurrentEntity.费用 = new List<费用>();
                }
                foreach (费用 i in ret[0].费用)
                {
                    i.凭证费用明细 = detailCm.DisplayManagerT.CurrentEntity;
                }

                detailCm.EditCurrent();
                detailCm.EndEdit();
            }
        }
    }
}
