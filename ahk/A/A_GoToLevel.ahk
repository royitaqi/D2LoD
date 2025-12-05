#Requires AutoHotkey v2.0.0


A_GoToLevel() {
    Assert(GetCurrentLevel() = "Catacombs Level 2", "Should be in Catacombs Level 2")

    ; Open minimap and apply buffs
    Send "Q"
    Click "Right"
    Sleep 400
    Send "W"
    Click "Right"
    Sleep 400
    Send "E"
    Click "Right"
    Sleep 400

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
    match_x := match_y := 0
    FindStairTorch() {
        d2bitmap := GetD2Bitmap(TempFile("GridPatternTwoPass.bmp"))
        found := GridPatternTwoPass(
            DetectColorCallback([[d2bitmap, true]], 0xFFDB60, 0x20, 0x49190F, 0x20),
            DetectColorCallback([[d2bitmap, true]], 0xFFDB60, 0, 0x49190F, 0),
            70, 70, , s_Hud_Y, 6, 6,
            &match_x, &match_y
        )
        AssertTrue(found, "Should find stair torch")
        LogVerbose("Found stair torch at x=" match_x " y=" match_y)
    }
    AssertNoError(RetryTimeout(FindStairTorch, 5000), "Should find stair torch (all retries have failed)")
    
    ; Go down to Level 4
    ClickOrMove2(match_x + 100, match_y + 100)

    StopScript("STOP", false, false)

    ; ClickOrMove2(match_x + 100, match_y + 100, "Left", , 400)
    ; AssertEqual(GetCurrentLevel(), "Catacombs Level 4", "Should be in Catacombs Level 4")
}
