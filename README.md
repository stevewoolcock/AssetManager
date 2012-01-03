# AssetManager

####A lightweight ActionScript 3.0 asset management solution


## Description

AssetManager is a simple, yet flexible, solution to asset management for AS3 projects.
It provides a clean, simple and well documented API to allow you to focus on building
your projects quickly without having to worry about how to load, store and retrieve assets.


## Features

* Clean and simple API
* Global and local loading queues
* Nestable queues
* Priority system for controlling loading priority of individual assets and nested queues
* Plugin architecture for handling different data and file formats. Included format handlers are:
	* Binary
	* Images (PNG, GIF and JPEG)
	* Sound (MP3)
	* SWF
	* Video (All Flash Platform supported video formats)
	* XML
	* Name/value pairs
	* Adobe Pixel Blender Shaders
* Support for XML formatted asset lists
* Easily extendable with custom plugins to support any format


## Quick API Examples

Load an external asset and listen for completion:
	
	var assetManager:AssetManager = AssetManager.getInstance();
	assetManager.addEventListener(AssetEvent.QUEUE_COMPLETE, onQueueComplete, false, 0, true);
	assetManager.add("assets/image1.jpg");
	assetManager.add("assets/sound.mp3");
	
Retrieving a loaded asset:
	
	var bmd:BitmapData = AssetManager.getInstance().get("assets/image1.jpg").asset;

Load an asset with a custom high priority:
	
	AssetManager.getInstance().add("myChildSWF.swf", { priority: 5 } );
	
Load a single asset and execute a callback upon completion:
	
	AssetManager.getInstance().add("image.png",	{
		onComplete: function():void
		{
			trace("Asset complete:", AssetManager.getInstance().get("image.png"));
		}
	});

See the [example](https://github.com/stevewoolcock/AssetManager/tree/master/examples "AssetManager examples") projects for more examples and advanced features.


## Documentation

[API documentation](http://docs.deadreckoned.com/assetmanager "AssetManager API documentation")

[Examples](https://github.com/stevewoolcock/AssetManager/tree/master/examples "AssetManager examples")


## Contribute

AssetManager is MIT-licensed. Please let me know of any issues and problems you encounter. Feel free
to submit suggestions or pull-requests with new features or fixes.

[Issue tracker](https://github.com/stevewoolcock/AssetManager/issues "AssetManager Issue Tracker")