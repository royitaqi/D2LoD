#include D2.ahk
#include SaveAndLoad.ahk


/*
    On Windows, tail the log file in VS Code's terminal window by running the following:
    > clear; Get-Content 'ahk/log.txt' -Wait -Tail 10
*/
s_Log_File := "log.txt"

/*
    -4 = Fatal
    -3 = Error
    -2 = Warning
    -1 = Important
     0 = Info
     1 = Verbose    - Often used by business level scripts (e.g. LK, P)
     2 = Debug      - Often used by util scripts
     3 = Tedious    - Often used by util scripts for extreme details
*/
s_Log_Level := 0
s_Fatal := -4
s_Error := -3
s_Warning := -2
s_Important := -1
s_Info := 0
s_Verbose := 1
s_Debug := 2
s_Tedious := 3

Say(text, delay := 100) {
    Send "{Enter}"
    Sleep 50
    Send text
    Sleep 50
    Send "{Enter}"
    Sleep delay
}

s_Log_To_File_Buffer := ""
ToFile(text, level := 0) {
    line := _GetLine(text, level)
    if (!line) {
        return
    }

    global s_Log_To_File_Buffer
    line := s_Log_To_File_Buffer "" FormatTime(A_Now, "HH:mm:ss") " - " line "`n"
    try {
        FileAppend(line, s_Log_File)
        s_Log_To_File_Buffer := ""
    }
    catch Error {
        s_Log_To_File_Buffer := line
    }
}

ToScreen(text, level := 0) {
    line := _GetLine(text, level)
    if (!line) {
        return
    }

    Say(line)
}

ClearLogFile() {
    FileOpen(s_Log_File, "w").Close()
}

_GetLine(text, level) {
    if (level > s_Log_Level) {
        return nil
    }

    switch (level) {
        case -4:    return "FATAL: " text
        case -3:    return "ERROR: " text
        case -2:    return "WARNING: " text
        case -1:    return "IMPORTANT: " text
        case 0:     return text
        case 1:     return "VERBOSE: " text
        case 2:     return "DEBUG: " text
        case 3:     return "TEDIOUS: " text
        default:    Assert(false, "Level cannot be recognized: " level)
    }
}

Log(text, destination := nil, level := 0) {
    ; If destination is given, log to destination only
    if (destination) {
        destination.Call(text, level)
        return
    }

    ; Otherwise, log to file, and to screen if suitable
    ToFile(text, level)
    ; Only log to screen if it's at or above INFO level, and message can be typed into the game.
    if (level <= 0 && D2Window.IsActive() && IsGameLoaded() && !IsGamePaused()) {
        ToScreen(text, level)
    }
}
LogFatal(text, destination := nil) {
    Log(text, destination, -4)
}
LogError(text, destination := nil) {
    Log(text, destination, -3)
}
LogWarning(text, destination := nil) {
    Log(text, destination, -2)
}
LogImportant(text, destination := nil) {
    Log(text, destination, -1)
}
LogVerbose(text, destination := nil) {
    Log(text, destination, 1)
}
LogDebug(text, destination := nil) {
    Log(text, destination, 2)
}
LogTedious(text, destination := nil) {
    Log(text, destination, 3)
}

IsLogLevelVerbose() {
    return s_Log_Level >= 1
}
IsLogLevelDebug() {
    return s_Log_Level >= 2
}
IsLogLevelTedious() {
    return s_Log_Level >= 3
}

LogLevelVerbose() {
    global s_Log_Level
    s_Log_Level := 1
}
LogLevelDebug() {
    global s_Log_Level
    s_Log_Level := 2
}
LogLevelTedious() {
    global s_Log_Level
    s_Log_Level := 3
}
