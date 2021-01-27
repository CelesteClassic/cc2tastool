# cc2tastool

<img src="https://raw.githubusercontent.com/db0z/cc2tastool/main/preview.gif">

Simple prototype of a TAS Tool for Celeste Classic 2. Functions the same way as a mod. Based on smalleste2 by @Meep and @gonengazit and uses free space to squeeze in some basic TAS tools. Only usable for short segments because it stores deep copies of states (the table `objects` specifically) in Lua RAM, which is limited; I made it ignore some (unnecessary) objects to save enough memory for at least 200 frames in the most intense levels.

Usage:

* To advance a frame, hold the buttons you want pressed and release them, or press space for no buttons, or hold Shift to input in real time (use this to skip intros and such)
* Press Q to enable/disable saving a state every frame
* Press Backspace to undo a frame
* Press O to dump the button states from recorded states to cc2tas.p8l file (let me know if you need this in a different format for something)

Hud: top line is player.x/y, player.speed_x/y, player.remainder_x/y (this is also printed to console), bottom line: number of states and memory usage (this number must stay below 2048 or tool crashes, thanks zep)

I also set level_index manually at the end

ping @avi on discord if something's wrong
