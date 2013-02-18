# -*- coding: UTF-8 -*- 
import clr
clr.AddReferenceByPartialName("System")
clr.AddReferenceByPartialName("System.Windows.Forms")
clr.AddReferenceByPartialName("NHibernate")
clr.AddReferenceByPartialName("Feng.Base")
clr.AddReferenceByPartialName("Feng.Windows")
clr.AddReferenceByPartialName("Feng.Data")
clr.AddReferenceByPartialName("Cd.Model.Yw")

import sys;
import System;
import System.Windows.Forms;
import NHibernate;
import Feng;
import Feng.Data;
import Cd.Model;
import time;

def execute():
        cd_db = Feng.Data.DbHelper.Instance.CreateDatabase("DataConnectionString");
        while (True):                
                try:
                        cd_boxList = cd_db.ExecuteDataView("select A.Id,箱号 from 业务备案_任务 as A inner join 业务备案_车辆产值 as B on A.车辆产值 = B.Id " + \
                                                           "where 日期 >= dateadd(month,-2,getdate()) and 委托人 = '900008' and 任务类别 = 2 and 箱号 is not null and 货代自编号 is null " + \
                                                           "union select Id,箱号 from 业务备案_任务 where 委托人 = '900008' and 任务类别 = 2 and 车辆产值 is null and 箱号 is not null and 货代自编号 is null");
                        hd_boxList = cd_db.ExecuteDataView("select 箱号,货代自编号 from 视图查询交互_货代任务_All where 委托人 = '易可' and (任务类别 = '装' or 任务类别 = '回') and 箱号 is not null and 货代自编号 is not null and 委托时间 >= dateadd(month,-2,getdate())");
                        print "Hd:" + str(hd_boxList.Count) + "\tCd:" + str(cd_boxList.Count);
                        time.sleep(2);
                        if (hd_boxList.Count == 0 or cd_boxList.Count == 0):
                                return;
                        cd_dataReader = cd_boxList.Table.CreateDataReader();
                        count = 0;
                        while (cd_dataReader.Read()):
                                cd_xianghao = Feng.Utils.ConvertHelper.ToString(cd_dataReader["箱号"]);
                                if (cd_xianghao == None):
                                        continue;
                                count = count + 1;
                                print "箱号:" + cd_xianghao + "\t" + str(count);
                                hd_dataReader = hd_boxList.Table.CreateDataReader();
                                while (hd_dataReader.Read()):
                                        if (cd_xianghao == Feng.Utils.ConvertHelper.ToString(hd_dataReader["箱号"])):
                                                with Feng.ServiceProvider.GetService[Feng.IRepositoryFactory]().GenerateRepository[Cd.Model.任务]() as rep:
                                                        try:
                                                                rwId = Feng.Utils.ConvertHelper.ToString(cd_dataReader["Id"]);
                                                                rep.BeginTransaction();
                                                                rw = rep.Get[Cd.Model.任务](System.Guid(rwId));
                                                                rw.货代自编号 = Feng.Utils.ConvertHelper.ToString(hd_dataReader["货代自编号"]);
                                                                rep.Update(rw);
                                                                rep.CommitTransaction();
                                                                print "Id:" + str(rw.Id) + "\t箱号:" + rw.箱号 + "\t货代自编号:" + rw.货代自编号;
                                                                break;
                                                        except System.Exception, ex:
                                                                rep.RollbackTransaction();
                                                                Feng.ServiceProvider.GetService[Feng.IExceptionProcess]().ProcessWithNotify(ex);
                                                                #System.Windows.Forms.MessageBox.Show(ex.Message);
                                                                continue;
                                hd_dataReader.Close();
                except System.Exception, ex:
                        Feng.ServiceProvider.GetService[Feng.IExceptionProcess]().ProcessWithNotify(ex);
                        System.Windows.Forms.MessageBox.Show(ex.Message);
                time.sleep(1800);
                                                
                
if __name__ == "__main__":
        execute();
if __name__ == "<module>" or __name__ == "__builtin__":
        execute();





