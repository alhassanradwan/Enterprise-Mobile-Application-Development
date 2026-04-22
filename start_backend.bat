@echo off
echo ========================================
echo Student Task Manager - Backend Server
echo ========================================
echo.

cd backend

if not exist node_modules (
    echo Installing dependencies...
    call npm install
    echo.
)

echo Starting server...
echo Server will run on http://localhost:3000
echo Press Ctrl+C to stop the server
echo.

call npm start
