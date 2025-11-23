#Requires AutoHotkey v2.0.0

#include ../Loot.ahk
#include ../ReadScreen.ahk
#include ../Script.ahk
#include ../UnitTest.ahk


Test_Loot_DetectLootByText_LinesCharsLootLevel() {
    MockD2Bitmaps(
        "Test_Loot_DetectLootByText_Line6PurpleOrange.bmp",
        "Test_Loot_DetectLootByText_Line6PurpleOrange.bmp",
        "Test_Loot_DetectLootByText_Line6PurpleOrange.bmp",
        "Test_Loot_DetectLootByText_Line6PurpleOrange.bmp",
        "Test_Loot_DetectLootByText_Line6PurpleOrange.bmp",
        "Test_Loot_DetectLootByText_Line6PurpleOrange.bmp",
    )
    Assert(DetectLootByText(, 5, 1, 1) = 0, "Should not detect loot")
    Assert(DetectLootByText(, 6, 1, 1) = 0, "Should not detect loot")
    Assert(DetectLootByText(, 6, 12, 1) = 1, "Should detect purple loot")
    Assert(DetectLootByText(, 5, 1, 2) = 0, "Should not detect loot")
    Assert(DetectLootByText(, 6, 1, 2) = 2, "Should detect orange loot")
    Assert(DetectLootByText(, 6, 12, 2) = 2, "Should detect orange loot")
}
RunTest(Test_Loot_DetectLootByText_LinesCharsLootLevel)

Test_Loot_DetectLootByText_FalsePositives() {
    MockD2Bitmaps(
        "Test_TorchInTextArea.bmp",
        "Test_TorchInTextArea2.bmp",
        "Test_EnemyInTextArea.bmp",
    )
    Assert(DetectLootByText() = 0, "Should not detect loot")
    Assert(DetectLootByText() = 0, "Should not detect loot")
    Assert(DetectLootByText() = 0, "Should not detect loot")
}
RunTest(Test_Loot_DetectLootByText_FalsePositives)

ReportPass("Test_Loot_DetectLootByText.ahk")
