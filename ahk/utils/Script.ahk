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

StopScriptWhenD2BecomeInactive() {
    Impl() {
        if (!IsD2Active()) {
            StopScript("Stopping script because D2 became inactive", false)
        }
    }
    SetTimer(Impl, 1000)
}

IsMainScript(scriptname) {
    return A_ScriptName = scriptname
}

; Calls func() once, then retries as long as should_retry() returns true.
; Returns the last returned value or the Error that was thrown.
Retry(func, should_retry, delay := 0) {
    loop {
        try {
            ret := func.Call()
        } catch Error as err {
            ret := err
        }
        if (!should_retry(ret)) {
            return ret
        }
        Sleep(delay)
    }
}

; Retries a func() call until it can execute without throwing an Error, or until all attempts are done.
RetryCount(func, attempts, delay := 0) {
    ; The function will always be tried at least once
    tries := 1
    should_retry(ret) {
        ; If the next try will exceed the attempts, don't retry
        if (tries + 1 > attempts) {
            return false
        }
        ; If it throws an Error, retry
        if (IsError(ret)) {
            tries := tries + 1
            return true
        }
        ; If it returns a normal value, don't retry
        return false
    }
    return Retry(func, should_retry, delay)
}

; Retries a func() call until it can execute without throwing an Error, or until timeout.
RetryTimeout(func, timeout, delay := 0) {
    start := A_TickCount
    should_retry(ret) {
        ; If the next try will exceed the timeout after the delay, don't retry
        if (A_TickCount + delay > start + timeout) {
            return false
        }
        ; If it throws an Error, retry
        if (IsError(ret)) {
            return true
        }
        ; If it returns a normal value, don't retry
        return false
    }
    return Retry(func, should_retry, delay)
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
