#include Inventory.ahk
#include Log.ahk


s_Purple_Minimap := 0xA420FC
s_Orange_Minimap := 0xE07020

; > The color at X=105 Y=89 is 0x8600C4
s_Purple_Text := 0x8600C4
; > The color at X=19 Y=90 is 0xC48100
s_Orange_Text :=0xC48100

s_Press_Delay := 100
s_Premove_Delay := 200
s_Blink_Delay := 400
s_Pick_Delay := 50

/*
    1 = purple only
    2 = purple and orange
*/
DetectLootInMinimap(d2bitmap := 0, max_loot_level := 2) {
    if (!d2bitmap) {
        d2bitmap := GetD2Bitmap()
    }

    if (max_loot_level = 1) {
        return DetectColorInMinimap(d2bitmap, s_Purple_Minimap, 0)
    } else {
        return DetectColorInMinimap(d2bitmap, s_Purple_Minimap, 0, s_Orange_Minimap, 0)
    }
}

DetectLootByText(d2bitmap := 0, max_loot_level := 2, lines := 10, chars := 1) {
    if (!d2bitmap) {
        d2bitmap := GetD2Bitmap()
    }

    x1 := 16
    y1 := 84
    ; Magic number. The width to look for.
    x2 := x1 + 8 * chars
    ; Each line is 9 pixels tall. Gap between two lines is 6 pixels tall.
    y2 := y1 + 9 + 15 * (lines - 1)

    if (max_loot_level = 1) {
        return DetectPixelColorInRect2(d2bitmap, x1, y1, x2, y2, s_Purple_Text, 0)
    } else {
        return DetectPixelColorInRect2(d2bitmap, x1, y1, x2, y2, s_Purple_Text, 0, s_Orange_Text, 0)
    }
}

/*
    1 = purple only
    2 = purple and orange

    Returns true if loot is detected on the ground by holding Alt, false otherwise.
*/
PickUpLootOnGround(max_loot_level := 2, walk_delay := 1000) {
    if (max_loot_level = 1) {
        color2 := 0
    } else {
        color2 := s_Orange_Text
    }

    /*
        The purple text "==HIGH== (26)" is 90 pixel wide
        > The cursor is at X=599 Y=300
        > The cursor is at X=509 Y=299
        
        and 10 pixel tall.
        > The cursor is at X=593 Y=290
        > The cursor is at X=543 Y=301

        Let's take 20 stride in X. That's at least 4 lines in <100 pixels.
    */
    c_X_Stride := 20

    d2bitmap1 := GetD2Bitmap()
    Press("{Alt down}", 200)
    d2bitmap2 := GetD2Bitmap()

    ; Find the top-left most pixel that has a loot color
    match := VerticalStridePattern(
        DetectColorCallback(
            [[d2bitmap1, false], [d2bitmap2, true]],
            s_Purple_Text, 0,
            color2, 0
        ),
        c_X_Stride, , , , s_Hud_Y, &match_x, &match_y
    )

    if (!match) {
        Press("{Alt up}", 200)
        return false
    }

    LogDebug("Loot detected on round: X=" match_x ", Y=" match_y ", match=" match[2])

    ClickOrMove(match_x, match_y, "", s_Premove_Delay)
    ClickOrMove(match_x, match_y, "Left", walk_delay)
    Press("{Alt up}", 200)

    return true
}

/*
    from_row, from_col: The top left corner of the loot area in the inventory.
    from_rows, from_cols: The height and width of the loot area in the inventory.
    to_row, to_col: The slot where the cube is.

    Returns the number of loot transfered. If the cube is full, return -1.
*/
TransferLootFromInventoryIntoCube(from_row, from_col, from_rows, from_cols, to_row, to_col) {
    OpenInventory()

    transfered_items := 0
    callback(row, col, x, y) {
        if (!IsInventorySlotEmpty(, row, col)) {
            ; Pick up the loot from inventory
            ClickOrMoveToInventorySlot(row, col, "Left")
            ; Put the loot into the cube
            ClickOrMoveToInventorySlot(to_row, to_col, "Left")

            ; Detect if the mouse is still holding the loot.
            ; If so, the cube is probably full, and we need to stop the script because there is no point running any more.
            if (IsMouseHoldingLoot()) {
                global s_Last_D2Bitmap
                SaveD2Bitmap(s_Last_D2Bitmap, TempFileOverwrite("Screenshot_P_cube_is_full.bmp"))
                return -1
            }

            transfered_items := transfered_items + 1
        }
    }
    ret := ForEachInventorySlot(callback, from_row, from_col, from_rows, from_cols)

    CloseInventory()

    if (ret) {
        return ret
    } else {
        return transfered_items
    }
}

/*
    Returns true if the mouse is holding a loot. Otherwise, returns false.
*/
IsMouseHoldingLoot(x := 0, y := 0) {
    ; If no coordinates are given, move mouse to a known location so that we can test that pixel.
    ; If coordinates are given, just test that pixel.
    if (!x && !y) {
        x := s_Max_X - 1
        y := 1
        ClearMouse(100, x, y)
    }
    d2bitmap := GetD2Bitmap()
    return GetPixelColorInRGB(d2bitmap, x, y) != 0x1C1C1C
}
