#include ../data_structure/Types.ahk


s_Premove_Delay := 200
s_Click_Delay := 100
s_Press_Delay := 100
s_Cast_Delay := 400
s_Blink_Delay := 400
s_Pick_Delay := 50

ClickOrMove := ClickOrMoveImplViaControl
ClickOrMoveImpl(x, y, button := "", delay := 100)
{
    if (button != "") {
        Click x, y, button
    } else {
        MouseMove x, y
    }
    if (delay != 0) {
        Sleep delay
    }
}
ClickOrMoveImplViaControl(x, y, button := nil, delay := 100)
{
    if (button) {
        ControlClick "X" x " Y" y, , , button, , "Pos"
    } else {
        ControlClick "X" x " Y" y, , , "Middle", , "Pos"
    }
    if (delay != 0) {
        Sleep delay
    }
}

Press := PressImplViaControl
PressImpl(key, delay := s_Press_Delay)
{
    Send key
    if (delay != 0) {
        Sleep delay
    }
}
PressImplViaControl(key, delay := s_Press_Delay)
{
    ControlSend key
    if (delay != 0) {
        Sleep delay
    }
}

ClearMouse := ClearMouseImpl
ClearMouseImpl(delay := 0, x := s_Max_X - 1, y := 1) {
    ; Move mouse to top right corner, where there is less things to detect
    ClickOrMove(x, y, "", delay)
}

ClickOrMove2 := ClickOrMove2ImplViaControl
ClickOrMove2Impl(x, y, button := "", premove_delay := s_Premove_Delay, click_delay := s_Click_Delay) {
    MouseMove(x, y)
    if (premove_delay) {
        Sleep(premove_delay)
    }
    if (button) {
        Click(x, y, button)
        if (click_delay) {
            Sleep(click_delay)
        }
    }
}
ClickOrMove2ImplViaControl(x, y, button := "", premove_delay := s_Premove_Delay, click_delay := s_Click_Delay) {
    ControlClick "X" x " Y" y, , , button, , "Pos 0"
    if (premove_delay) {
        Sleep(premove_delay)
    }
    if (button) {
        ControlClick "X" x " Y" y, , , button, , "Pos"
        if (click_delay) {
            Sleep(click_delay)
        }
    }
}
