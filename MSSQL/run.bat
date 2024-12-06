@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

IF "%~1"=="" (
    echo Usage: %0 ^<script_name.sql^>
    exit /b 1
)

SET SCRIPT_NAME=%~1

IF NOT EXIST ".\scripts\!SCRIPT_NAME!" (
    echo Script '.\scripts\!SCRIPT_NAME!' not found
    exit /b 1
)

docker exec -it hd-mssql /opt/mssql-tools/bin/sqlcmd ^
  -S localhost -U SA -P "YourStrong!Passw0rd" ^
  -i /scripts/!SCRIPT_NAME!