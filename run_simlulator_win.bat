@echo off
cd /d %~dp0
START /B win32\cocos2dx.exe -workdir . -write-debug-log debug.log -resolution 1334x750 -scale 1 -console enable -writable-path .\data\
