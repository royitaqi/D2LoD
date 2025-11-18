#include D2.ahk
#include KeyboardAndMouse.ahk
#include ReadScreen.ahk


SaveAndQuit(timeout := 5000) {
    Send "{Escape}"
    ClickOrMove 500, 265, "", s_Premove_Delay
    ClickOrMove 500, 265, "Left", 0

    waited := 0
    while (!IsMainScreen(, true)) {
        Assert(timeout = 0 || waited < timeout, "Timed out while waiting for main screen")
        Sleep(100)
        waited := waited + 100
    }
}

SinglePlayerChar1Hell(timeout := 5000)
{
    ClickOrMove(475, 315, "Left", 100)
    ClickOrMove(200, 150, "Left", 0)
    ClickOrMove(200, 150, "Left", 100)
    ClickOrMove(475, 375, "Left", 0)

    waited := 0
    while (!IsGameLoaded(, true)) {
        Assert(timeout = 0 || waited < timeout, "Timed out while waiting for game to be loaded")
        Sleep(100)
        waited := waited + 100
    }
}

IsMainScreen(d2bitmap := 0, clear_mouse := false) {
    if (!d2bitmap) {
        if (clear_mouse) {
            ClearMouse()
        }
        d2bitmap := GetD2Bitmap()
    }

    /*
        The black space inside the second "I" of "Diablo II" should be black.
        > The color at X440 Y150 is 040404
    */
    if (GetPixelColorInRGB(d2bitmap, 440, 150) != 0x040404) {
        return 0
    }

    /*
        The "BATTLE.NET" button should be gray.
        > The color at X480 Y350 is 606060
    */
    if (GetPixelColorInRGB(d2bitmap, 480, 350) != 0x606060) {
        return 0
    }

    /*
        The snow mountain to the left of "D" should be gray.
        > The color at X150 Y70 is 707070
    */
    if (GetPixelColorInRGB(d2bitmap, 150, 70) != 0x707070) {
        return 0
    }

    /*
        The flame to the right of the menu should be bright yellow.
        > The color at X690 Y375 is FCE874
    */
    if (GetPixelColorInRGB(d2bitmap, 690, 375) != 0xFCE874) {
        return 0
    }

    return 1
}

IsGameLoaded(d2bitmap := 0, clear_mouse := false) {
    if (!d2bitmap) {
        if (clear_mouse) {
            ClearMouse()
        }
        d2bitmap := GetD2Bitmap()
    }

    /*
        The background to the left of the health gauge should be gray.
        > The color at X20 Y555 is 383838
    */
    if (GetPixelColorInRGB(d2bitmap, 20, 555) != 0x383838) {
        return 0
    }

    /*
        The arm ring on the angle to the left of the health gauge should be yellow.
        > The color at X20 Y553 is 484020
    */
    if (GetPixelColorInRGB(d2bitmap, 20, 553) != 0x484020) {
        return 0
    }

    /*
        The background to the right of the mana gauge should be gray.
        > The color at X1055 Y555 is 404040
    */
    if (GetPixelColorInRGB(d2bitmap, 1055, 555) != 0x404040) {
        return 0
    }

    /*
        The arm ring on the demon to the right of the mana gauge should be yellow.
        > The color at X1055 Y563 is 584438
    */
    if (GetPixelColorInRGB(d2bitmap, 1055, 563) != 0x584438) {
        return 0
    }

    return 1
}

IsGamePaused(d2bitmap := 0, clear_mouse := false) {
    if (!d2bitmap) {
        if (clear_mouse) {
            ClearMouse()
        }
        d2bitmap := GetD2Bitmap()
    }

    /*
        The center of the three "O"s in the pause menu should be yellow.
        The color at X467 Y210 is 74643C
        The color at X554 Y212 is 645834
        The color at X573 Y312 is 645834
    */
    if (GetPixelColorInRGB(d2bitmap, 467, 210) != 0x74643C ||
            GetPixelColorInRGB(d2bitmap, 554, 212) != 0x645834 ||
            GetPixelColorInRGB(d2bitmap, 573, 312) != 0x645834) {
        return 0
    }
    return 1
}

s_D2State_GamePaused := "GamePaused"
s_D2State_GameRunning := "GameRunning"
s_D2State_MainScreen := "MainScreen"
s_D2State_Unknown := "unknown"

GetD2State(d2bitmap := 0, clear_mouse := false) {
    if (!d2bitmap) {
        if (clear_mouse) {
            ClearMouse()
        }
        d2bitmap := GetD2Bitmap()
    }

    if (IsGameLoaded(d2bitmap, clear_mouse)) {
        if (IsGamePaused(d2bitmap, clear_mouse)) {
            global s_D2State_GamePaused
            return s_D2State_GamePaused
        } else {
            global s_D2State_GameRunning
            return s_D2State_GameRunning
        }
    }
    if (IsMainScreen(d2bitmap, clear_mouse)) {
        global s_D2State_MainScreen
        return s_D2State_MainScreen
    }
    global s_D2State_Unknown
    return s_D2State_Unknown
}

ReloadFromAnywhere() {
    c_Max_Escape_Count := 3
    escapeCount := 0
    ; Use an infinite loop to guide the game into a loaded state
    loop {
        state := GetD2State(nil, true)
        LogDebug("ReloadFromAnywhere: state=" state, ToFile)
        switch state {
            case s_D2State_GameRunning:
                ; Game could have panels open, or be in the chat box.
                ; Keep pressing ESC until the pause menu show up.
                Press("{Escape}")
                escapeCount := escapeCount + 1
                Assert(escapeCount <= c_Max_Escape_Count, "Cannot press more then " c_Max_Escape_Count " ESC during reload")
            case s_D2State_GamePaused:
                ; Cancel the pause menu just so that we can call SaveAndQuit().
                Press("{Escape}")
                SaveAndQuit()
            case s_D2State_MainScreen:
                SinglePlayerChar1Hell()
                LogDebug("Reloaded into the game")
                return
            case s_D2State_Unknown:
                ; Could be in the splash screen, the character selection screen, or the difficulty selection screen.
                ; Keep pressing ESC until the main screen show up.
                Press("{Escape}")
                escapeCount := escapeCount + 1
                Assert(escapeCount <= c_Max_Escape_Count, "Cannot press more then " c_Max_Escape_Count " ESC during reload")
        }
        Sleep 100
    }
}

PauseGameIfPossible() {
    ClearMouse()
    loop {
        d2bitmap := GetD2Bitmap()

        ; Cannot pause game if the game isn't loaded, or if the game is already paused
        if (!IsGameLoaded(d2bitmap, true) || IsGamePaused(d2bitmap, true)) {
            break
        }

        ; Game isn't paused yet. Press ESC to exit one layer of interaction (e.g. inventory,
        ; hireling, stats, skills, message box) or bring up pause menu.
        Send "{Escape}"
        Sleep 50
    }
}
