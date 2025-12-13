#Requires AutoHotkey v2.0.0

#include A_GoToLevel.ahk
#include A_HealAndEnterWaypoint.ahk
#include A_PickUpLoot.ahk
#include A_TeleportToAndarialAndKill.ahk


s_A_Tasks := nil
s_A_Run_ID := nil
s_A_Loot := nil
s_A_Loot_Caught_by_Text := nil
s_A_Heal_Concerns := nil
s_A_Hires := nil
s_A_Restarts := nil

A_Init() {
    global s_A_Tasks, s_A_Run_ID, s_A_Loot, s_A_Heal_Concerns, s_A_Hires, s_A_Restarts
    s_A_Tasks := Queue()
    s_A_Run_ID := -1
    s_A_Loot := { Detected: 0, Looted: 0, Failed: 0 }
    s_A_Heal_Concerns := { Hero: 0, Merc: 0 }
    s_A_Hires := 0
    s_A_Restarts := -1

    LogLevelVerbose()
    ClearLogFile()
    SetPlayers(1)
    ApplyFiles(
        "BH.cfg",
        "BH_settings.cfg",
        "BaseMod.ini",
        "PlugY.ini",
        "data/global/excel/cubemain.txt",
        "data/global/excel/ItemStatCost.txt",
        "data/global/excel/misc.txt",
        "data/global/excel/Missiles.txt",
        "data/global/excel/Properties.txt",
        "data/global/excel/skills.txt",
        "data/global/items/invpk1.dc6",
        "data/global/items/invpk2.dc6",
        "data/global/items/invpk3.dc6",
        "data/global/tiles/expansion/Town/townWest.ds1",
        "data/local/LNG/ENG/patchstring.tbl",
    )
}

A_Main() {
    A_Init()
    RunForever(A_Start)
}

A_Start() {
    global s_A_Tasks, s_A_Restarts
    s_A_Restarts := s_A_Restarts + 1
    s_A_Tasks.Clear()
    s_A_Tasks.Append(A_SaveLoadAnnounce)
    A_Loop()
}

A_Loop() {
    global s_A_Tasks
    loop {
        task := s_A_Tasks.Pop()
        LogVerbose("Running task: " task.Name)
        task.Call()
    }
}

A_SaveLoadAnnounce() {
    s_A_Tasks.Append(SaveAndQuit)
    s_A_Tasks.Append(SinglePlayerChar1Hell)
    s_A_Tasks.Append(A_Announce)

    s_A_Tasks.Append(A_RunOnce)
}

A_RunOnce() {
    s_A_Tasks.Append(A_HealAndEnterWaypoint)
    s_A_Tasks.Append(A_GoToLevel)
    s_A_Tasks.Append(A_TeleportToAndarialAndKill)
    s_A_Tasks.Append(A_PickUpLoot)

    s_A_Tasks.Append(A_SaveLoadAnnounce)
}

A_EmergencyRestart() {
    s_A_Tasks.Clear()
    A_SaveLoadAnnounce()
}

A_Announce() {
    global s_A_Run_ID, s_A_Loot, s_A_Heal_Concerns, s_A_Hires, s_A_Restarts

    s_A_Run_ID := s_A_Run_ID + 1

    Log("Runs: " s_A_Run_ID
        "   |   P: " s_A_Loot.Detected "=>" s_A_Loot.Looted "-" s_A_Loot.Failed
            "   H: " s_A_Heal_Concerns.Hero "/" s_A_Heal_Concerns.Merc
            "   Hi: " s_A_Hires
            "   R: " s_A_Restarts
    )
}
