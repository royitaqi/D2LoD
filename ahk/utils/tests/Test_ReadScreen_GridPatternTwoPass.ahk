#Requires AutoHotkey v2.0.0

#include ../ReadScreen.ahk
#include ../UnitTest.ahk


Test_ReadScreen_GridPatternTwoPass_CatacampsLevel3Stairs() {
    MockD2Bitmaps(
        "Test_CatacombsLevel3_StairsToLevel4.bmp",
    )

    d2bitmap := GetD2Bitmap()
    found := GridPatternTwoPass(
        DetectColorCallback([[d2bitmap, true]], 0xFFDB60, 0x20),
        DetectColorCallback([[d2bitmap, true]], 0xFFDB60, 0),
        70, 70, , s_Hud_Y, 6, 6,
        &match_x, &match_y
    )
    AssertTrue(found, "Should find stair torch")
}
RunTest(Test_ReadScreen_GridPatternTwoPass_CatacampsLevel3Stairs)

ReportPass("Test_ReadScreen_GridPatternTwoPass.ahk")
