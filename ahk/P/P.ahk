#Requires AutoHotkey v2.0.0

#include "../data_structure/Queue.ahk"
#include "../utils/D2.ahk"
#include "../utils/Health.ahk"
#include "../utils/Log.ahk"
#include "../utils/Loot.ahk"
#include "../utils/ReadScreen.ahk"
#include "../utils/SaveAndLoad.ahk"

#include "P_HealAndEnterRedPortal.ahk"
#include "P_TeleportToPindleAndKill.ahk"
#include "P_PickUpLoot.ahk"


s_P_Tasks := nil
s_P_Run_ID := nil
s_P_Loot := nil
s_P_Loot_Caught_by_Text := nil
s_P_Potions_Used := nil
s_P_Restarts := nil

P_Init() {
    global s_P_Tasks, s_P_Run_ID, s_P_Loot, s_P_Loot_Caught_by_Text, s_P_Potions_Used, s_P_Restarts
    s_P_Tasks := Queue()
    s_P_Run_ID := -1
    s_P_Loot := { Detected: 0, Looted: 0, Failed: 0 }
    s_P_Loot_Caught_by_Text := 0
    s_P_Potions_Used := 0
    s_P_Restarts := -1

    LogLevelVerbose()
    ClearLogFile()
    SetPlayers(1)
    ApplyBHCfg("../BH.cfg")
}

P_Main() {
    P_Init()
    RunForever(P_Start)
}

P_Start() {
    global s_P_Tasks, s_P_Restarts
    s_P_Restarts := s_P_Restarts + 1
    s_P_Tasks.Clear()
    s_P_Tasks.Append(P_SaveLoadAnnounce)
    P_Loop()
}

P_Loop() {
    global s_P_Tasks
    loop {
        task := s_P_Tasks.Pop()
        LogVerbose("Running task: " task.Name)
        task.Call()
    }
}

P_SaveLoadAnnounce() {
    s_P_Tasks.Append(SaveAndQuit)
    s_P_Tasks.Append(SinglePlayerChar1Hell)
    s_P_Tasks.Append(P_Announce)

    s_P_Tasks.Append(P_RunOnce)
}

P_RunOnce() {
    s_P_Tasks.Append(P_HealAndEnterRedPortal)
    s_P_Tasks.Append(P_TeleportToPindleAndKill)
    s_P_Tasks.Append(P_PickUpLoot)

    s_P_Tasks.Append(P_SaveLoadAnnounce)
}

P_EmergencyRestart() {
    s_P_Tasks.Clear()
    P_SaveLoadAnnounce()
}

P_Announce() {
    global s_P_Run_ID, s_P_Loot

    s_P_Run_ID := s_P_Run_ID + 1

    Log("Runs: " s_P_Run_ID
        "   |   P: " s_P_Loot.Detected "=>" s_P_Loot.Looted "-" s_P_Loot.Failed
            "   H: " s_P_Potions_Used
            "   T: " s_P_Loot_Caught_by_Text
            "   R: " s_P_Restarts
    )
}
