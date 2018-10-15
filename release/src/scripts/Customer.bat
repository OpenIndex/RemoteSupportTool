@REM ----------------------------------------------------------------------------
@REM RemoteSupportTool for customers
@REM Copyright (C) 2015-2018 OpenIndex.de
@REM ----------------------------------------------------------------------------
@echo off

:: Use a specific command to launch the Java Runtime Environment
set "JAVACMD="

:: Memory settings of the Java Runtime Environment
set "JAVA_HEAP_MINIMUM=32m"
set "JAVA_HEAP_MAXIMUM=512m"

:: Additional options for the Java Runtime Environment
set "JAVA_OPTS=-Dfile.encoding=UTF-8"

set "APP=de.openindex.support.customer/de.openindex.support.customer.CustomerApplication"

::
:: Start execution...
::

:: set "SCRIPT=%~nx0"
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
:: set "BASE_DIR=%SCRIPT_DIR%"
set "BASE_DIR=%SCRIPT_DIR%\..\"
if "%JAVACMD%"=="" set "JAVACMD=%BASE_DIR%\bin\java.exe"

pushd %BASE_DIR%
set "BASE_DIR=%CD%"

:: echo SCRIPT: %SCRIPT%
:: echo SCRIPT_DIR: %SCRIPT_DIR%
:: echo BASE_DIR: %BASE_DIR%

"%JAVACMD%" -Xms%JAVA_HEAP_MINIMUM% -Xmx%JAVA_HEAP_MAXIMUM% %JAVA_OPTS% -p "modules" -m %APP% %*
popd
