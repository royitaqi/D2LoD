#Requires AutoHotkey v2.0.0

#include ../Loot.ahk
#include ../Script.ahk
#include ../UnitTest.ahk


Test_Loot_PickUpLootOnGround_1() {
    MockD2Bitmaps(
        "Test_Loot_PickUpLootOnGround_NoAlt.bmp",
        "Test_Loot_PickUpLootOnGround_HoldAlt.bmp",
    )
    AssertTrue(PickUpLootOnGround(), "Should be able to detect orange loot")
}
RunTest(Test_Loot_PickUpLootOnGround_1)

Test_Loot_PickUpLootOnGround_2() {
    MockD2Bitmaps(
        "Test_Loot_PickUpLootOnGround_NoAlt.bmp",
        "Test_Loot_PickUpLootOnGround_HoldAlt.bmp",
    )
    AssertTrue(PickUpLootOnGround(1), "Should be able to detect purple loot")
}
RunTest(Test_Loot_PickUpLootOnGround_2)

Test_Loot_PickUpLootOnGround_3() {
    MockD2Bitmaps(
        "Test_Loot_PickUpLootOnGround_Test3_NoAlt.bmp",
        "Test_Loot_PickUpLootOnGround_Test3_HoldAlt.bmp",
    )
    AssertTrue(PickUpLootOnGround(2, 1000), "Should be able to detect loot")
}
RunTest(Test_Loot_PickUpLootOnGround_3)

ReportPass("Test_Loot_PickUpLootOnGround.ahk")
