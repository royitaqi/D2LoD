#include ../data_structure/Types.ahk


/*
    The strategy should be an array of health-percentage/action pairs. Each pair has two elements:
    - [1] Health percentage (10-90). If the actual health of the character is below this percentage, the following action will be taken.
    - [2] Action. If it's a number (1-4), it indicates which potion to use (1-4). If it's a function, it will be invoked.
    Note: The percentages will be checked in order. Lower health percentage pairs should always be put in front of higher health percentage pairs.

    Finds the first percentage that is NOT met. Takes the corresponding action and returns the index (start from 1; or 0 if no action is taken).
*/
CheckHealth(d2bitmap, strategy) {
    if (!d2bitmap) {
        d2bitmap := GetD2Bitmap()
    }

    /*
        The cursor is at X=70 Y=510 - 100%  - The color at X=70 Y=510 is 0x380804
        The cursor is at X=70 Y=518 - 90%   - The color at X=70 Y=518 is 0x5C0000
        The cursor is at X=70 Y=526 - 80%   - The color at X=70 Y=526 is 0x5C0000
        The cursor is at X=70 Y=534 - 70%   - The color at X=70 Y=534 is 0x5C0000
        The cursor is at X=70 Y=542 - 60%   - The color at X=70 Y=542 is 0x5C0000
        The cursor is at X=70 Y=550 - 50%   - The color at X=70 Y=550 is 0x5C0000
        The cursor is at X=70 Y=558 - 40%   - The color at X=70 Y=558 is 0x5C0000
        The cursor is at X=70 Y=566 - 30%   - The color at X=70 Y=566 is 0x5C0000
        The cursor is at X=70 Y=574 - 20%   - The color at X=70 Y=574 is 0x240000
        The cursor is at X=70 Y=582 - 10%   - The color at X=70 Y=582 is 0x080404
        The cursor is at X=70 Y=585 - 0%    - The color at X=70 Y=590 is 0x080404 vs. 0x101010
    */
    pixels := Map(
        110, Map("Y", 502, "Color", 0x5C0000, "PoisonedColor", 0x18480C, "EmptyColor", 0x000000), ; For test purpose only
        100, Map("Y", 508, "Color", 0x380804, "PoisonedColor", 0x18480C, "EmptyColor", 0x000000),
        90,  Map("Y", 518, "Color", 0x5C0000, "PoisonedColor", 0x18480C, "EmptyColor", 0x000000),
        80,  Map("Y", 526, "Color", 0x5C0000, "PoisonedColor", 0x18480C, "EmptyColor", 0x000000),
        70,  Map("Y", 534, "Color", 0x5C0000, "PoisonedColor", 0x18480C, "EmptyColor", 0x000000),
        60,  Map("Y", 542, "Color", 0x5C0000, "PoisonedColor", 0x18480C, "EmptyColor", 0x000000),
        50,  Map("Y", 550, "Color", 0x5C0000, "PoisonedColor", 0x18480C, "EmptyColor", 0x000000),
        40,  Map("Y", 558, "Color", 0x5C0000, "PoisonedColor", 0x18480C, "EmptyColor", 0x000000),
        30,  Map("Y", 566, "Color", 0x5C0000, "PoisonedColor", 0x042410, "EmptyColor", 0x000000),
        20,  Map("Y", 574, "Color", 0x240000, "PoisonedColor", 0x042410, "EmptyColor", 0x000000),
        10,  Map("Y", 582, "Color", 0x080404, "PoisonedColor", 0x040404, "EmptyColor", 0x101010),
        0,   Map("Y", 585, "Color", 0x080404, "PoisonedColor", 0x040404, "EmptyColor", 0x101010),
    )
    
    for i, pair in strategy {
        percentage := pair[1]
        action := pair[2]
        Assert(pixels.Has(percentage), "Given percentage (" percentage ") is not supported")

        pixel := pixels[percentage]
        y := pixel["Y"]
        color := pixel["Color"]
        poisoned_color := pixel["PoisonedColor"]

        pixel_color := GetPixelColorInRGB(d2bitmap, 70, y)
        is_health_below_percentage := (pixel_color != color && pixel_color != poisoned_color)

        if (is_health_below_percentage) {
            msg := "Health is lower than " percentage "%."
            if (IsInteger(action)) {
                Press("" action "")
                Log(msg " Potion [" action "] used.")
            }
            else if (IsFunction(action)) {
                action.Call()
                Log(msg " Action [" action.Name "] taken.")
            }
            else {
                Log(msg " No action taken.")
            }
            return i
        }

        i := i + 1
    }
    return 0
}
