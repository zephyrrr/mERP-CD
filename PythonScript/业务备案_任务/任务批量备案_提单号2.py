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
clr.AddReferenceByPartialName("Hd.Model.Base")
clr.AddReferenceByPartialName("Hd.Model.Dao")
clr.AddReferenceByPartialName("Hd.NetRead")

import sys;
import System;
import System.Windows.Forms;
import NHibernate;
import Feng;
import Feng.Grid;
import Feng.Windows.Forms;
import Hd.Model;
import Hd.NetRead;

#程序无法编译，该函数未测试
def execute(masterForm):
    try:
        entity = masterForm.DisplayManager.CurrentItem;
        if (entity == None):
            return;
        if (System.String.IsNullOrEmpty(entity.提单号)):
            Feng.Windows.Forms.MessageForm.ShowWarning("请先输入提单号！");
            return;
        if (System.String.IsNullOrEmpty(entity.委托人编号)):
            Feng.Windows.Forms.MessageForm.ShowWarning("请先输入委托人！");
            return;
        pos = masterForm.DisplayManager.Position;
        nbeportGrab = Hd.NetRead.npediRead();
        boxList = nbeportGrab.进口卸箱查询(entity.提单号);
        editCurrent = False;
        for box in boxList:
            if (not editCurrent and (entity.箱号 == box.集装箱号 or System.String.IsNullOrEmpty(entity.箱号))):
                masterForm.DisplayManager.Position = pos;
                masterForm.ControlManager.EditCurrent();
                entity.箱号 = box.集装箱号;
                entity.提单号 = box.提单号;
                entity.船名航次 = box.船名航次;
                masterForm.ControlManager.OnCurrentItemChanged();
                masterForm.ControlManager.EndEdit(True);
                editCurrent = True;
            else:
                entity2 = masterForm.ControlManager.AddNew();
                entity2.箱号 = box.集装箱号;
                entity2.提单号 = box.提单号;
                entity2.委托人编号 = entity.委托人编号;
                entity2.任务类别 = entity.任务类别;
                entity2.自备箱 = entity.自备箱;
                entity2.船名航次 = box.船名航次;
                masterForm.ControlManager.EndEdit(True);
        Feng.Windows.Forms.MessageForm.ShowWarning("读取完成！");
    finally:
        return;
            
if __name__ == "<module>" or __name__ == "__builtin__":
    execute(masterForm);





