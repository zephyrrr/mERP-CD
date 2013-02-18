# -*- coding: UTF-8 -*- 
import clr
clr.AddReferenceByPartialName("System")
clr.AddReferenceByPartialName("System.Windows.Forms")
clr.AddReferenceByPartialName("System.Drawing")
clr.AddReferenceByPartialName("NHibernate")
clr.AddReferenceByPartialName("Feng.Base")
clr.AddReferenceByPartialName("Feng.Windows.Model")
clr.AddReferenceByPartialName("Feng.Model")
clr.AddReferenceByPartialName("Feng.Windows.Forms")
clr.AddReferenceByPartialName("Feng.Windows.Application")
clr.AddReferenceByPartialName("Cd.Model.Yw")
clr.AddReferenceByPartialName("Hd.Model.Base")
clr.AddReferenceByPartialName("Hd.Model.Dao")

import System;
import System.Windows.Forms;
import NHibernate;
import Feng;
import Feng.Windows.Forms;
import Cd.Model;
import Hd.Model;

def execute(masterForm):
    dict = System.Collections.Generic.Dictionary[System.String, System.Object]();
    if (masterForm.ControlManager.DisplayManager.DataControls["相关人编号"].SelectedDataValue != None):
	    dict["相关人编号"] = masterForm.ControlManager.DisplayManager.DataControls["相关人编号"].SelectedDataValue;
    
    checkWindow = Feng.ServiceProvider.GetService[Feng.IWindowFactory]().CreateWindow(Feng.ADInfoBll.Instance.GetWindowInfo("选择_应付对账单_费用"))
    form = Feng.ProcessSelect.Execute(masterForm.ArchiveDetailForm.ControlManager.DisplayManager, checkWindow, dict);
    if (form != None):
        detailCm = masterForm.ArchiveDetailForm.DetailGrids[0].ControlManager;
        for item in form.SelectedEntites:
            item.对账单 = masterForm.DisplayManager.CurrentItem;
            detailCm.AddNew();
            detailCm.DisplayManager.Items[detailCm.DisplayManager.Position] = item;
            detailCm.EndEdit();

if __name__ == "<module>" or __name__ == "__builtin__":
    execute(masterForm);





