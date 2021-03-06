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
    if (lt == None):
        return;
    dao = Cd.Model.非业务车辆费用Dao();#Hd.Model.HdBaseDao[Cd.Model.非业务车辆费用]();
    item = Cd.Model.非业务车辆费用();
    item1 = Cd.Model.非业务车辆费用();
    with Feng.ServiceProvider.GetService[Feng.IRepositoryFactory]().GenerateRepository[Cd.Model.车辆资产]() as rep:
        try:
            rep.BeginTransaction();
            item.费用实体 = lt;
            item.收付标志 = Hd.Model.收付标志.付;
            item.费用归属 = Cd.Model.费用归属.对外;
            item.相关人编号 = lt.相关人编号;
            item.费用项编号 = "386";
            item.金额 = lt.剩余折旧;
            #item.费用类别编号 = lt.费用实体类型编号;
            #item.车辆编号 = lt.车辆编号;
            #item.车辆承担 = True;
            dao.Save(rep, item);
            item1.费用实体 = lt;
            item1.收付标志 = Hd.Model.收付标志.收;
            item1.费用归属 = Cd.Model.费用归属.对外;
            item1.相关人编号 = lt.买方编号;            
            item1.费用项编号 = "386";
            item1.金额 = lt.卖出金额;
            #item1.费用类别编号 = lt.费用实体类型编号;
            #item1.车辆编号 = lt.车辆编号;
            #item.车辆承担 = False;
            dao.Save(rep, item1);
            rep.CommitTransaction();
            lt.费用.Add(item);
            lt.费用.Add(item1);
            masterForm.ControlManager.OnCurrentItemChanged();
            Feng.Windows.Forms.MessageForm.ShowInfo("已生成费用！");
        except System.Exception, ex:
            rep.RollbackTransaction();
            Feng.ServiceProvider.GetService[Feng.IExceptionProcess]().ProcessWithNotify(ex);

if __name__ == "<module>" or __name__ == "__builtin__":
    execute(masterForm);





