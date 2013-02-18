# -*- coding: UTF-8 -*- 
import clr
clr.AddReferenceByPartialName("System")
clr.AddReferenceByPartialName("System.Windows.Forms")
clr.AddReferenceByPartialName("System.Drawing")
clr.AddReferenceByPartialName("NHibernate")
clr.AddReferenceByPartialName("Feng.Base")
clr.AddReferenceByPartialName("Feng.Windows.Forms")
clr.AddReferenceByPartialName("Feng.Windows.Application")
clr.AddReferenceByPartialName("Feng.Grid")
clr.AddReferenceByPartialName("Feng.Data")
clr.AddReferenceByPartialName("Feng.Windows")
clr.AddReferenceByPartialName("Cd.Model.Yw")
clr.AddReferenceByPartialName("Hd.Model.Dao")
clr.AddReferenceByPartialName("Hd.NetRead")

import sys;
import System;
import System.Windows.Forms;
import NHibernate;
import Feng;
import Feng.Windows.Forms;
import Feng.Grid;
import Cd.Model;
import Hd.NetRead;

def execute(masterForm):
    def DoWork():
        with Feng.ServiceProvider.GetService[Feng.IRepositoryFactory]().GenerateRepository[Cd.Model.任务]() as rep:
            try:
                rep.BeginTransaction();
                read = Hd.NetRead.npediRead();
                idx = -1;
                for entity in masterForm.DisplayManager.Items:
                    idx = idx + 1;
                    if (entity.提箱时间 != None):
                        continue;
                    if (System.String.IsNullOrEmpty(entity.提单号)):
                        continue;
                    boxList = read.集装箱出门查询(entity.提单号);
                    for data in boxList:
                        if (entity.箱号.Trim() == data.集装箱号.Trim()):
                            masterForm.DisplayManager.Position = idx;
                            entity.提箱时间 = data.出门时间;
                            rep.Update(entity);
                            break;
                rep.CommitTransaction();
                return None;
            except System.Exception, ex:
                rep.RollbackTransaction();
                Feng.Windows.Forms.MessageForm.ShowError(ex.Message);                
    def WorkDown(result):
        #masterForm.ControlManager.OnCurrentItemChanged();
        Feng.Grid.BoundGridExtention.ReloadData(masterForm.MasterGrid);
        
    Feng.Utils.ProgressAsyncHelper(     \
                Feng.Async.AsyncHelper.DoWork(DoWork), \
                Feng.Async.AsyncHelper.WorkDone(WorkDown), \
                masterForm, "读取");
        
if __name__ == "<module>" or __name__ == "__builtin__":
    execute(masterForm);





