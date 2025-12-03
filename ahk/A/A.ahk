#Requires AutoHotkey v2.0.0


A_Main() {
    SetPlayers(3)
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
