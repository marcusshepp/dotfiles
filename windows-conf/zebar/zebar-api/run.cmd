@echo off
rem Supervisor for the Zebar status API. Restarts bun if it exits; `zbar api stop`
rem drops a .stop file so the loop ends instead of resurrecting the server.
cd /d "%~dp0"
del /q .stop 2>nul
:loop
if exist .stop goto :eof
"C:\Users\marcu\.bun\bin\bun.exe" run server.ts >> api.log 2>&1
if exist .stop goto :eof
ping -n 6 127.0.0.1 >nul
goto loop
