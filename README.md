# cc2tastool

<img src="https://raw.githubusercontent.com/db0z/cc2tastool/main/preview.gif">

A set of tools to make Tool Assisted Speedruns for Celeste Classic 2. Tools run directly under PICO-8 as modded versions of the game, based upon the token-optimized smalleste2 by @Meep and @gonengazit. Storing and reloading states is implemented via deepcopying of the `objects` table, minus certain objects that are completely static, plus a few global variables. Because PICO-8 limits RAM usage, this means that large levels require you to work in relatively small segments (not too small, at least about 200 frames).

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

* To insert a frame, press the buttons you want held this frame at once and release them, or press **Space** to press no buttons.
* Press or hold **.** to repeat input from last frame - useful when you need to keep pressing the same buttons for a while.
* The tool won't let you advance past the end of the level, for convenience.
* Press **Backspace** to undo a frame.
* Press **-** or **=** to scroll backward/forward; this lets you change inputs in the middle of the segment.
* Press **I** to copy the segment to the clipboard, it will look like `[[0 2 4 ...]],`, so you'll be able to paste it into `segments` in play.p8.
* Press **O** to copy the player coordinates at the last frame to the clipboard, it will look like `{x=66,y=104,speed_x=2,speed_y=0,remainder_x=-0.4001,remainder_y=0,}`, so you can paste that into `conf_player` in edit.p8 and make the next segment from there.
* The numbers at the top of the screen are as follows: white are player.x/y, blue are player.speed_x/y, pink are player.remainder_x/y, yellow/red are the number of states stored (i.e. current frame) (left) and current RAM usage (right). **Keep this number below 2048**; otherwise, PICO-8 will crash because that's what our lord and savior @zep intended for us.

(you might notice there's no snow or clouds in this tool, I cut them to save some more tokens)

# play10.p8 / play11.p8

This tool plays back a list of segments obtained from edit.p8

To use it, save a copy of it in a separate file (that will be the TAS file), open the first tab and you'll see the following template:

```lua
--config

conf_level=0
conf_player=nil

segments={
[[16]], --start game
1,
[[2 2 2 2 2 18 18 2 2 2 2 2 2]],
2,
3,
4,
5,
6,
7,
8,
}

showoverlays=true

```

`conf_level` is the level index (0-8) to start playback from.

`segments` is a list that contains either of the following:

* A segment, which looks like `[[0 2 4 ...]]` - a string containing a list of button presses that can be obtained from edit.p8;
* A number (1-8), which is understood as a "level marker" - this tells when the level starts. When you set `conf_level`, play.p8 will use level markers to skip segments before the corresponding marker. Markers are also used for calculate total frame counts for levels when you press **L**.

Note that play.p8 will automatically insert empty frames during all intros - that's why you only need one button press for the titlescreen.

`showoverlays` enables/disables the same overlays as in edit.p8.

You can also use these controls during playback:

* **T** to pause/unpause, **Space** to advance a frame when paused - for debugging
* **O** will copy the player coordinates to the clipboard. This helps deal with any potential desyncs - play to the end, if there's desync from what you did in the editor - cut the end off, then play again and use this shortcut to make a new segment from there.
* **L** will show and copy to the clipboard the list of total frame counts for each level, so you can compare them with each other.

Note: there is also a cart named `play11_verifier.p8`; the difference is that `play11.p8` is based upon the token optimized smalleste2 to obtain enough tokens to insert the playback code, while `play11_verifier.p8` is based upon the original version of the game to make sure playback is 100% accurate, as smalleste2 could've accidentally changed the mechanics in some minor way; to get tokens, however, a lot of graphics are cut; this shouldn't impact gameplay at all.
