call "D:\Program Files\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" 
msbuild /verbosity:n build-vs.proj

IF ERRORLEVEL 1 "C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\msbuild.exe" /verbosity:n build-vs.proj

pause