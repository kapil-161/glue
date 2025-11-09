@echo off
REM Launch script for GLUE Shiny UI (Windows)
REM Usage: run_ui.bat

echo Starting GLUE Shiny Application...
echo The application will open in your default web browser.
echo Press Ctrl+C to stop the application.
echo.

REM Check if Rscript exists
where Rscript >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: Rscript is not installed or not in PATH
    echo Please install R from https://cran.r-project.org/
    pause
    exit /b 1
)

REM Check if app.R exists
if not exist "app.R" (
    echo Error: app.R not found. Please run this script from the GLUE directory.
    pause
    exit /b 1
)

REM Run the Shiny app
Rscript run_ui.R

pause

