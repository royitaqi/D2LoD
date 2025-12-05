#Requires AutoHotkey v2.0.0

; Include all actual implementations first, so that the following mock happens last, so that they always override the function handles.
#include KeyboardAndMouse.ahk
#include ReadScreen.ahk


s_Tests_Ran := []
s_Mocked_D2Bitmaps := []

ClickOrMove := Noop
Press := Noop
ClearMouse := Noop
ClickOrMove2 := Noop

GetD2Bitmap := MockedGetD2Bitmap

Noop(args*) {
}

MockedGetD2Bitmap(args*) {
    global s_Mocked_D2Bitmaps
    Assert(s_Mocked_D2Bitmaps.Length >= 1, "Not enough mocked bitmaps")
    d2bitmap := s_Mocked_D2Bitmaps.RemoveAt(1)
    
    global s_Last_D2Bitmap
    s_Last_D2Bitmap := d2bitmap
    
    return d2bitmap
}

MockD2Bitmaps(files*) {
    global s_Mocked_D2Bitmaps
    Assert(s_Mocked_D2Bitmaps.Length = 0, "Leftover bitmaps detected: " s_Mocked_D2Bitmaps.Length)
    for file in files {
        bitmap := Gdip_CreateBitmapFromFile(file)
        Assert(bitmap, "Cannot load test bitmap from file: " file)
        s_Mocked_D2Bitmaps.Push(D2Bitmap(bitmap))
    }
}

DoNotMockD2Bitmaps(test) {
    global GetD2Bitmap
    GetD2Bitmap := GetD2BitmapImpl
    test.Call()
    GetD2Bitmap := MockedGetD2Bitmap
}

RunTest(test) {
    global s_Tests_Ran, s_Mocked_D2Bitmaps

    time := TimeIt(() => test.Call())
    s_Tests_Ran.Push("[" time "] " test.Name)

    Assert(s_Mocked_D2Bitmaps.Length = 0, "Leftover bitmaps detected: " s_Mocked_D2Bitmaps.Length)
}

ReportPass(scriptname) {
    global s_Tests_Ran
    if (IsMainScript(scriptname)) {
        result := "Ran tests:`n"
        for test in s_Tests_Ran {
            result := result "- " test "`n"
        }
        result := result "`nTotally " s_Tests_Ran.Length " tests ran. All tests passed."
        MsgBox result
    }
}
