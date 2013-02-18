# -*- coding: UTF-8 -*- 
import clr
clr.AddReferenceByPartialName("System")
clr.AddReferenceByPartialName("System.Windows.Forms")
clr.AddReferenceByPartialName("System.Drawing")
clr.AddReferenceByPartialName("NHibernate")
clr.AddReferenceByPartialName("Feng.Base")
clr.AddReferenceByPartialName("Feng.Windows.Application")
clr.AddReferenceByPartialName("Feng.Data")
clr.AddReferenceByPartialName("Feng.Windows")
clr.AddReferenceByPartialName("Cd.Model.Yw")
clr.AddReferenceByPartialName("Hd.NetRead")

import System;
import System.Windows.Forms;
import NHibernate;
import Feng;
import Feng.Data;
import Cd.Model;
import Hd.NetRead;
import time;

def execute():
    while (True):
        nbeportGrab = Hd.NetRead.nbeportRead();
        db = Feng.Data.DbHelper.Instance.CreateDatabase("DataConnectionString");
        try:            
            nbeportGrab.SetLoginInfo(Feng.SystemDirectory.DefaultUserProfile.GetValue("Hd.Options", "NetReadUserName", ""),  \
                                     Feng.SystemDirectory.DefaultUserProfile.GetValue("Hd.Options", "NetReadPassword", ""));
            boxList = db.ExecuteDataView("select A.Id,箱号 from 业务备案_任务 as A inner join 业务备案_车辆产值 as B on A.车辆产值 = B.Id " + \
                                         "where 日期 >= dateadd(month,-2,getdate()) and 任务类别 = 2 and 箱号 is not null and (还箱时间 is null or 还箱地 is null) " + \
                                         "union select Id,箱号 from 业务备案_任务 where 车辆产值 is null");
            print "Cd:" + str(boxList.Count);
            time.sleep(2);
            if (boxList.Count == 0):
                return;
            dataReader = boxList.Table.CreateDataReader();
            while (dataReader.Read()):
                xianghao = Feng.Utils.ConvertHelper.ToString(dataReader["箱号"]);
                if (xianghao == None):
                    continue;
                web_boxList = nbeportGrab.查询集装箱数据通过箱号(Hd.NetRead.ImportExportType.出口集装箱, xianghao);
                print xianghao + "\t" + str(web_boxList.Count);
                if (web_boxList == None or web_boxList.Count == 0):
                    continue;
                with Feng.ServiceProvider.GetService[Feng.IRepositoryFactory]().GenerateRepository[Cd.Model.任务]() as rep:
                    try:
                        xiangId = Feng.Utils.ConvertHelper.ToString(dataReader["Id"]);
                        rep.BeginTransaction();
                        rw = rep.Get[Cd.Model.任务](System.Guid(xiangId));
                        if (rw == None):
                            continue;
                        for box in web_boxList:
                            if (rw.箱号 == box.集装箱号):
                                rw.还箱时间 = Feng.Utils.ConvertHelper.ToDateTime(box.进场时间);
                                rw.还箱地编号 = Feng.NameValueMappingCollection.Instance.FindColumn2FromColumn1("人员单位_全部", "全称", "编号", box.堆场区);
                                rep.Update(rw);
                        rep.CommitTransaction();
                        print "Id:" + str(rw.Id) + "\t箱号:" + rw.箱号 + "\t还箱时间:" + str(rw.还箱时间) + "\t还箱地编号:" + rw.还箱地编号;
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





