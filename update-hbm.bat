cd .\Reference
mkdir hbm

del /Q ..\Reference\hbm\*
..\Reference\ADInfosUtil.exe -hbm Cd.Model.Yw
copy /B /Y ..\Reference\hbm\* ..\Cd.Model.Base\Domain.hbm.xml

IF ERRORLEVEL 1 pause

cd ..