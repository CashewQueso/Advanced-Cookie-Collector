#Persistent
#SingleInstance Force

; --- THE TWEAK SETTINGS ---
PivotSpeed := 100    ; Milliseconds between selling towers (Try 75 or 50 for faster)
CastDelay  := 200    ; Milliseconds for the spell to process in the engine
; -------------------------

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
SetMouseDelay, -1    ; Absolute minimum delay
SetDefaultMouseSpeed, 0
SetBatchLines, -1

Hotkey_Toggle := "^f"
Hotkey_Exit   := "^e"

DllCall("winmm\timeBeginPeriod", "UInt", 1)
OnExit, Cleanup

Running := false
cookie_X := ""
cookie_Y := ""

Hotkey, %Hotkey_Toggle%, ToggleProtocol
Hotkey, %Hotkey_Exit%, EmergencyExit
return

ToggleProtocol:
    if (Running) {
        Running := false
        ToolTip, PROTOCOL: STOPPED, , , 1 ; Clear Main ToolTip
        ToolTip, , , , 3                  ; Clear Status ToolTip
        SetTimer, ClearToolTip, -1000
        return
    }

    Running := true
    
    ; 1. Setup & Pre-Scan
    if (cookie_X = "")
        MouseGetPos, cookie_X, cookie_Y
    
    ToolTip, PROTOCOL: Locating Wizard Towers...
    
    ; Identify coordinates once (supports active or greyed-out snippets)
    ImageSearch, twX, twY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 row_wizard.png
    if (ErrorLevel != 0)
        ImageSearch, twX, twY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 row_wizard_off.png

    if (ErrorLevel != 0) {
        MsgBox, 16, Error, Could not find Wizard Towers. Toggle F8 to try again.
        Running := false
        return
    }
    
    ; Lock coordinates for high-speed clicking
    targetX := twX + 10
    targetY := twY + 10

    ; 2. THE WAIT (FTHOF + Golden)
    ToolTip, PROTOCOL: Waiting for FTHOF + Natural Golden..., , , 3
    Loop {
        if (!Running) return
        
        ImageSearch, fX, fY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 fhof.png
        fReady := (ErrorLevel = 0)
        
        ImageSearch, gX, gY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 gimg.png
        gReady := (ErrorLevel = 0)

        if (fReady && gReady)
            break
            
        Sleep, 150
    }

    ; 3. THE REFINED PIVOT
    ToolTip, PROTOCOL: EXECUTING PIVOT!, , , 3
    
    ; Click Natural GC
    Click, % gX+5 "," gY+5
    Sleep, 100

    ; CAST 1: (Deliberate check to ensure it fires BEFORE the sell-off)
    ImageSearch, fX, fY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 fhof.png
    if (ErrorLevel = 0) {
        Click, % fX+5 "," fY+5
        Sleep, 400 ; Buffer to let mana subtract before selling towers
    }

    ; Prep Shop UI
    ClickOptionalImage("sell.png", "sell_on.png")
    ClickOptionalImage("100.png", "100_on.png")

    ; Sell 500 Towers (Hyper-Fast Coordinate Clicks)
    Loop, 5 {
        Click, %targetX%, %targetY%
        Sleep, %PivotSpeed% 
    }

    Sleep, 250

    ; CAST 2: (Lowered Mana Cost)
    ImageSearch, fX, fY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 fhof.png
    if (ErrorLevel = 0) {
        Click, % fX+5 "," fY+5
        Sleep, %CastDelay%
    }

    ; --- RECOVERY: Buy Towers Back ---
    ToolTip, PROTOCOL: Buying back Wizard Towers..., , , 3
    
    ; Ensure we are in "Buy" mode
    ClickOptionalImage("buy.png", "buy_on.png")
    Sleep, 150

    ; Buy 500 Towers (Using saved coordinates)
    Loop, 5 {
        Click, %targetX%, %targetY%
        Sleep, %PivotSpeed%
    }

    ; --- END OF PROTOCOL ---
    Running := false
    ToolTip, PROTOCOL: COMPLETE, , , 3
    SetTimer, ClearToolTip, -3000
return
  
; --------------------
; Helpers
; --------------------

ClickOptionalImage(img, altImg := "") {
    ImageSearch, oX, oY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 %img%
    if (ErrorLevel != 0 && altImg != "")
        ImageSearch, oX, oY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 %altImg%
    
    if (ErrorLevel = 0) {
        Click, % oX+5 "," oY+5
        Sleep, 150 ; UI update buffer
        return true
    }
    return false
}

ClearToolTip:
    ToolTip
    ToolTip, , , , 3
return

EmergencyExit:
    ExitApp

Cleanup:
    DllCall("winmm\timeEndPeriod", "UInt", 1)
    ExitApp