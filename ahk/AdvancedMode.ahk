#include A/A.ahk
#include LK/LK.ahk
#include P/P.ahk
#include utils/Log.ahk


s_CurrentMode := 0
Numpad0::SetAdvancedMode(0)
^1::
Numpad1::SetAdvancedMode(1)
^2::
Numpad2::SetAdvancedMode(2)
^3::
Numpad3::SetAdvancedMode(3)
^4::
Numpad4::SetAdvancedMode(4)
^5::
Numpad5::SetAdvancedMode(5)
^6::
Numpad6::SetAdvancedMode(6)
SetAdvancedMode(mode)
{
    global s_CurrentMode
    s_CurrentMode := mode

    global s_Log_Destination
    if (s_CurrentMode = 1) {
        s_Log_Destination := ToAll
    } else {
        s_Log_Destination := ToDefault
    }

    AnnounceMode()
}
NumLock::
{
    AnnounceMode()
}
AnnounceMode()
{
    global s_CurrentMode
    switch s_CurrentMode
    {
    case 0: Log("Advanced Mode = 0/OFF", ToAll)
    case 1: Log("Advanced Mode = 1/Debug", ToAll)
    case 2: Log("Advanced Mode = 2/Gamble", ToAll)
    case 3: Log("Advanced Mode = 3/LK", ToAll)
    case 4: Log("Advanced Mode = 4/Reroll", ToAll)
    case 5: Log("Advanced Mode = 5/Pindle", ToAll)
    case 6: Log("Advanced Mode = 6/Andarial", ToAll)
    }
}
Delete::
{
    global s_CurrentMode
    if (s_CurrentMode != 0)
    {
        StopScript("Stopping script", true, false)
        return
    }
    Send "{Delete}"
}
F12::
{
    global s_CurrentMode
    if (s_CurrentMode != 0)
    {
        TestMousePosition()
        return
    }
    Send "{F12}"
}
F11::
{
    global s_CurrentMode
    if (s_CurrentMode != 0)
    {
        TestPixelColor()
        return
    }
    Send "{F11}"
}
F10::
{
    global s_CurrentMode
    switch s_CurrentMode
    {
    case 1:
        TakeScreenShot()
        return
    }
    Send "{F10}"
}
; Temporary
F9::
{
    global s_CurrentMode
    switch s_CurrentMode
    {
    case 1:
        d2bitmap := LoadD2Bitmap("utils/tests/Test_Andarial2.bmp")
        DumpBitmapArray(d2bitmap, 505, 19, 569, 46)
        return
    }
    Send "{F9}"
}
N::
{
    global s_CurrentMode
    switch s_CurrentMode
    {
    case 2:
        N_2Gamble()
        return
    case 4:
        N_4Reroll()
        return
    }
    Send "N"
}
M::
{
    global s_CurrentMode
    switch s_CurrentMode
    {
    case 2:
        M_2Gamble()
        return
    case 4:
        N_4Reroll()
        return
    }
    Send "N"
}
J::
{
    global s_CurrentMode
    switch s_CurrentMode
    {
    case 0:
        SinglePlayerChar1Hell()
        return
    case 1:
        SinglePlayerChar1Hell()
        return
    case 3:
        SinglePlayerChar1Hell()
        return
    case 4:
        J_4Reroll()
        return
    }
    Send "J"
}
K::
{
    global s_CurrentMode
    switch s_CurrentMode
    {
    case 4:
        K_4Reroll()
        return
    }
    Send "K"
}
L::
{
    global s_CurrentMode
    switch s_CurrentMode
    {
    case 1:
        DumpLevelBitmap()
        Log("Current level = " GetCurrentLevel())
        return
    case 3:
        LK_Main()
        return
    case 5:
        P_Main()
        return
    case 6:
        A_Main()
        return
    }
    Send "L"
}


;;------------------------------------------------------------
;; Advanced Mode: 1/Debug
;;------------------------------------------------------------

/* Delete pages which has items (PlugY's /dp can only delete empty pages) */
TooglePages()
{
    start_page := 244
    end_page := 260

    i := start_page
    n := end_page - start_page + 1

    loop n
    {
        Say("/tp " i, 100)
        ClickStashNext("Left", 100)
        i := i + 1

        if (!IsD2Active()) {
            return
        }
    }
}


;;------------------------------------------------------------
;; Advanced Mode: 2/Gamble
;;------------------------------------------------------------

N_2Gamble()
{
    NextGamblePage("Horker")
}
M_2Gamble()
{
    loop 10
    {
        NextGamblePage("Sorc")
        GambleAmulet()
    }
}
NextGamblePage(who)
{
    MouseGetPos &xpos, &ypos
    Send "{Escape}"
    Sleep 100
    MouseMove 535, 191
    Sleep 100
    Click 535, 191, "Left"
    Sleep 100

    if (who == "Sorc") {
        y := 128
    }
    if (who == "Horker") {
        y := 114
    }

    MouseMove 535, y
    Sleep 100
    Click 535, y, "Left"
    Sleep 100
    MouseMove xpos, ypos
}
GambleAmulet()
{
    MouseMove 504, 172
    Sleep 100
    Click 504, 172, "Right"
    Sleep 100
}


;;------------------------------------------------------------
;; Advanced Mode: 4/Reroll
;;------------------------------------------------------------

N_4Reroll()
{
    NextReroll()
}
J_4Reroll()
{
    FillInventory(0, 0, 4, 10)
}
K_4Reroll()
{
    FillInventory(4, 0, 4, 10)
}

s_CurrentColumn := 0
NextReroll()
{
    global

    Send "{Shift Down}"
    ClickCube(3, 2, "Right")
    ClickOrMoveToInventorySlot(0, s_CurrentColumn, "Right")
    ClickOrMoveToInventorySlot(1, s_CurrentColumn, "Right")
    ClickOrMoveToInventorySlot(2, s_CurrentColumn, "Right")
    ClickOrMoveToInventorySlot(3, s_CurrentColumn, "Right")
    ClickCubeButton("Left")
    ClickCube(3, 2)
    Send "{Shift Up}"

    s_CurrentColumn := Mod(s_CurrentColumn + 1, 10)
}

FillInventory(row_start, col_start, row_count, col_count)
{
    Send "{Shift Down}"
    c := col_start
    Loop col_count / 2 {
        r := row_start
        Loop row_count {
            ClickStash(r, c, "Right")
            ClickStash(r, c + 1, "Right")
            r := r + 1
        }
        c := c + 2
    }
    Send "{Shift Up}"

    Click 490, 400, "Right"
}



/* Caster Reroll
N::NextReroll()

s_CurrentColumn := 0
NextReroll()
{
    global
    x := 560 + 30 * s_CurrentColumn

    Send "{Shift Down}"
    y := 330
    Click x, y, "Right"
    Sleep 100
    Click x, y + 30, "Right"
    Sleep 100
    Click x, y + 60, "Right"
    Sleep 100
    Send "{Shift Up}"

    Click 375, 335, "Left"

    MouseMove 345, 240

    s_CurrentColumn := Mod(s_CurrentColumn + 1, 10)
}

FillInventory(x, cs, rs)
{
    Send "{Shift Down}"
    Loop cs {
        y := 160
        Loop rs {
            Click x, y, "Right"
            Sleep 100

            y := y + 30
        }
        x := x + 30
    }
    Send "{Shift Up}"

    Click 490, 400, "Right"
}
*/
