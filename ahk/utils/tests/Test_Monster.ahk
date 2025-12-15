#Requires AutoHotkey v2.0.0

#include ../Monster.ahk
#include ../UnitTest.ahk


Test_Monster_Andarial() {
    MockD2Bitmaps(
        "Test_Andarial.bmp",
        "Test_Andarial2.bmp",
        "Test_PurpleRing.bmp",
    )
    AssertTrue(DetectAndarial(nil), "Should detect Andarial")
    AssertTrue(DetectAndarial(nil), "Should detect Andarial from a different image")
    AssertFalse(DetectAndarial(nil), "Should not detect Andarial when she isn't there")
}
RunTest(Test_Monster_Andarial)

ReportPass("Test_Monster.ahk")
