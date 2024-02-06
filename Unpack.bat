 @echo off

 @echo "Solution Name can be Smartform"
set /p arg1=Enter the solution name:

powershell -command "C:\Users\sarah.chen\project\H2H\src\HealthDirect.H2H.Release\PowerShell\PAC-SoutionUnpack.ps1" %arg1%
pause