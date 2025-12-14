#Requires AutoHotkey v2.0.0


A_HealAndEnterWaypoint() {
    Press("B")
    AssertEqual(GetCurrentLevel(), "Rogue Encampment", "Should be in Rouge Encampment")

    ; Check that the hireling is alive
    if (!CheckHirelingAlive()) {
        global s_A_Hires
        s_A_Hires += 1

        LogImportant("Hireling is dead. Rehiring")
        A_Rehire()
        AssertTrue(CheckHirelingAlive(), "Hireling should be alive after rehire")

        LogVerbose("Restarting after rehire")
        A_EmergencyRestart()
        return
    }
    LogVerbose("Hireling is alive")

    ; Run towards Akara
    Hold(999, 406, "Left", 2000)
    MouseMove(534, 300)
    Sleep(1000)

    ; Find Akara
    ; Akara color: #381444
    d2bitmap := GetD2Bitmap()
    found := GridPattern(
        DetectColorCallback([[d2bitmap, true]], 0x381444, 0),
        , , , s_Hud_Y, 6, 6,
        &match_x, &match_y
    )
    AssertTrue(found, "Should find Akara")
    LogVerbose("Found Akara at x=" match_x " y=" match_y)

    ; Talk to Akara
    ClickOrMove2(match_x, match_y, "Left")
    ; Cancel dialog menu
    ClickOrMove2(750, 575, "Left")

    ; Move to the left so as to clear the way to the waypoint
    ClickOrMove2(200, 250, "Left", , 800)

    d2bitmap := GetD2Bitmap()

    ; Double check health should be full
    AssertEqual(CheckHealth(d2bitmap, [[100, () => nil]]), 0, "Health should be full")

    ; Find the waypoint
    found := GridPattern(
        DetectColorCallback([[d2bitmap, true]], 0x76A9DE, 0x20, 0x6988F4, 0x20),
        , , , s_Hud_Y, 6, 6,
        &match_x, &match_y
    )
    AssertTrue(found, "Should find waypoint")
    LogVerbose("Found waypoint at x=" match_x " y=" match_y)
    
    ; Go to the waypoint
    ClickOrMove2(match_x + 50, match_y, "Left", , 1200)

    ; Click the level in the waypoint menu
    ClickOrMove2(400, 420, "Left")
}

A_Rehire() {
    ; Talk to Qual-Kehk
    ClickOrMove2(903, 390, "Left", , 1000)

    ;StopScript(nil, false, false)
    
    ; Hire
    ClickOrMove2(597, 170, "Left", , 500)

    ; Cancel dialog menu
    Press("{Escape}", 500)
}
