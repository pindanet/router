# WinPE aanmaken met Windows 10 ADK
* Plak in de opdrachtprompt met rechtermuisklik
* Windows 10 ADK downloaden en installeren
* Start > Deployment and Imaging Tools Environment Als administrator starten

        copype.cmd amd64 c:\WinPE_amd64

* Als administrator

        Dism /mount-image /imagefile:C:\winpe_amd64\media\sources\boot.wim /index:1 /mountdir:C:\winpe_amd64\mount
        REG LOAD HKLM\WINFE2 C:\winpe_amd64\mount\Windows\System32\config\DEFAULT
        REG DELETE "HKLM\WINFE2\Keyboard Layout\Preload" /f
        REG ADD "HKLM\WINFE2\Keyboard Layout\Preload" /v 1 /t REG_MULTI_SZ /D "0001080c" /f
        REG UNLOAD HKLM\WINFE2

* toevoegen met notepad

        notepad C:\WinPE_amd64\mount\Windows\System32\startnet.cmd
        wpeinit
        :TEST
        ping -n 1 router | find "TTL=" >nul
        if errorlevel 1 (
            goto RETRY
        ) else (
            goto DOSTUFF
        )

        :RETRY
        ping 127.0.0.1 -n 10>nul REM waits given amount of time, set to 10 seconds
        goto TEST

        :DOSTUFF
        net use s: \\router\sntbeheerder snt+4567 /user:sntbeheerder
        s:

        Dism /unmount-image /mountdir:C:\winpe_amd64\mount\ /commit
* terug in Deployment and imaging Tools Environment

        MakeWinPEMedia /ISO C:\WinPE_amd64 C:\WinPE_amd64\WinPE_amd64.iso
