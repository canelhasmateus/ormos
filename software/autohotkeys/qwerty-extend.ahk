
; AutoHotKey script for defining an Extend layer (default is CapsLock)
; Hold Extend and press other keys to provide navigation and other fuctionality
; http://www.keyboard-layout-editor.com/#/gists/5f31818f137440704db9
;
; The script defines F24 as Extend, so you can apply to any key of your choice
; e.g. to use CapsLock, define:
#InputLevel 1
CapsLock::F24
#InputLevel 

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

F24 & SC010::
  Send {AppsKey}
return

F24 & SC011::
  Send {Esc}
return

F24 & SC012::
  Send {Blind}{CtrlDown}{AltDown}
return

F24 & SC012 Up::
  Send {CtrlUp}{AltUp}
return

; F24 & SC01B::
;   Send {Insert}
; return

; ; middle row

;  Left hand goodies

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

; -----

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

F24 & SC02B::
; AltGr + "]"
  Reload
return


; -----

;;  Input
F24 & SC039::
  Send {Blind}{Enter}
return

F24 & SC033::
  Send {Blind}{Backspace}
return

F24 & SC034::
  Send {Blind}{Del}
return
 
; ; bottom row

F24 & SC073::
GetKeyState, cp, CapsLock, T
  if cp = D
    SetCapsLockState, AlwaysOff
  else
    SetCapsLockState, AlwaysOn
return

