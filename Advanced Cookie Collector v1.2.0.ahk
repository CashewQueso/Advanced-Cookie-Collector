; -------------------------------------------------------------------
; Cookie Clicker automation script (Lean Shop Edition)
; Optimized for "Sell All / Buy Custom" Godzamok Cycles
; Extended by: (CashewQueso)
; -------------------------------------------------------------------

#Persistent
#SingleInstance Force
#MaxThreadsPerHotkey 2

; --- Settings ---
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
SetMouseDelay, 5
SetDefaultMouseSpeed, 0
SetBatchLines, -1

BuffClickTime := 9890 

; --- Configurable Hotkeys ---
Hotkey_BaseClicker := "F8"
Hotkey_AutoShop    := "F7"
Hotkey_Exit        := "^e"

; --- Improve timer resolution ---
DllCall("winmm\timeBeginPeriod", "UInt", 1)
OnExit, Cleanup

; --- State Variables ---
MainClickerActive := false
AutoShopActive := false
autoStopRequested := false
IsShopping := false
cookie_X := ""
cookie_Y := ""

; --- Target Array ---
Buildings := ["row_farm.png:6", "row_mine.png:6", "row_factory.png:6", "row_bank.png:6", "row_shipment.png:5", "row_alchemy.png:5", "row_portal.png:5", "row_temple.png:6"]

; --- Initialize Dynamic Hotkeys ---
Hotkey, %Hotkey_BaseClicker%, ToggleBaseClicker
Hotkey, %Hotkey_AutoShop%, ToggleAutoShop
Hotkey, %Hotkey_Exit%, EmergencyExit

SetTimer, MainLoop, 50
return

; --------------------
; Hotkey Labels
; --------------------

ToggleBaseClicker:
    MainClickerActive := !MainClickerActive
    if (MainClickerActive) {
        if (cookie_X = "")
            MouseGetPos, cookie_X, cookie_Y
        ToolTip, Base Clicker: ON
    } else {
        ToolTip, Base Clicker: OFF
    }
    SetTimer, ClearToolTip, -2000
return

ToggleAutoShop:
    if (!AutoShopActive) {
        AutoShopActive := true
        autoStopRequested := false
        IsShopping := false
        if (cookie_X = "")
            MouseGetPos, cookie_X, cookie_Y
        ToolTip, Auto-Shop: ON
        SetTimer, AutomationCycle, -1
    } else {
        autoStopRequested := true
        ToolTip, Auto-Shop: Stopping after current cycle...
    }
    SetTimer, ClearToolTip, -1500
return

EmergencyExit:
    ExitApp

ClearToolTip:
    ToolTip
return

; --------------------
; Helper Functions
; --------------------

ClickImage(img, altImg := "") {
    global cookie_X, cookie_Y 
    ImageSearch, outX, outY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 %img%
    if (ErrorLevel != 0 && altImg != "") {
        ImageSearch, outX, outY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 %altImg%
    }
    if (ErrorLevel = 0) {
        clickX := outX + 5
        clickY := outY + 5
        Click, %clickX%, %clickY%
        if (cookie_X != "")
            MouseMove, %cookie_X%, %cookie_Y%, 0
        Sleep, 100 
        return true
    }
    ToolTip, ABORT: Could not find %img% or %altImg%.
    SetTimer, ClearToolTip, -3000
    return false
}

FastClickImage(img) {
    ImageSearch, outX, outY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 %img%
    if (ErrorLevel != 0) {
        Sleep, 10
        ImageSearch, outX, outY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 %img%
    }
    if (ErrorLevel = 0) {
        clickX := outX + 5
        clickY := outY + 5
        Click, %clickX%, %clickY%
        return true
    }
    return false
}

ClickOptionalImage(img) {
    global cookie_X, cookie_Y 
    ImageSearch, outX, outY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 %img%
    if (ErrorLevel = 0) {
        clickX := outX + 5
        clickY := outY + 5
        Click, %clickX%, %clickY%
        if (cookie_X != "")
            MouseMove, %cookie_X%, %cookie_Y%, 0
        Sleep, 50 
        return true
    }
    return false 
}

CheckReindeer() {
    ImageSearch, rX, rY, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 reindeer.png
    if (ErrorLevel = 0) {
        rX += 15
        rY += 15
        MouseMove, %rX%, %rY%, 0
        Click
        Sleep, 150 
        return true
    }
    return false
}

CheckGolden() {
    ; 1. Search for regular Golden Cookie
    ImageSearch, gX, gY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 gimg.png
    
    ; 2. If not found, search for Wrath Cookie
    if (ErrorLevel != 0) {
        ImageSearch, gX, gY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 wimg.png
    }

    ; 3. If either was found, click it
    if (ErrorLevel = 0) {
        gX += 5
        gY += 5
        Click, %gX%, %gY%
        return true
    }
    return false
}

; --------------------
; Background Thread
; --------------------

MainLoop:
    if (!MainClickerActive || IsShopping)
        return
    Loop, 25
        Click, %cookie_X%, %cookie_Y%
    CheckGolden()
    CheckReindeer()
return

; --------------------
; Automation Thread: Shop Cycle
; --------------------

AutomationCycle:
    while (AutoShopActive && !autoStopRequested) {
        CheckGolden()
        CheckReindeer()

        IsShopping := true
        CoordsMap := {} ; Temporary storage for this cycle's coordinates

        ; --- PHASE 1: SELL ALL & RECORD ---
        ClickImage("sell.png", "sell_on.png")
        Sleep, 400 
        ClickOptionalImage("all.png")

        for index, entry in Buildings {
            data := StrSplit(entry, ":")
            buildingImg := data[1]
            
            ; Find it once, record it, and click it
            ImageSearch, outX, outY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 %buildingImg%
            if (ErrorLevel = 0) {
                cX := outX + 5
                cY := outY + 5
                CoordsMap[index] := {x: cX, y: cY} ; Store for buyback
                Click, %cX%, %cY%
            }
            
            if (index = 1)
                cursorSellTime := A_TickCount
        }

        ; --- PHASE 2: CLICKING ---
        IsShopping := false
        endTime := cursorSellTime + BuffClickTime
        while (A_TickCount < endTime) {
            Loop, 25
                Click, %cookie_X%, %cookie_Y%
            CheckGolden()
            CheckReindeer()
        }

        ; --- PHASE 3: BUY BACK (HIGH SPEED) ---
        IsShopping := true
        ClickImage("buy.png", "buy_on.png")
        Sleep, 150 ; Wait for UI toggle
        ClickOptionalImage("100.png") 
        Sleep, 50

        for index, entry in Buildings {
            data := StrSplit(entry, ":")
            clickCount := data[2] + 0
            
            pos := CoordsMap[index]
            if (pos.x != "") {
                targetX := pos.x
                targetY := pos.y
                
                ; Move mouse once per building type to reduce overhead
                MouseMove, %targetX%, %targetY%, 0
                
                Loop, %clickCount% {
                    Click
                    ; 30ms is the "sweet spot" for most browsers to 
                    ; register the click AND calculate the new cost.
                    Sleep, 30 
                }
            }
        }
        IsShopping := false
    }

    ; --- TEARDOWN ---
    IsShopping := true
    ClickImage("buy.png", "buy_on.png")
    Sleep, 100
    ClickOptionalImage("1.png")
    AutoShopActive := false
    autoStopRequested := false
    IsShopping := false
    ToolTip, Auto-Shop: OFF
    SetTimer, ClearToolTip, -1500
return

Cleanup:
    DllCall("winmm\timeEndPeriod", "UInt", 1)
    ExitApp