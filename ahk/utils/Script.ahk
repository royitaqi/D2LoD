#include D2.ahk
#include Log.ahk


StopScript(msg := "", try_to_pause := true, try_to_notify := true) {
    ; Print/log the message is possible
    if (msg) {
        LogImportant(msg)
    }

    ; Try to pause the game
    if (try_to_pause) {
        LogVerbose("Trying to pause the game")
        PauseGameIfPossible()
    }

    ; Try to play notification sound
    if (try_to_notify) {
        playSound() {
            LogVerbose("Trying to play notification sound")
            SoundPlay("sounds/Notification.aac", 1)
        }
        if (IsError(RetryCount(playSound, 3, 100))) {
            LogWarning("Cannot play notification sound when stopping script")
        }
    }

    ; Actually stop the script
    Reload
    Sleep 1000
    throw "Should have reloaded"
}

IsMainScript(scriptname) {
    return A_ScriptName = scriptname
}

; Calls func() once, then retries as long as should_retry() returns true.
; Returns the last returned value or the Error that was thrown.
Retry(func, should_retry, delay := 0) {
    log_prefix := "Retry([" ToString(func) "]): "
    loop {
        try {
            LogDebug(log_prefix "Calling function [" ToString(func) "]")
            ret := func.Call()
            LogDebug(log_prefix "Finished with ret: [" ToString(ret) "]")
        } catch Error as err {
            ret := err
            LogDebug(log_prefix "Thrown error: [" ToString(ret) "]")
        }
        if (!should_retry(ret)) {
            LogDebug(log_prefix "Shouldn't retry. Returning [" ToString(ret) "]")
            return ret
        }
        LogDebug(log_prefix "Should retry. Sleeping for " delay)
        Sleep(delay)
    }
}

; Retries a func() call until it can execute without throwing an Error, or until all attempts are done.
RetryCount(func, attempts, delay := 0) {
    ; The function will always be tried at least once
    tries := 1
    shouldRetry(ret) {
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
    return Retry(func, shouldRetry, delay)
}

; Retries a func() call until it can execute without throwing an Error, or until timeout.
RetryTimeout(func, timeout, delay := 0) {
    start := A_TickCount
    shouldRetry(ret) {
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
    return Retry(func, shouldRetry, delay)
}

RunForever(func) {
    loop {
        try {
            LogImportant("Running " func.Name)
            func.Call()
        } catch Error as err {
            LogError("Error was thrown: [" err.what "] " err.message "`n`n" err.stack, ToFile)

            c_sound := "Notification"
            playSound() {
                ;SoundPlay("sounds/" c_sound ".aac", 0)
                LogImportant("Played " c_sound " sound", ToFile)
            }
            if (IsError(RetryCount(playSound, 3, 100))) {
                LogWarning("Cannot play " c_sound " sound during a failure recovery")
            }

            recoverFromFailure() {
                LogImportant("Attempting failure recovery", ToFile)

                hwnd := WinGetID("Diablo II")
                WinActivate { Hwnd: hwnd } ; https://www.autohotkey.com/docs/v2/misc/WinTitle.htm
                LogImportant("Activated D2 window", ToFile)

                ReloadFromAnywhere()

                LogImportant("Recovered from failure", ToFile)
            }
            AssertNoError(RetryCount(recoverFromFailure, 3, 1000), "Cannot recover from failure", s_Fatal)
        }
    }
}
