#Requires AutoHotkey v2.0.0


A_PickUpLoot() {
    global s_A_Loot

    c_Max_Loot_Level := 1

/*
    ; Sleep for a bit to allow loot to fall on the ground and be detected.
    Press("{Alt Down}")
    Sleep(1000)
    GetD2Bitmap(TempFile("Screenshot_A_detect_loot.bmp"))
    Press("{Alt Up}")
*/

    ; Detect and try to pick up loot on ground
    was_loot_detected := false
    loot_level := nil
    loot_bitmap := nil
    loop 3 {
        LogVerbose("Detecting loot on ground")
        detected := PickUpLootOnGround(c_Max_Loot_Level, 1000)

        if (detected) {
            LogVerbose("Loot was detected.")
            was_loot_detected := true
            loot_level := detected[1]
            loot_bitmap := detected[2]
            SaveD2Bitmap(loot_bitmap, TempFile("Screenshot_A_loot_detected.bmp"))

            transfered_count := TransferLootFromInventoryIntoCube(2, 8, 4, 2, 1, 8)
            if (transfered_count = -1) {
                ; The cube is full. No point to do more runs. Stop the script by pausing the game.
                StopScript("Cube is full. Pausing the game and stopping the script.", true, true)
            }
        } else {
            LogVerbose("Loot was not detected.")
            break
        }

        if (CheckHealth(nil, [[40, nil]]) == 40) {
            global s_A_Health_Problem
            s_A_Health_Problem.Hero += 1
            break
        }
    }

    if (!was_loot_detected) {
        ; No loot
        return
    } else if (!detected) {
        ; Loot picked up
        Log("Successfully picked up loot (level " loot_level ")")
        s_A_Loot[loot_level].Detected += 1
        s_A_Loot[loot_level].Looted += 1
    } else {
        ; Loot not picked up
        LogWarning("Failed to pick up loot (level " loot_level ")")
        s_A_Loot[loot_level].Detected += 1
        s_A_Loot[loot_level].Failed += 1

        ; Take a picture of the scene before moving on
        now := FormatTime(A_Now, "HHmmss")
        Press("{Alt down}", 200)
        GetD2Bitmap(TempFile("Screenshot_A_failed_to_pick_up_loot_run_" s_A_Run_ID "_level_" loot_level ".bmp"))
        Press("{Alt up}", 0)

        if (loot_level == 1) {
            SoundPlay("sounds/Notification.aac", 0)
        }
    }

    ; Have to restart anyways
    A_EmergencyRestart()
}
