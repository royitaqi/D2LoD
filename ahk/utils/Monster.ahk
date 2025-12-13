#include ReadScreen.ahk


/*
    Blood marble
    > The color at X=732 Y=166 is 0x61160E
*/
DetectBloodMarbleInRect() {
    throw "Not implemented"
}

DetectBossInMinimap(bitmap := 0) {
    /*
        > The color at X=270 Y=314 is 0x18FC00
    */
    return DetectColorInMinimap(bitmap, s_Boss_Minimap_Color, 0)
}
