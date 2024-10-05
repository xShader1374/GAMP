<div align="center">
	<br/><br/><img width="100"
	src="addons/tattomoosa.network-texture-rect/icons/NetworkTextureRect.svg"/><br/><h1> NetworkTextureRect <br/><sub><sub><sub>
	Dead simple network images,
	for <a href="https://godotengine.org/">
	Godot</a>
	</sub></sub></sub><br/><br/><br/></h1><br/><br/>
	<img src="./promo/loading_state_previews.png" height="180">
	<img src="./promo/editor_inspector.png" height="180">
	<!-- <img src="./readme_images/editor_view.png" height="140"> -->
	<br/>
	<br/>
</div>

Adds a new TextureRect Control node called NetworkTextureRect which dynamically loads
and displays images from a web address.

## Features

* Loads an image via http/https (utilizing the HTTPRequest node)
* Comes with default placeholder loading spinner, error placeholder
* Button to load image early in editor
* Images loaded in-editor can then be saved to the filesystem as CompressedImageTexture resources
* Size or add materials any way you want, it's a simple extension of TextureRect
* Remove the script from the node, even uninstall the plugin, and keep your loaded images

## Installation

Install via the AssetLib tab within Godot by searching for NetworkTextureRect

## Usage

Just fill out the url field and start the game! Or press the "Load Image" button in the
inspector.

### Custom Placeholders

Error and loading placeholders can be added as packed scenes, and will display instead
of the default placeholders if supplied.

## The Future

One thought is that via HTTPClient and
extending Texture2D with a resource it should be possible to create a
resource that handles all loading/caching internally and that could be applied to
any node that can take a Texture2D, then the existing NetworkTextureRect could be
simplified/modified to use that while still maintaining placeholder functionality.

This would allow any node that can take a texture to load that texture from the internet,
either as an editing convenience or during runtime.

Not sure how useful network textures are outside of the TextureRect use here, but could be cool.

## My Other Godot Plugins

* [VisionCone3D](https://github.com/Tattomoosa/VisionCone3D)
* [Spinner](https://github.com/Tattomoosa/Spinner)