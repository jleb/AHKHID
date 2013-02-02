AHKHID - An AHK implementation of the HID functions
===================================================

AHKHID allows you to easily interface with HID devices (such as keyboards, mice,
joysticks, etc...) in your AHK code without having to resort to interacting with
the raw input API of Windows.

All the API calls that AHKHID wraps can be found here:
http://msdn.microsoft.com/en-us/library/ms645543%28v=vs.85%29.aspx

AHKHID includes three examples:
* Example 1 lists all the registered HID devices currently connected to your PC
* Example 2 allows you to register for input from any HID device
* Example 3 shows how the mouse can be registered and its input extracted
