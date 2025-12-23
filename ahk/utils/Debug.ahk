#include Log.ahk


Assert(expr, msg := "Assertion failed", log_level := s_Error, backtrack_level := -1)
{
    if (!expr) {
        Log(msg, ToFile, log_level)
        ; -1 makes AHK show the calling function instead of this function
        throw Error(msg, backtrack_level)
    }
    return expr
}

AssertEqual(actual, expected, msg := "Values should equal", log_level := s_Error, backtrack_level := -1) {
    Assert(actual = expected, msg " (expected " ToString(expected) ", actually " ToString(actual) ")", log_level, backtrack_level - 1)
    return actual
}

AssertTrue(expr, msg := "Value should be true", log_level := s_Error, backtrack_level := -1) {
    expr := not not expr
    Assert(expr = true, msg " (expected 1, actually " ToString(expr) ")", log_level, backtrack_level - 1)
    return expr
}

AssertFalse(expr, msg := "Value should be false", log_level := s_Error, backtrack_level := -1) {
    expr := not not expr
    Assert(expr = false, msg " (expected 0, actually " ToString(expr) ")", log_level, backtrack_level - 1)
    return expr
}

AssertNoError(expr, msg := "Value should not be Error", log_level := s_Error, backtrack_level := -1) {
    Assert(!IsError(expr), msg " (expected not Error, actually " ToString(expr) ")", log_level, backtrack_level - 1)
    return expr
}

AssertError(expr, expected_msg, msg := "Value should be Error", log_level := s_Error, backtrack_level := -1) {
    AssertTrue(IsError(expr), msg " (expected Error, actually " ToString(expr) ")", log_level, backtrack_level - 1)
    AssertEqual(expr.message, expected_msg, msg " (expected Error, actually " ToString(expr) ")", log_level, backtrack_level - 1)
    return expr
}

CatchReturn(func) {
    try {
        return func.Call()
    } catch Error as err {
        return err
    }
}

/* Test mouse position */
TestMousePosition()
{
    MouseGetPos &xpos, &ypos
    Log("The cursor is at X=" xpos " Y=" ypos)
}

/* Test pixel color at current mouse position + (-10,-10) */
TestPixelColor()
{
    MouseGetPos &xpos, &ypos

    CountDown("Will test pixel in ...")

    bitmap := GetD2BitMap()
    color := GetPixelColorInHex(bitmap, xpos, ypos)
    Log("The color at X=" xpos " Y=" ypos " is 0x" color)
}

TakeScreenShot() {
    i := 1
    while (FileExist(filename := "tmp/Screenshot" Format("{:03u}", i) ".bmp")) {
        i := i + 1
    }
    
    CountDown("Will take screenshot in ...")

    GetD2BitMap(filename)
    Log("Screenshot saved to " filename)
}

DumpLevelBitmap() {
    d2bitmap1 := GetD2BitMap()

    s := "`n"
    y := 0
    while (y <= s_Level_Y) {
        s := s "        ["
        x := s_Level_X
        while (x <= s_Max_X) {
            color := GetPixelColorInRGB(d2bitmap1, x, y)
            if (color = 0x99895B) {
                color := "0x99895B"
            } else {
                color := "0x000000"
            }
            if (x != s_Level_X) {
                s := s ","
            }
            s := s color
            x := x + 1
        }
        s := s "],`n"
        y := y + 1
    }
    Log(s, ToFile)
}

CountDown(msg) {
    Log(msg)
    countdown := 3
    loop 3
    {
        Log(countdown)
        Sleep(1000)
        countdown := countdown - 1
    }
}

TempFile(file) {
    return "tmp/" FormatTime(A_Now, "yyyyMMdd_HHmmss") "_" file
}

TempFileOverwrite(file) {
    return "tmp/" file
}

TimeIt(func) {
    start := A_TickCount
    func.Call()
    return A_TickCount - start
}
