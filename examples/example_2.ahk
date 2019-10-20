/*! TheGood
    AHKHID - An AHK implementation of the HID functions.
    AHKHID Example 2
    Last updated: August 22nd, 2010
    
    Registers HID devices and displays data coming upon WM_INPUT.
    This example shows how to use AHKHID_AddRegister(), AHKHID_Register(), AHKHID_GetInputInfo() and AHKHID_GetInputData().
    _______________________________________________________________
    1. Input the TLC (Usage Page and Usage) you'd like to register.
    2. Select any flags you want to associate with the TLC (see Docs for more info about each of them).
    3. Press Add to add the TLC to the array.
    3. Repeat 1, 2 and 3 for all the TLCs you'd like to register (the TLC array listview will get filled up).
    4. Press Call to register all the TLCs in the array.
    5. Any TLCs currently registered will show up in the Registered devices listview.
    6. Any data received will be displayed in the listbox.
    
    For example, if you'd like to register the keyboard and the mouse, put UsagePage 1 and check the flag RIDEV_PAGEONLY.
    Then press Add and then Call to register.
*/

;Check if the OS is Windows Vista or higher
bVista := (DllCall("GetVersion") & 0xFF >= 6)

;Create GUI
Gui +LastFound -Resize -MaximizeBox -MinimizeBox
Gui, Add, Text, x6 y10 w80 h20, Usage&Page
Gui, Add, Edit, x86 y10 w100 h20 Number vtxtUsPg,
Gui, Add, Text, x6 y30 w80 h20, &Usage
Gui, Add, Edit, x86 y30 w100 h20 Number vtxtUs,
Gui, Add, GroupBox, x6 y60 w180 h210, &Flags
Gui, Add, CheckBox, x16 y80 w160 h20 vchkAPPKEYS, RIDEV_APPKEYS
Gui, Add, CheckBox, x16 y100 w160 h20 vchkCAPTUREMOUSE, RIDEV_CAPTUREMOUSE
Gui, Add, CheckBox, x16 y120 w160 h20 vchkEXCLUDE, RIDEV_EXCLUDE
Gui, Add, CheckBox, x16 y140 w160 h20 vchkINPUTSINK, RIDEV_INPUTSINK
Gui, Add, CheckBox, x16 y160 w160 h20 vchkNOHOTKEYS, RIDEV_NOHOTKEYS
Gui, Add, CheckBox, x16 y180 w160 h20 vchkNOLEGACY, RIDEV_NOLEGACY
Gui, Add, CheckBox, x16 y200 w160 h20 vchkPAGEONLY gPAGEONLY_Click, RIDEV_PAGEONLY
Gui, Add, CheckBox, x16 y220 w160 h20 vchkREMOVE, RIDEV_REMOVE
If bVista
    Gui, Add, CheckBox, x16 y240 w160 h20 vchkEXINPUTSINK, RIDEV_EXINPUTSINK
Gui, Add, Button, x196 y10 w40 h40 vbtnAdd gbtnAdd_Event, &Add
Gui, Add, Button, x196 y60 w40 h40 vbtnRem gbtnRem_Event, &Rem
Gui, Add, Text, x246 y10 w340 h20, TLC Array:
Gui, Add, ListView, x246 y30 w410 h70 vlvwTLC, Usage Page|Usage|Flags
Gui, Add, Button, x196 y110 w225 h40 vbtnCall gbtnCall_Event, &Call
Gui, Add, Button, x431 y110 w225 h40 vbtnRefresh gbtnRefresh_Event, Refresh &list
Gui, Add, Text, x196 y160 w390 h20, Registered devices:
Gui, Add, ListView, x196 y180 w460 h80 vlvwRegistered, Usage Page|Usage|Flags
Gui, Add, Text, x6 y276 w580 h20, To register keyboards, use Usage Page 1 and Usage 6. For mice, Usage Page 1 and Usage 2.
Gui, Font, w700 s8, Courier New
Gui, Add, ListBox, x6 y296 w650 h320 vlbxInput hwndhlbxInput glbxInput_Event,

;Keep handle
GuiHandle := WinExist()

;Set up the constants
#include AHKHID.ahk
AHKHID_UseConstants()

;Intercept WM_INPUT
OnMessage(0x00FF, "InputMsg")

;Show GUI
Gui, Show
Return

GuiClose:
ExitApp

btnAdd_Event:
    
    ;Get vars
    Gui, Submit, NoHide
    
    ;Set default listview
    Gui, ListView, lvwTLC
    
    ;Prep flags
    iFlags := 0
    iFlags |= chkAPPKEYS      ? RIDEV_APPKEYS      : 0
    iFlags |= chkCAPTUREMOUSE ? RIDEV_CAPTUREMOUSE : 0
    iFlags |= chkEXCLUDE      ? RIDEV_EXCLUDE      : 0
    iFlags |= chkINPUTSINK    ? RIDEV_INPUTSINK    : 0
    iFlags |= chkNOHOTKEYS    ? RIDEV_NOHOTKEYS    : 0
    iFlags |= chkNOLEGACY     ? RIDEV_NOLEGACY     : 0
    iFlags |= chkPAGEONLY     ? RIDEV_PAGEONLY     : 0
    iFlags |= chkREMOVE       ? RIDEV_REMOVE       : 0
    If bVista
        iFlags |= chkEXINPUTSINK ? RIDEV_EXINPUTSINK : 0
    
    ;Add item
    LV_Add("", txtUsPg, txtUs, iFlags)
    
Return

;Delete selected
btnRem_Event:
    Gui, ListView, lvwTLC
    LV_Delete(LV_GetNext())
Return

;Using RIDEV_PAGEONLY means Usage has to be 0
PAGEONLY_Click:
    Gui, Submit, NoHide
    If chkPAGEONLY
        GuiControl,, txtUs, 0
Return

;Clear on doubleclick
lbxInput_Event:
    If (A_GuiEvent = "DoubleClick") {
        GuiControl,, lbxInput,|
        iInputNum := 0
    }
Return

btnCall_Event:
    
    ;Set default listview
    Gui, ListView, lvwTLC
    
    ;Get count
    iCount := LV_GetCount()
    
    ;Dimension the array
    AHKHID_AddRegister(iCount)
    
    Loop %iCount% {
        
        ;Extract info from listview
        LV_GetText(iUsPg, A_Index, 1)
        LV_GetText(iUs,   A_Index, 2)
        LV_GetText(iFlag, A_Index, 3)
        
        ;Add for registration
        r := AHKHID_AddRegister(iUsPg, iUs, GuiHandle, iFlag)
    }
    
    ;Register
    AHKHID_Register()
    
    ;Refresh list
    Gosub btnRefresh_Event
    
    ;Clear listview
    Gui, ListView, lvwTLC
    LV_Delete()
    
Return

btnRefresh_Event:
    
    ;Set default listview
    Gui, ListView, lvwRegistered
    
    ;Clear listview
    LV_Delete()
    
    ;Check the size of a pointer
    PtrSize := (A_PtrSize ? A_PtrSize : 4)
    
    ;Get devs
    iCount := AHKHID_GetRegisteredDevs(uDev)
    If (iCount > 0)
        Loop %iCount% ;Add to listview
            LV_Add("", NumGet(uDev, ((A_Index - 1) * (8 + PtrSize)) + 0, "UShort")
            , NumGet(uDev, ((A_Index - 1) * (8 + PtrSize)) + 2, "UShort")
            , NumGet(uDev, ((A_Index - 1) * (8 + PtrSize)) + 4, "UInt"))
    
Return

InputMsg(wParam, lParam) {
    Local r, h
    Critical    ;Or otherwise you could get ERROR_INVALID_HANDLE
    
    ;Get device type
    r := AHKHID_GetInputInfo(lParam, II_DEVTYPE) 
    If (r = -1)
        OutputDebug %ErrorLevel%
    If (r = RIM_TYPEMOUSE) {
        GuiControl,, lbxInput, % ""
        . " Flags: "       AHKHID_GetInputInfo(lParam, II_MSE_FLAGS) 
        . " ButtonFlags: " AHKHID_GetInputInfo(lParam, II_MSE_BUTTONFLAGS) 
        . " ButtonData: "  AHKHID_GetInputInfo(lParam, II_MSE_BUTTONDATA) 
        . " RawButtons: "  AHKHID_GetInputInfo(lParam, II_MSE_RAWBUTTONS) 
        . " LastX: "       AHKHID_GetInputInfo(lParam, II_MSE_LASTX)
        . " LastY: "       AHKHID_GetInputInfo(lParam, II_MSE_LASTY) 
        . " ExtraInfo: "   AHKHID_GetInputInfo(lParam, II_MSE_EXTRAINFO)
    } Else If (r = RIM_TYPEKEYBOARD) {
        GuiControl,, lbxInput, % ""
        . " MakeCode: "    AHKHID_GetInputInfo(lParam, II_KBD_MAKECODE)
        . " Flags: "       AHKHID_GetInputInfo(lParam, II_KBD_FLAGS)
        . " VKey: "        AHKHID_GetInputInfo(lParam, II_KBD_VKEY)
        . " Message: "     AHKHID_GetInputInfo(lParam, II_KBD_MSG) 
        . " ExtraInfo: "   AHKHID_GetInputInfo(lParam, II_KBD_EXTRAINFO)
    } Else If (r = RIM_TYPEHID) {
        h := AHKHID_GetInputInfo(lParam, II_DEVHANDLE)
        r := AHKHID_GetInputData(lParam, uData)
        GuiControl,, lbxInput, % ""
        . " Vendor ID: "   AHKHID_GetDevInfo(h, DI_HID_VENDORID,     True)
        . " Product ID: "  AHKHID_GetDevInfo(h, DI_HID_PRODUCTID,    True)
        . " UsPg/Us: " AHKHID_GetDevInfo(h, DI_HID_USAGEPAGE, True) . "/" . AHKHID_GetDevInfo(h, DI_HID_USAGE, True)
        . " Data: " Bin2Hex(&uData, r)
    }
    SendMessage, 0x018B, 0, 0,, ahk_id %hlbxInput%
    SendMessage, 0x0186, ErrorLevel - 1, 0,, ahk_id %hlbxInput%
}

;By Laszlo, adapted by TheGood
;http://www.autohotkey.com/forum/viewtopic.php?p=377086#377086
Bin2Hex(addr,len) {
    Static fun, ptr 
    If (fun = "") {
        If A_IsUnicode
            If (A_PtrSize = 8)
                h=4533c94c8bd14585c07e63458bd86690440fb60248ffc2418bc9410fb6c0c0e8043c090fb6c00f97c14180e00f66f7d96683e1076603c8410fb6c06683c1304180f8096641890a418bc90f97c166f7d94983c2046683e1076603c86683c13049ffcb6641894afe75a76645890ac366448909c3
            Else h=558B6C241085ED7E5F568B74240C578B7C24148A078AC8C0E90447BA090000003AD11BD2F7DA66F7DA0FB6C96683E2076603D16683C230668916240FB2093AD01BC9F7D966F7D96683E1070FB6D06603CA6683C13066894E0283C6044D75B433C05F6689065E5DC38B54240833C966890A5DC3
        Else h=558B6C241085ED7E45568B74240C578B7C24148A078AC8C0E9044780F9090F97C2F6DA80E20702D1240F80C2303C090F97C1F6D980E10702C880C1308816884E0183C6024D75CC5FC606005E5DC38B542408C602005DC3
        VarSetCapacity(fun, StrLen(h) // 2)
        Loop % StrLen(h) // 2
            NumPut("0x" . SubStr(h, 2 * A_Index - 1, 2), fun, A_Index - 1, "Char")
        ptr := A_PtrSize ? "Ptr" : "UInt"
        DllCall("VirtualProtect", ptr, &fun, ptr, VarSetCapacity(fun), "UInt", 0x40, "UInt*", 0)
    }
    VarSetCapacity(hex, A_IsUnicode ? 4 * len + 2 : 2 * len + 1)
    DllCall(&fun, ptr, &hex, ptr, addr, "UInt", len, "CDecl")
    VarSetCapacity(hex, -1) ; update StrLen
    Return hex
}
