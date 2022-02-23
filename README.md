AHKHID - An AHK implementation of the HID functions
===================================================

[AHKHID](AHKHID.ahk) allows you to easily interface with HID devices (such as
keyboards, mice, joysticks, etc...) in your AHK code without having to resort to
interacting with the raw input API of Windows. The original AutoHotkey forum thread can be found
[here](http://www.autohotkey.com/board/topic/38015-ahkhid-an-ahk-implementation-
of-the-hid-functions/).

All the API calls that AHKHID wraps can be found here:  
http://msdn.microsoft.com/en-us/library/ms645543.aspx

To get started download the entire repo and chech out the three included AHKHID examples.
They should work as is from the examples folder with AHKHID.ahk at the root
(or you can edit the #include's to specify a unique path)

* [Example 1](examples/example_1.ahk) lists all the HID devices currently
connected to your computer
* [Example 2](examples/example_2.ahk) allows you to register input from any
HID device and display the incoming data
* [Example 3](examples/example_3.ahk) shows how the mouse can be registered


To use AHKHID in your own scripts simply include AHKHID.ahk in the same folder and 
add '#include AHKHID.ahk' to the begining of your script. Then add a HID_Register() call
and use OnMessage() to react to the desired calls found from example 2 or prior knowledge.

For more detail information check out the [Documentation](documentation.md).
