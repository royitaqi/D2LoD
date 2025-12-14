#Requires AutoHotkey v2.0.0

#include ../Loot.ahk
#include ../ReadScreen.ahk
#include ../UnitTest.ahk


Test_ReadScreen_GridPattern_PurpleRing_HappyPath() {
    MockD2Bitmaps(
        "Test_PurpleRing.bmp",
    )

    d2bitmap := GetD2Bitmap()
    found := GridPattern(
        DetectColorCallback([[d2bitmap, true]], s_Purple_Text, 0),
        , , , s_Hud_Y, , 7,
        &match_x, &match_y
    )
    AssertTrue(found, "Should find purple ring")
    AssertEqual(match_x, 585, "Should find the match at specific X")
    AssertEqual(match_y, 224, "Should find the match at specific Y")
}
RunTest(Test_ReadScreen_GridPattern_PurpleRing_HappyPath)

Test_ReadScreen_GridPattern_PurpleRing_TooLargeYStride() {
    MockD2Bitmaps(
        "Test_PurpleRing.bmp",
    )

    d2bitmap := GetD2Bitmap()

    found := GridPattern(
        DetectColorCallback([[d2bitmap, true]], s_Purple_Text, 0),
        , 8, , s_Hud_Y, , 10,
        &match_x, &match_y
    )
    AssertFalse(found, "Should not find purple ring")

    found := GridPattern(
        DetectColorCallback([[d2bitmap, true]], s_Purple_Text, 0),
        , , , s_Hud_Y, , 10,
        &match_x, &match_y
    )
    AssertTrue(found, "Should find purple ring")
    AssertEqual(match_x, 582, "Should find the match at specific X")
    AssertEqual(match_y, 220, "Should find the match at specific Y")
}
RunTest(Test_ReadScreen_GridPattern_PurpleRing_TooLargeYStride)

Test_ReadScreen_GridPattern_TwoLoot() {
    MockD2Bitmaps(
        "Test_TwoPurpleLoot.bmp",
    )

    d2bitmap := GetD2Bitmap()
    found := GridPattern(
        DetectColorCallback([[d2bitmap, true]], s_Purple_Text, 0),
        , , , s_Hud_Y, , 7,
        &match_x, &match_y
    )
    AssertTrue(found, "Should find purple ring")
    ; Since the grid pattern goes from small X to big X at higher level,
    ; the left most loot will be found first, in this case, the purple "Ring".
    AssertEqual(match_x, 588, "Should find the match at specific X")
    AssertEqual(match_y, 280, "Should find the match at specific Y")
}
RunTest(Test_ReadScreen_GridPattern_TwoLoot)

ReportPass("Test_ReadScreen_GridPattern.ahk")
