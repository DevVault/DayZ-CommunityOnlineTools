@echo off
setlocal enableextensions enabledelayedexpansion

set batchDirectory=%~dp0

set /a failed=0

set /p enableCompression=Enable Compression?[Y/N]?

if /I "%enableCompression%"=="Y" ( 
	set /a compression=1
) else (
	set /a compression=0
)

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

if %failed%==1 (
	endlocal

	echo Failed to package the mod.
	goto:eof
)

set githubDirectory=%~dp0\
set workbenchDataDirectory=%githubDirectory%Workbench\
set toolsDirectory=%workbenchDataDirectory%Tools\

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

echo KeyDirectory is: "%keyDirectory%"
if "%keyDirectory%"=="" (
	set /a failed=1
	echo KeyDirectory parameter was not set in the project.cfg
)

echo KeyName is: "%keyName%"
if "%keyName%"=="" (
	set /a failed=1
	echo KeyName parameter was not set in the project.cfg
)

echo ModName is: "%modName%"
if "%modName%"=="" (
	set /a failed=1
	echo ModName parameter was not set in the project.cfg
)

echo WorkDrive is: "%workDrive%"
if "%workDrive%"=="" (
	set /a failed=1
	echo WorkDrive parameter was not set in the project.cfg
)

echo ModBuildDirectory is: "%modBuildDirectory%"
if "%modBuildDirectory%"=="" (
	set /a failed=1
	echo ModBuildDirectory parameter was not set in the project.cfg
)

echo PrefixLinkRoot is: "%prefixLinkRoot%"
if "%prefixLinkRoot%"=="" (
	set /a failed=1
	echo PrefixLinkRoot parameter was not set in the project.cfg
)

echo Searching for Mikero Tools...
for /F "Tokens=2* skip=2" %%A In ('REG QUERY "HKCU\SOFTWARE\Mikero\depbo" /v "path" 2^>nul') do (set _MIKEDLL=%%B)
if not defined _MIKEDLL (
	for /F "Tokens=2* skip=2" %%A In ('REG QUERY "HKLM\SOFTWARE\Mikero\depbo" /v "path" 2^>nul') do (set _MIKEDLL=%%B)
	if not defined _MIKEDLL (
		echo Mikero Tools was not set in the registry path, trying default.
		set "_MIKEDLL=C:\Program Files (x86)\Mikero\DePboTools"
	) else (
		echo Found.
	)
) else (
	echo Found.
)

echo Searching for DayZ Tools...
for /F "Tokens=2* skip=2" %%A In ('REG QUERY "HKCU\Software\bohemia interactive\Dayz Tools" /v "Path" 2^>nul') do (set _DAYZTOOLSPATH=%%B)
if not defined _DAYZTOOLSPATH (
	echo DayZ Tools was not set in the registry path, trying default.
	set "_DAYZTOOLSPATH=D:\Program Files (x86)\Steam\steamapps\common\DayZ Tools"
) else (
	echo Found.
)

if %failed%==1 (
	endlocal

	echo Failed to package the mod.
	goto:eof
)

set pboProject="%_MIKEDLL%\bin\pboProject.exe"
set signFile="%_DAYZTOOLSPATH%\Bin\DsUtils\DSSignFile.exe"

IF exist "%modBuildDirectory%%modName%\" (
	echo Removing folder "%modBuildDirectory%%modName%\"
	rmdir /S /Q "%modBuildDirectory%%modName%\"
)

IF NOT exist "%modBuildDirectory%%modName%\" (
	echo Creating folder "%modBuildDirectory%%modName%\"
	mkdir "%modBuildDirectory%%modName%\"
)

IF NOT exist "%modBuildDirectory%%modName%\Addons\" (
	echo Creating folder "%modBuildDirectory%%modName%\Addons\"
	mkdir "%modBuildDirectory%%modName%\Addons\"
)

IF NOT exist "%modBuildDirectory%%modName%\Keys\" (
	echo Creating folder "%modBuildDirectory%%modName%\Keys\"
	mkdir "%modBuildDirectory%%modName%\Keys\"
)

echo Copying over "%workDrive%%prefixLinkRoot%\mod.cpp" to "%modBuildDirectory%%modName%\"
copy "%workDrive%%prefixLinkRoot%\mod.cpp" "%modBuildDirectory%%modName%\" > nul

for /F "tokens=*" %%F in ('git rev-parse --abbrev-ref HEAD') do (
	set branch=%%F
)
echo GIT branch: %branch%

echo Creating "%modBuildDirectory%%modName%\meta.cpp"
if exist "%modBuildDirectory%%modName%\meta.cpp" del /F "%modBuildDirectory%%modName%\meta.cpp"
for /f "usebackq tokens=1,2 delims==;" %%a in ( "%~dp0..\..\meta.%branch%.cpp" ) do (
	set key=%%a
	set key=!key: =!
	set value=%%b
	set value=!value: =!
	if !key!==timestamp (
		set value1=!value:~0,11!
		set value2=!value:~11!
		set /a value2=!value2!+1
		set value=!value1!!value2!
	)
	echo !key! = !value!;>>"%modBuildDirectory%%modName%\meta.cpp"
)
type "%modBuildDirectory%%modName%\meta.cpp"

echo Copying over "%keyDirectory%\%keyName%.bikey" to "%modBuildDirectory%%modName%\Keys\"
echo Copying over "%keyDirectory%\%keyName%.biprivatekey" to "%modBuildDirectory%%modName%\Keys\"

echo Packaging %modName% PBO's

@echo off

pushd "%workDrive%%prefixLinkRoot%\"

for /R %%D in ( config.cpp ) do (
	echo Checking directory %%~dD%%~pD, searching for config.cpp
	IF EXIST "%%~dD%%~pDconfig.cpp" (
		echo config.cpp found!
		IF NOT EXIST "%%~dD%%~pD..\config.cpp" (
			IF NOT EXIST "%%~dD%%~pD..\..\config.cpp" (
				IF NOT EXIST "%%~dD%%~pD..\..\..\config.cpp" (
					IF NOT EXIST "%%~dD%%~pD..\..\..\..\config.cpp" (
						IF NOT EXIST "%%~dD%%~pD..\..\..\..\..\config.cpp" (
							IF NOT EXIST "%%~dD%%~pD..\..\..\..\..\..\config.cpp" (
								IF NOT EXIST "%%~dD%%~pD..\..\..\..\..\..\..\config.cpp" (
									IF NOT EXIST "%%~dD%%~pD..\..\..\..\..\..\..\..\config.cpp" (
										rem echo No parent config.cpp found, building pbo %%D
										echo START /MIN "BinarizePBO" "%batchDirectory%/BinarizePBO.bat" %%D fuckThurston %compression%
										START /MIN "BinarizePBO" "%batchDirectory%/BinarizePBO.bat" %%D fuckThurston %compression%
									)
								)
							)
						)
					)
				)
			)
		)
	)
)

popd

goto end

:end
endlocal