# -*- coding: UTF-8 -*-
import clr
clr.AddReference("Feng.Windows")
from Feng.Utils import SecurityHelper;

SecurityHelper.SaveConnectionStrings(r"Cd.Run\connectionStrings.config", r"Reference\Data\Dbs.dat")




