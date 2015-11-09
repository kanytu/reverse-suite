@echo off
color 0a

java -version >nul 2>&1||echo Error: Java is not found&&echo Please install JRE first &&echo.&&echo Existing..&&pause&&exit

cd /d "%~dp0"
cd ..

SET /p APK="Drag the APK..."
SET OUT="output\output.jar"

if exist "%OUT%" del /f "%OUT%"

CALL "tools\dex2jar\d2j-dex2jar.bat" -f -o %OUT% %APK%
java -jar "tools\gui\luyten.jar" %OUT%