#Requires AutoHotkey v2.0.0


A_TeleportToAndarialAndKill() {
    ; Apply buffs
    Send "Q"
    Click "Right"
    Sleep 400
    Send "W"
    Click "Right"
    Sleep 400
    Send "E"
    Click "Right"
    Sleep 400

    ; Teleport to Andarial
    Send "C"
    ClickOrMove2(640, 0)
    Click "Right"
    Sleep 400
    Click "Right"
    Sleep 400
    Click "Right"
    Sleep 400

    ; Switch to kill gear
    Press "``"

    ; Switch to Berserker and kill Andiarial
    ; > The cursor is at X=563 Y=170
    ClickOrMove2(563, 170)
    start_tick := A_TickCount
    timeout_tick := start_tick + 10000
    emergency_restart := false
    is_boss_alive := true
    first_round := true
    while (A_TickCount < timeout_tick) {
        Send "R"
        Click "Right"
        Sleep 400
        Send "F"
        ; Hold down SHIFT if this is not the first round of attack.
        ; For the first round, we want to walk to Andrarial so that she is in attack range.
        if (!first_round) {
            Send "{Shift Down}"
        }
        Click "Right Down"
        Sleep 2000
        Click "Right Up"
        if (!first_round) {
            Send "{Shift Up}"
        }
        Sleep 400
        first_round := false

        ; Check if Andarial is dead or not
        ; > 892 162
        ; > 909 173
        d2bitmap := GetD2Bitmap()
        is_boss_alive := DetectPixelColorInRect2(d2bitmap, 892, 162, 909, 173, s_Boss_Minimap_Color, 0)
        if (!is_boss_alive) {
            break
        }
        LogVerbose("Andarial is still alive")

        if (CheckHealth(d2bitmap, [[40, A_EmergencyRestart]])) {
            global s_A_Heal_Concerns
            s_A_Heal_Concerns.Hero += 1
            emergency_restart := true
            break
        }
    }

    ; Switch to cast gear
    Press "``"

    if (emergency_restart) {
        LogWarning("Emergency restarting")
        A_EmergencyRestart()
    } else if (is_boss_alive) {
        LogWarning("Couldn't kill boss in 10 seconds")
    } else {
        dur := A_TickCount - start_tick
        LogVerbose("Killed boss in " (dur // 1000) "." Format("{:03u}", Mod(dur, 1000)) " seconds")
    }
}
