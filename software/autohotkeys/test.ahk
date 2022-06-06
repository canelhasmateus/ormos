globalState := { "Tasks" : [{ "Name" : "aaa" , "Start" : "20220606081255" }]}
Diff( start, finish ) { 
   result := finish
   EnvSub result, start, seconds
   return result
}

GetUnixTime() {
   return A_Now
}

ToHumanTime( timestamp ) {
   FormatTime, result, %timestamp%, yyyy/MM/dd HH:mm:ss
   return result
}

SecondsSinceStart( state ) {
    mainTask := state["Tasks"][1]
    timeStart := mainTask["Start"]
    right_now := GetUnixTime()
    timeSince := Diff(  timeStart,  right_now)
    return timeSince
}
ApproxMinutesSinceStart( state ) {
    timeSince := SecondsSinceStart( state )
    halfHours := timeSince / 1800
    minutePassed := Round(halfHours) * 30
    return minutePassed
}

timeSince := ApproxMinutesSinceStart( globalState )
MsgBox,  %timeSince% "~ minutes since task started." 
