#Requires AutoHotkey v2.0.0

#include ../Hireling.ahk
#include ../UnitTest.ahk


Test_Hireling_CheckHirelingAlive() {
    MockD2Bitmaps(
        "Test_TorchInTextArea2.bmp",
        "Test_HealthLow.bmp",
        "Test_HirelingAzrael.bmp",
        "Test_HirelingHealthYellow.bmp",
        "Test_HirelingHealthRed.bmp",
        "Test_HirelingDead.bmp",
    )
    AssertTrue(CheckHirelingAlive(), "Should detect that hireling is alive")
    AssertTrue(CheckHirelingAlive(), "Should detect that a different hireling is alive")
    AssertTrue(CheckHirelingAlive(), "Should detect that hireling is alive in a different act")
    AssertTrue(CheckHirelingAlive(), "Should detect that hireling is alive (even though yellow health)")
    AssertTrue(CheckHirelingAlive(), "Should detect that hireling is alive (even though red health)")
    AssertFalse(CheckHirelingAlive(), "Should detect that hireling is dead")
}
RunTest(Test_Hireling_CheckHirelingAlive)

Test_Hireling_CheckHirelingHealth() {
    MockD2Bitmaps(
        "Test_TorchInTextArea2.bmp",
        "Test_HealthLow.bmp",
        "Test_HirelingAzrael.bmp",
        "Test_HirelingHealthYellow.bmp",
        "Test_HirelingHealthRed.bmp",
        "Test_HirelingDead.bmp",
    )
    AssertEqual(CheckHirelingHealth(), 3, "Should detect that hireling has green health")
    AssertEqual(CheckHirelingHealth(), 3, "Should detect that a different hireling has green health")
    AssertEqual(CheckHirelingHealth(), 3, "Should detect that hireling has green health in a different act")
    AssertEqual(CheckHirelingHealth(), 2, "Should detect that hireling has yellow health")
    AssertEqual(CheckHirelingHealth(), 1, "Should detect that hireling has red health")
    AssertEqual(CheckHirelingHealth(), 0, "Should detect that hireling is dead")
}
RunTest(Test_Hireling_CheckHirelingHealth)

ReportPass("Test_Hireling.ahk")
