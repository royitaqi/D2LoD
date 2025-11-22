IsD2Active() {
    return WinActive("Diablo II")
}


/*
    src_file: ../BH.cfg
    src_file: ../BH(LK).cfg
*/
ApplyBHCfg(src_file) {
    if (FileExist("D:/Battle.net/Diablo II/Game.exe")) {
        dest_file := "D:/Battle.net/Diablo II/BH.cfg"
    } else if (FileExist("C:/Diablo II/Game.exe")) {
        dest_file := "C:/Diablo II/BH.cfg"
    } else {
        Assert(false, "Should find Game.exe")
    }

    LogVerbose("Comparing content of [" src_file "] and [" dest_file "]")
    src_content := FileRead(src_file)
    dest_content := FileRead(dest_file)
    If (StrCompare(src_content, dest_content) = 0) {
        LogVerbose("Same. Skipping copy and reload.")
        return
    }

    ; Copy and reload BH.cfg
    LogVerbose("Copying [" src_file "] into [" dest_file "]")
    FileCopy(src_file, dest_file, 1)

    LogVerbose("Reloading BH.cfg in game")
    Send "{Backspace}"
    Sleep 1000
}
