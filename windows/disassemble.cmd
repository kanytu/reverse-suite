@echo off
color 0a

java -version >nul 2>&1||echo Error: Java is not found&&echo Please install JRE first &&echo.&&echo Existing..&&pause&&exit

cd /d "%~dp0"
cd ..

SET /p APK="Drag the apk..."
SET OUT="output/apk_code"

if not exist %OUT% md %OUT%
if exist %OUT%\. rd /s /q %OUT%

java -jar "tools\others\apktool.jar" d %APK% -o %OUT%