/*! TheGood
    AHKHID - An AHK implementation of the HID functions.
    AHKHID Example 3
    Last updated: August 22nd, 2010
    
    Monitors the mouse movements and button state changes.
    This is a good example showing how to use the RI_MOUSE flags of the member II_MSE_BUTTONFLAGS.
    ___________________________________________________________
    1. Check RIDEV_INPUTSINK (or Alt+k) if you'd like to capture events even when in the background.
    2. Press the Register button (or Alt+r) to start monitoring the mouse.
    3. Any mouse button state changes will be displayed in the left listbox. Mouse movements will show up in the right one.
    4. Doubleclick any of the listboxes to clear.
    5. Press Unregister (or Alt+u) to stop monitoring the mouse.
*/

;To make x,y movements look nice
SetFormat, FloatFast, 3.0

Gui, +Resize -MaximizeBox -MinimizeBox +LastFound
Gui, Add, Button, w80 gRegister, &Register
Gui, Add, Button, w80 yp x+10 gUnregister, &Unregister
Gui, Add, CheckBox, ym+5 x+10 vInputSink, RIDEV_INPUTSIN&K
Gui, Font, s8, Courier New
Gui, Add, Listbox,    R10 xm y+15 w390 vlbxInput hwndhlbxInput gClear
Gui, Add, Listbox,    R9 x+10 yp w100 vlbxMove hwndhlbxMove gClear
Gui, Add, Text, xp+4 y+1 w100 vlblXY, % " dX" A_Tab " dY"

;Keep handle
GuiHandle := WinExist()

;Set up the constants
AHKHID_UseConstants()

;Intercept WM_INPUT
OnMessage(0x00FF, "InputMsg")

Gui, Show
Return

GuiEscape:
GuiClose:
ExitApp

GuiSize:
    Anchor("lbxInput", "wh")
    Anchor("lbxMove", "xh")
    Anchor("lblXY", "xy")
Return

Register:
    Gui, Submit, NoHide    ;Put the checkbox in associated var
    AHKHID_Register(1,2,GuiHandle,InputSink ? RIDEV_INPUTSINK : 0)
Return

Unregister:
    AHKHID_Register(1,2,0,RIDEV_REMOVE)    ;Although MSDN requires the handle to be 0, you can send GuiHandle if you want.
Return                                    ;AHKHID will automatically put 0 for RIDEV_REMOVE.

Clear:
    If A_GuiEvent = DoubleClick
        GuiControl,, %A_GuiControl%,|
Return

InputMsg(wParam, lParam) {
    Local flags, s, x, y
    Critical
    
    ;Get movement and add to listbox
    x := AHKHID_GetInputInfo(lParam, II_MSE_LASTX) + 0.0
    y := AHKHID_GetInputInfo(lParam, II_MSE_LASTY) + 0.0
    If (x Or y)
        GuiControl,, lbxMove, % x A_Tab y
    
    ;Auto-scroll
    SendMessage, 0x018B, 0, 0,, ahk_id %hlbxMove%
    SendMessage, 0x0186, ErrorLevel - 1, 0,, ahk_id %hlbxMove%
    
    ;Get flags and add to listbox
    flags := AHKHID_GetInputInfo(lParam, II_MSE_BUTTONFLAGS)
    If (flags & RI_MOUSE_LEFT_BUTTON_DOWN)
        s := "You pressed the left button "
    If (flags & RI_MOUSE_LEFT_BUTTON_UP)
        s .= (s <> "" ? "and" : "You") " released the left button "
    If (flags & RI_MOUSE_RIGHT_BUTTON_DOWN)
        s .= (s <> "" ? "and" : "You") " pressed the right button "
    If (flags & RI_MOUSE_RIGHT_BUTTON_UP)
        s .= (s <> "" ? "and" : "You") " released the right button "
    If (flags & RI_MOUSE_MIDDLE_BUTTON_DOWN)
        s .= (s <> "" ? "and" : "You") " pressed the middle button "
    If (flags & RI_MOUSE_MIDDLE_BUTTON_UP)
        s .= (s <> "" ? "and" : "You") " released the middle button "
    If (flags & RI_MOUSE_BUTTON_4_DOWN)
        s .= (s <> "" ? "and" : "You") " pressed XButton1 "
    If (flags & RI_MOUSE_BUTTON_4_UP)
        s .= (s <> "" ? "and" : "You") " released XButton1 "
    If (flags & RI_MOUSE_BUTTON_5_DOWN)
        s .= (s <> "" ? "and" : "You") " pressed XButton2 "
    If (flags & RI_MOUSE_BUTTON_5_UP)
        s .= (s <> "" ? "and" : "You") " released XButton2 "
    If (flags & RI_MOUSE_WHEEL)
        s .= (s <> "" ? "and" : "You") " turned the wheel by " Round(AHKHID_GetInputInfo(lParam, II_MSE_BUTTONDATA) / 120) " notches "
    
    ;Add background/foreground info
    s .= (InputSink And s <> "") ? (wParam ? "in the background" : "in the foreground") : ""
    GuiControl,, lbxInput,%s%
    
    ;Auto-scroll
    SendMessage, 0x018B, 0, 0,, ahk_id %hlbxInput%
    SendMessage, 0x0186, ErrorLevel - 1, 0,, ahk_id %hlbxInput%
}

;Anchor by Titan, adapted by TheGood
;http://www.autohotkey.com/forum/viewtopic.php?p=377395#377395
Anchor(i, a = "", r = false) {
	static c, cs = 12, cx = 255, cl = 0, g, gs = 8, gl = 0, gpi, gw, gh, z = 0, k = 0xffff, ptr
	If z = 0
		VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), ptr := A_PtrSize ? "Ptr" : "UInt", z := true
	If (!WinExist("ahk_id" . i)) {
		GuiControlGet, t, Hwnd, %i%
		If ErrorLevel = 0
			i := t
		Else ControlGet, i, Hwnd, , %i%
	}
	VarSetCapacity(gi, 68, 0), DllCall("GetWindowInfo", "UInt", gp := DllCall("GetParent", "UInt", i), ptr, &gi)
		, giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
	If (gp != gpi) {
		gpi := gp
		Loop, %gl%
			If (NumGet(g, cb := gs * (A_Index - 1)) == gp, "UInt") {
				gw := NumGet(g, cb + 4, "Short"), gh := NumGet(g, cb + 6, "Short"), gf := 1
				Break
			}
		If (!gf)
			NumPut(gp, g, gl, "UInt"), NumPut(gw := giw, g, gl + 4, "Short"), NumPut(gh := gih, g, gl + 6, "Short"), gl += gs
	}
	ControlGetPos, dx, dy, dw, dh, , ahk_id %i%
	Loop, %cl%
		If (NumGet(c, cb := cs * (A_Index - 1), "UInt") == i) {
			If a =
			{
				cf = 1
				Break
			}
			giw -= gw, gih -= gh, as := 1, dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
				, cw := dw, dw := NumGet(c, cb + 8, "Short"), ch := dh, dh := NumGet(c, cb + 10, "Short")
			Loop, Parse, a, xywh
				If A_Index > 1
					av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
						, d%av% += (InStr("yh", av) ? gih : giw) * (A_LoopField + 0 ? A_LoopField : 1)
			DllCall("SetWindowPos", "UInt", i, "UInt", 0, "Int", dx, "Int", dy
				, "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
			If r != 0
				DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
			Return
		}
	If cf != 1
		cb := cl, cl += cs
	bx := NumGet(gi, 48, "UInt"), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52, "UInt")
	If cf = 1
		dw -= giw - gw, dh -= gih - gh
	NumPut(i, c, cb, "UInt"), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
		, NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
	Return, true
}
