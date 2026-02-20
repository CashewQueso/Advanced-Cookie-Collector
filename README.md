Advanced Cookie Collector
AutoHotkey v1.0.2
===

## OVERVIEW

This is an automation script for Cookie Clicker,
extended from the Cookie Collector script by ophee:
https://sourceforge.net/projects/cookiecollector/
It features three independent modules that can run simultaneously or separately:

1. Base Clicker: Rapidly clicks on the big cookie w/ Golden Cookie & Reindeer detection.
2. Auto-Shop: Automates the Godzamok buy/sell cycle.
3. Auto-Cast: Automatically clicks "Force the Hand of Fate" when available.

The script uses a "state machine" approach, meaning you can toggle these
features on and off independently without stopping the script.

I built this to expand upon the Cookie Collector script developed by ophee,
which proved just too OP to not optimize further. This script is designed for
early game progression, and assumes you have unlocked the Grimoire and
the Pantheon (although the real power of the script comes from the Pantheon,
being able to cast FHOF is just an added bonus). The script uses image recognition
(thanks ophee) to initiate a buy/sell cycle that automatically sells your buildings
before clicking the cookie until the buff from Godzamok ends, and repeats this cycle
in a loop. The script will always check for and collect any golden cookies or reindeer that spawn
when either the Base Clicker or the Auto-Shop feature is active.

This could be used to set-up a variety of late game combos as well, and I do have
plans to further expand the functionality as I progress through the game.

## RECOMMENDED SETUP

At least 100 Cursors and 100 Grandmas.
The Pantheon unlocked with Godzamok in your diamond slot.
The Grimoire unlocked with enough Wizard Towers available to cast FHOF.
The script is currently configured to Auto-shop for the following buildings:

* 200 each: Cursors, Grandmas, Farms, and Mines
* 100 each of the following: Factories, Banks, Temples, Shipments, Alchemy Labs, and Portals
  This is easily adjusted to complement your current CPS by editing the Target Array
  found near the top of the script. Instructions are provided within the script.

## REQUIREMENTS

1. AutoHotkey v1.1 installed.
2. Cookie Clicker must be visible on the primary monitor.
3. Visual Settings: It is recommended to turn OFF fancy graphics, particles, and fullscreen in
   the game settings to ensure image recognition works reliably.

## SETUP INSTRUCTIONS

1. Clone or download this repository to a folder on your machine.
2. Ensure the .ahk script and all .png image files are in the SAME folder.
3. Run the Advanced Cookie Collector v1.1.0.ahk script.
4. (Important) If the script fails to recognize the UI, you will need to
   create your own image snippets (see the "Required Image Files" section).

## CONTROLS / HOTKEYS (DEFAULTS)

All hotkeys can be customized in the script (see Configuration below).

\[ F7 ]      TOGGLE BASE CLICKER
Starts/Stops rapid clicking and Golden Cookie hunting.
Locks onto the big cookie location when activated.

\[ F8 ]       TOGGLE AUTO-SHOP (GODZAMOK CYCLE)
Starts the Sell -> Click -> Buy loop.
Before starting the loop, it clicks "100" to ensure correct
quantities. If pressed while running, it requests a "Graceful
Stop" (finishes the current buy-back before stopping).

\[ F9 ]       TOGGLE AUTO-CAST (FTHOF)
Starts a background timer that scans for the FTHOF spell
every 3 seconds. Displays a tooltip next to the cursor.

\[ Ctrl+E ]  EMERGENCY STOP
Instantly kills the script.

## REQUIRED IMAGE FILES

NOTE ON PROVIDED IMAGES:
This repository includes a set of example .png files to get you started.
However, because AutoHotkey's ImageSearch relies on exact pixel matching,
these example files may NOT work for you due to differences in screen
resolution, monitor scaling, or browser zoom levels.

If the script aborts or fails to click, you will need to use a tool like
the Windows Snipping Tool to take your own small, precise screenshots of
these elements and overwrite the provided files in the folder.

I have also provided a script that simply scans the screen for reindeer 
and gives an alert when one is found. I found it difficult to find the right
combination of pixels that would both be triggered by a reindeer and ignore
the sheen of the Godzamok buff over certain colors of milk. Just run the script
and press F9 to activate the radar.

-- Store Controls --

1.png             (The "1" quantity toggle button)

100.png           (The "100" quantity toggle button)

sell.png          (The "Sell" switch text/button)

buy.png           (The "Buy" switch text/button)

-- Gameplay --

gimg.png          (A Golden Cookie)

reindeer.png          (A Reindeer)

fhof.png          (The "Force the Hand of Fate" spell icon)

-- Building Rows --

row\_cursor.png

row\_grandma.png

row\_farm.png

row\_mine.png

row\_factory.png

row\_bank.png

row\_temple.png

row\_shipment.png

row\_alchemy.png

row\_portal.png

## CONFIGURATION

Open the .ahk file in a text editor to modify these settings at the top:

1. Configurable Hotkeys

   * You can easily change the trigger keys for the script.
   * Use "^" for Ctrl, "+" for Shift, and "!" for Alt.
   * Example: To change the Auto-Shop toggle to Alt+s, change
     Hotkey\_AutoShop := "F8"  --->  Hotkey\_AutoShop := "!s"

2. BuffClickTime

   * Default: 9890
   * Controls how long (in ms) the script clicks the big cookie
     after selling buildings but before buying them back. Tweak this if you
     notice your click loop is not aligned with the end of your Godzamok buff.

3. Buildings Array

   * This list determines the order and quantity of buildings sold.
   * Example: \["row\_cursor.png", "row\_grandma.png", ...]
   * If a building is listed twice, the script clicks it twice.

## TROUBLESHOOTING

* If the shop cycle aborts immediately:
  Check that your browser zoom is set to 100%. If you play zoomed in/out,
  you will probably have to replace the provided .png files with your own snippets.
* If Image Search Fails:
  If the script fails during the "Fast-Click" phase, ensure your Buildings array matches the filenames in your directory exactly, and are ordered  sequentially. FastClickImage includes a tiny 10ms buffer, but it is designed for performance over persistence. High game lag may require increasing the `Sleep` values in the `FastClickImage` function
