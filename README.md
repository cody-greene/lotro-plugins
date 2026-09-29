This repository contains a few Lord of the Rings: Online (LOTRO) plugins & utilities. To use these plugins, copy or link the `src` directory into "My Documents/The Lord of the Rings Online/Plugins/" or run the `./build.sh` script to create standalone archives for distribution.


## The build script
```
Usage: ./build.sh <plugin_name> [<out_dir>]
Example: ./build.sh CombatHUD
```
Creates `build/CombatHUD/` which can be copied or linked into the game's plugin directory. And `build/CombatHUD.zip` which is an archive of the same.

## Notes
- `StretchMode.Stretch/StretchNoClick` and `Window.SetScale` seems to interfere with `BlendMode.Overlay` which we rely on for all the transparent image assets in the HUD. In other words, we can't dynamically scale the HUD. We have to load a different set of images for each group of display resolutions.
