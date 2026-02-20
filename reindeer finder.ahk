#SingleInstance Force
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

IsScanning := false

MsgBox, Reindeer Radar Loaded!`n`nPress F9 to toggle the scanner ON/OFF.`nPress Esc to exit.
return

; --- F9: Toggle the Radar ---
F9::
    IsScanning := !IsScanning
    if (IsScanning) {
        ToolTip, [RADAR ON] Waiting for Reindeer to appear...
        SetTimer, ScanForReindeer, 100
    } else {
        ToolTip, [RADAR OFF]
        SetTimer, ScanForReindeer, Off
        SetTimer, ClearTT, -1500
    }
return

; --- The Core Search Logic ---
ScanForReindeer:
    ; Using the *65 variance from our helper logic
    ImageSearch, rX, rY, 0, 0, A_ScreenWidth, A_ScreenHeight, *65 reindeer.png
    
    if (ErrorLevel = 0) {
        ; MATCH FOUND!
        ; 1. Turn off the scanner so it doesn't spam popups
        IsScanning := false
        SetTimer, ScanForReindeer, Off
        ToolTip 
        
        ; 2. Snap the mouse to the exact pixel it matched to prove it visually
        MouseMove, %rX%, %rY%, 0
        
        ; 3. Alert the user
        MsgBox, SUCCESS! `nMatched reindeer.png at coordinates: X%rX% Y%rY%
        
    } else if (ErrorLevel = 2) {
        ; FILE ERROR!
        IsScanning := false
        SetTimer, ScanForReindeer, Off
        ToolTip
        MsgBox, ERROR: AutoHotkey cannot find the "reindeer.png" file.`nMake sure it is in the exact same folder as this script.
    }
return

ClearTT:
    ToolTip
return

; --- Emergency Exit ---
Esc::ExitApp