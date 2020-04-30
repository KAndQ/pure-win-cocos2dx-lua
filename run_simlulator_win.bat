@echo off
cd /d %~dp0
START /B win32\cocos2dx.exe -workdir . -write-debug-log debug.log -resolution 960x640 -scale 1 -console enable -writable-path .\data\
