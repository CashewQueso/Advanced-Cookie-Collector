========================================================================
NAME GOES HERE
AutoHotkey v1.1
========================================================================

OVERVIEW
--------
This is an automation script for Cookie Clicker,
extended from the Cookie Collector script by ophee: 
https://sourceforge.net/projects/cookiecollector/
It features three independent modules that can run simultaneously or separately:
1. Base Clicker: Rapid clicks on the big cookie & Golden Cookie hunting.
2. Auto-Shop: Automates the Godzamok buy/sell cycle.
3. Auto-Cast: Automatically clicks "Force the Hand of Fate" on a timer.

The script uses a "state machine" approach, meaning you can toggle these 
features on and off independently without stopping the script.

I built this to expand upon the Cookie Collector script developed by ophee, 
which proved just too OP to not optimize further. This script is designed for 
early game progression, and assumes you have unlocked the Grimoire and
the Pantheon (although the real power of the script comes from the Pantheon,
being able to cast FHOF is just an added bonus). The script uses image recognition
(thanks ophee) to initiate a buy/sell cycle that automatically sells your buildings
before clicking the cookie until the buff from Godzamok ends, and repeats this cycle
in a loop. The script will always check for and collect any golden cookies that spawn
when either the Base Clicker or the Auto-Shop feature is active.

This could be used to set-up a variety of late game combos as well, and I do have
plans to further expand the functionality as I progress through the game.

RECOMMENDED SETUP
-----------------
At least 100 Cursors and 100 Grandmas.
The Pantheon unlocked with Godzamok in your diamond slot.
The Grimoire unlocked with enough Wizard Towers available to cast FHOF.
The script is currently configured to Auto-shop for the following buildings:
* 200 each: Cursors, Grandmas, Farms, and Mines
* 100 each of the following: Factories, Banks, Temples, Shipments, and Alchemy Labs 
This is easily adjusted to complement your current CPS by editing the Target Array
found near the top of the script. Instructions are provided.

REQUIREMENTS
------------
1. AutoHotkey v1.1 installed.
2. Cookie Clicker must be visible on the primary monitor.
3. Visual Settings: It is recommended to turn OFF fancy graphics and fullscreen in
    the game settings to ensure image recognition works reliably. 

SETUP INSTRUCTIONS
------------------
1. Clone or download this repository to a folder on your machine.
2. Ensure the .ahk script and all .png image files are in the SAME folder.
3. Run the .ahk script.
4. (Important) If the script fails to recognize the UI, you will need to 
   create your own image snippets (see the "Required Image Files" section).

CONTROLS / HOTKEYS (DEFAULTS)
-----------------------------
All hotkeys can be customized in the script (see Configuration below).

[ F8 ]      TOGGLE BASE CLICKER
            Starts/Stops rapid clicking and Golden Cookie hunting.
            Locks onto the big cookie location when activated.

[ Z ]       TOGGLE AUTO-SHOP (GODZAMOK CYCLE)
            Starts the Sell -> Click -> Buy loop. 
            Before starting the loop, it clicks "100" to ensure correct 
            quantities. If pressed while running, it requests a "Graceful 
            Stop" (finishes the current buy-back before stopping).

[ F ]       TOGGLE AUTO-CAST (FTHOF)
            Starts a background timer that scans for the FTHOF spell
            every 3 seconds. Displays a tooltip next to the cursor.

[ Ctrl+E ]  EMERGENCY STOP
            Instantly kills the script.

REQUIRED IMAGE FILES
--------------------
NOTE ON PROVIDED IMAGES:
This repository includes a set of example .png files to get you started. 
However, because AutoHotkey's ImageSearch relies on exact pixel matching, 
these example files may NOT work for you due to differences in screen 
resolution, monitor scaling, or browser zoom levels. 

If the script aborts or fails to click, you will need to use a tool like 
the Windows Snipping Tool to take your own small, precise screenshots of 
these elements and overwrite the provided files in the folder.

-- Store Controls --
100.png           (The "100" quantity toggle button)
sell.png          (The "Sell" switch text/button)
buy.png           (The "Buy" switch text/button)

-- Gameplay --
gimg.png          (A Golden Cookie)
fhof.png          (The "Force the Hand of Fate" spell icon)

-- Building Rows (For identification) --
row_cursor.png
row_grandma.png
row_farm.png
row_mine.png
row_factory.png
row_bank.png
row_temple.png
row_shipment.png
row_alchemy.png

CONFIGURATION
-------------
Open the .ahk file in a text editor to modify these settings at the top:

1. Configurable Hotkeys
   - You can easily change the trigger keys for the script.
   - Use "^" for Ctrl, "+" for Shift, and "!" for Alt.
   - Example: To change the Auto-Shop toggle to Shift+X, change
     Hotkey_AutoShop := "z"  --->  Hotkey_AutoShop := "+x"

2. BuffClickTime
   - Default: 9820
   - Controls how long (in ms) the script clicks the big cookie 
     after selling buildings but before buying them back. Tweak this if you
     notice your click loop is not aligned with the end of your Godzamok buff.

3. Buildings Array
   - This list determines the order and quantity of buildings sold.
   - Example: ["row_cursor.png", "row_cursor.png", ...]
   - If a building is listed twice, the script clicks it twice.

TROUBLESHOOTING
---------------
* If the shop cycle aborts immediately:
  Check that your browser zoom is set to 100%. If you play zoomed in/out, 
  you will probably have to replace the provided .png files with your own snippets.

* If Image Search Fails:
  The script has a built-in "Retry" mechanism. If it fails to find an
  image, it waits 50ms and tries one more time before aborting to handle 
  minor lag spikes. If it continually fails to find the provided .pngs,
  you will most likely need to create your own.
========================================================================