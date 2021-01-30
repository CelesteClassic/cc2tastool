# cc2tastool

<img src="https://raw.githubusercontent.com/db0z/cc2tastool/main/preview.gif">

A set of tools to make Tool Assisted Speedruns for Celeste Classic 2. Tools run directly under PICO-8 as modded versions of the game, based upon the token-optimized smalleste2 by @Meep and @gonengazit. Storing and reloading states is implemented via deepcopying of the `objects` table, minus certain objects that are completely static, plus a few global variables. Because PICO-8 limits RAM usage, this means that large levels require you to work in relatively small segments (not too small, at least about 200 frames). Also, because of the hacky nature of this method, it seems to be still possible that segments don't play back correctly, but don't worry about it I fixed all of it 100%.

The tools are 2 PICO-8 carts: edit.p8 and play.p8

# edit10.p8 / edit11.p8

This tool lets you set the player's coordinates, play the game frame-by frame, and obtain a list of inputs as well as the table containing new player coordinates, for use in the next segment.

Open the first tab of code and you'll see this:

```lua
--config

conf_level=1
conf_player=nil
```

`conf_level` is the level index (1-8), `conf_player` is either nil or the player coordinate table (see below).

* To advance a frame, press the buttons you want held this frame at once and release them, or press **Space** to press no buttons. The tool won't let you advance past the end of the level, for convenience.
* Press **Backspace** to undo a frame.
* Press **I** to copy the segment to the clipboard, it will look like `[[0 2 4 ...]],`, so you'll be able to paste it into `segments` in play.p8.
* Press **O** to copy the player coordinates at the last frame to the clipboard, it will look like `{x=66,y=104,speed_x=2,speed_y=0,remainder_x=-0.4001,remainder_y=0,}`, so you can paste that into `conf_player` in edit.p8 and play.p8 and make the next segment from there.
* **I** and **O** also output *both* inputs and coordinates to the log file `seglog.p8l` and to the console, just in case.
* The numbers at the top of the screen are as follows: white are player.x/y, blue are player.speed_x/y, pink are player.remainder_x/y, yellow/red are the number of states stored (i.e. current frame) (left) and current RAM usage (right). **Keep this number below 2048**; otherwise, PICO-8 will crash because that's what our lord and savior @zep intended for us.
* You can also press **Tab** to go into real-time mode, but this isn't really useful for much and would mess up your states.

(you might notice there's no snow or clouds in this tool, I cut them to save some more tokens)

# play10.p8 / play11.p8

This tool plays back a list of segments obtained from edit.p8

To use it, save a copy of it in a separate file (that will be the TAS file), open the first tab and you'll see this:

```lua
--config

conf_level=0
conf_player=nil

segments={
--0
[[16 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]],
}

showoverlays=true
```

`conf_level` and `conf_player` are the same as in edit.p8 (to work on a separate level).

`segments` is the list of segments that you can copy-paste right from edit.p8 (remember: in lua, `[[...]]` is another way to denote a string `"..."`). The default value contains a segment that skips the intro card for you (level 0). Also, you can insert this segment at the beginning of every level that contains intros (3, 4, 5, 8) (edit.p8 skips intros):

```
[[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]],
```

Note: if you want to comment out a segment, use `//`, `--` doesn't comment out the comma for some reason.

`showoverlays` enables/disables the same overlays as in edit.p8.

You can also use these controls during playback:

* **T** to pause/unpause, **Space** to advance a frame when paused - for debugging
* **O** will copy the player coordinates to the clipboard, use it at the end if you lost them.
