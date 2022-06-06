#SingleInstance, Force
#NoEnv
/*
	=======================================================================================
	 Function:			SHAutoComplete
	 Description:		Auto-completes typed values in an edit with various options.
	 Usage:
		Gui, Add, Edit, w200 h21 hwndEditCtrl1
		SHAutoComplete(EditCtrl1)
	=======================================================================================
*/
_SHAutoComplete(hEdit, Option := 0x20000000) {
	; https://bit.ly/335nOYt		For more info on the function.
	DllCall("ole32\CoInitialize", "Uint", 0)
	; SHACF_AUTOSUGGEST_FORCE_OFF (0x20000000)
	;	Ignore the registry default and force the AutoSuggest feature off.
	;	This flag must be used in combination with one or more of the SHACF_FILESYS* or SHACF_URL* flags.
	; AKA. It won't autocomplete anything, but it will allow functionality such as Ctrl+Backspace deleting a word.
	DllCall("shlwapi\SHAutoComplete", "Uint", hEdit, "Uint", Option)
	DllCall("ole32\CoUninitialize")
}

/*
	=======================================================================================
	 Function:			CbAutoComplete
	 Description:		Auto-completes typed values in a ComboBox.

	 Author:			Pulover [Rodolfo U. Batista]
	 Usage:
		Gui, Add, ComboBox, w200 h50 gCbAutoComplete, Billy|Joel|Samual|Jim|Max|Jackson|George
	=======================================================================================
*/
CbAutoComplete() {
	; CB_GETEDITSEL = 0x0140, CB_SETEDITSEL = 0x0142
	If ((GetKeyState("Delete", "P")) || (GetKeyState("Backspace", "P")))
		Return
	GuiControlGet, lHwnd, Hwnd, %A_GuiControl%
	SendMessage, 0x0140, 0, 0,, ahk_id %lHwnd%
	_MakeShort(ErrorLevel, Start, End)
	GuiControlGet, CurContent,, %lHwnd%
	GuiControl, ChooseString, %A_GuiControl%, %CurContent%
	If (ErrorLevel) {
		ControlSetText,, %CurContent%, ahk_id %lHwnd%
		PostMessage, 0x0142, 0, _MakeLong(Start, End),, ahk_id %lHwnd%
		Return
	}
	GuiControlGet, CurContent,, %lHwnd%
	PostMessage, 0x0142, 0, _MakeLong(Start, StrLen(CurContent)),, ahk_id %lHwnd%
}

; Required for: CbAutoComplete()
_MakeLong(LoWord, HiWord) {
	Return, (HiWord << 16) | (LoWord & 0xffff)
}

; Required for: CbAutoComplete()
_MakeShort(Long, ByRef LoWord, ByRef HiWord) {
	LoWord := Long & 0xffff, HiWord := Long >> 16
}

ListenNextKey() 
{
	Input pressedKey, M L1 T2 B, {Escape}{Tab}{Backspace}
	return pressedKey
}

AutoCompletingListView( prompt , options ) {
	Global ChosenOption

	ChosenOption := ""
	Gui, 2:+LastFound
	GuiHWND := WinExist() ;--get handle to this gui..
	Gui, 2:Default
	Gui, 2:Add , Text , Center w700, %prompt%
	Gui, 2:Add , ListView,h400 w700, Todo
	Gui, 2:Add , ComboBox, h400 w700 vChosenOption gCbAutoComplete
	Gui, 2:Add , Button, gButtonComplete, OK
	Gui, 2:Show

	for k, v in options { 
		GuiControl,2:, ChosenOption, % v "|"
		LV_Add("", v)		
	}
	GuiControl, 2:Focus, ChosenOption
	WinWaitClose, ahk_id %GuiHWND% ;--waiting for 'gui to close
	StringReplace, ChosenOption, ChosenOption, `n,, All
	StringReplace, ChosenOption, ChosenOption, `r,, All
	return ChosenOption

	;-------

	ButtonComplete:
		GuiControlGet, ChosenOption
		Gui, 2:Destroy
	return
	;-------

	2GuiEscape:
	2GuiClose:
		Gui, 2:Destroy
	return

}

GatherText( prompt ) {

	Global ChosenOption

	ChosenOption := ""
	Gui, 3:+LastFound
	GuiHWND := WinExist() ;--get handle to this gui..

	Gui, 3:Add , Text , Center, %prompt%
	Gui, 3:Add , Edit, vChosenOption
	Gui, 3:Add , Button, gButtonGather, OK
	Gui, 3:Show

	WinWaitClose, ahk_id %GuiHWND% ;--waiting for 'gui to close
	return ChosenOption

	;-------

	ButtonGather:
		GuiControlGet, ChosenOption
		Gui, 3:Destroy
	return
	;-------

	3GuiEscape:
	3GuiClose:
		Gui, 3:Destroy
	return

	
}
GatherChoice( prompt , options ) {
	Global ChosenOption

	ChosenOption := ""
	Gui, 4:+LastFound
	GuiHWND := WinExist() ;--get handle to this gui..

	Gui, 4:Add , Text , , %prompt%
	Gui, 4:Add , ListBox, vChosenOption
	Gui, 4:Add , Button, gButtonList, OK
	Gui, 4:Show

	for k, v in options { 
		if (k == 1) {
			GuiControl,4:, ChosenOption, % v "||"
		}
		else {
			GuiControl,4:, ChosenOption, % v "|"
		}
		
	}

	WinWaitClose, ahk_id %GuiHWND% ;--waiting for 'gui to close
	return ChosenOption

	;-------

	ButtonList:
		GuiControlGet, ChosenOption
		Gui, 4:Destroy
	return
	;-------

	4GuiEscape:
	4GuiClose:
		Gui, 4:Destroy
	return

}
WriteText( msg ) {


	Gui, 5:+LastFound +MaximizeBox
	
	GuiHWND := WinExist() ;--get handle to this gui..
	Gui, 5:Add , Text ,Left, %msg%
	Gui, 5:Add , Button, gButtonText, OK
	Gui, 5:Show
	WinWaitClose, ahk_id %GuiHWND% ;--waiting for 'gui to close
	return


	ButtonText:
	5GuiEscape:
	5GuiClose:
		Gui, 5:Destroy
	return


}
WriteTip( msg , duration := 3000) {
	ToolTip, %msg%, A_ScreenWidth - 200, A_ScreenHeight-100
	SetTimer, RemoveToolTip, -%duration%
	return

	RemoveToolTip:
		ToolTip
	return
}

SetCurrentProcessVolume(volume) ; volume can be number 0 — 100 or "mute" or "unmute"
{
   static MMDeviceEnumerator      := "{BCDE0395-E52F-467C-8E3D-C4579291692E}"
        , IID_IMMDeviceEnumerator := "{A95664D2-9614-4F35-A746-DE8DB63617E6}"
        , IID_IAudioClient        := "{1cb9ad4c-dbfa-4c32-b178-c2f568a703b2}"
        , IID_ISimpleAudioVolume  := "{87ce5498-68d6-44e5-9215-6da47ef883d8}"
        , eRender := 0, eMultimedia := 1, CLSCTX_ALL := 0x17
        , _ := OnExit( Func("SetCurrentProcessVolume").Bind(100) )
        
   IMMDeviceEnumerator := ComObjCreate(MMDeviceEnumerator, IID_IMMDeviceEnumerator)
   ; IMMDeviceEnumerator::GetDefaultAudioEndpoint
   DllCall(NumGet(NumGet(IMMDeviceEnumerator + 0) + A_PtrSize*4), "Ptr", IMMDeviceEnumerator, "UInt", eRender, "UInt", eMultimedia, "PtrP", IMMDevice)
   ObjRelease(IMMDeviceEnumerator)

   VarSetCapacity(GUID, 16)
   DllCall("Ole32\CLSIDFromString", "Str", IID_IAudioClient, "Ptr", &GUID)
   ; IMMDevice::Activate
   DllCall(NumGet(NumGet(IMMDevice + 0) + A_PtrSize*3), "Ptr", IMMDevice, "Ptr", &GUID, "UInt", CLSCTX_ALL, "Ptr", 0, "PtrP", IAudioClient)
   ObjRelease(IMMDevice)
   
   ; IAudioClient::GetMixFormat
   DllCall(NumGet(NumGet(IAudioClient + 0) + A_PtrSize*8), "Ptr", IAudioClient, "UIntP", pFormat)
   ; IAudioClient::Initialize
   DllCall(NumGet(NumGet(IAudioClient + 0) + A_PtrSize*3), "Ptr", IAudioClient, "UInt", 0, "UInt", 0, "UInt64", 0, "UInt64", 0, "Ptr", pFormat, "Ptr", 0)
   DllCall("Ole32\CLSIDFromString", "Str", IID_ISimpleAudioVolume, "Ptr", &GUID)
   ; IAudioClient::GetService
   DllCall(NumGet(NumGet(IAudioClient + 0) + A_PtrSize*14), "Ptr", IAudioClient, "Ptr", &GUID, "PtrP", ISimpleAudioVolume)
   ObjRelease(IAudioClient)
   if (volume + 0 != "")
      ; ISimpleAudioVolume::SetMasterVolume
      DllCall(NumGet(NumGet(ISimpleAudioVolume + 0) + A_PtrSize*3), "Ptr", ISimpleAudioVolume, "Float", volume/100, "Ptr", 0)
   else
      ; ISimpleAudioVolume::SetMute
      DllCall(NumGet(NumGet(ISimpleAudioVolume + 0) + A_PtrSize*5), "Ptr", ISimpleAudioVolume, "UInt", volume = "mute" ? true : false, "Ptr", 0)
   ObjRelease(ISimpleAudioVolume)
}
SoundWind( volume := 50) {
	SetCurrentProcessVolume(volume)
	SoundPlay, %A_ScriptDir%\blob\windchime.wav 
}
SoundChirp( volume := 50) {
	SetCurrentProcessVolume(volume)
	SoundPlay, %A_ScriptDir%\blob\chirp.wav 
}