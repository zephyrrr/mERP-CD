using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Text;
using Feng;
using Cd.Model;
using Hd.Model;
using Feng.Windows.Forms;

namespace Cd.Service
{
    public class process_clcz
    {
        public static void 自动生成出车(GeneratedArchiveOperationForm masterForm)
        {
            if (MessageForm.ShowYesNo("是否自动生成出车？","提示"))
            {
                using (IRepository rep = ServiceProvider.GetService<IRepositoryFactory>().GenerateRepository<车辆>())
                {
                    IList<车辆> cl_List = (rep as Feng.NH.INHibernateRepository).List<车辆>(NHibernate.Criterion.DetachedCriteria.For<车辆>()
                    .Add(NHibernate.Criterion.Expression.Eq("默认出车", true)));

                    if (cl_List.Count == 0)
                    {
                        throw new InvalidUserOperationException("您还没有安排默认车！");
                    }

                    foreach (车辆 cl in cl_List)
                    {
                        车辆产值 clcz = new 车辆产值();
                        clcz = masterForm.ControlManager.AddNew() as 车辆产值;
                        clcz.日期 = DateTime.Now.AddDays(1);
                        clcz.车辆编号 = cl.ID;
                        clcz.承运人编号 = cl.车主编号;
                        clcz.驾驶员编号 = cl.默认驾驶员编号;
                        masterForm.DisplayManager.DisplayCurrent();
                        masterForm.ControlManager.EndEdit(true);
                    }
                }  
            }
        }
    }
}
