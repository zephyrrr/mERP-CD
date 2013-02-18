# -*- coding: UTF-8 -*- 
import clr
clr.AddReferenceByPartialName("System")
clr.AddReferenceByPartialName("System.Windows.Forms")
clr.AddReferenceByPartialName("System.Drawing")
clr.AddReferenceByPartialName("NHibernate")
clr.AddReferenceByPartialName("Feng.Base")
clr.AddReferenceByPartialName("Feng.Model")
clr.AddReferenceByPartialName("Feng.Windows.Forms")
clr.AddReferenceByPartialName("Feng.Windows.Application")
clr.AddReferenceByPartialName("Cd.Model.Yw")
clr.AddReferenceByPartialName("Hd.Model.Base")
clr.AddReferenceByPartialName("Hd.Model.Dao")

import System;
import System.Windows.Forms;
import NHibernate;
import Feng;
import Feng.Windows.Forms;
import Cd.Model;
import Hd.Model;

def execute(masterForm):
    lt = masterForm.DisplayManager.CurrentItem;
    if (lt == None or str(lt.买卖标志) == "买入" or lt.车辆编号 == None):
        return;
    dao = Cd.Model.非业务车辆费用Dao();
    yj = Feng.ServiceProvider.GetService[Feng.IDefinition]().TryGetValue("车主油价");
    cbyj = Feng.ServiceProvider.GetService[Feng.IDefinition]().TryGetValue("成本油价");
    jsyyj = Feng.ServiceProvider.GetService[Feng.IDefinition]().TryGetValue("驾驶员油价");
    item = Cd.Model.非业务车辆费用();
    item1 = Cd.Model.非业务车辆费用();
    with Feng.ServiceProvider.GetService[Feng.IRepositoryFactory]().GenerateRepository[Cd.Model.车辆库存加油]() as rep:
        try:
            rep.BeginTransaction();
            lt.车辆 = rep.Get[Cd.Model.车辆](lt.车辆编号);
            
            item.费用实体 = lt;
            item.收付标志 = Hd.Model.收付标志.付;
            item.费用归属 = Cd.Model.费用归属.对外;
            item.相关人编号 = "900031";
            item.费用项编号 = "204";
            item.数量 = lt.数量;
            if (cbyj != None and System.Convert.ToDecimal(cbyj) != 0):
                item.金额 = item.数量 * System.Convert.ToDecimal(cbyj);  
            if (lt.车辆编号 != None and str(lt.车辆.车辆类别) == "挂靠车" and str(lt.买卖标志) == "卖出"):
                
                #item.车辆承担 = False;
                item1.费用实体 = lt;
                item1.收付标志 = Hd.Model.收付标志.收;
                item1.费用归属 = Cd.Model.费用归属.车主;
                item1.相关人编号 = lt.车主编号;
                item1.费用项编号 = "204";
                item1.数量 = lt.数量;
                if (yj != None and System.Convert.ToDecimal(yj) != 0):
                    item1.金额 = item.数量 * System.Convert.ToDecimal(yj);
                dao.Save(rep, item1);
                lt.费用.Add(item1);
            if (lt.车辆编号 != None and (str(lt.车辆.车辆类别) == "自有车" or str(lt.车辆.车辆类别) == "代管车") and str(lt.买卖标志) == "卖出"):
                #item.车辆承担 = False;
                item1.费用实体 = lt;
                item1.收付标志 = Hd.Model.收付标志.收;
                item1.费用归属 = Cd.Model.费用归属.驾驶员;
                item1.相关人编号 = lt.驾驶员编号;
                item1.费用项编号 = "204";
                item1.数量 = lt.数量;
                if (yj != None and System.Convert.ToDecimal(yj) != 0):
                    item1.金额 = item.数量 * System.Convert.ToDecimal(jsyyj);
                dao.Save(rep, item1);
                lt.费用.Add(item1);
            dao.Save(rep, item);
            rep.CommitTransaction();
            lt.费用.Add(item);
            masterForm.ControlManager.OnCurrentItemChanged();
            Feng.Windows.Forms.MessageForm.ShowInfo("已生成费用！");
        except System.Exception, ex:
            rep.RollbackTransaction();
            Feng.ServiceProvider.GetService<Feng.IExceptionProcess>().ProcessWithNotify(ex);

if __name__ == "<module>" or __name__ == "__builtin__":
    execute(masterForm);





