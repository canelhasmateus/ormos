
; AutoHotKey script for defining an Extend layer (default is CapsLock)
; Hold Extend and press other keys to provide navigation and other fuctionality
; http://www.keyboard-layout-editor.com/#/gists/5f31818f137440704db9
;
; The script defines F24 as Extend, so you can apply to any key of your choice
; e.g. to use CapsLock, define:
#InputLevel 1
CapsLock::F24
#InputLevel 0

#Persistent
SetCapsLockState, AlwaysOff

; digit row

; F24 & SC001::
; return

; F24 & SC002::
;   Send {Blind}{F1}
; return

; F24 & SC003::
;   Send {Blind}{F2}
; return

; F24 & SC004::
;   Send {Blind}{F3}
; return

; F24 & SC005::
;   Send {Blind}{F4}
; return

; F24 & SC006::
;   Send {Blind}{F5}
; return

; F24 & SC007::
;   Send {Blind}{F6}
; return

; F24 & SC008::
;   Send {Blind}{F7}
; return

; F24 & SC009::
;   Send {Blind}{F8}
; return

; F24 & SC00A::
;   Send {Blind}{F9}
; return

; F24 & SC00B::
;   Send {Blind}{F10}
; return

; F24 & SC00C::
;   Send {Blind}{F11}
; return

; F24 & SC00D::
;   Send {Blind}{F12}
; return

; ; top row

; F24 & SC010::
;   Send {Esc}
; return

; F24 & SC011::
;   mouseclick, x1
;   ;Send {Browser_Back}
; return

; F24 & SC012::
;   Send {CtrlDown}{f}{CtrlUp}
; return

; F24 & SC014::
;   Send {Insert}
; return

; F24 & SC015::
;   Send {Blind}{PgUp}
; return

; F24 & SC019::
;   Send {AppsKey}
; return

; F24 & SC01A::
;   Send {Blind}{PrintScreen}
; return

; F24 & SC01B::
;   Send {Insert}
; return

; ; middle row

;  Left hand goodies
F24 & SC01E::
  Send {CtrlDown}{a}{CtrlUp}
return

; F24 & SC01F::
;   Send {Blind}{Tab}
; return

F24 & SC020::
  Send {Blind}{ShiftDown}
return

F24 & SC020 Up::
  Send {ShiftUp}
return

F24 & SC021::
  Send {Blind}{CtrlDown}
return

F24 & SC021 Up::
  Send {CtrlUp}
return

F24 & SC022::
  Send {Blind}{AltDown}
return

; F24 & SC022 Up::
;   Send {AltUp}
; return

;; Directionals

F24 & SC023::
  Send {Blind}{Home}
return

F24 & SC024::
  Send {Blind}{Left}
return

F24 & SC026::
  Send {Blind}{Right}
return

F24 & SC027::
  Send {Blind}{End}
return

F24 & SC017::
  Send {Blind}{Up}
return

F24 & SC025::
  Send {Blind}{Down}
return

;;  Input
F24 & SC039::
  Send {Blind}{Enter}
return

F24 & SC033::
  Send {Blind}{Backspace}
return

F24 & SC032::
  Send {CtrlDown}{Blind}{Backspace}{CtrlUp}
return

F24 & SC018::
  Send {Blind}{Del}
return

; Remap caps. 
F24 & SC028::
  GetKeyState, cp, CapsLock, T
  if cp = D
    SetCapsLockState, AlwaysOff
  else
    SetCapsLockState, AlwaysOn
return

F24 & SC02B::
  Reload
return
; ; bottom row

; F24 & SC056::
;   Send {CtrlDown}{y}{CtrlUp}
; return

; F24 & SC02C::
;   Send {CtrlDown}{z}{CtrlUp}
; return

; F24 & SC02D::
;   Send {CtrlDown}{x}{CtrlUp}
; return

; F24 & SC02E::
;   Send {CtrlDown}{c}{CtrlUp}
; return

; F24 & SC02F::
;   Send {CtrlDown}{v}{CtrlUp}
; return

; F24 & SC030::
; return

; F24 & SC031::
;   mouseclick, left
; return

; F24 & SC033::
;   Send {Blind}{F13}
; return

; F24 & SC034::
;   Send {Blind}{F14}
; return

; F24 & SC035::
;   Send {LWin}
; return

; ; RAlt cancel caps / nav layer

; RAlt::
;   GetKeyState, cp, CapsLock, T
;   if navLayer 
;   {
;     navLayer := 0
;   } 
;   else if cp = D
;   {
;     SetCapsLockState, AlwaysOff
;   } 
; Return

; Workspace

sendOrSwitch( desktopNumber ) 
{

  if GetKeyState("Alt" , "P") = 0
  { 
    
    switchDesktopByNumber(1)

  }
  else {
    MsgBox "Alt is down"
    MoveCurrentWindowToDesktopNumber( 1 )
  }
  
  return
}

#Include %A_ScriptDir%\workspaces.ahk
F24 & SC007::

  sendOrSwitch( 1 )

return

F24 & SC008::
  switchDesktopByNumber(2)
return

F24 & SC009::
  switchDesktopByNumber(3)

return
F24 & SC00A::
  switchDesktopByNumber(4)
return

F24 & SC00B::
  switchDesktopByNumber(5)
return

F24 & SC013::
  switchDesktopToLastOpened()
  send {AltDown}{Tab}{AltUp}
return
