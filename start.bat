@REM ----------------------------------------------------------------------------
@REM  Start application directly from source code.
@REM
@REM  Copyright (C) 2015-2016 OpenIndex.de
@REM  Distributed under the MIT License.
@REM  See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
@REM ----------------------------------------------------------------------------
@echo off

:: path to python interpreter
set PYTHON="python.exe"

:: get current directory
set BASE_DIR=%~dp0
:: echo %BASE_DIR%

:: launch application
set PYTHONPATH=%BASE_DIR%
cd "%BASE_DIR%"
"%PYTHON%" "src\Support.py"
