#Requires AutoHotkey v2.0.0

#include "../data_structure/Queue.ahk"
#include "../utils/Health.ahk"
#include "../utils/Log.ahk"
#include "../utils/Loot.ahk"
#include "../utils/ReadScreen.ahk"
#include "../utils/SaveAndLoad.ahk"

#include "LK_Route.ahk"
#include "LK_WaypointDetectionAndRecovery.ahk"


s_LK_Tasks := Queue()
s_LK_Run_ID := -1
EmptyLootData() {
    return { Detected: 0, LootedPlanned: 0, LootedAltClick: 0, Failed: 0 }
}
s_LK_Loot := [
    [EmptyLootData(), EmptyLootData()],
    [EmptyLootData(), EmptyLootData()],
    [EmptyLootData(), EmptyLootData()],
    [EmptyLootData(), EmptyLootData()]
]
s_LK_Potions_Used := 0
s_LK_Loot_Detected_by_Text := 0

LK_Main() {
    global s_LK_Tasks

    ClearLogFile()
    SetPlayers(7)
    ApplyBHCfg("../BH(LK).cfg")
    
    s_LK_Tasks.Clear()
    s_LK_Tasks.Append(LK_BackToAct4AndRestart)
    LK_Loop()
}

LK_Loop() {
    global s_LK_Tasks
    loop {
        task := s_LK_Tasks.Pop()
        LogVerbose("Running task: " task.Name)
        task.Call()
    }
}

LK_EmergencyRestart() {
    global s_LK_Tasks
    s_LK_Tasks.Clear()
    LK_RestartInAct3()
}

LK_BackToAct4AndRestart() {
    ClickOrMove 536, 278, "", s_Premove_Delay
    ClickOrMove 536, 278, "Left", 500
    ClickOrMove 431, 78, "Left", 100
    ClickOrMove 427, 142, "Left", 1000

    s_LK_Tasks.Append(LK_SaveLoadAnnounce)
    s_LK_Tasks.Append(LK_FromAct4SpawnToLK)
}

LK_RestartInAct3() {
    s_LK_Tasks.Append(LK_SaveLoadAnnounce)
    s_LK_Tasks.Append(LK_FromAct3SpawnToLK)
}

LK_SaveLoadAnnounce() {
    global s_LK_Potions_Used

    SaveAndQuit()
    SinglePlayerChar1Hell()
    LK_Announce()
}

LK_Announce() {
    global s_LK_Run_ID, s_LK_Loot, s_LK_Loot_Detected_by_Text

    s_LK_Run_ID := s_LK_Run_ID + 1

    purple := EmptyLootData()
    orange := EmptyLootData()
    purple.Detected       := s_LK_Loot[1][1].Detected + s_LK_Loot[2][1].Detected + s_LK_Loot[3][1].Detected + s_LK_Loot[4][1].Detected
    orange.Detected       := s_LK_Loot[1][2].Detected + s_LK_Loot[2][2].Detected + s_LK_Loot[3][2].Detected + s_LK_Loot[4][2].Detected
    purple.LootedPlanned  := s_LK_Loot[1][1].LootedPlanned + s_LK_Loot[2][1].LootedPlanned + s_LK_Loot[3][1].LootedPlanned + s_LK_Loot[4][1].LootedPlanned
    orange.LootedPlanned  := s_LK_Loot[1][2].LootedPlanned + s_LK_Loot[2][2].LootedPlanned + s_LK_Loot[3][2].LootedPlanned + s_LK_Loot[4][2].LootedPlanned
    purple.LootedAltClick := s_LK_Loot[1][1].LootedAltClick + s_LK_Loot[2][1].LootedAltClick + s_LK_Loot[3][1].LootedAltClick + s_LK_Loot[4][1].LootedAltClick
    orange.LootedAltClick := s_LK_Loot[1][2].LootedAltClick + s_LK_Loot[2][2].LootedAltClick + s_LK_Loot[3][2].LootedAltClick + s_LK_Loot[4][2].LootedAltClick
    purple.Failed         := s_LK_Loot[1][1].Failed + s_LK_Loot[2][1].Failed + s_LK_Loot[3][1].Failed + s_LK_Loot[4][1].Failed
    orange.Failed         := s_LK_Loot[1][2].Failed + s_LK_Loot[2][2].Failed + s_LK_Loot[3][2].Failed + s_LK_Loot[4][2].Failed

    msg := (
        "Runs: " s_LK_Run_ID
        "   |   P: " purple.Detected "=>" purple.LootedPlanned "/" purple.LootedAltClick "-" purple.Failed
            "   O: " orange.Detected "=>" orange.LootedPlanned "/" orange.LootedAltClick "-" orange.Failed
            "   HP: " s_LK_Potions_Used
            "   T: " s_LK_Loot_Detected_by_Text
    )
    if (purple.Failed) {
        msg := (
            msg "   |   Purple: "
            s_LK_Loot[1][1].Detected "=>" s_LK_Loot[1][1].LootedPlanned "/" s_LK_Loot[1][1].LootedAltClick "-" s_LK_Loot[1][1].Failed " | "
            s_LK_Loot[2][1].Detected "=>" s_LK_Loot[2][1].LootedPlanned "/" s_LK_Loot[2][1].LootedAltClick "-" s_LK_Loot[2][1].Failed " | "
            s_LK_Loot[3][1].Detected "=>" s_LK_Loot[3][1].LootedPlanned "/" s_LK_Loot[3][1].LootedAltClick "-" s_LK_Loot[3][1].Failed " | "
            s_LK_Loot[4][1].Detected "=>" s_LK_Loot[4][1].LootedPlanned "/" s_LK_Loot[4][1].LootedAltClick "-" s_LK_Loot[4][1].Failed
        )
    }
    if (orange.Failed) {
        msg := (
            msg "   |   Orange: "
            s_LK_Loot[1][2].Detected "=>" s_LK_Loot[1][2].LootedPlanned "/" s_LK_Loot[1][2].LootedAltClick "-" s_LK_Loot[1][2].Failed " | "
            s_LK_Loot[2][2].Detected "=>" s_LK_Loot[2][2].LootedPlanned "/" s_LK_Loot[2][2].LootedAltClick "-" s_LK_Loot[2][2].Failed " | "
            s_LK_Loot[3][2].Detected "=>" s_LK_Loot[3][2].LootedPlanned "/" s_LK_Loot[3][2].LootedAltClick "-" s_LK_Loot[3][2].Failed " | "
            s_LK_Loot[4][2].Detected "=>" s_LK_Loot[4][2].LootedPlanned "/" s_LK_Loot[4][2].LootedAltClick "-" s_LK_Loot[4][2].Failed
        )
    }
    Log(msg)

    if (CheckHealth(nil, [[70, 1]])) {
        global s_LK_Potions_Used
        s_LK_Potions_Used := s_LK_Potions_Used + 1
    }
}

LK_FromAct4SpawnToLK() {
    ClickOrMove 835, 70, "", 100
    ClickOrMove 835, 70, "Left", 1750
    ClickOrMove 371, 80, "Left", 100
    ClickOrMove 408, 280, "Left", 500

    s_LK_Tasks.Append(LK_StartRun)
}

LK_FromAct3SpawnToLK() {
    ClickOrMove 995, 310, "Left", 1100 ; 1250
    ClickOrMove 1050, 25, "Left", 1800 ; 2000
    ClickOrMove 1000, 60, "Left", 1650 ; 2000
    ClickOrMove 1060, 300, "Left", 1050 ; 2000
    ClickOrMove 1067, 110, "", s_Premove_Delay
    ClickOrMove 1067, 110, "Left", 2000
    ClickOrMove 408, 280, "Left", 500

    s_LK_Tasks.Append(LK_StartRun)
}

LK_StartRun() {
    ; Get ready: open map, turn on ice shield
    Send "B"
    Send "E"
    Click "Right"
    Sleep 500

    s_LK_Tasks.Append(LK_Run1stHut)
    s_LK_Tasks.Append((*) => LK_DetectLoot(1, LK_Gather1stHutLoot))
    s_LK_Tasks.Append(LK_Run2ndHut)
    s_LK_Tasks.Append((*) => LK_DetectLoot(2, LK_Gather2ndHutLoot))
    s_LK_Tasks.Append(LK_Run3rdHut)
    s_LK_Tasks.Append((*) => LK_DetectLoot(3, LK_Gather3rdHutLoot))
    s_LK_Tasks.Append(LK_Run4thHut)
    s_LK_Tasks.Append((*) => LK_DetectLoot(4, LK_Gather4thHutLoot))
    s_LK_Tasks.Append(LK_RunReturn)
    s_LK_Tasks.Append(LK_WaypointRecoveryIfNeeded)
    s_LK_Tasks.Append(LK_BackToAct4AndRestart)
}

LK_DetectLoot(hut_name, gather_loot_func) {
    global s_LK_Loot, s_LK_Loot_Detected_by_Text

    ; Sleep for a bit to allow loot to fall on the ground and be detected.
    Sleep(200)
    bitmap := GetD2Bitmap()
    if (CheckHealth(nil, [[40, LK_EmergencyRestart], [70, 1]])) {
        global s_LK_Potions_Used
        s_LK_Potions_Used := s_LK_Potions_Used + 1
        return
    }

    loot_level := DetectLootInMinimap(bitmap)
    loot_level_by_text := DetectLootByText(bitmap)
    if (loot_level_by_text > 0 && loot_level = 0) {
        s_LK_Loot_Detected_by_Text := s_LK_Loot_Detected_by_Text + 1
        GetD2Bitmap(TempFile("Screenshot_LK_failed_to_detect_loot_run_" s_LK_Run_ID "_hut_" hut_name "_level_" loot_level "_by_text_" loot_level_by_text ".bmp"))
    }
    if (loot_level = 0) {
        return
    }
    ; Loot detected
    Log("Loot level " loot_level " detected in hut " hut_name)
    if (loot_level = 1) {
        SaveD2Bitmap(d2bitmap, TempFile("Screenshot_LK_level_1_loot_detected.bmp"))
    }
    s_LK_Loot[hut_name][loot_level].Detected := s_LK_Loot[hut_name][loot_level].Detected + 1

    ; Try to pick it up by the planned route.
    gather_loot_func.Call()
    remaining_loot_level := DetectLootInMinimap()
    looted := (remaining_loot_level = 0)
    if (looted) {
        ; Looted by planned route
        s_LK_Loot[hut_name][loot_level].LootedPlanned := s_LK_Loot[hut_name][loot_level].LootedPlanned + 1
    }

    ; Try to pick it up by Alt + Click for 3 times.
    if (!looted) {
        loop 3 {
            Log("Attempting to pick up loot by Alt + Click")
            detected := PickUpLootOnGround()
            Log("Was loot detected by holding Alt: " detected)

            remaining_loot_level := DetectLootInMinimap()
            looted := (remaining_loot_level = 0)
            if (looted) {
                s_LK_Loot[hut_name][loot_level].LootedAltClick := s_LK_Loot[hut_name][loot_level].LootedAltClick + 1
                break
            }
        }
    }

    ; Transfer loot from inventory to cube.
    ; NOTE: This has to be done no matter the loot was collected or not, because other items could have been accidentally picked up.
    OpenInventory()
    loot_count := LK_TransferLootToCube()
    CloseInventory()
    Log(loot_count " loot has been transfered to cube")

    ; Check if the loot has been picked up (by see what's remaining on the ground)
    remaining_loot_level := DetectLootInMinimap()
    looted := (remaining_loot_level = 0)
    if (looted) {
        Log("Successfully picked up loot (level " loot_level ")")
    } else {
        LogWarning("Failed to pick up loot (level " loot_level ")")
        s_LK_Loot[hut_name][loot_level].Failed := s_LK_Loot[hut_name][loot_level].Failed + 1

        ; Take a picture of the scene before moving on
        Press("{Alt down}", 200)
        GetD2Bitmap(TempFile("Screenshot_LK_failed_to_pick_up_loot_run_" s_LK_Run_ID "_hut_" hut_name "_level_" loot_level ".bmp"))
        Press("{Alt up}", 0)

        if (loot_level = 1) {
            ; Play sound and wait so that a human can have the chance to interfere before moving on
            SoundPlay("sounds/Notification.aac", 1)
            Sleep(1000)
            SoundPlay("sounds/Notification.aac", 1)
        }
    }

    ; Have to restart anyways
    s_LK_Tasks.Clear()
    s_LK_Tasks.Append(LK_RestartInAct3)
}

/*
    Returns the number of transfered items.
*/
LK_TransferLootToCube() {
    cube_inventory_row := 1
    cube_inventory_col := 8

    transfered_items := 0
    callback(row, col, x, y) {
        if (!IsInventorySlotEmpty(, row, col)) {
            ClickOrMoveToInventorySlot(row, col, "Left")
            ClickOrMoveToInventorySlot(cube_inventory_row, cube_inventory_col, "Left")
            transfered_items := transfered_items + 1
        }
    }
    ForEachInventorySlot(callback, 2, 8, 3, 2)

    return transfered_items
}

LK_WaypointRecoveryIfNeeded() {
    confidence := LK_DetectWaypointAndRecover()
    if (confidence < 0.5) {
        ; Failed to recover
        Log("Failed to recover to waypoint. Restarting in Act 3.")
        s_LK_Tasks.Clear()
        s_LK_Tasks.Append(LK_RestartInAct3)
    }
}
