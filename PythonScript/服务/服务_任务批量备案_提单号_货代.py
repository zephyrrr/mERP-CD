# -*- coding: UTF-8 -*- 
import clr
clr.AddReferenceByPartialName("System")
clr.AddReferenceByPartialName("System.Windows.Forms")
clr.AddReferenceByPartialName("System.Drawing")
clr.AddReferenceByPartialName("NHibernate")
clr.AddReferenceByPartialName("Feng.Base")
clr.AddReferenceByPartialName("Feng.Data")
clr.AddReferenceByPartialName("Cd.Model.Yw")
clr.AddReferenceByPartialName("Hd.NetRead")

import sys;
import System;
import System.Windows.Forms;
import NHibernate;
import Feng;
import Cd.Model;
import Hd.NetRead;
import time;

def execute():
    db = Feng.Data.DbHelper.Instance.CreateDatabase("DataConnectionString");
    while (True):
        try:
            boxList = db.ExecuteDataView("select * from 视图查询交互_货代任务 where 任务类别 = '拆' and 到港时间 > DATEADD(dd, - 60, GETDATE()) order by 委托时间 desc");
            print "Hd:" + str(boxList.Count);
            time.sleep(2);
            if (boxList.Count == 0):
                return;
            count = 0;
            dataReader = boxList.Table.CreateDataReader();
            with Feng.ServiceProvider.GetService[Feng.IRepositoryFactory]().GenerateRepository[Cd.Model.任务]() as rep:
                try:
                    rep.BeginTransaction();
                    while (dataReader.Read()):
                        rw = Cd.Model.任务();
                        rw.委托人编号 = "900008";
                        rw.箱号 = Feng.Utils.ConvertHelper.ToString(dataReader["箱号"]);
                        rw.箱型编号 = Feng.Utils.ConvertHelper.ToInt(dataReader["箱型"]);
                        rw.货代自编号 = Feng.Utils.ConvertHelper.ToString(dataReader["货代自编号"]);
                        rw.提单号 = Feng.Utils.ConvertHelper.ToString(dataReader["提单号"]);
                        rw.箱量 = Feng.Utils.ConvertHelper.ToInt(dataReader["箱量"]);
                        rw.船公司编号 = Feng.Utils.ConvertHelper.ToString(Feng.NameValueMappingCollection.Instance.FindColumn2FromColumn1("人员单位_全部", "全称", "编号", dataReader["船公司"]));
                        rw.还箱地编号 = Feng.Utils.ConvertHelper.ToString(Feng.NameValueMappingCollection.Instance.FindColumn2FromColumn1("人员单位_全部", "全称", "编号", dataReader["还箱地"]));
                        rw.指运地编号 = Feng.Utils.ConvertHelper.ToString(Feng.NameValueMappingCollection.Instance.FindColumn2FromColumn1("人员单位_全部", "全称", "编号", dataReader["指运地"]));
                        rw.装卸货地编号 = Feng.Utils.ConvertHelper.ToString(Feng.NameValueMappingCollection.Instance.FindColumn2FromColumn1("人员单位_全部", "全称", "编号", dataReader["装卸货地"]));
                        rw.提箱地编号 = Feng.Utils.ConvertHelper.ToString(Feng.NameValueMappingCollection.Instance.FindColumn2FromColumn1("人员单位_全部", "全称", "编号", dataReader["提箱地"]));
                        rw.提箱时间要求止 = Feng.Utils.ConvertHelper.ToDateTime(dataReader["货代提箱时间要求止"]);
                        rw.还箱时间要求止 = Feng.Utils.ConvertHelper.ToDateTime(dataReader["货代还箱时间要求止"]);
                        rw.查验时间 = Feng.Utils.ConvertHelper.ToDateTime(dataReader["商检查验时间"]);
                        rw.到港时间 = Feng.Utils.ConvertHelper.ToDateTime(dataReader["到港时间"]);
                        rw.转关标志 = Feng.Utils.ConvertHelper.ToInt(dataReader["转关标志"]);
                        rw.船名航次 = Feng.Utils.ConvertHelper.ToString(dataReader["船名航次"]);
                        if (Feng.Utils.ConvertHelper.ToString(dataReader["任务类别"]) == "拆"):
                            rw.任务类别 = Cd.Model.任务类别.拆;
                        elif (Feng.Utils.ConvertHelper.ToString(dataReader["任务类别"]) == "装"):
                            rw.任务类别 = Cd.Model.任务类别.装;
                        elif (Feng.Utils.ConvertHelper.ToString(dataReader["任务类别"]) == "驳"):
                            rw.任务类别 = Cd.Model.任务类别.驳;
                        else:
                            rw.任务类别 = Cd.Model.任务类别.回;
                        rw.Created = System.DateTime.Now;
                        rw.CreatedBy = "货代读取";
                        rep.Save(rw);
                        print rw.箱号 + "\t" + str(count);
                        count = count + 1;
                    rep.CommitTransaction();
                except System.Exception, ex:
                    rep.RollbackTransaction();
                    Feng.ServiceProvider.GetService[Feng.IExceptionProcess]().ProcessWithNotify(ex);
                    System.Windows.Forms.MessageBox.Show(ex.Message);
        except System.Exception, ex:
            Feng.ServiceProvider.GetService[Feng.IExceptionProcess]().ProcessWithNotify(ex);
            System.Windows.Forms.MessageBox.Show(ex.Message);
        time.sleep(1800);
            
if __name__ == "<module>" or __name__ == "__builtin__":
    execute();





