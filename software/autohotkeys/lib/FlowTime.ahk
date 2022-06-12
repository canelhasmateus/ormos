#SingleInstance, Force
#NoEnv
#Include %A_ScriptDir%\lib\VisualUtils.ahk

; ----- Pure Utilities
ToHumanTime( timestamp ) {
    FormatTime, result, %timestamp%, yyyy/MM/dd HH:mm:ss
    return result
}
ToUnixTime( timestamp ) {
    timestamp := RegExReplace(timestamp, "[/: ]")
    FormatTime, result, %timestamp%, yyyyMMddHHmmss
    return result
}
Diff( start, finish ) { 
    result = %finish%
    EnvSub result, %start%, seconds
    return result
}
Sum( start, offset ) { 
    result = %start%
    EnvAdd result, %offset%, seconds
    return result
}
SecondsSinceStart( state ) {
    mainTask := state["Tasks"][1]
    timeStart := mainTask["Start"]
    right_now := GetUnixTime()
    timeSince := Diff( timeStart, right_now)
    return timeSince
}
ApproxMinutesSinceStart( state ) {
    timeSince := SecondsSinceStart( state )
    halfHours := timeSince / 1800
    minutePassed := Round(halfHours) * 30
    return minutePassed
}
StrRepeat(string, times) {
    output := ""

    loop % times
        output .= string

    return output
}
Coalesce( val , fallback ) {

    if (val == "" || val == ) {
        return fallback
    }

    return val

}

; ----- Core Logic
BreakSize( start, finish ) {
    Duration := Diff( start , finish )
    Length := Ceil( 0.3 * Duration )
    if (Length <= 5) {
        Length := 0
    }
    else if (Length <= 60) {
        Length := 60
    }
    else if ( Length >= 3600 ) {
        Length := 3600
    }
    return Length
}

AdvanceState( action , state) {

    if (!action) {
        return state
    }

    detail := "None"
    breakLength := 0
    newMode := state["Mode"]
    newTasks := state["Tasks"].Clone()
    actionName := action["Action"]
    if (actionName == "Fork") {
        task := action["Task"]
        newTasks.Push( task )
        newMode := "Flow"
    }
    else if ( actionName == "Join") {
        task := newTasks.Pop()
        ; 
        newMode := newTasks.Count() == 0 ? "Off" : "Flow"
    }
    else if ( actionName == "Gather" || actionName == "Break") {
        task := { "Name" : "None" , "Start" : GetUnixTime()}
        newTasks := [ ]
        newMode := "Off"
    }
    else {
        return state
    }

    return { "Mode" : newMode , "Tasks" : newTasks , "Detail" : "None"}
}

_FormatForkMessage( state ) {
    tasks := state["Tasks"] 
    sinceStart := SecondsSinceStart( state )
    message := "Currently Working for " sinceStart ":`n"
    for idx , obj in tasks {
        spaces := StrRepeat( " " , idx) 
        name := obj["Name"] 
        message .= "`n" spaces name
    }
    return message
}
_FormatOffMessage( state ) {
    ; Couldn't make this fit nicely. There goes a global :(
    global breakEnd
    remainingTime := Diff( GetUnixTime() , breakEnd)
    remainingTime := Coalesce( remainingTime , 0 )
    if ( remainingTime <= 0 ) {
        return "There is no time to explain.`n Get in the flow!"
    }
    else {
        return "Relaxing for " remainingTime " more seconds.`n`t...Or am i?!"
    }

}
_FormatStartMessage( state ) {

    task := state["Tasks"][ 1 ]["Name"]
    content = 
    (
        `tWhile Working on %task%,
        Take care of your phisiology:

            - Coffee
            - Water
            - Bathroom
            - Reading Glasses

        Optimize your environment:

            - Distractions
            - Music
            - Scents
            - Lightning
            - Tidiness

            Have a good time!
        )

        return content
    }
    ; ---

    GetUnixTime() {
        return A_Now
    }
    StateLog( action , state ) {
        if ( !action ) {
        return
    }
    detail := state["Detail"]

    actionName := action["Action"]
    if (actionName == "Fork") {
        timestamp := state["Tasks"][ state["Tasks"].Count() + 1 ]["Start"]
        taskName := action["Task"]["Name"]
    }
    else if ( actionName == "Join") {
        timestamp := GetUnixTime()
        taskName := action["Task"]["Name"]
    } 
    else {
        timestamp := GetUnixTime()
        taskName := "N/A"
    }

    timestamp := ToHumanTime( timestamp )
    content := "`n" timestamp "`t" actionName "`t" taskName "`t" detail
    flowtimeLog := "C:\Users\Mateus\OneDrive\gnosis\limni\lists\stream\flowtime.tsv"

    FileAppend ,%content% ,%flowtimeLog%
    return
}
LoadState() {
    state := { "Mode" : "Off" , "Tasks" : [] , "Detail" : "None"}

    Loop, read, C:\Users\Mateus\OneDrive\gnosis\limni\lists\stream\flowtime.tsv
    {
        if (A_Index == 1) {
            Continue
        }

        if (!A_LoopReadLine) {
            Continue
        }

        action := { "Task" : { }}
        Loop, parse, A_LoopReadLine, %A_Tab%
        {
            if ( A_Index == 1 ) {

                started := ToUnixTime( A_LoopField ) 
                action["Task"]["Start"] := started
            }
            else if ( A_Index == 2 ) {
                action["Action"] := A_LoopField
            }
            else if ( A_Index == 3 ) {
                action["Task"]["Name"] := A_LoopField 
            }
            else if ( A_Index == 4 ) {
                action["Detail"] := A_LoopField
            }

        }
        state := AdvanceState( action , state )

    }
    _RegisterFlowReminders( state )
    return state
}

newDesktop() {
    ; todo Maybe check the number of currently opened desktops, and act accordingly?
    Sleep, 100
    Send {CtrlDown}{LWinDown}{d}{CtrlUp}{LWinUp}
    Sleep, 100
    return
}
; ------ User Interface ; 

_BreakInstructions( oldState , state) {

    now := GetUnixTime() 
    breakLength := BreakSize( oldState["Tasks"][ 1 ]["Start"] , now )
    breakEnd := Sum(now , breakLength)

    MilliBreak := 1000*breakLength

    prefix := breakLength > 0 ? "Relax for " breakLength ".`n" : ""
    comment := GatherText( prefix "Any thoughts on this session?")
    if (MilliBreak >= 1000) {
        SetTimer BreakOver, -%MilliBreak%
    }

    state["Detail"] := Coalesce( comment , "N/A")
    return state

    BreakOver:
        global globalState
        mode := globalState["Mode"] 
        if (globalState["Mode"] != "Flow" ) {
            SoundChirp()
            MsgBox, "Back to the grind." 
        }
    return
}

_RemindFlow( ) {
    Remind1:
    Remind2:
    Remind3:
        global globalState

        minutePassed := ApproxMinutesSinceStart( globalState )
        WriteTip( minutePassed "~ minutes since task started." , 10000)
        SoundChirp()
    return
}
_RegisterFlowReminders( state ) {
    if state["Mode"] != "Flow" {
    return
}

sinceStart := SecondsSinceStart( state )
for i , period in [1800 , 3600 , 5400] {
    untilRing := period - sinceStart
    if ( untilRing > 0) {
        milliUntilRing := Ceil( 1000 * untilRing)
        SetTimer, Remind%i%, -%milliUntilRing%
    } 
}
return

}
_FlowInstructions( state ) {
    newDesktop()
    content := _FormatStartMessage( state )
    MsgBox, %content%
    state["Tasks"][1]["Start"] = GetUnixTime()
    _RegisterFlowReminders( state )
    return state

}
ChooseAction( message , options) {
    choice := GatherChoice( message, options)
    if (choice == "Fork") {
        action := ChooseTask( "A wild subtask appeared!")
    }
    else if ( choice == "Join") {
        action := { "Action" : "Join" }
    }
    else if ( choice == "Gather") {
        action := { "Action" : "Gather" }
    }
    else if ( choice == "Break") {
        action := { "Action" : "Break" }
    }
    else if ( choice ) {
        WriteTip( "Flowtime: unknown choice: " choice) 
    }

    return action
}
ChooseTask( message ) {
    choices := [ ]
    Loop, Read, C:\Users\Mateus\OneDrive\gnosis\limni\lists\stream\todos.txt
    {
        if (A_LoopReadLine) {
            choices.Push(A_LoopReadLine) 
        } 
    }

    task := AutoCompletingListView( message , choices)
    if ( task ) { 
        action := { "Action" : "Fork" , "Task" : { "Name" : task , "Start" : GetUnixTime() }}
    }
    return action
}
; -----

FlowUI( ) {
    global globalState

    ; ----- 
    if ( !globalState ) {
        globalState := LoadState()
    }
    state := globalState
    currentMode := state["Mode"]
    if (currentMode == "Flow") {
        message := _FormatForkMessage( state ) 
        action := ChooseAction( message , [ "Fork" , "Join" , "Gather" , "Break"] )

    }
    else if (currentMode == "Off") {
        message := _FormatOffMessage( state ) 
        action := ChooseTask( message)
    }
    else {
        WriteTip( "Flowtime in unknown state. " currentMode)
    return
}
if action["Action"] == "Join" {
    currentTasks := state["Tasks"]
    action["Task"] := currentTasks[ currentTasks.Count() ] 
}
; -----
newState := AdvanceState( action , state )
if (!newState) {
    return 
}
newMode := newState["Mode"]
if ( newMode == "Off" && currentMode == "Flow") { 
    newState := _BreakInstructions( state, newState )
} 
else if ( newMode == "Flow" && currentMode != "Flow") {
    newState := _FlowInstructions( newState )
}
StateLog( action , newState )
globalState := newState

return 
}
