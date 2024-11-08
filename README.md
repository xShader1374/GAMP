# ImportCleaner

This Godot Engine plugin cleans up orphan files in the `res://.godot/imported` directory.

Sometimes various metadata files are left behind in the aforementioned  directory. This can easily happen when moving or renaming a file after importing it. Even after deleting an imported file, an MD5 metadata file may be left behind.

Most of these files are very, very small, so it's usually not a problem. However, it still feels good to remove them.

## Installation

1. Install `ImportCleaner` via AssetLib. Alternatively, download this project, copy the folder `ImportCleaner` and place it in your `res://addons/` folder.
2. Enable the plugin at `Project -> Project Settings -> Plugins`.

## Usage

Simply click on `Project -> Tools -> Clean Up Import Data`.

You can see in the Output which files were removed:

```
Removing MPLUSCodeLatin-Regular.ttf-67569e40c0899fd0c670ecf3a87b62b3.md5
Removing prototype_character.png-761d70f128cb8187a5d0152aa0b6ab00.ctex
Removing prototype_character.png-761d70f128cb8187a5d0152aa0b6ab00.md5
Removing Sono-Regular.ttf-e6b7445e1aee4289214bc01091445c96.md5
Removing splash_bg.png-69d104ec010f76e7ef3343071d2ac674.ctex
Removing splash_bg.png-69d104ec010f76e7ef3343071d2ac674.md5
Removing sprite001.png-3446b725d58ed275ac1a2eea8713dc96.md5
Removing sprite001.png-e3301b67fc6afd3d0519db64eca13790.ctex
Removing sprite001.png-e3301b67fc6afd3d0519db64eca13790.md5
Removed 9 files.
```
