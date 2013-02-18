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
                                                           "where 日期 >= dateadd(month,-2,getdate()) and 委托人 = '900008' and 任务类别 = 1 and 箱号 is not null " + \
                                                           "and (提箱时间要求止 is null or 还箱时间要求止 is null or 查验时间 is null or 到港时间 is null or 装卸货地 is null or 还箱地 is null) " + \
                                                           "union select Id,箱号 from 业务备案_任务 where 车辆产值 is null");
                        hd_boxList = cd_db.ExecuteDataView("select * from 视图查询交互_货代任务_All where 委托人 = '易可' and 箱号 is not null and 到港时间 >= dateadd(month,-2,getdate())");
                        print "Hd:" + str(hd_boxList.Count) + "\tCd:" + str(cd_boxList.Count);
                        time.sleep(2);
                        if (hd_boxList.Count == 0 or cd_boxList.Count == 0):
                                return;
                        cd_dataReader = cd_boxList.Table.CreateDataReader();
                        count = 0;
                        while (cd_dataReader.Read()):
                                xianghao = Feng.Utils.ConvertHelper.ToString(cd_dataReader["箱号"]);                                
                                if (xianghao == None):
                                        continue;
                                count = count + 1;
                                print "箱号:" + xianghao + "\t" + str(count);
                                hd_dataReader = hd_boxList.Table.CreateDataReader();
                                while (hd_dataReader.Read()):
                                        hd_xianghao = Feng.Utils.ConvertHelper.ToString(hd_dataReader["箱号"]);                                        
                                        if (str(xianghao) == str(hd_xianghao)):                                                
                                                with Feng.ServiceProvider.GetService[Feng.IRepositoryFactory]().GenerateRepository[Cd.Model.任务]() as rep:
                                                        try:
                                                                rwId = Feng.Utils.ConvertHelper.ToString(cd_dataReader["Id"]);
                                                                rep.BeginTransaction();
                                                                rw = rep.Get[Cd.Model.任务](System.Guid(rwId));
                                                                isCommit = False;
                                                                if (rw.提箱时间要求止 == None and hd_dataReader["货代提箱时间要求止"].ToString() != ""):
                                                                        rw.提箱时间要求止 = Feng.Utils.ConvertHelper.ToDateTime(hd_dataReader["货代提箱时间要求止"]);
                                                                        isCommit = True;
                                                                if (rw.还箱时间要求止 == None and hd_dataReader["货代还箱时间要求止"].ToString() != ""):
                                                                        rw.还箱时间要求止 = Feng.Utils.ConvertHelper.ToDateTime(hd_dataReader["货代还箱时间要求止"]);
                                                                        isCommit = True;
                                                                if (rw.查验时间 == None and hd_dataReader["商检查验时间"].ToString() != ""):
                                                                        rw.查验时间 = Feng.Utils.ConvertHelper.ToDateTime(hd_dataReader["商检查验时间"]);
                                                                        isCommit = True;
                                                                if (rw.到港时间 == None and hd_dataReader["到港时间"].ToString() != ""):
                                                                        rw.到港时间 = Feng.Utils.ConvertHelper.ToDateTime(hd_dataReader["到港时间"]);
                                                                        isCommit = True;
                                                                if (rw.还箱地编号 == None and hd_dataReader["还箱地"].ToString() != ""):
                                                                        rw.还箱地编号 = Feng.NameValueMappingCollection.Instance.FindColumn2FromColumn1("人员单位_全部", "简称", "编号", hd_dataReader["还箱地"]);
                                                                        isCommit = True;
                                                                if (rw.装卸货地编号 == None and hd_dataReader["装卸货地"].ToString() != ""):
                                                                        rw.装卸货地编号 = Feng.NameValueMappingCollection.Instance.FindColumn2FromColumn1("人员单位_全部", "简称", "编号", hd_dataReader["装卸货地"]);
                                                                        isCommit = True;
                                                                if (rw.放行时间 == None and hd_dataReader["放行时间"].ToString() != ""):
                                                                        rw.放行时间 = Feng.Utils.ConvertHelper.ToDateTime(hd_dataReader["放行时间"]);
                                                                        isCommit = True;
                                                                if (rw.船名航次 == None and hd_dataReader["船名航次"].ToString() != ""):
                                                                        rw.船名航次 = Feng.Utils.ConvertHelper.ToString(hd_dataReader["船名航次"]);
                                                                        isCommit = True;
                                                                if (isCommit):
                                                                        rep.Update(rw);
                                                                        print "Id:" + str(rw.Id) + "\t箱号:" + rw.箱号 + "\t货代自编号:" + rw.货代自编号;
                                                                rep.CommitTransaction();
                                                                if (isCommit):
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





