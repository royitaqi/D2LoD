#Requires AutoHotkey v2.0.0


window_title := "Diablo II"

; This call to find the window is important.
; The following ControlSend() calls are all done to the Last Found Window (see https://www.autohotkey.com/docs/v2/lib/ControlSend.htm).
if (!WinExist(window_title)) {
    MsgBox "This example requires Diablo II to be running"
    exit
}

if (!A_IsAdmin) {
    MsgBox "This example requires the script to be run as admin"
    exit
}

; Send "Hello world" message
ControlSend "{Enter}"
Sleep 50
ControlSendText "Hello world"   ; ControlSendText is faster and more consistent than ControLSend
Sleep 50
ControlSend "{Enter}"
Sleep 100

; Cast spell E
ControlSend "E"
Sleep 100
ControlClick "x628 y463", , , "Right", , "Pos"
Sleep 400

; Open inventory, ready to drop 999 gold
ControlSend "D"
Sleep 100
ControlClick "x628 y463", , , "Left", , "Pos"
Sleep 100
ControlSendText "999"
Sleep 50

; Hover on the 1st potion in belt
; TODO: This doesn't work
ControlClick "x575 y580", , , , 0, "Pos NA"


; Result should be that the D2 window doesn't have to be active or on top,
; and the windows mouse won't move, and the above actions are carried out in the game.
