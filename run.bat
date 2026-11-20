@echo off
REM ============================================================
REM  Madhuban Group - one-click launcher (Windows)
REM  Double-click this file to start the website + backend.
REM ============================================================
cd /d "%~dp0"
title Madhuban Group - Launcher

echo.
echo   Madhuban Group - starting up...
echo.

REM First run? Install dependencies.
if not exist "node_modules" (
  echo   Installing dependencies for the first time. Please wait...
  call npm install
  echo.
)

REM No config yet? Create it from the template.
if not exist ".env" (
  copy ".env.example" ".env" >nul
  echo   Created .env  -  open it and set your ADMIN_PASSWORD before going live.
  echo.
)

REM Start the server in its own window (close that window to stop the site).
start "Madhuban Server (close to stop)" cmd /k "npm start"

REM Give the server a moment, then open the site in the browser.
timeout /t 3 /nobreak >nul
start "" "http://localhost:3000"

echo   The site is opening in your browser:  http://localhost:3000
echo   Admin dashboard:                      http://localhost:3000/admin
echo.
echo   A separate "Madhuban Server" window is now running the site.
echo   Close that window (or press Ctrl+C in it) to stop the site.
echo.
pause
