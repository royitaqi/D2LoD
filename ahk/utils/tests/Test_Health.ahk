#Requires AutoHotkey v2.0.0

#include ../Health.ahk
#include ../UnitTest.ahk


Test_Health_CheckHealth() {
    VerifyHealth(expected_hp, expected_index, test_image_file) {
        MockD2Bitmaps(test_image_file)
        
        detected_hp := -1
        ret := CheckHealth(nil, [
            [0, () => detected_hp := 0],
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
    VerifyHealth(-1, 0, "Test_PurpleRing.bmp")
    VerifyHealth(100, 11, "Test_Health90%.bmp")
    VerifyHealth(90, 10, "Test_Health80%.bmp")
    VerifyHealth(80, 9, "Test_Health70%.bmp")
    VerifyHealth(70, 8, "Test_Health60%.bmp")
    VerifyHealth(60, 7, "Test_Health50%.bmp")
    VerifyHealth(50, 6, "Test_Health40%.bmp")
    VerifyHealth(40, 5, "Test_Health30%.bmp")
    VerifyHealth(30, 4, "Test_Health20%.bmp")
    VerifyHealth(20, 3, "Test_Health10%.bmp")
    VerifyHealth(10, 2, "Test_Health5%.bmp")

    ; Poinsoned HP
    VerifyHealth(50, 6, "Test_HealthLowPoisoned.bmp")
    VerifyHealth(-1, 0, "Test_HealthPoisoned.bmp")

    ; Dead
    VerifyHealth(0, 1, "Test_Health1.bmp")  ; Nearly dead
    VerifyHealth(0, 1, "Test_Dead.bmp")     ; Actually dead
}
RunTest(Test_Health_CheckHealth)

ReportPass("Test_Health.ahk")
