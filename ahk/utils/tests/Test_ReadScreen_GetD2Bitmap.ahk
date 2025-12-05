#Requires AutoHotkey v2.0.0

#include ../../data_structure/Memory.ahk

#include ../Loot.ahk
#include ../ReadScreen.ahk
#include ../Script.ahk
#include ../UnitTest.ahk


Test_ReadScreen_GetD2Bitmap_MemoryLeak() {
    SetTitleMatchMode(1)
    try {
        WinActivate("Diablo II")
    }
    catch Error {
        throw "This test requires Diablo II to be running. It's because the test need to capture screen from the game."
    }

    before := GlobalMemoryStatusEx()
    n := 2000
    valid_bitmap_count := 0
    loop n {
        d2bitmap := GetD2Bitmap()
        if (d2bitmap.val) {
            valid_bitmap_count := valid_bitmap_count + 1
        }
    }
    after := GlobalMemoryStatusEx()
    Assert(valid_bitmap_count = n, "All bitmaps should be valid")

    mem_used := after.MemoryLoad - before.MemoryLoad
    Assert(mem_used <= 2, "This test shouldn't use more than 1% of memory (actually used " mem_used "%, from " before.MemoryLoad "% to " after.MemoryLoad "%)")
}
DoNotMockD2Bitmaps(() => RunTest(Test_ReadScreen_GetD2Bitmap_MemoryLeak))

ReportPass("Test_ReadScreen_GetD2Bitmap.ahk")
