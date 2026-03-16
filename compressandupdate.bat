@echo off
setlocal

:: Set your Steam Workshop item ID here after first upload
set "MOD_ITEM_ID=YOUR_WORKSHOP_ID_HERE"
set "MOD_FOLDER=creativemode"
set "OUTPUT_ZIP=CreativeMode.zip"

:: Compress files
powershell -Command "Compress-Archive -Path '%MOD_FOLDER%\*' -DestinationPath '%OUTPUT_ZIP%' -Force"

:: Upload mod
DesyncedModUploader.exe -u %MOD_ITEM_ID% %OUTPUT_ZIP%

echo Done!
endlocal
