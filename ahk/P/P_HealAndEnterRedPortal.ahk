#include ../utils/Hireling.ahk


P_HealAndEnterRedPortal() {
    ; Talk to Malah to heal
    ClickOrMove2(158, 184, "Left", , 1000)

    ; Open minimap and apply frozen armor
    Send "B"
    Send "E"
    Click "Right"
    Sleep 400
    
    ; Check that the hireling is alive
    if (!CheckHirelingAlive()) {
        StopScript("Hireling is dead. Re-hire isn't implemented.", true)
    }
    LogVerbose("Hireling is alive")

    ; Find the portal's position from a list of candidates by checking a few different pixels where the portal is supposed to be
    /*
        Portal positions:
        - 900, 285 (Anya is in the corner)
        - 1060, 325 (Anya is in the middle)
    */
    c_Portal_Positions := [{ x: 900, y: 285 }, { x: 1060, y: 325 }]
    c_Deltas := [{ x: 0, y: 0 }, { x: 0, y: -25 }, { x: 0, y: 25 }]
    redness := []
    redness.Length := c_Portal_Positions.Length
    bitmap := GetD2Bitmap(TempFileOverwrite("Screenshot_P_before_entering_red_portal.bmp"))
    for i, pp in c_Portal_Positions {
        redness[i] := 0
        for , delta in c_Deltas {
            x := pp.x + delta.x
            y := pp.y + delta.y
            color := GetPixelColorInRGB(bitmap, x, y)
            ARGB2RGB(color, &r, &g, &b)
            redness[i] := redness[i] + r * 2 - g - b
        }
    }
    max_redness := Max(redness*)
    for i, v in redness {
        if (v = max_redness) {
            idx := i
            break
        }
    }
    
    ; Click the red portal
    ClickOrMove2(c_Portal_Positions[idx].x, c_Portal_Positions[idx].y, "Left", , 1000)

    ; Detect that we have entered the Temple
    loop {
        bitmap := GetD2Bitmap()

        /*
            The top left area should be black.
            > The color at X=100 Y=30 is 0x000000

            The area to the right should be light gray.
            > The color at X=180 Y=30 is 0x1C1C1C
        */
        if (GetPixelColorInRGB(bitmap, 100, 30) == 0x000000 &&
                GetPixelColorInRGB(bitmap, 180, 30) == 0x1C1C1C) {
            ; We are in the temple!
            break
        }

        Sleep(200)
    }
}
