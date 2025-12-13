#Requires AutoHotkey v2.0.0

#include ../Health.ahk
#include ../UnitTest.ahk


Test_Health_CheckHealth() {
    VerifyHealth(expected_hp, expected_index, test_image_file) {
        MockD2Bitmaps(test_image_file)
        
        detected_hp := -1
        ret := CheckHealth(nil, [
            [10, () => detected_hp := 10],
            [20, () => detected_hp := 20],
            [30, () => detected_hp := 30],
            [40, () => detected_hp := 40],
            [50, () => detected_hp := 50],
            [60, () => detected_hp := 60],
            [70, () => detected_hp := 70],
            [80, () => detected_hp := 80],
            [90, () => detected_hp := 90],
            [100, () => detected_hp := 100],
        ])
        AssertEqual(detected_hp, expected_hp, "Should detect the correct HP for " test_image_file)
        AssertEqual(ret, expected_index, "Should return the correct strategy index for " test_image_file)
    }

    ; Regular HP
    VerifyHealth(-1, 0, "Test_MouseOnLoot.bmp")
    VerifyHealth(90, 9, "Test_TorchInTextArea2.bmp")
    VerifyHealth(40, 4, "Test_HealthLow.bmp")

    ; Poinsoned HP
    VerifyHealth(50, 5, "Test_HealthLowPoisoned.bmp")
    VerifyHealth(-1, 0, "Test_HealthPoisoned.bmp")
}
RunTest(Test_Health_CheckHealth)

ReportPass("Test_Health.ahk")
