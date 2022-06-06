#SingleInstance, Force
#NoEnv
#Include %A_ScriptDir%\lib\AccessibilityData.ahk
#Include %A_ScriptDir%\lib\Flowtime.ahk
#Include %A_ScriptDir%\lib\VisualUtils.ahk

CurrentDatetime(  ) {
    timestamp := A_now
    FormatTime, result, %timestamp%, yyyy/MM/dd HH:mm:ss
    return result
}

GetBrowserUrl() {
    accData:= GetAccData() ; parameter: "A" (default), "WinTitle", "ahk_class IEFrame", "ahk_exe chrome.exe", etc.
    if ( accData ) {
        return accData.2
    }
}

GrabUrl(){

    url := GetBrowserUrl()

    if (!url) {
        WriteTip("No url found.")
        return
    } 

    chosenQuality := AutoCompletingListView("Saving " url , ["Premium" , "Good" , "History" , "Bookmark" , "Bad", "Queue" , "Revisit" , "Tool" , "Utility" , "Explore" , "Done" ]) 
    if (chosenQuality) { 
        currentTime := CurrentDatetime()
        content := "`n" currentTime "`t" chosenQuality "`t" url
        FileAppend , %content% ,C:\Users\Mateus\OneDrive\gnosis\limni\lists\stream\articles.tsv
        WriteTip("Saved url as " chosenQuality)
    }
}

OpenHighlighted() {
    MyClipboard := "" ; Clears variable
    previousClip := clipboard
    Send, {ctrl down}c{ctrl up} ; More secure way to Copy things
    ClipWait 1
    MyClipboard := RegexReplace( clipboard, "^\s+|\s+$" ) ; Trim additional spaces and line return
    MyStripped := StrReplace(MyClipboard, " ", "") ; Removes every spaces in the string.

    StringLeft, OutputVarUrl, MyStripped, 7 ; Takes the 8 firsts characters
    StringLeft, OutputVarLocal, MyStripped, 3 ; Takes the 3 first characters

    if (OutputVarUrl == "http://" || OutputVarUrl == "https:/" || OutputVarLocal == "www")
        Desc := "URL", Target := MyStripped
    else if (OutputVarLocal == "C:/" || OutputVarLocal == "C:\" || OutputVarLocal == "Z:/" || OutputVarLocal == "Z:\" || OutputVarLocal == "R:/" || OutputVarLocal == "R:\" ||)
        Desc := "Windows", Target := MyClipboard
    else
        Desc := "GoogleSearch", Target := "http://www.google.com/search?q=" MyClipboard

    WriteTip( Desc " : " MyClipboard  )
    Run, %Target%
    Clipboard := previousClip
    Return
}

ProcessArticles() {
    run python "C:\Users\Mateus\OneDrive\gnosis\limni\lists\scripts\update.py"
}

CreateIssue() {
    issue := GatherText( "Create an issue") 
    if ( issue ){
        FileAppend,`n%issue%, C:\Users\Mateus\OneDrive\gnosis\limni\lists\stream\todos.txt
        WriteTip("Issue created.")
    }
}
; -----

