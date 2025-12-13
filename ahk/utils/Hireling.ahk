CheckHirelingAlive() {
    /*
        ~~If the hireling is alive, their name should be white.~~
        > The color at X=35 Y=68 is 0xC4C4C4

        ~~If the hireling is alive, their portrait should have a brown frame.~~
        > 16 19 0x786634
    */
    ;d2bitmap := GetD2Bitmap()
    ;return GetPixelColorInRGB(d2bitmap, 16, 19) = 0x786634

    return CheckHirelingHealth() > 0
}

/*
    Returns 3 if hireling health is green, 2 if yellow, 1 if red, 0 if not found.
*/
CheckHirelingHealth() {
    d2bitmap := GetD2Bitmap()

    x_min := 15
    x_max := 60
    y := 18
    green := 0x186408
    yellow := 0xD08420
    red := 0xFC2C00
    
    color := GetPixelColorInRGB(d2bitmap, x_min, y)
    switch (color) {
        case green: return 3
        case yellow: return 2
        case red: return 1
        default: return 0
    }
}
