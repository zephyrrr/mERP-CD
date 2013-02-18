cd ..
mkdir Cd2Deploy
del /Q .\Cd2Deploy\*.*

cd .\Feng
rem call "build-vs.bat"
call "DeployAssemblies.bat"
cd..

cd .\Cd2
call "CopyAssembliesFeng.bat"
rem  call "build-vs.bat"
call "CopyConfig.bat"

cd .\Reference
del *.log
del log.txt*
del *.vshost.*
cd..

copy .\Reference\*.* ..\Cd2Deploy

copy .\Release.config ..\Cd2eploy\Feng.Run.exe.config

cd ..\Cd2Deploy

del *.pdb
del *.log
del *.bak
del *.sql
del log.txt*
del *.vshost.*
del schemaexport.*
del Cd.Run.*
del HibernatingRhinos.NHibernate.Profiler.Appender.dll
del SqlServerProject.dll
del ipy.exe
rem del ADInfosUtil.*

rmdir hdm

del Cd2.*
rename Feng.Run.exe.config Cd.exe.config
copy ..\Hd.Run.exe .\Cd.exe


cd ..\Cd2

IF ERRORLEVEL 1 pause
