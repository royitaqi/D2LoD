#include D2.ahk
#include Log.ahk


StopScript(msg := "", try_to_pause_and_notify := true) {
    ; Print/log the message is possible
    if (msg) {
        LogImportant(msg)
    }

    ; Try to pause the game and play notification sound
    if (try_to_pause_and_notify) {
        LogDebug("Trying to pause the game and play notification sound")
        PauseGameIfPossible()
        SoundPlay("sounds/Notification.aac", 1)
    }

    ; Actually stop the script
    Reload
    Sleep 1000
    throw "Should have reloaded"
}

IsMainScript(scriptname) {
    return A_ScriptName = scriptname
}

RetryCount(func, attempts, delayBetweenTries := 0) {
    tried := 0
    loop {
        try {
            func.Call()
        } catch Error {
            tried := tried + 1
            if (tried = attempts) {
                return false
            }
        } else {
            return true
        }
        Sleep(delayBetweenTries)
    }
}

RunForever(func) {
    loop {
        try {
            LogImportant("Running " func.Name)
            func.Call()
        } catch Error as err {
            LogError("Error was thrown: [" err.what "] " err.message "`n`n" err.stack, ToFile)

            ; Make sure D2 window is activated
            activateD2() {
                hwnd := WinGetID("Diablo II")
                WinActivate { Hwnd: hwnd } ; https://www.autohotkey.com/docs/v2/misc/WinTitle.htm
                LogImportant("Activated D2 window", ToFile)
            }
            Assert(RetryCount(activateD2, 3, 1000), "Cannot activate D2 during a failure recovery", s_Fatal)
            
            ; Play alarm sound, but don't wait for it because it's too long
            playSound() {
                SoundPlay("sounds/WarSiren.aac", 0)
                LogImportant("Played war siren sound", ToFile)
            }
            if (!RetryCount(playSound, 3, 1000)) {
                LogWarning("Cannot play war siren sound during a failure recovery")
            }
            
            ; Reload the game
            Assert(RetryCount(ReloadFromAnywhere, 3, 1000), "Cannot reload the game during a failure recovery", s_Fatal)
        }
    }
}

RequireAdmin() {
    if (!A_IsAdmin) {
        MsgBox "This script requires to be run as admin"
        ExitApp
    }
}
