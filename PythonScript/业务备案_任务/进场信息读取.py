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

import System;
import System.Windows.Forms;
import NHibernate;
import Feng;
import Feng.Grid;
import Feng.Windows.Forms;
import Cd.Model;
import Hd.NetRead;

def execute(masterForm):
    def DoWork():
        with Feng.ServiceProvider.GetService[Feng.IRepositoryFactory]().GenerateRepository[Cd.Model.任务]() as rep:
            try:
                rep.BeginTransaction();
                entityList = masterForm.DisplayManager.Items;
                if (entityList.Count == 0):
                    return;
                pos = -1;     
                nbeportGrab = Hd.NetRead.nbeportRead();
                nbeportGrab.SetLoginInfo(Feng.SystemDirectory.DefaultUserProfile.GetValue("Hd.Options", "NetReadUserName", ""),  \
                            Feng.SystemDirectory.DefaultUserProfile.GetValue("Hd.Options", "NetReadPassword", ""));                
                for entity in entityList:
                    pos = pos + 1;
                    if (entity.还箱时间 != None and entity.还箱地编号 != None):
                        continue;
                    if (str(entity.任务类别) != "装" or System.String.IsNullOrEmpty(entity.箱号)):
                        continue;            
                    boxList = nbeportGrab.查询集装箱数据通过箱号(Hd.NetRead.ImportExportType.出口集装箱, entity.箱号);
                    for box in boxList:
                        if (entity.箱号 == box.集装箱号):
                            masterForm.DisplayManager.Position = pos;
                            entity.还箱时间 = box.进场时间;
                            entity.还箱地编号 = Feng.NameValueMappingCollection.Instance.FindColumn2FromColumn1("人员单位_全部", "全称", "编号", box.堆场区);
                            rep.Update(entity);
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





