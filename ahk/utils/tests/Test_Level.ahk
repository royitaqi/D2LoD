#Requires AutoHotkey v2.0.0

#include ../Level.ahk
#include ../UnitTest.ahk


Test_Level_IsCurrentLevel() {
    MockD2Bitmaps(
        "Test_CatacombsLevel4.bmp",
        "Test_CatacombsLevel4.bmp",
    )
    AssertTrue(IsCurrentLevel("Catacombs Level 4"), "Should detect the correct level")
    AssertFalse(IsCurrentLevel("Rogue Encampment"), "Should detect the correct level")
    AssertError(CatchReturn(() => IsCurrentLevel("Catacombs Level 3")), "Level [Catacombs Level 3] should exist in s_Level_Bitmaps", "Should assertion fail because [Catacombs Level 3] isn't in s_Level_Bitmaps")
}
RunTest(Test_Level_IsCurrentLevel)

Test_Level_GetCurrentLevel() {
    MockD2Bitmaps(
        "Test_CatacombsLevel4.bmp",
    )
    AssertEqual(GetCurrentLevel(), "Catacombs Level 4", "Should detect the correct level")
}
RunTest(Test_Level_GetCurrentLevel)

ReportPass("Test_Level.ahk")
