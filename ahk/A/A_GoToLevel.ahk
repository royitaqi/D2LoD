#Requires AutoHotkey v2.0.0


A_GoToLevel() {
    if (!A_PassCheckpoint("i2", GetCurrentLevel() = "Catacombs Level 2")) {
        A_EmergencyRestart()
        return
    }

    ; Blink bottom right to stairs
    Send "C"
    ClickOrMove2(1000, 545)
    Click "Right"
    Sleep 400
    Click "Right"
    Sleep 400

    ; Go down to Level 3
    ClickOrMove2(580, 145, "Left", , 400)

    ; Blink bottom left then top left to stairs
    ClickOrMove(13, 528)
    Click "Right"
    Sleep 400
    Click "Right"
    Sleep 400
    Click "Right"
    Sleep 400
    ClickOrMove(100, 160)
    Click "Right"
    Sleep 400
    Click "Right"
    Sleep 400
    Click "Right"
    Sleep 400

    ; Find stair torch
    ; The mouse hover box is this large:
    ; > The cursor is at X=620 Y=207
    ; > The cursor is at X=845 Y=311
    ; It's about 225 x 115

    ; Find stair torch
    match_x := match_y := 0
    FindStairTorch() {
        ;d2bitmap := GetD2Bitmap(TempFile("GridPatternTwoPass.bmp"))
        d2bitmap := GetD2Bitmap()
        found := GridPatternTwoPass(
            DetectColorCallback([[d2bitmap, true]], 0xFFDB60, 0x20, 0xB2541D, 0x20),
            DetectColorCallback([[d2bitmap, true]], 0xFFDB60, 0x10, 0xB2541D, 0x10),
            70, 70, , s_Hud_Y, 6, 6,
            &match_x, &match_y
        )
        AssertTrue(found, "Should find stair torch")
        LogVerbose("Found stair torch at x=" match_x " y=" match_y)
    }
    if (!A_PassCheckpoint("w4", !IsError(RetryTimeout(FindStairTorch, 10000)))) {
        A_EmergencyRestart()
        return
    }

    ; Go down to Level 4
    ClickOrMove2(match_x + 100, match_y + 100, "Left", , 1000)
    if (!A_PassCheckpoint("i4", GetCurrentLevel() = "Catacombs Level 4")) {
        A_EmergencyRestart()
        return
    }
}
