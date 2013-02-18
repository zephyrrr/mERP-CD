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
                                idx = -1;
                                db = Feng.Data.DbHelper.Instance.CreateDatabase("HdConnecitonString");        
                                for entity in masterForm.DisplayManager.Items:
                                        if entity == None: System.Windows.Forms.MessageBox.Show("Entity is None");
                                        if (entity.委托人编号 != "900008"):
                                                continue;
                                        idx = idx + 1;
                                        if (System.String.IsNullOrEmpty(entity.回货箱号)):
                                                continue;
                                        row = db.ExecuteDataRow("select * from 视图查询_车队任务 where 委托人 = '易可' and 回货箱号 = '" + entity.回货箱号 + "' order by 委托时间 desc");             
                                        if (row == None):
                                                continue;
                                        masterForm.ControlManager.DisplayManager.Position = idx;
                                        entity.箱号 = Feng.Utils.ConvertHelper.ToString(row["箱号"]);
                                        entity.货代自编号 = Feng.Utils.ConvertHelper.ToString(row["货代自编号"]);
                                        entity.提单号 = Feng.Utils.ConvertHelper.ToString(row["提单号"]);
                                        entity.箱量 = Feng.Utils.ConvertHelper.ToInt(row["箱量"]);
                                        entity.船公司编号 = Feng.NameValueMappingCollection.Instance.FindColumn2FromColumn1("人员单位_全部", "简称", "编号", row["船公司"]);
                                        entity.还箱地编号 = Feng.NameValueMappingCollection.Instance.FindColumn2FromColumn1("人员单位_全部", "简称", "编号", row["还箱地"]);
                                        entity.船名航次 = Feng.Utils.ConvertHelper.ToString(row["船名航次"]);
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





