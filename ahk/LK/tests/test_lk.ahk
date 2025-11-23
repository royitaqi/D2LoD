#Requires AutoHotkey v2.0.0

Test_LK()
{
    Test_LK_Loot()
    ;Test_LK_Waypoint()
}
Test_LK_Waypoint()
{
    Test(file)
    {
        bitmap := Gdip_CreateBitmapFromFile("LK/tests/" file)
        Say(file " loaded")

        start := A_TickCount
        confidence := LK_DetectWaypointAndRecover(bitmap, recover := 0)
        time := A_TickCount - start
        Say("New: " confidence " (" time ")")

        ;start := A_TickCount
        ;confidence := LK_DetectWaypointAndRecover_Old(bitmap, recover := 0)
        ;time := A_TickCount - start
        ;Say("Old: " confidence " (" time ")")
    }

    Test("Test_LK_WayPoint_FarAbove_Night.jpg")
    Test("Test_LK_WayPoint_FarAbove_Night2.jpg")
    Test("Test_LK_WayPoint_FarAbove_NightRain.jpg")
    Test("Test_LK_WayPoint_FarBelow_Day.jpg")
    Test("Test_LK_WayPoint_FarBelow_Night.jpg") ; failing test
    Test("Test_LK_WayPoint_FarBelow_Night2.jpg") ; failing test
    Test("Test_LK_WayPoint_FarLeft_Day.jpg")
    Test("Test_LK_WayPoint_FarRight_Day.jpg")
    Test("Test_LK_WayPoint_MediumBottomLeft_Day.jpg")
    Test("Test_LK_WayPoint_MediumBottomLeft_Night.jpg")
    Test("Test_LK_WayPoint_RightAbove_Day.jpg")
    Test("Test_LK_WayPoint_RightAbove_Night.jpg")
    Test("Test_LK_WayPoint_RightBelow_Day.jpg")
    Test("Test_LK_WayPoint_RightBelow_Night.jpg")
}
