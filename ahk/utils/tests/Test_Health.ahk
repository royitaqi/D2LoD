#Requires AutoHotkey v2.0.0

#include ../Health.ahk
#include ../UnitTest.ahk


Test_Health_CheckHealth() {
    VerifyHealth(expected_hp, test_image_file) {
        MockD2Bitmaps(test_image_file)
        
        detected_hp := CheckHealth(nil, [
            [0, () => nil],
            [10, () => nil],
            [20, () => nil],
            [30, () => nil],
            [40, () => nil],
            [50, () => nil],
            [60, () => nil],
            [70, () => nil],
            [80, () => nil],
            [90, () => nil],
            [100, () => nil],
        ])
        AssertEqual(detected_hp, expected_hp, "Should detect the correct HP for " test_image_file)
    }

    ; Regular HP
    VerifyHealth(999, "Test_PurpleRing.bmp")
    VerifyHealth(100, "Test_Health90%.bmp")
    VerifyHealth(90,  "Test_Health80%.bmp")
    VerifyHealth(80, "Test_Health70%.bmp")
    VerifyHealth(70, "Test_Health60%.bmp")
    VerifyHealth(60, "Test_Health50%.bmp")
    VerifyHealth(50, "Test_Health40%.bmp")
    VerifyHealth(40, "Test_Health30%.bmp")
    VerifyHealth(30, "Test_Health20%.bmp")
    VerifyHealth(20, "Test_Health10%.bmp")
    VerifyHealth(10, "Test_Health5%.bmp")

    ; Poinsoned HP
    VerifyHealth(999, "Test_HealthPoisoned.bmp")
    VerifyHealth(80, "Test_HealthPoisoned73%.bmp")
    VerifyHealth(50, "Test_HealthLowPoisoned.bmp")

    ; Dead
    VerifyHealth(0, "Test_Health1.bmp")  ; Nearly dead
    VerifyHealth(0, "Test_Dead.bmp")     ; Actually dead
}
RunTest(Test_Health_CheckHealth)

ReportPass("Test_Health.ahk")
