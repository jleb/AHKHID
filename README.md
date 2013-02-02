AHKHID - An AHK implementation of the HID functions
===================================================

[AHKHID](AHKHID.ahk) allows you to easily interface with HID devices (such as
keyboards, mice, joysticks, etc...) in your AHK code without having to resort to
interacting with the raw input API of Windows.

All the API calls that AHKHID wraps can be found here:  
http://msdn.microsoft.com/en-us/library/ms645543.aspx

AHKHID includes three examples:
* [Example 1](examples/example_1.ahk) lists all the HID devices currently
connected to your computer
* [Example 2](examples/example_2.ahk) allows you to register for input from any
HID device and display the incoming data
* [Example 3](examples/example_3.ahk) shows how the mouse can be registered
