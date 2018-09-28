; The MIT License (MIT)
; 
; Copyright (c) 2018 Ganlv
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.

#SingleInstance force

; Config

POSITION_X := 0
POSITION_Y := 0
MARGIN_X := 10
MARGIN_Y := 5

FONT_COLOR := "FFFFFF"
FONT_SIZE := 16
FONT_NAME := "Consolas"
FONT_STYLE := "Bold"

; don't set too large
NUM_BUTTONS := 5

TRANS_COLOR := "CCCCCC"
TRANS_OPACITY := 128

; -1, 0 or 1
LIST_BUBBLING_DIRECTION = 1

HOT_KEYS = 1,2,3,4,5,6,7,8,9,0,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
,-,=,[,],\,`;,',.,/,``
,CapsLock,Space,Tab,Enter,Escape,Backspace
,ScrollLock,Delete,Insert,Home,End,PgUp,PgDn,Up,Down,Left,Right
,Numpad0,Numpad1,Numpad2,Numpad3,Numpad4,Numpad5,Numpad6,Numpad7,Numpad8,Numpad9,NumpadDot
,NumLock,NumpadIns,NumpadEnd,NumpadDown,NumpadPgDn,NumpadLeft,NumpadClear,NumpadRight,NumpadHome,NumpadUp,NumpadPgUp,NumpadDel
,NumpadDiv,NumpadMult,NumpadAdd,NumpadSub,NumpadEnter
,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12,F13,F14,F15,F16,F17,F18,F19,F20,F21,F22,F23,F24
,Browser_Back,Browser_Forward,Browser_Refresh,Browser_Stop,Browser_Search,Browser_Favorites,Browser_Home,Volume_Mute,Volume_Down,Volume_Up
,Media_Next,Media_Prev,Media_Stop,Media_Play_Pause,Launch_Mail,Launch_Media,Launch_App1,Launch_App2,
,AppsKey,PrintScreen,CtrlBreak,Pause,Break,Help,Sleep

;============================================================
; Main script

InitializeWindow()
current := 1
InitializeHotKeys()
return

GuiClose:
ExitApp
return

;============================================================
; Functions and subroutines

InitializeWindow()
{
    global
    Gui, Font, c%FONT_COLOR% s%FONT_SIZE% %FONT_STYLE%, %FONT_NAME%
    Gui, Margin, %MARGIN_X%, %MARGIN_Y%
    Loop, %NUM_BUTTONS%
    {
        Gui, Add, Button, vButton%A_Index%, InitialKey%A_Index%
    }
    Gui, Add, Button, vButtonLock gLockWindow, LockWindow
    Gui +LastFound +AlwaysOnTop +ToolWindow
    Gui, Color, %TRANS_COLOR%
    WinSet, TransColor, %TRANS_COLOR% %TRANS_OPACITY%
    Gui, Show, x%POSITION_X% y%POSITION_Y% Autosize NoActivate
    return

    LockWindow:
    ; WS_EX_TRANSPARENT = 0x20 bypass MouseEvent won't focus on this window
    Gui +LastFound -Caption +E0x20
    GuiControl, Hide, ButtonLock
    return
}

InitializeHotKeys()
{
    global

    Loop, Parse, HOT_KEYS, `,
        Hotkey, ~*%A_LoopField%, KeyHandleLabel, UseErrorLevel
    ; Special chars
    Hotkey, ~*`,, KeyHandleLabel, UseErrorLevel

    return

    KeyHandleLabel:
    key := RegExReplace(A_ThisHotKey, "~\*", "")
    str := KeyWithModifiers(key)
    KeyHandle()
    return
}

; on key up event handler

KeyHandle()
{
    global
    if (LIST_BUBBLING_DIRECTION > 0) {
        if (current > NUM_BUTTONS) {
            ButtonListBubblingUp()
            current := NUM_BUTTONS
        }
        key := RegExReplace(A_ThisHotKey, "~\*", "")
        str := KeyWithModifiers(key)
        SetButtonText(current, str)
        current++
    } else if (LIST_BUBBLING_DIRECTION < 0) {
        ButtonListBubblingDown()
        key := RegExReplace(A_ThisHotKey, "~\*", "")
        str := KeyWithModifiers(key)
        SetButtonText(1, str)
        current++
    } else {
        if (current > NUM_BUTTONS) {
            current := 1
        }
        key := RegExReplace(A_ThisHotKey, "~\*", "")
        str := KeyWithModifiers(key)
        SetButtonText(current, str)
        current++
    }
}

ButtonListBubblingUp()
{
    global
    repeatCount := NUM_BUTTONS - 1
    Loop, %repeatCount%
    {
        fromButtonId := A_Index + 1
        toButtonId := A_Index
        SetButtonText(toButtonId, GetButtonText(fromButtonId))
    }
}

ButtonListBubblingDown()
{
    global
    repeatCount := NUM_BUTTONS - 1
    Loop, %repeatCount%
    {
        fromButtonId := NUM_BUTTONS - A_Index
        toButtonId := NUM_BUTTONS - A_Index + 1
        SetButtonText(toButtonId, GetButtonText(fromButtonId))
    }
}

MeasureButtonWidth(str)
{
    global
    Gui, 2:Default
    Gui, Color, %TRANS_COLOR%
    Gui, Font, c%FONT_COLOR% s%FONT_SIZE% %FONT_STYLE%, %FONT_NAME%
    Random, rand
    ButtonTempId := "ButtonTemp" . rand
    Gui, Add, Button, v%ButtonTempId%, %str%
    GuiControlGet, %ButtonTempId%, Pos
    Gui, Destroy
    Gui, 1:Default
    ButtonTempW := %ButtonTempId%W
    return ButtonTempW
}

GetButtonText(buttonId)
{
    Gui +LastFound
    ControlGetText, str, Button%buttonId%
    return str
}

SetButtonText(buttonId, str)
{
    global
    width := MeasureButtonWidth(str)
    Gui +LastFound
    GuiControl Move, Button%buttonId%, w%width%
    ControlSetText Button%buttonId%, %str%
    Gui, Show, Autosize NoActivate
}

; Format hotkey text

IsAlphabetic(key)
{
    return StrLen(key) == 1 && key >= "a" && key <= "z"
}

CanKeyShift(key)
{
    return IsAlphabetic(key) || ShiftKey(key) != key
}

ShiftKey(key)
{
    if (StrLen(key) == 1) {
        if (IsAlphabetic(key)) {
            StringUpper key, key
            return key
        }
        if (key == "1")
            return "!"
        if (key == "2")
            return "@"
        if (key == "3")
            return "#"
        if (key == "4")
            return "$"
        if (key == "5")
            return "%"
        if (key == "6")
            return "^"
        if (key == "7")
            return "&&"
        if (key == "8")
            return "*"
        if (key == "9")
            return "("
        if (key == "0")
            return ")"
        if (key == "-")
            return "_"
        if (key == "=")
            return "+"
        if (key == "[")
            return "{"
        if (key == "]")
            return "}"
        if (key == "\")
            return "|"
        if (key == ";")
            return ":"
        if (key == "'")
            return """"
        if (key == ",")
            return "<"
        if (key == ".")
            return ">"
        if (key == "/")
            return "?"
        if (key == "``")
            return "~"
    }
    return key
}

KeyWithModifiers(key)
{
    ctrlState := GetKeyState("Ctrl", "P")
    altState := GetKeyState("Alt", "P")
    shiftState := GetKeyState("Shift", "P")
    winState := GetKeyState("LWin", "P")

    ; | Original               | Display       |
    ; | :--------------------: | :------------ |
    ; | a                      | a             |
    ; | CapsLock a             | A             |
    ; | Shift a                | A             |
    ; | Shift 1                | !             |
    ; | Shift F1               | Shift+F1      |
    ; | CapsLock Shift a       | a             |
    ; | CapsLock Shift 1       | !             |
    ; | CapsLock Shift F1      | Shift+F1      |
    ; | ---------------------- | ------------- |
    ; | Ctrl Shift a           | Ctrl+Shift+A  |
    ; | Ctrl Shift 1           | Ctrl+Shift+1  |
    ; | Ctrl Shift F1          | Ctrl+Shift+F1 |
    ; | CapsLock Ctrl Shift a  | Ctrl+Shift+A  |
    ; | CapsLock Ctrl Shift 1  | Ctrl+Shift+1  |
    ; | CapsLock Ctrl Shift F1 | Ctrl+Shift+F1 |

    if (ctrlState || altState || winState) {
        if (IsAlphabetic(key)) {
            displayKey := ShiftKey(key)
        } else {
            displayKey := key
        }
    } else {
        if (CanKeyShift(key)) {
            capsState := GetKeyState("CapsLock", "T")
            shiftState := GetKeyState("Shift", "P")
            if (IsAlphabetic(key)) {
                if (capsState && !shiftState || shiftState && !capsState) {
                    displayKey := ShiftKey(key)
                } else {
                    displayKey := key
                }
             } else {
                if (shiftState) {
                    displayKey := ShiftKey(key)
                } else {
                    displayKey := key
                }
            }
            shiftState := false
        } else {
            displayKey := key
        }
    }

    modifiers := ""
    if (ctrlState)
        modifiers := modifiers . "Ctrl+"
    if (altState)
        modifiers := modifiers . "Alt+"
    if (shiftState)
        modifiers := modifiers . "Shift+"
    if (winState)
        modifiers := modifiers . "Win+"

    return modifiers . displayKey
}
