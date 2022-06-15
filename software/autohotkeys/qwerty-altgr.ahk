#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\lib\Workspaces.ahk
#Include %A_ScriptDir%\lib\Gnosis.ahk
#Include %A_ScriptDir%\lib\VisualUtils.ahk
#Include %A_ScriptDir%\lib\Flowtime.ahk


<^>!SC01E:: 
  {
    ; AltGr + "A"
    Send {\}
    return
  }

<^>!SC01F:: 
  {
    ; AltGr + "S"
    Send {|}
    return
  }
<^>!SC020:: 
  {
    ; AltGr + "D"
    Send {}
    return
  }

; ------

<^>!SC018::
  {
    ; AltGr + "O"
    pressedKey := ListenNextKey()

    WriteTip( "pressed key is " pressedkey )

    if pressedKey is number
    {
      sendDesktopOrSwitchDesktop( pressedKey )
    }
    else if ( pressedKey = "f") {
      OpenHighlighted() 
    }
    else if (pressedkey = "r") {
      switchDesktopToLastOpened()
    }
    else if ( pressedKey = "w") {
      alternateWindowMonitor()
    }
    else if ( pressedKey = "i") { 
      WinMaximize, A
    }    
    else if ( pressedKey ) {
      WriteTip("Unknown key: " pressedKey)
    }

    return 
  } 

<^>!SC022::
  {
    ; AltGr + "G"
    pressedKey := ListenNextKey()
    if (pressedKey = "s") {
      ProcessArticles()
    } 
    else if (pressedKey = "m"){
      FlowUI()
    }
    else if ( pressedKey = "q") {
      GrabUrl()
    }
    else if ( pressedKey = "i") {
      CreateIssue()
    }
    else if ( pressedKey ) {
      WriteTip("Unknown key: " pressedKey)
    }

    return
  } 

