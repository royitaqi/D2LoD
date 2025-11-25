#include ../data_structure/Types.ahk


IsD2Active() {
    return WinActive("Diablo II")
}


s_D2_Folder := nil

GetD2Folder() {
    global s_D2_Folder
    if (!s_D2_Folder) {
        if (FileExist("D:/Battle.net/Diablo II/Game.exe")) {
            s_D2_Folder := "D:/Battle.net/Diablo II/"
        } else if (FileExist("C:/Diablo II/Game.exe")) {
            s_D2_Folder := "C:/Diablo II/"
        } else {
            Assert(false, "Should find Game.exe")
        }
    }
    return s_D2_Folder
}


/*
    src_file: BH.cfg
    src_file: BH(LK).cfg

    Returns the level of reload required:
    0 = don't need reload
    1 = need to reload via {Backspace}
    2 = need to restart game
*/
ApplyFile(src_file, dest_file := nil) {
    if (!dest_file) {
        dest_file := src_file
    }

    src_path := "../" src_file
    dest_path := GetD2Folder() dest_file
    Assert(FileExist(src_path), "File [" src_path "] should exist")

    if (FileExist(dest_path)) {
        LogVerbose("Comparing content of [" src_path "] and [" dest_path "]")
        src_content := FileRead(src_path)
        dest_content := FileRead(dest_path)
        If (StrCompare(src_content, dest_content) = 0) {
            LogVerbose("Same. Skipping copy and reload.")
            return 0
        }
    }

    LogVerbose("Copying [" src_path "] into [" dest_path "]")
    FileCopy(src_path, dest_path, 1)

    if (SubStr(src_file, 1, 5) = "data/") {
        return 2
    } else if (SubStr(src_file, 1, 7) = "BaseMod") {
        return 2
    } else if (SubStr(src_file, 1, 5) = "PlugY") {
        return 2
    } else if (SubStr(src_file, 1, 2) = "BH") {
        return 1
    } else {
        Assert(false, "Unsupported file [" src_file "]")
    }
}

ApplyFiles(files*) {
    reload_level := 0
    for _, item in files {
        if (IsArray(item)) {
            ret := ApplyFile(item[1], item[2])
            reload_level := Max(reload_level, ret)
        } else if (IsString(item)) {
            ret := ApplyFile(item, item)
            reload_level := Max(reload_level, ret)
        } else {
            Assert(false, "Unsupported input type " ToString(item))
        }
    }

    if (reload_level = 1) {
        LogVerbose("Some files have been updated. Reloading files in game.")
        Send "{Backspace}"
        Sleep 1000
    } else if (reload_level = 2) {
        StopScript("Some files have been updated. Restarting the game is required.", true, false)
    } else if (reload_level = 0) {
        LogVerbose("No reloading is needed")
    } else {
        Assert(false, "Unsupported reload level " reload_level)
    }

    CountDown("Will start in ...")
}
