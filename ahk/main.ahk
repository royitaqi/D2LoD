#Requires AutoHotkey v2.0.0

#HotIf WinActive("Diablo II")

SetTitleMatchMode(1)
SetDefaultMouseSpeed(0)
CoordMode("Mouse", "Client")
CoordMode("Pixel", "Client")

#include utils/Cube.ahk
#include utils/Debug.ahk
#include utils/Inventory.ahk
#include utils/KeyboardAndMouse.ahk
#include utils/Log.ahk
#include utils/ReadScreen.ahk
#include utils/SaveAndLoad.ahk
#include utils/Script.ahk
#include utils/Stash.ahk

#include LK/LK.ahk

#include P/P.ahk

#include AdvancedMode.ahk
#include HoradricStack.ahk
#include QuickCast.ahk
#include SetPlayers.ahk
