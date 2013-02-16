# AssetManager

####A lightweight ActionScript 3.0 asset management solution


## Description

AssetManager is a simple, yet flexible, solution to asset management for AS3 projects.

It provides a clean, simple and well documented API to allow you to focus on building
your projects quickly without having to worry about how to load, store and retrieve assets.

AssetManager contains a simple plugin architecture for file formated to keep the footprint low.
A default import of AssetManager with no custom plugins activated weighs in at around 8.3kb.


## Features

* Clean and simple API
* Global and local loading queues
* Nestable queues
* Simple purging system for managing garbage collection and keeping memory usage in check
* Priority system for controlling loading priority of individual assets and nested queues
* Ability to store any valid ActionScript object, so all assets, internal or external, can be managed through AssetManager
* Support for XML formatted asset lists
* Plugin architecture for handling different data and file formats. Included format handlers are:
	* Binary
	* Images (PNG, GIF and JPEG)
	* Sound (MP3)
	* SWF
	* XML
	* GZIP (requires [Paul Robertson's Actionscript GZIP encoding library](http://probertson.com/projects/gzipencoder/ "Actionscript GZIP encoding library"))
	* Name/value pairs
	* Adobe Pixel Blender Shaders
* Easily extendable with plugin architecture to support any format
* Suitable for use in both small projects and large enterprise level projects

## Future Additions

* Support for loading and decompressing of ZIP archives

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
	
Remove a loading, or previously loaded asset:
	
	AssetManager.getInstance().purge("image.png");
	
Remove all loaded and currently loading assets:
	
	AssetManager.getInstance().purge();

See the [example](https://github.com/stevewoolcock/AssetManager/tree/master/examples "AssetManager examples") projects for more examples and advanced features.


## Documentation

[API documentation](http://docs.deadreckoned.com/assetmanager "AssetManager API documentation")

[Examples](https://github.com/stevewoolcock/AssetManager/tree/master/examples "AssetManager examples")


## Contribute

AssetManager is MIT-licensed. Please let me know of any issues and problems you encounter. Feel free
to submit suggestions or pull-requests with new features or fixes.

[Issue tracker](https://github.com/stevewoolcock/AssetManager/issues "AssetManager Issue Tracker")