; -------------------------------------------------------------------
; Cookie Clicker automation script
; Extended from the original Cookie Collector project by ophee:
; https://sourceforge.net/projects/cookiecollector/
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

BuffClickTime := 9890  ; <-- Adjust this to fine-tune the click duration during the auto-shop cycle (in milliseconds)

; --- Configurable Hotkeys ---
; You can set the hotkeys by simply changing the values below
; Use "^" for Ctrl, "+" for Shift, "!" for Alt
Hotkey_BaseClicker := "F7"
Hotkey_AutoShop    := "F8"
Hotkey_AutoCast    := "F9"
Hotkey_Exit        := "^e"

; --- Improve timer resolution (helps short sleeps/cadence) ---
DllCall("winmm\timeBeginPeriod", "UInt", 1)
OnExit, Cleanup

; --- State Variables (Decoupled) ---
MainClickerActive := false
AutoShopActive := false
autoStopRequested := false
IsShopping := false
AutoFhofActive := false 
cookie_X := ""
cookie_Y := ""

; --- Target Array ---
; This is an example set-up showing how to sell/buy more than 100 of any building type
; Cursors, Grandmas, Farms, and Mines are listed twice so they are clicked twice per cycle
Buildings := ["row_cursor.png", "row_grandma.png", "row_farm.png", "row_mine.png", "row_factory.png", "row_bank.png", "row_temple.png", "row_shipment.png", "row_alchemy.png", "row_portal.png", "row_cursor.png", "row_grandma.png", "row_farm.png", "row_mine.png"]

; --- Initialize Dynamic Hotkeys ---
Hotkey, %Hotkey_BaseClicker%, ToggleBaseClicker
Hotkey, %Hotkey_AutoShop%, ToggleAutoShop
Hotkey, %Hotkey_AutoCast%, ToggleAutoCast
Hotkey, %Hotkey_Exit%, EmergencyExit

; Run base loop frequently
SetTimer, MainLoop, 50
return

; --------------------
; Hotkey Labels
; --------------------

ToggleBaseClicker:
    MainClickerActive := !MainClickerActive
    
    if (MainClickerActive) {
        ; Ensure we have coordinates if starting this first
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
        
        ; Ensure we have coordinates if starting this first without the base clicker
        if (cookie_X = "")
            MouseGetPos, cookie_X, cookie_Y
            
        ToolTip, Auto-Shop: ON
        SetTimer, ClearToolTip, -1000
        SetTimer, AutomationCycle, -1
    } else {
        autoStopRequested := true
        ToolTip, Auto-Shop: Stopping after current cycle...
        SetTimer, ClearToolTip, -1500
    }
return

ToggleAutoCast:
    AutoFhofActive := !AutoFhofActive
    if (AutoFhofActive) {
        ToolTip, [Auto Cast: ON], , , 2 
        SetTimer, CastFhofRoutine, 3000 ; Sweeps every 3 seconds
    } else {
        ToolTip, [Auto Cast: OFF], , , 2 
        SetTimer, CastFhofRoutine, Off
    }
    SetTimer, ClearFhofToolTip, -2000
return

EmergencyExit:
    ExitApp

; --------------------
; ToolTip Clear Routines
; --------------------
ClearToolTip:
    ToolTip
return

ClearFhofToolTip:
    ToolTip,,,, 2  
return

; --------------------
; Helper: ImageSearch Click (Required with Retry Contingency)
; --------------------
ClickImage(img, altImg := "") {
    global cookie_X, cookie_Y 

    ; 1. Single attempt at the primary image
    ImageSearch, outX, outY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 %img%
    
    ; 2. If not found and we have an alt, one attempt at the alt
    if (ErrorLevel != 0 && altImg != "") {
        ImageSearch, outX, outY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 %altImg%
    }
    
    ; 3. If either search succeeded
    if (ErrorLevel = 0) {
        clickX := outX + 5
        clickY := outY + 5
        Click, %clickX%, %clickY%
        
        if (cookie_X != "")
            MouseMove, %cookie_X%, %cookie_Y%, 0
        
        Sleep, 100 
        return true
    }
    
    ; 4. Immediate failure if both single checks fail
    ToolTip, ABORT: Could not find %img% or %altImg%.
    SetTimer, ClearToolTip, -3000
    return false
}

; --------------------
; Helper: Fast Click (No Sleep, No Return - For Rapid Shopping)
; --------------------
FastClickImage(img) {
    ; Attempt 1
    ImageSearch, outX, outY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 %img%
    
    ; Contingency: Shorter retry buffer (10ms instead of 50ms)
    if (ErrorLevel != 0) {
        Sleep, 10
        ImageSearch, outX, outY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 %img%
    }

    if (ErrorLevel = 0) {
        clickX := outX + 5
        clickY := outY + 5
        Click, %clickX%, %clickY%
        
        ; Notice: No MouseMove return logic here.
        ; Notice: No Sleep, 50 here.
        
        return true
    }
    return false
}

; --------------------
; Helper: ImageSearch Click (Optional/Silent)
; --------------------
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

; --------------------
; Helper: ImageSearch Click (Moving Target/Double Check)
; --------------------
ClickMovingOptionalImage(img) {
    global cookie_X, cookie_Y 

    ImageSearch, outX, outY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 %img%
    if (ErrorLevel = 0) {
        Sleep, 150 
        ImageSearch, finalX, finalY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 %img%
        if (ErrorLevel = 0) {
            clickX := finalX + 5
            clickY := finalY + 5
            Click, %clickX%, %clickY%
            
            if (cookie_X != "")
                MouseMove, %cookie_X%, %cookie_Y%, 0
            
            Sleep, 50 
            return true
        }
    }
    return false 
}

; --------------------
; Helper: Check Reindeer (Moving Target)
; --------------------
CheckReindeer() {
    ImageSearch, rX, rY, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 reindeer.png
    if (ErrorLevel = 0) {
        rX += 15
        rY += 15
        
        ; 1. Move to the target to trigger the browser's hover state
        MouseMove, %rX%, %rY%, 0
        
        ; 2. Send the click
        Click
        
        ; 3. CRITICAL: Sleep the thread so the browser registers the event
        Sleep, 150 
        
        return true
    }
    return false
}

; --------------------
; Helper: Check Golden Cookie
; --------------------
CheckGolden() {
    ImageSearch, gX, gY, 0, 0, A_ScreenWidth, A_ScreenHeight, *32 gimg.png
    if (ErrorLevel = 0) {
        gX += 5
        gY += 5
        Click, %gX%, %gY%
        return true
    }
    return false
}

; --------------------
; Background Thread: FTHOF Cast Routine
; --------------------
CastFhofRoutine:
    ; Yield to the shop sequence if it is currently executing
    if (IsShopping)
        return
        
    ; Lock out the base clicker from stealing the mouse
    IsShopping := true
    
    ; We use the standard click here because the UI is static during independent casting
    ClickOptionalImage("fhof.png")
    
    IsShopping := false
return

; --------------------
; Background Thread: Main Cookie & Golden Loop
; --------------------
MainLoop:
    if (!MainClickerActive)
        return

    ; Yield to the shop sequence if it is currently executing
    if (IsShopping)
        return

    Loop, 25
        Click, %cookie_X%, %cookie_Y%

    CheckGolden()
    CheckReindeer()
return

; --------------------
; Automation Thread: Shop Cycle (Sell -> Click -> Buy)
; --------------------
AutomationCycle:
    ; --- INITIALIZATION: QUANTITY CHECK ---
    ; Attempt to set shop quantity to 100 before entering the loop
    IsShopping := true
    ClickOptionalImage("100.png")
    IsShopping := false

    while (AutoShopActive && !autoStopRequested) {
        
        CheckGolden()
        CheckReindeer()

        ; Lock the mouse (pauses MainLoop and CastFhofRoutine)
        IsShopping := true

        ; --- SELL OUT ---
        if (!ClickImage("sell.png", "sell_on.png")) {
            IsShopping := false
            continue
        }
        
        Sleep, 250  ; <-- UI Render Pause (Sell Mode)

        shoppingFailed := false
        For index, building in Buildings {
            if (!FastClickImage(building)) {
                shoppingFailed := true
                break
            }
            
            ; --- TIMING ANCHOR ---
            if (index = 1) {
                cursorSellTime := A_TickCount
            }
        }

        if (shoppingFailed) {
            IsShopping := false
            continue
        }

        ; --- CAST SPELLS ---
        ; Only execute if the F toggle is active
        if (AutoFhofActive) {
            ClickMovingOptionalImage("fhof.png")
        }

        ; Unlock mouse for click phase
        IsShopping := false

        CheckGolden()
        CheckReindeer()

      ; --- CLICK COOKIE ---
        endTime := cursorSellTime + BuffClickTime
        
        ; Using the exact same stable logic from the MainLoop
        while (A_TickCount < endTime) {
            Loop, 25
                Click, %cookie_X%, %cookie_Y%

            CheckGolden()
            CheckReindeer()
        }

        CheckGolden()
        CheckReindeer()

        ; Re-lock mouse for buy phase
        IsShopping := true

        ; --- BUY BACK ---
        if (!ClickImage("buy.png", "buy_on.png")) {
            IsShopping := false
            continue
        }
        
        Sleep, 250  ; <-- UI Render Pause (Buy Mode)

        shoppingFailed := false
        For index, building in Buildings {
            if (!FastClickImage(building)) {
                shoppingFailed := true
                break
            }
        }

        if (shoppingFailed) {
            IsShopping := false
            continue
        }

        ; Cycle complete. Unlock the mouse. 
        ; If MainClickerActive is true, MainLoop will instantly resume here.
        IsShopping := false
    }

  ; --- TEARDOWN: RESET QUANTITY ---
    IsShopping := true
    ClickOptionalImage("1.png")
    
    ; Final cleanup when loop breaks or stops gracefully
    AutoShopActive := false
    autoStopRequested := false
    IsShopping := false
    
    ToolTip, Auto-Shop: OFF
    SetTimer, ClearToolTip, -1500
return

; --- This Cleanup label must remain at the very bottom! ---
Cleanup:
    DllCall("winmm\timeEndPeriod", "UInt", 1)
    ExitApp