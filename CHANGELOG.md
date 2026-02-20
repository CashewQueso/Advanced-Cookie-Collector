## Changelog: v1.1.0

### New Capability: Reindeer Sniping

* **Dynamic Target Tracking:** Implemented `CheckReindeer()` to scan for and click reindeer, providing parity with Golden Cookie logic.
* **Hover-State Simulation:** Uses `MouseMove` before clicking reindeer to trigger browser-side hover events, ensuring the click is registered by the game engine.
* **Thread Integration:** Both `MainLoop` and `AutomationCycle` now check for reindeer at a high frequency.

### Stability & Robustness

* **Dual-State Detection:** `ClickImage()` now accepts an `altImg` parameter. This allows the script to identify the Buy/Sell buttons regardless of their "Active" vs "Inactive" visual state, eliminating mode-switching failures.
* **Fail-Fast Implementation:** `ClickImage()` has been streamlined to a **single-pass** search (per image) rather than a loop, ensuring the script aborts immediately if the UI is obstructed.
* **DOM Transition Buffer:** Added a `Sleep, 100` in the main helper to ensure the game has finished its visual transition before the script attempts the next building interaction.

### Optimization: "Devastation Protocol"

* **Latency Reduction:** Refined UI render pauses from **500ms** to **250ms**
* **FastClick Execution:** Building sales and purchases now utilize `FastClickImage()`, which bypasses `MouseMove` and `Sleep` calls. This drastically increases the Godzamok buff's effective uptime by spending less time in the shop.
* **Deterministic Clicking:** The shop's click phase now uses the same `Loop, 25` logic as the `MainLoop`, providing more consistent reindeer and golden cookie sniping.
* **Double Click Fix:** Refactored the Buildings array to cycle through different building types rather than double-tapping the same row. This naturally bypasses browser input lag and ensures every click is registered by the game engine.

### New Control Mapping

* **Hotkey Finalization:**
* `F7`: Base Clicker (Moved from F8)
* `F8`: Auto-Shop (Moved from Z)
* `F9`: Auto-Cast (Moved from F)
* `^e`: Emergency Exit (Standardized)

