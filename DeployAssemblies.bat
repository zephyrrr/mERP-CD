copy .\Reference\Cd.*.dll ..\Application\Cd\
copy .\Reference\Hd.*.dll ..\Application\Cd\
copy Cd.Run\release.config ..\Application\Cd\Cd.exe.config
copy Cd.Run\cd.model.*.config ..\Application\Cd\
copy Cd.Run\hd.model.*.config ..\Application\Cd\

IF ERRORLEVEL 1 pause