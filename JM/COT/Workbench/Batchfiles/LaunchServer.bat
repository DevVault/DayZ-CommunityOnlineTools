@echo off
setlocal enableextensions enabledelayedexpansion

cd /D "%~dp0"

set /a failed=0

if exist ../project.cfg (
	echo Found the project.cfg
) else (
	echo Failed to find the project.cfg file, exitting.
	set /a failed=1
)

if exist ../user.cfg (
	echo Found the user.cfg
) else (
	echo Failed to find the user.cfg file, exitting.
	set /a failed=1
)

if exist "%~dp0..\project.cfg.bat" del "%~dp0..\project.cfg.bat"

for /f "usebackq delims=" %%a in ( "%~dp0..\project.cfg" ) do (
	echo set %%a>>"%~dp0..\project.cfg.bat"
)

call "%~dp0..\project.cfg.bat"

if exist "%~dp0..\user.cfg.bat" del "%~dp0..\user.cfg.bat"

for /f "usebackq delims=" %%a in ( "%~dp0..\user.cfg" ) do (
	echo set %%a>>"%~dp0..\user.cfg.bat"
)

call "%~dp0..\user.cfg.bat"

echo ClientLaunchParams is: "%clientLaunchParams%"
if "%clientLaunchParams%"=="" (
    set /a failed=1
    echo ClientLaunchParams parameter was not set in the project.cfg
)

echo ServerLaunchParams is: "%serverLaunchParams%"
if "%serverLaunchParams%"=="" (
    set /a failed=1
    echo ServerLaunchParams parameter was not set in the project.cfg
)

echo ClientEXE is: "%clientEXE%"
if "%clientEXE%"=="" (
    set /a failed=1
    echo ClientEXE parameter was not set in the project.cfg
)

echo ServerEXE is: "%serverEXE%"
if "%serverEXE%"=="" (
    set /a failed=1
    echo ServerEXE parameter was not set in the project.cfg
)

echo MPMission is: "%mission%"
if "%mission%"=="" (
    set /a failed=1
    echo MPMission parameter was not set in the project.cfg
)

echo ModName is: "%modName%"
if "%modName%"=="" (
    set /a failed=1
    echo ModName parameter was not set in the project.cfg
)

echo AdditionalMPMods is: "%mods%"
if "%mods%"=="" (
    echo AdditionalMPMods parameter was not set in the project.cfg, ignoring.
    
    set mods=%modName%
) else (
    set mods=%mods%;%modName%
)

echo Port is: "%port%"
if "%port%"==0 (
    echo Port parameter was not set in the project.cfg, using 2302.
    set port=-port=2302
) else (
    set port=-port=%port%
)

echo ServerPassword is: "%password%"
if "%password%"=="" (
    echo ServerPassword parameter was not set in the project.cfg, continuing.
) else (
    set password=-password=%password%
)

echo GameDirectory is: "%gameDirectory%"
if "%gameDirectory%"=="" (
    set /a failed=1
    echo GameDirectory parameter was not set in the project.cfg
)

echo ServerDirectory is: "%serverDirectory%"
if "%serverDirectory%"=="" (
    set /a failed=1
    echo ServerDirectory parameter was not set in the project.cfg
)

echo ServerProfileDirectory is: "%serverProfileDirectory%"
if "%serverProfileDirectory%"=="" (
    set /a failed=1
    echo ServerProfileDirectory parameter was not set in the project.cfg
)

echo ServerConfig is: "%serverConfig%"
if "%serverConfig%"=="" (
    set /a failed=1
    echo ServerConfig parameter was not set in the project.cfg
)

echo ModBuildDirectory is: "%modBuildDirectory%"
if "%modBuildDirectory%"=="" (
	set /a failed=1
	echo ModBuildDirectory parameter was not set in the project.cfg
)

for %%a in ("%mods:;=" "%") do (
    set mod=%%~a
    if not defined modList (
        set modList=%modBuildDirectory%!mod!
    ) else (
        set modList=!modList!;%modBuildDirectory%!mod!
    )
)

chdir /d "%serverDirectory%"
echo start %serverEXE% %serverLaunchParams% "-config=%serverConfig%" "%port%" "-profiles=%serverProfileDirectory%" -dologs -adminlog -freezecheck "-scriptDebug=true" "-cpuCount=4" "-mission=%mission%" "-mod=%modList%"
start %serverEXE% %serverLaunchParams% "-config=%serverConfig%" "%port%" "-profiles=%serverProfileDirectory%" -dologs -adminlog -freezecheck "-scriptDebug=true" "-cpuCount=4" "-mission=%mission%" "-mod=%modList%"

TIMEOUT /T 5 /NOBREAK