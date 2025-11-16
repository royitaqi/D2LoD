#include ../data_structure/Types.ahk


class D2Window {
    static Hwnd := nil

    static GetHwnd() {
        if (!this.Hwnd) {
            this.Hwnd := WinExist("Diablo II")
        }
        Assert(this.Hwnd, "Diablo II should be running")
        return this.hwnd
    }

    static IsActive() {
        return WinActive()
    }

    static Activate() {
        return WinActivate()
    }
}
