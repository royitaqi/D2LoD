#include ../gdip/Gdip_All.ahk
#include ../gdip/Gdip_Toolbox.ahk
pToken := Gdip_Startup()

#include ../data_structure/Disposable.ahk
#include ../data_structure/Types.ahk

#include Debug.ahk


s_Max_X := 1068
s_Max_Y := 600
s_Hud_Y := 550
s_Level_X := 900
s_Level_Y := 30

s_Boss_Minimap_Color := 0x18FC00

s_Last_D2Bitmap := nil

GetD2Bitmap := GetD2BitmapImpl
GetD2BitmapImpl(save_to_file := "")
{
    ; Get the active game window's handle
    hwnd := WinGetID("Diablo II")

    ; Capture a screenshot of the window
    bitmap := Gdip_BitmapFromHWND(hwnd, 1)

    ; Create the disposable D2Bitmap object
    global s_Last_D2Bitmap
    s_Last_D2Bitmap := D2Bitmap(bitmap)

    ; Save the bitmap to a file if asked
    if (save_to_file) {
        SaveD2Bitmap(s_Last_D2Bitmap, save_to_file)
    }

    return s_Last_D2Bitmap
}

GetLastD2Bitmap() {
    global s_Last_D2Bitmap
    return s_Last_D2Bitmap
}

class D2Bitmap extends Disposable {
    __New(bitmap) {
        super.__New(
            bitmap,
            Gdip_DisposeImage,
            (bitmap) => Assert(bitmap, "D2Bitmap should be constructured with an actual bitmap"),
        )
    }
}

SaveD2Bitmap(d2bitmap, file) {
    Gdip_SaveBitmapToFile(d2bitmap.val, file)
}

LoadD2Bitmap(file) {
    return D2Bitmap(Gdip_CreateBitmapFromFile(file))
}

ARGB2RGB(argb, &r, &g, &b)
{
    r := Gdip_RFromARGB(argb)
    g := Gdip_GFromARGB(argb)
    b := Gdip_BFromARGB(argb)
}

RGB2Hex(r, g, b)
{
    return Format("{:02X}{:02X}{:02X}", r, g, b)
}

ARGB2Hex(argb) {
    ARGB2RGB(argb, &r, &g, &b)
    return RGB2Hex(r, g, b)
}

GetPixelColorInRGB(d2bitmap, x, y)
{
    argb := Gdip_GetPixel(d2bitmap.val, x, y)
    return argb & 0xffffff
}

GetPixelColorInHex(d2bitmap, x, y)
{
    ; Get the color of the pixel at the coordinates
    rgb := GetPixelColorInRGB(d2bitmap, x, y)

    ; Convert the ARGB color to a hex value
    ARGB2RGB(rgb, &r, &g, &b)
    return RGB2Hex(r, g, b)
}

RGBAreClose(r1, g1, b1, r2, g2, b2, variation) {
    return r1 >= r2 - variation
        && r1 <= r2 + variation
        && g1 >= g2 - variation
        && g1 <= g2 + variation
        && b1 >= b2 - variation
        && b1 <= b2 + variation
}

DetectPixelColor(d2bitmap, x, y, r1, g1, b1, variation1 := 0, r2 := 0, g2 := 0, b2 := 0, variation2 := 0) {
    Assert(d2bitmap, "d2bitmap should have value")

    argb := Gdip_GetPixel(d2bitmap.val, x, y)
    ARGB2RGB(argb, &r, &g, &b)

    if (IsLogLevelTedious()) {
        hex := RGB2Hex(r, g, b)
        LogTedious("DetectPixelColor(): X=" x " Y=" y " color=0x" hex)
    }

    ; Check if the color of the pixel is within range of any input colors
    if (RGBAreClose(r, g, b, r1, g1, b1, variation1)) {
        match_x := x
        match_y := y
        return 1
    }
    if ((r2 || g2 || b2) && RGBAreClose(r, g, b, r2, g2, b2, variation2)) {
        match_x := x
        match_y := y
        return 2
    }
    return 0
}

DetectPixelColorInRect(d2bitmap, x1, y1, x2, y2, color1, variation1 := 0, color2 := 0, variation2 := 0, &match_x := 0, &match_y := 0) {
    Assert(d2bitmap, "d2bitmap should have value")

    ARGB2RGB(color1, &r1, &g1, &b1)
    r2 := g2 := b2 := 0
    if (color2) {
        ARGB2RGB(color2, &r2, &g2, &b2)
    }

    x := x1
    loop x2 - x1 + 1
    {
        y := y1
        loop y2 - y1 + 1
        {
            match := DetectPixelColor(d2bitmap, x, y, r1, g1, b1, variation1, r2, g2, b2, variation2)
            if (match) {
                match_x := x
                match_y := y
                return match
            }
            y := y + 1
        }
        x := x + 1
    }
    return 0
}
/*
    Returns 1 or 2 if the corresponding color is detected. Otherwise return 0.
*/
DetectPixelColorInRect2(d2bitmap, x1, y1, x2, y2, color1, variation1 := 0, color2 := 0, variation2 := 0, &match_x := 0, &match_y := 0) {
    ret := RectanglePattern(DetectColorCallback([[d2bitmap, true]], color1, variation1, color2, variation2), x1, y1, x2, y2, &match_x, &match_y)
    if (ret) {
        return ret[1]
    } else {
        return 0
    }
}

DetectPixelColorInVerticalLine(d2bitmap, x, y1, y2, color1, variation1 := 0, color2 := 0, variation2 := 0, &match_x := 0, &match_y := 0) {
    Assert(d2bitmap, "bitmad2bitmapp should have value")

    ARGB2RGB(color1, &r1, &g1, &b1)
    if (color2) {
        ARGB2RGB(color2, &r2, &g2, &b2)
    }

    y := y1
    loop y2 - y1 + 1
    {
        match := DetectPixelColor(d2bitmap, x, y, r1, g1, b1, variation1, r2, g2, b2, variation2)
        if (match) {
            match_x := x
            match_y := y
            return match
        }
        y := y + 1
    }
    return 0
}

DetectColoredText(d2bitmap, lines, color1, variation1 := 0, color2 := 0, variation2 := 0) {
    x1 := 16
    y1 := 84
    ; Magic number. The width to look for.
    x2 := x1 + 8
    ; Each line is 9 pixels tall. Gap between two lines is 6 pixels tall.
    y2 := y1 + 9 + 15 * (lines - 1)

    return DetectPixelColorInRect(d2bitmap, x1, y1, x2, y2, color1, variation1, color2, variation2)
}

/*
    Returns 1 if color1 is found in minimap, 2 if color2, 0 if none.
*/
DetectColorInMinimap(d2bitmap := 0, color1 := 0, variation1 := 0, color2 := 0, variation2 := 0) {
    if (!d2bitmap) {
        d2bitmap := GetD2Bitmap()
    }

    /*
        Orange loot.
        > The color at X=899 Y=174 is 0xE07020

        Purple loot.
        > The color at X=899 Y=174 is 0xA420FC

        Minimap area.
        > The cursor is at X=791 Y=126
        > The cursor is at X=1004 Y=244
        Rounded to:
        - 800, 125
        - 1000, 245

        Character is at:
        > The cursor is at X=900 Y=172
        Rounded to:
        - 900, 172~173

        Finally adjust the minimap area to:
        - 800, 125
        - 1000, 220

        --

        A smaller area is:
        > The cursor is at X=857 Y=155
        > The cursor is at X=936 Y=191

        Adjusted area is:
        - 865, 155
        - 935, 190

        This seems more symmetric around the character
        - 865, 150
        - 935, 190
    */
    return DetectPixelColorInRect2(d2bitmap, 865, 150, 935, 190, color1, variation1, color2, variation2)
}


/*
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    For all the patterns below:
    - Expect callback:
        ```
        callback(x, y) {
            ...
        }
        ```
    - Returns the first non-nil value the callback returns. Otherwise, returns nil.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/

/*
    Search through a grid of spots by both x_stride and y_stride
*/
GridPattern(callback, x1 := 0, y1 := 0, x2 := s_Max_X, y2 := s_Max_Y, x_stride := 1, y_stride := 1, &match_x := 0, &match_y := 0) {
    x := x1
    while (x <= x2) {
        y := y1
        while (y <= y2) {
            ret := callback(x, y)
            if (ret != nil) {
                match_x := x
                match_y := y
                return ret
            }
            y := y + y_stride
        }
        x := x + x_stride
    }
    return nil
}

/*
    Two pass approach:
    - Pass #1: Search through a grid of spots by both x_stride and y_stride.
    - Pass #2: For any spot that is found in pass 1, search pixel-by-pixel in the grid.

    Return any successful match returned by the pass2_callback.
*/
GridPatternTwoPass(pass1_callback, pass2_callback, x1 := 0, y1 := 0, x2 := s_Max_X, y2 := s_Max_Y, x_stride := 1, y_stride := 1, &match_x := 0, &match_y := 0) {
    ; Pass #1
    x := x1
    while (x <= x2) {
        y := y1
        while (y <= y2) {
            ret := pass1_callback(x, y)
            if (ret != nil) {

                ; Pass #2
                xx := max(x - x_stride // 2, x1)
                xx_max := min(xx + x_stride - 1, x2)
                while (xx <= xx_max) {
                    yy := max(y - y_stride // 2, y1)
                    yy_max := min(yy + y_stride - 1, y2)
                    while (yy <= yy_max) {
                        retret := pass2_callback(xx, yy)
                        if (retret != nil) {
                            match_x := xx
                            match_y := yy
                            return retret
                        }
                        yy := yy + 1
                    }
                    xx := xx + 1
                }
                ; End of Pass #2
                
            }
            y := y + y_stride
        }
        x := x + x_stride
    }
    return nil
}


VerticalStridePattern(callback, x_stride := 1, x1 := 0, y1 := 0, x2 := s_Max_X, y2 := s_Max_Y, &match_x := 0, &match_y := 0) {
    x := x1
    while (x <= x2) {
        y := y1
        while (y <= y2) {
            ret := callback(x, y)
            if (ret != nil) {
                match_x := x
                match_y := y
                return ret
            }
            y := y + 1
        }
        x := x + x_stride
    }
    return nil
}

RectanglePattern(callback, x1 := 0, y1 := 0, x2 := s_Max_X, y2 := s_Max_Y, &match_x := 0, &match_y := 0) {
    ; Rectangle pattern is just a vertical stride pattern with stride being 1
    return VerticalStridePattern(callback, 1, x1, y1, x2, y2, &match_x, &match_y)
}

/*
    Bitmap config is an array of pairs. Each pair is a bitmap and a boolean.
    The boolean indicates whether the color(s) should be detected in the bitmap or not.

    Returns a callback that can be given to one of the patterns in the above.
    
    When the callback is called with a (x, y) coordinate, it will return an array of integers.
    Each integer is the return value of DetectPixelColor() for the pixel on that coordinate in each of the bitmaps, respectively.
*/
DetectColorCallback(bitmap_config, color1 := 0, variation1 := 0, color2 := 0, variation2 := 0) {
    n := bitmap_config.Length
    for i, cfg in bitmap_config {
        Assert(cfg[1], "Bitmap [" i "] should have value")
    }

    ARGB2RGB(color1, &r1, &g1, &b1)
    r2 := g2 := b2 := 0
    if (color2) {
        ARGB2RGB(color2, &r2, &g2, &b2)
    }

    callback(x, y) {
        ret := []
        ret.Length := n
        for i, cfg in bitmap_config {
            d2bitmap := cfg[1]
            should_detect := cfg[2]
            ret[i] := DetectPixelColor(d2bitmap, x, y, r1, g1, b1, variation1, r2, g2, b2, variation2)
            if ((ret[i] != 0) != should_detect) {
                return nil
            }
        }
        return ret
    }
    return callback
}

/*
    Dump the wanted colors in a rectangle into a bitmap array in the log file.
    Unwanted colors are all wiped to 0x000000.
    If no wanted colors are specified, all non-zero colors are treated as wanted.
*/
DumpBitmapArray(d2bitmap, x1, y1, x2, y2, colors*) {
    if (!d2bitmap) {
        d2bitmap := GetD2Bitmap()
    }

    s := '`n'
    s .= "bitmap_array := {`n"
    s .= "    x1: " x1 ",`n"
    s .= "    y1: " y1 ",`n"
    s .= "    x2: " x2 ",`n"
    s .= "    y2: " y2 ",`n"
    s .= "    array: [`n"
    y := y1
    while (y <= y2) {
        s := s "        ["
        x := x1
        while (x <= x2) {
            color := GetPixelColorInRGB(d2bitmap, x, y)

            is_wanted := false
            if (colors.Length > 0) {
                for _, c in colors {
                    if (color == c) {
                        is_wanted := true
                        break
                    }
                }
            } else {
                is_wanted := color
            }

            if (is_wanted) {
                ARGB2RGB(color, &r, &g, &b)
                hex := RGB2Hex(r, g, b)
                color := "0x" hex
            } else {
                color := "0x000000"
            }
            if (x != x1) {
                s := s ","
            }
            s := s color
            x += 1
        }
        s := s "],`n"
        y += 1
    }
    s .= "    ],`n"
    s .= "}`n"
    Log(s, ToFile)
}

/*
    Confirm if the bitmap array exists in the given image.
*/
CheckBitmapArray(d2bitmap, bitmap_array) {
    if (!d2bitmap) {
        d2bitmap := GetD2Bitmap()
    }

    y := bitmap_array.y1
    i := 1
    while (y <= bitmap_array.y2) {
        x := bitmap_array.x1
        j := 1
        while (x <= bitmap_array.x2) {
            array_color := bitmap_array.array[i][j]
            if (array_color) {
                pixel_color := GetPixelColorInRGB(d2bitmap, x, y)
                if (pixel_color != array_color) {
                    return false
                }
            }
            x += 1
            j += 1
        }
        y += 1
        i += 1
    }
    return true
}
