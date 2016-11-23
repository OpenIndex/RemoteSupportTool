@REM ----------------------------------------------------------------------------
@REM  Build application binary on Windows.
@REM
@REM  Copyright (C) 2015-2016 OpenIndex.de
@REM  Distributed under the MIT License.
@REM  See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
@REM ----------------------------------------------------------------------------
@echo off

:: path to pyinstaller script
set BUILD=C:\Python27\Scripts\pyinstaller.exe

:: get current directory
set BASE_DIR=%~dp0
:: echo %BASE_DIR%

set SPEC=%BASE_DIR%\misc\Remote-Support-Tool.spec
set TARGET=%BASE_DIR%\target
set LOG_LEVEL=INFO
:: set LOG_LEVEL=DEBUG

echo building application package
echo specified by %SPEC%
rmdir "%TARGET%" /s /q
mkdir "%TARGET%"
cd "%BASE_DIR%"
"%BUILD%" --log-level "%LOG_LEVEL%" --distpath "%TARGET%" --workpath "target\build" "%SPEC%"
echo .... done.
