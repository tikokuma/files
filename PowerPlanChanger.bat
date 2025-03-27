@echo off
setlocal enabledelayedexpansion

REM Delete existing registry entries
reg delete "HKEY_CLASSES_ROOT\DesktopBackground\Shell\SwitchPowerScheme" /f

REM Create the base registry entries
reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\SwitchPowerScheme" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\system32\powercpl.dll" /f
reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\SwitchPowerScheme" /v "MUIVerb" /d "Change Power Plan" /f
reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\SwitchPowerScheme" /v "Position" /d "Middle" /f
reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\SwitchPowerScheme" /v "SubCommands" /d "" /f

REM Counter for subcommands
set counter=1

REM Get the list of power schemes
for /f "tokens=1,* delims=:" %%i in ('powercfg /L ^| findstr /R "GUID"') do (
    set "line=%%i:%%j"
    
    REM Extract the GUID
    for /f "tokens=2 delims=:" %%j in ("%%i:%%j") do (
        set "guid=%%j"
        set "guid=!guid:~1,36!"
    )
    
    REM Extract the name
    for /f "tokens=2,* delims=()" %%k in ("%%j") do (
        set "name=%%k"
        REM Remove leading and trailing spaces and parentheses
        setlocal enabledelayedexpansion
        set "name=!name:~1!"
        for /l %%a in (1,1,31) do (
            if "!name:~-1!"==" " set "name=!name:~0,-1!"
        )
        endlocal & set "name=%%k"
    )
    
    REM Format the counter as 01, 02, etc.
    set "keyName=0!counter!"
    set /a counter+=1

    REM Add the power scheme to the registry
    reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\SwitchPowerScheme\Shell\!keyName!" /v "MUIVerb" /d "!name!" /f
    reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\SwitchPowerScheme\Shell\!keyName!" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\system32\powercpl.dll" /f
    reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\SwitchPowerScheme\Shell\!keyName!\Command" /ve /t REG_EXPAND_SZ /d "\"%SystemRoot%\system32\powercfg.exe\" /S !guid!" /f

    REM Debug output for verification
    echo Name: !name!
    echo GUID: !guid!
    echo Command: %SystemRoot%\system32\powercfg.exe /S !guid!
)

REM Add the "Power Options" entry
reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\SwitchPowerScheme\Shell\Z" /v "CommandFlags" /t REG_DWORD /d 32 /f
reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\SwitchPowerScheme\Shell\Z" /v "MUIVerb" /d "Power Options" /f
reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\SwitchPowerScheme\Shell\Z\Command" /ve /t REG_EXPAND_SZ /d "\"%SystemRoot%\system32\control.exe\" powercfg.cpl" /f

endlocal