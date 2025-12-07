P_PickUpLoot() {
    global s_P_Loot

    c_Max_Loot_Level := 1

    ; Sleep for a bit to allow loot to fall on the ground and be detected.
    Sleep(1000)
    d2bitmap := GetD2Bitmap()
    loot_level := DetectLootInMinimap(d2bitmap, c_Max_Loot_Level)
    loot_level_by_text := DetectLootByText(d2bitmap, c_Max_Loot_Level)
    if (loot_level_by_text > 0 && loot_level = 0) {
        global s_P_Loot_Caught_by_Text
        s_P_Loot_Caught_by_Text := s_P_Loot_Caught_by_Text + 1
        SaveD2Bitmap(d2bitmap, TempFile("Screenshot_P_failed_to_detect_loot_run_" s_LK_Run_ID "_level_" loot_level "_caught_by_text_" loot_level_by_text ".bmp"))
    }
    if (loot_level = 0) {
        LogVerbose("No loot is detected")
        return
    }
    Log("Loot detected (level=" loot_level ")")
    SaveD2Bitmap(d2bitmap, TempFile("Screenshot_P_loot_detected.bmp"))
    s_P_Loot[loot_level].Detected := s_P_Loot[loot_level].Detected + 1

    ; Blink towards where loot may be
    Press "C"
    ClickOrMove2 800, 150, "Right", , s_Blink_Delay

    ; Try to pick it up by Alt + Click for 3 times.
    loot_count := 0
    loop 3 {
        LogVerbose("Attempting to pick up loot")
        detected := PickUpLootOnGround(c_Max_Loot_Level, 1000)
        LogVerbose("Was loot detected by holding Alt: " detected)

        if (detected) {
            transfered_count := TransferLootFromInventoryIntoCube(2, 8, 4, 2, 1, 8)
            if (transfered_count = -1) {
                ; The cube is full. No point to do more runs. Stop the script by pausing the game.
                StopScript("Cube is full. Pausing the game and stopping the script.", true, true)
            }
            loot_count := loot_count + transfered_count
        }

        remaining_loot_level := DetectLootInMinimap(, c_Max_Loot_Level)
        looted := (remaining_loot_level = 0)
        if (looted) {
            break
        }

        CheckHealth(nil, [[40, P_EmergencyRestart]])
    }
    LogVerbose(loot_count " loot has been transfered to cube")

    ; Check if the loot has been picked up (by see what's remaining on the ground)
    remaining_loot_level := DetectLootInMinimap(, c_Max_Loot_Level)
    looted := (remaining_loot_level = 0)
    if (looted) {
        Log("Successfully picked up loot (level " loot_level ")")
        s_P_Loot[loot_level].Looted := s_P_Loot[loot_level].Looted + 1
    } else {
        LogWarning("Failed to pick up loot (level " loot_level ")")
        s_P_Loot[loot_level].Failed := s_P_Loot[loot_level].Failed + 1

        ; Take a picture of the scene before moving on
        now := FormatTime(A_Now, "HHmmss")
        Press("{Alt down}", 200)
        GetD2Bitmap(TempFile("Screenshot_P_failed_to_pick_up_loot_run_" s_P_Run_ID "_level_" loot_level ".bmp"))
        Press("{Alt up}", 0)

        if (loot_level = 1) {
            ; Play sound and wait so that a human can have the chance to interfere before moving on
            SoundPlay("sounds/Notification.aac", 1)
            Sleep(1000)
            SoundPlay("sounds/Notification.aac", 1)
        }
    }

    ; Have to restart anyways
    P_EmergencyRestart()
}
