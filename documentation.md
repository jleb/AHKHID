# Documentation #

AHKHID exposes the API calls necessary in order to interact with HID devices.
This document contains all the information you need to use it.

## Table of Contents ##

[How do I map buttons on my keyboard/mouse/device?](#how-do-i-map-buttons-on-my-keyboardmousedevice)

Reference
* [Function List](#function-list)
* [Flags for HID_GetDevInfo()](#flags-for-hid_getdevinfo)
* [Flags for HID_GetInputInfo()](#flags-for-hid_getinputinfo)
* [Flags for HID_AddRegister() or HID_Register()](#flags-for-hid_addregister-or-hid_register)
* Raw input flags
  * [Interpreting II_MSE_FLAGS](#interpreting-ii_mse_flags)
  * [Interpreting II_MSE_BUTTONFLAGS](#interpreting-ii_mse_buttonflags)
  * [Interpreting II_KBD_FLAGS](#interpreting-ii_kbd_flags)
* [Other constants](#other-constants)

## How do I map buttons on my keyboard/mouse/device? ##

Before going ahead and registering devices, you need to understand how
registration works. You cannot register a device in specific. HID devices are
categorized into what is called Top Level Collections (TLCs). In other words, a
whole class of devices might be listed under the same TLC. What constitutes a
TLC is the "Usage Page" value and the "Usage" value. For example, all keyboards
are categorized under the keyboard TLC which is Usage Page 1 and Usage 6.
Similarly, mice are under the TLC with Usage Page 1 and Usage 2.

When registering, you can only tell Windows which TLCs you'd like to register
with your application. However, you can still tell apart which HID device sent
what upon reception of the data (at least for HID devices other than keyboards
and mice). Therefore, even if you have two HID devices under the same TLC, you
can still tell them apart by comparing data specific to each, such as Vendor ID,
Product ID, etc...

The first thing you need to do when mapping data from your HID device, is to
find out where it comes from (from which HID device), and what it looks like.
You can use Example 1 and 2 for that. Example 1 allows you to explore the
different HID devices connected to your computer (and find out what TLC they
belong to), and Example 2 allows you to examine the data coming out of them (by
plugging in the TLC you found in Example 1).

Once you know what that keyboard/mouse/HID button press generates, there are
different ways you can integrate it into your script. The simplest would be to
use #Include to include AHKHID, and then do a call at the beginning of your
script to HID_Register() and use your OnMessage() sub to treat the data. Or if
you just need the bare minimum in order to interact with a non-keyboard-or-mouse
device, you can simply copy/paste the HID_Register() function as well as the
HID_GetInputData() function into your script. For more information on how to use
those functions, you can look into Example 2.

## Function List ##

### HID_Initialize(bRefresh = False) ###

You don't have to call this function manually. It is automatically called by
other functions to get the pointer of the RAWINPUTDEVICELIST struct array.
However, if a new device is plugged in, you will have to refresh the listing by
calling it with bRefresh = True. Returns -1 on error.

### HID_GetDevCount() ###

Returs the number of HID devices connected to this computer. Returns -1 on
error.

### HID_GetDevHandle(i) ###

Returns the handle of device i (starts at 1). Mostly used internally for API
calls.

### HID_GetDevIndex(Handle) ###

Returns the index (starts at 1) of the device in the enumeration with matching
handle.
Returns 0 if not found.

### HID_GetDevType(i, IsHandle = False) ###

Returns the type of the device. See the RIM_ constants for possible values. If
IsHandle is false, then i is considered the index (starts at 1) of the device in
the enumeration. Otherwise it is the handle of the device.

### HID_GetDevName(i, IsHandle = False) ###

Returns the name of the device (or empty string on error).
If IsHandle is false, then i is considered the index (starts at 1) of the device
in the enumeration. Otherwise it is the handle of the device.

### HID_GetDevInfo(i, Flag, IsHandle = False) ###

Retrieves info from the RID_DEVICE_INFO struct. To retrieve a member, simply use
the corresponding flag. A list of flags can be found at the top of the script
(the constants starting with DI_). Each flag corresponds to a member in the
struct. See Example 1 for an example on how to use it. If IsHandle is false,
then i is considered the index (starts at 1) of the device in the enumeration.
Otherwise it is the handle of the device.

### HID_AddRegister(UsagePage = False, Usage = False, Handle = False, Flags = 0)

Allows you to queue up RAWINPUTDEVICE structures before doing the registration.
To use it, you first need to initialize the var by calling
HID_AddRegister(iNumberOfElements). To then add to the stack, simply call it
with the parameters you want (eg. HID_AddRegister(1,6,MyGuiHandle) for
keyboards). When you're finally done, you just have to call HID_Register() with
no parameters. The function returns -1 if the struct is full. Redimensioning the
struct will erase all previous structs added. On success, it returns the address
of the array of structs (if you'd rather manipulate it yourself).

You will need to do this if you want to use advance features of the
RAWINPUTDEVICE flags. For example, if you want to register all devices using
Usage Page 1 but would like to exclude devices of Usage Page 1 using Usage 2
(keyboards), then you need to place two elements in the array. The first one is
HID_AddRegister(1,0,MyGuiHandle,RIDEV_PAGEONLY) and the second one is
HID_AddRegister(1,2,MyGuiHandle,RIDEV_EXCLUDE).

Tip: Have a look at all the flags you can use (see the constants starting with
RIDEV_). The most useful is RIDEV_INPUTSINK.  
Tip: Set Handle to 0 if you want the WM_INPUT messages to go to the window with
keyboard focus.  
Tip: To unregister, use the flag RIDEV_REMOVE. Note that you also need to use
the RIDEV_PAGEONLY flag if the TLC was
registered with it.  

### HID_Register(UsagePage = False, Usage = False, Handle = False, Flags = 0) ###

This function can be used in two ways. If no parameters are specified, it will
use the RAWINPUTDEVICE array created through HID_AddRegister() and register.
Otherwise, it will register only the specified parameters. For example, if you
just want to register the mouse, you can simply do
HID_Register(1,2,MyGuiHandle). See Example 3 for such a simple scenario.

### HID_GetRegisteredDevs(ByRef uDev) ###

This function allows you to get an array of the TLCs that have already been
registered. It fills uDev with an array of RAWINPUTDEVICE and returns the number
of elements in the array. Returns -1 on error. See Example 2 for an example on
how to use it.

### HID_GetInputInfo(InputHandle, Flag) ###

This function is used to retrieve the data upon receiving WM_INPUT messages. By
passing the lParam of the WM_INPUT (0xFF00) messages, it can retrieve all the
members of the RAWINPUT structure, except the raw data coming from HID devices
(use HID_GetInputData for that). To retrieve a member, simply specify the flag
corresponding to the member you want, and call the function. A list of all the
flags can be found at the top of this script (the constants starting with II_).
See Example 2 for an example on how to use it. See Example 3 for an example on
how to access member flags.

Tip: You have to use Critical in your message function or you might get invalid
handle errors.  
Tip: You can check the value of wParam to know if the application was in the
foreground upon reception (see RIM_INPUT).  

### HID_GetInputData(InputHandle, ByRef uData) ###

This function is used to retrieve the data sent by HID devices of type
RIM_TYPEHID (ie. neither keyboard nor mouse) upon receiving WM_INPUT messages.
CAUTION: it does not check if the device is indeed of type HID. It is up to you
to do so (you can use GetInputInfo for that). Specify the lParam of the WM_INPUT
(0xFF00) message and the function will put in uData the raw data received from
the device. It will then return the size (number of bytes) of uData. Returns -1
on error. See Example 2 for an example on how to use it (although you need an
HID device of type RIM_TYPEHID to test it).

## Flags for HID_GetDevInfo() ##

Type of the device. See RIM_ constants.  
DI_DEVTYPE                  := 4

ID for the mouse device.  
DI_MSE_ID                   := 8

Number of buttons for the mouse.  
DI_MSE_NUMBEROFBUTTONS      := 12

Number of data points per second. This information may not be applicable for
every mouse device.  
DI_MSE_SAMPLERATE           := 16

Vista only: TRUE if the mouse has a wheel for horizontal scrolling; otherwise,
FALSE.  
DI_MSE_HASHORIZONTALWHEEL   := 20

Type of the keyboard.  
DI_KBD_TYPE                 := 8

Subtype of the keyboard.  
DI_KBD_SUBTYPE              := 12

Scan code mode.  
DI_KBD_KEYBOARDMODE         := 16

Number of function keys on the keyboard.  
DI_KBD_NUMBEROFFUNCTIONKEYS := 20

Number of LED indicators on the keyboard.  
DI_KBD_NUMBEROFINDICATORS   := 24

Total number of keys on the keyboard.  
DI_KBD_NUMBEROFKEYSTOTAL    := 28

Vendor ID for the HID.  
DI_HID_VENDORID             := 8

Product ID for the HID.  
DI_HID_PRODUCTID            := 12

Version number for the HID.  
DI_HID_VERSIONNUMBER        := 16

Top-level collection Usage Page for the device.  
DI_HID_USAGEPAGE            := 20 | 0x0100

Top-level collection Usage for the device.  
DI_HID_USAGE                := 22 | 0x0100

## Flags for HID_GetInputInfo() ##

Type of the device generating the raw input data. See RIM_ constants.  
II_DEVTYPE          := 0

Handle to the device generating the raw input data.  
II_DEVHANDLE        := 8

Mouse state. This member can be any reasonable combination of the following
values -> see MOUSE constants.  
II_MSE_FLAGS        := 16 | 0x0100

Transition state of the mouse buttons. This member can be one or more of the
following values -> see RI_MOUSE constants.  
II_MSE_BUTTONFLAGS  := 20 | 0x0100

If usButtonFlags is RI_MOUSE_WHEEL, this member is a signed value that
specifies the wheel delta.  
II_MSE_BUTTONDATA   := 22 | 0x1100  

Raw state of the mouse buttons.  
II_MSE_RAWBUTTONS   := 24

Motion in the X direction. This is signed relative motion or absolute motion,
depending on the value of usFlags.  
II_MSE_LASTX        := 28 | 0x1000  

Motion in the Y direction. This is signed relative motion or absolute motion,
depending on the value of usFlags.  
II_MSE_LASTY        := 32 | 0x1000  

Device-specific additional information for the event.  
II_MSE_EXTRAINFO    := 36           

Scan code from the key depression. The scan code for keyboard overrun is
KEYBOARD_OVERRUN_MAKE_CODE.  
II_KBD_MAKECODE     := 16 | 0x0100  

Flags for scan code information. It can be one or more of the following values 
-> see RI_KEY constants.  
II_KBD_FLAGS        := 18 | 0x0100  

Microsoft Windows message compatible virtual-key code.  
II_KBD_VKEY         := 22 | 0x0100

Corresponding window message, for example WM_KEYDOWN, WM_SYSKEYDOWN, and so
forth.  
II_KBD_MSG          := 24

Device-specific additional information for the event.  
II_KBD_EXTRAINFO    := 28

Size, in bytes, of each HID input in bRawData.  
II_HID_SIZE         := 16

Number of HID inputs in bRawData.  
II_HID_COUNT        := 20

Raw input data as an array of bytes.
II_HID_DATA         := 24

DO NOT USE WITH HID_GetInputInfo. Use HID_GetInputData instead to retrieve the
raw data.

## Flags for HID_AddRegister() or HID_Register() ##

If set, this removes the top level collection from the inclusion list. This
tells the operating system to stop reading from a device which matches the top
level collection.  
RIDEV_REMOVE        := 0x00000001

If set, this specifies the top level collections to exclude when reading a
complete usage page. This flag only affects a TLC whose usage page is already
specified with RIDEV_PAGEONLY.  
RIDEV_EXCLUDE       := 0x00000010

If set, this specifies all devices whose top level collection is from the
specified usUsagePage. Note that usUsage must be zero. To exclude a particular
top level collection, use RIDEV_EXCLUDE.  
RIDEV_PAGEONLY      := 0x00000020

If set, this prevents any devices specified by usUsagePage or usUsage from
generating legacy messages. This is only for the mouse and keyboard. See
Remarks.  
RIDEV_NOLEGACY      := 0x00000030

If set, this enables the caller to receive the input even when the caller is
not in the foreground. Note that hwndTarget must be specified.  
RIDEV_INPUTSINK     := 0x00000100

If set, the mouse button click does not activate the other window.  
RIDEV_CAPTUREMOUSE  := 0x00000200

If set, the application-defined keyboard device hotkeys are not handled.
However, the system hotkeys; for example, ALT+TAB and CTRL+ALT+DEL, are still
handled. By default, all keyboard hotkeys are handled. RIDEV_NOHOTKEYS can be
specified even if RIDEV_NOLEGACY is not specified and hwndTarget is NULL.  
RIDEV_NOHOTKEYS     := 0x00000200

Microsoft Windows XP Service Pack 1 (SP1): If set, the application command keys
are handled. RIDEV_APPKEYS can be specified only if RIDEV_NOLEGACY is specified
for a keyboard device.  
RIDEV_APPKEYS       := 0x00000400

                                 
Vista only: If set, this enables the caller to receive input in the background
only if the foreground application does not process it. In other words, if the
foreground application is not registered for raw input, then the background
application that is registered will receive the input.  
RIDEV_EXINPUTSINK   := 0x00001000

## Interpreting II_MSE_FLAGS ##

Mouse movement data is relative to the last mouse position.  
MOUSE_MOVE_RELATIVE         := 0

Mouse movement data is based on absolute position.  
MOUSE_MOVE_ABSOLUTE         := 1

Mouse coordinates are mapped to the virtual desktop (for a multiple monitor
system)  
MOUSE_VIRTUAL_DESKTOP       := 0x02

Mouse attributes changed; application needs to query the mouse attributes.  
MOUSE_ATTRIBUTES_CHANGED    := 0x04

## Interpreting II_MSE_BUTTONFLAGS ##

Self-explanatory  
RI_MOUSE_LEFT_BUTTON_DOWN   := 0x0001

Self-explanatory  
RI_MOUSE_LEFT_BUTTON_UP     := 0x0002

Self-explanatory  
RI_MOUSE_RIGHT_BUTTON_DOWN  := 0x0004

Self-explanatory  
RI_MOUSE_RIGHT_BUTTON_UP    := 0x0008

Self-explanatory  
RI_MOUSE_MIDDLE_BUTTON_DOWN := 0x0010

Self-explanatory  
RI_MOUSE_MIDDLE_BUTTON_UP   := 0x0020

XBUTTON1 changed to down.  
RI_MOUSE_BUTTON_4_DOWN      := 0x0040

XBUTTON1 changed to up.  
RI_MOUSE_BUTTON_4_UP        := 0x0080

XBUTTON2 changed to down.  
RI_MOUSE_BUTTON_5_DOWN      := 0x0100

XBUTTON2 changed to up.  
RI_MOUSE_BUTTON_5_UP        := 0x0200

Raw input comes from a mouse wheel. The wheel delta is stored in usButtonData.  
RI_MOUSE_WHEEL              := 0x0400

## Interpreting II_KBD_FLAGS ##

RI_KEY_MAKE             := 0  
RI_KEY_BREAK            := 1  
RI_KEY_E0               := 2  
RI_KEY_E1               := 4  
RI_KEY_TERMSRV_SET_LED  := 8  
RI_KEY_TERMSRV_SHADOW   := 0x10  

## Other constants ##

Device type values returned by HID_GetDevType() as well as DI_DEVTYPE and
II_DEVTYPE

The device is a mouse.  
RIM_TYPEMOUSE       := 0

The device is a keyboard.  
RIM_TYPEKEYBOARD    := 1

The device is an Human Interface Device (HID) that is not a keyboard and not a
mouse.  
RIM_TYPEHID         := 2

Different values wParam can take on during a WM_INPUT message

Input occurred while the application was in the foreground. The application
must call DefWindowProc so the system can perform cleanup.  
RIM_INPUT       := 0

Input occurred while the application was not in the foreground. The application
must call DefWindowProc so the system can perform the cleanup.  
RIM_INPUTSINK   := 1    

Flag for the II_KBD_MAKECODE member in the event of a keyboard overrun  
KEYBOARD_OVERRUN_MAKE_CODE  := 0xFF  
