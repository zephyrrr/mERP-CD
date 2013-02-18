# -*- coding: UTF-8 -*- 
import clr
clr.AddReferenceByPartialName("System")
clr.AddReferenceByPartialName("System.Windows.Forms")
clr.AddReferenceByPartialName("NHibernate")
clr.AddReferenceByPartialName("Feng.Base")
clr.AddReferenceByPartialName("Feng.Windows")
clr.AddReferenceByPartialName("Feng.Data")

import sys;
import System;
import System.Windows.Forms;
import NHibernate;
import Feng;
import Feng.Data;
import time;

def execute():
    db = Feng.Data.DbHelper.Instance.CreateDatabase("DataConnectionString");
    sqlList = ["exec 过程更新_查询_现金日记帐_行数", "exec 过程更新_查询_银行日记帐_行数", "exec 过程更新_查询_资金日记帐_行数", "exec 过程更新_业务备案_任务", \
               "exec 过程更新_车辆机油_警示状态", "exec 过程更新_车辆加油_警示状态", "exec 过程更新_车辆轮胎_警示状态", "exec 过程更新_车辆其他_警示状态", "exec 过程更新_车辆事故_警示状态", \
               "exec 过程更新_车辆维修_警示状态", "exec 过程更新_车辆资产_警示状态", "exec 过程更新_固定资产", "exec 过程更新_财务_费用信息", "exec 过程更新_财务_对账单", "exec 过程更新_业务备案_车辆产值"];
    while (True):
        for sql in sqlList:
            try:
                print sql;
                executeTime = System.DateTime.Now;
                db.ExecuteNonQuery(sql);
                print "执行时间：" + str(executeTime) + "\t用时：" + (System.DateTime.Now - executeTime).ToString() + "\n";
            except System.Exception, ex:
                #如执行过程中出错，忽略错误，继续执行
                print ex.Message + "\n";
                continue;
                #Feng.ServiceProvider.GetService[Feng.IExceptionProcess]().ProcessWithNotify(ex);
                #System.Windows.Forms.MessageBox.Show(ex.Message);
        time.sleep(3600);
            
if __name__ == "__main__":
    execute();
if __name__ == "<module>" or __name__ == "__builtin__":
    execute();





