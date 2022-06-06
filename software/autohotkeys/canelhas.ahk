#SingleInstance Force ; The script will Reload if launched while already running
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases
;#KeyHistory 0 ; Ensures user privacy when debugging is not needed
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
FileEncoding, UTF-8 ; 
#Include %A_ScriptDir%\qwerty-extend.ahk
#Include %A_ScriptDir%\qwerty-altgr.ahk
#Include %A_ScriptDir%\lib\FlowTime.ahk


; remaps / ? to Shift
*SC073::Shift
; remaps \ | to Ctrl
*SC056::Ctrl

