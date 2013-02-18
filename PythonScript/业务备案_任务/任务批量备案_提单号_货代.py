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
clr.AddReferenceByPartialName("Cd.Model.Yw")
clr.AddReferenceByPartialName("Hd.Model.Dao")
clr.AddReferenceByPartialName("Hd.NetRead")

import sys;
import System;
import System.Windows.Forms;
import NHibernate;
import Feng;
import Feng.Grid;
import Feng.Windows.Forms;
import Cd.Model;
import Hd.NetRead;

def execute(masterForm):
    try:
        db = Feng.Data.DbHelper.Instance.CreateDatabase("DataConnectionString");
        boxList = db.ExecuteDataSet("select * from 视图查询交互_货代任务 where 任务类别 = '拆' and 到港时间 > DATEADD(dd, - 60, GETDATE()) order by 委托时间 desc");
        dataReader = boxList.CreateDataReader();
        while (dataReader.Read()):
                entity2 = masterForm.ControlManager.AddNew();
                entity2.委托人编号 = "900008";
                entity2.箱号 = Feng.Utils.ConvertHelper.ToString(dataReader["箱号"]);
                entity2.箱型编号 = Feng.Utils.ConvertHelper.ToInt(dataReader["箱型"]);
                entity2.货代自编号 = Feng.Utils.ConvertHelper.ToString(dataReader["货代自编号"]);
                entity2.提单号 = Feng.Utils.ConvertHelper.ToString(dataReader["提单号"]);
                entity2.箱量 = Feng.Utils.ConvertHelper.ToInt(dataReader["箱量"]);
                entity2.船公司编号 = Feng.Utils.ConvertHelper.ToString(Feng.NameValueMappingCollection.Instance.FindColumn2FromColumn1("人员单位_全部", "全称", "编号", dataReader["船公司"]));
                entity2.还箱地编号 = Feng.Utils.ConvertHelper.ToString(Feng.NameValueMappingCollection.Instance.FindColumn2FromColumn1("人员单位_全部", "全称", "编号", dataReader["还箱地"]));
                entity2.指运地编号 = Feng.Utils.ConvertHelper.ToString(Feng.NameValueMappingCollection.Instance.FindColumn2FromColumn1("人员单位_全部", "全称", "编号", dataReader["指运地"]));
                entity2.装卸货地编号 = Feng.Utils.ConvertHelper.ToString(Feng.NameValueMappingCollection.Instance.FindColumn2FromColumn1("人员单位_全部", "全称", "编号", dataReader["装卸货地"]));
                entity2.提箱地编号 = Feng.Utils.ConvertHelper.ToString(Feng.NameValueMappingCollection.Instance.FindColumn2FromColumn1("人员单位_全部", "全称", "编号", dataReader["提箱地"]));
                entity2.提箱时间要求止 = Feng.Utils.ConvertHelper.ToDateTime(dataReader["货代提箱时间要求止"]);
                entity2.还箱时间要求止 = Feng.Utils.ConvertHelper.ToDateTime(dataReader["货代还箱时间要求止"]);
                entity2.查验时间 = Feng.Utils.ConvertHelper.ToDateTime(dataReader["商检查验时间"]);
                entity2.到港时间 = Feng.Utils.ConvertHelper.ToDateTime(dataReader["到港时间"]);
                entity2.转关标志 = Feng.Utils.ConvertHelper.ToInt(dataReader["转关标志"]);
                entity2.船名航次 = Feng.Utils.ConvertHelper.ToString(dataReader["船名航次"]);
                if (Feng.Utils.ConvertHelper.ToString(dataReader["任务类别"]) == "拆"):
                    entity2.任务类别 = Cd.Model.任务类别.拆;
                elif (Feng.Utils.ConvertHelper.ToString(dataReader["任务类别"]) == "装"):
                    entity2.任务类别 = Cd.Model.任务类别.装;
                elif (Feng.Utils.ConvertHelper.ToString(dataReader["任务类别"]) == "驳"):
                    entity2.任务类别 = Cd.Model.任务类别.驳;
                else:
                    entity2.任务类别 = Cd.Model.任务类别.回;
                #entity2.自备箱 = entity.自备箱;
                masterForm.ControlManager.EndEdit(True);
        Feng.Windows.Forms.MessageForm.ShowWarning("读取了" + boxList.Tables[0].Rows.Count.ToString() + "条信息！");
    except System.Exception, ex:
        Feng.ServiceProvider.GetService[Feng.IExceptionProcess]().ProcessWithNotify(ex);
            
if __name__ == "<module>" or __name__ == "__builtin__":
    execute(masterForm);





